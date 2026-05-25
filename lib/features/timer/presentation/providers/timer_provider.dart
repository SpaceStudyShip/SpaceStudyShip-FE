import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/timer_session_entity.dart';
import '../../domain/exceptions/timer_session_exceptions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../badge/domain/entities/badge_entity.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../../todo/presentation/providers/todo_provider.dart';
import 'timer_session_provider.dart';
import 'timer_state.dart';
import 'today_stats_provider.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerNotifier extends _$TimerNotifier with WidgetsBindingObserver {
  Timer? _timer;

  @override
  TimerState build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() {
      _timer?.cancel();
      binding.removeObserver(this);
    });
    return const TimerState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 앱 백그라운드 진입 시 UI 갱신 타이머만 중지 (경과시간 계산에는 영향 없음)
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // 앱 복귀 시 타이머가 running 상태면 UI 갱신 재개
      if (this.state.status == TimerStatus.running) {
        _startPeriodicUiUpdate();
      }
    }
  }

  /// 타이머 시작 (할일 연동 선택)
  void start({String? todoId, String? todoTitle}) {
    _timer?.cancel();

    state = state.copyWith(
      status: TimerStatus.running,
      startTime: DateTime.now(),
      accumulatedBeforePause: Duration.zero,
      linkedTodoId: todoId,
      linkedTodoTitle: todoTitle,
      idempotencyKey: const Uuid().v4(),
    );

    _startPeriodicUiUpdate();
  }

  /// 테스트 전용: 세션 상태를 직접 주입합니다.
  ///
  /// 실 타이머 없이 1분 이상 경과 상태를 시뮬레이션하기 위해 사용합니다.
  @visibleForTesting
  void setSessionForTest({
    required TimerStatus status,
    required DateTime startTime,
    required Duration accumulatedBeforePause,
    String? linkedTodoId,
    String? linkedTodoTitle,
    String? idempotencyKey,
  }) {
    state = state.copyWith(
      status: status,
      startTime: startTime,
      accumulatedBeforePause: accumulatedBeforePause,
      linkedTodoId: linkedTodoId,
      linkedTodoTitle: linkedTodoTitle,
      idempotencyKey: idempotencyKey,
    );
  }

  /// 타이머 일시정지
  void pause() {
    _timer?.cancel();

    // 현재까지 경과 시간을 accumulated에 저장
    state = state.copyWith(
      status: TimerStatus.paused,
      accumulatedBeforePause: state.elapsed,
      startTime: null,
    );
  }

  /// 타이머 재개
  void resume() {
    if (state.status != TimerStatus.paused) return;

    state = state.copyWith(
      status: TimerStatus.running,
      startTime: DateTime.now(),
    );

    _startPeriodicUiUpdate();
  }

  /// 타이머 정지 + 세션 저장 + 배지 해금 체크
  ///
  /// 인증 모드: 서버 POST /api/timer-sessions 에 위임 (fuel/todo/streak 서버 갱신).
  /// 게스트 모드: 기존 로컬 로직 (actualMinutes 업데이트 + 로컬 세션 저장 + 연료 충전).
  /// 반환: sessionDuration, todoTitle, totalMinutes, newBadges 레코드 (1분 미만 세션은 null)
  Future<
    ({
      Duration sessionDuration,
      String? todoTitle,
      int? totalMinutes,
      List<BadgeEntity> newBadges,
    })?
  >
  stop() async {
    _timer?.cancel();

    final sessionDuration = state.elapsed;
    final elapsedMinutes  = sessionDuration.inMinutes;
    final endedAt         = DateTime.now();
    final startedAt       = endedAt.subtract(sessionDuration);
    final todoId          = state.linkedTodoId;
    final todoTitle       = state.linkedTodoTitle;
    final idempotencyKey  = state.idempotencyKey;

    // 1분 미만 세션은 저장하지 않음 (서버 SESSION_TOO_SHORT 사전 차단 + 게스트 기존 로직과 동일).
    if (elapsedMinutes < 1) {
      state = const TimerState();
      return null;
    }

    final isAuthenticated = ref.read(isAuthenticatedProvider);

    int? totalMinutes;
    List<BadgeEntity> newBadges = [];

    try {
      if (isAuthenticated) {
        // === 서버 권위 모드 ===
        assert(idempotencyKey != null, 'start() 시 발급된 idempotencyKey 가 있어야 함');
        final repository = ref.read(timerSessionRepositoryProvider);
        try {
          await repository.createSession(
            startedAt: startedAt,
            endedAt:   endedAt,
            durationMinutes: elapsedMinutes,
            todoId:    todoId,
            todoTitle: todoTitle,
            idempotencyKey: idempotencyKey!,
          );
        } on LinkedTodoNotFound {
          // 404 → todoId 빼고 1회 재시도 (세션은 저장하되 Todo 미연결).
          await repository.createSession(
            startedAt: startedAt,
            endedAt:   endedAt,
            durationMinutes: elapsedMinutes,
            todoId:    null,
            todoTitle: todoTitle,
            idempotencyKey: idempotencyKey!,
          );
        }
        // 서버가 이미 fuel/actualMinutes 갱신. 재조회 트리거.
        ref.invalidate(fuelNotifierProvider);
        ref.invalidate(todoListNotifierProvider);
        ref.invalidate(timerSessionListNotifierProvider);
        ref.invalidate(todayStatsNotifierProvider);

        // 배지 해금은 서버 미제공 → 클라이언트 유지.
        try {
          newBadges = await ref
              .read(badgeNotifierProvider.notifier)
              .checkAndUnlock(sessionStartTime: startedAt);
        } catch (e) {
          debugPrint('배지 해금 체크 실패: $e');
        }
      } else {
        // === 게스트 모드 (기존 로직 그대로) ===
        if (todoId != null && elapsedMinutes > 0) {
          totalMinutes = await _updateTodoActualMinutes(todoId, elapsedMinutes);
        }
        final session = TimerSessionEntity(
          id: endedAt.millisecondsSinceEpoch.toString(),
          todoId: todoId,
          todoTitle: todoTitle,
          startedAt: startedAt,
          endedAt: endedAt,
          durationMinutes: elapsedMinutes,
        );
        await ref
            .read(timerSessionListNotifierProvider.notifier)
            .addSession(session);

        // 연료 충전 (30분 = 1통)
        await ref
            .read(fuelNotifierProvider.notifier)
            .chargeFuel(studyMinutes: elapsedMinutes, sessionId: session.id);

        // 배지 해금 체크 — 실패해도 세션 저장에 영향 없음
        try {
          newBadges = await ref
              .read(badgeNotifierProvider.notifier)
              .checkAndUnlock(sessionStartTime: session.startedAt);
        } catch (e) {
          debugPrint('배지 해금 체크 실패: $e');
        }
      }
    } finally {
      state = const TimerState(); // idempotencyKey 폐기 포함.
    }

    return (
      sessionDuration: sessionDuration,
      todoTitle: todoTitle,
      totalMinutes: totalMinutes,
      newBadges: newBadges,
    );
  }

  /// 강제 리셋 (세션 저장 없이 초기 상태로 복원)
  ///
  /// 로그아웃 시 호출. 진행 중인 타이머를 즉시 중단합니다.
  void forceReset() {
    _timer?.cancel();
    state = const TimerState();
  }

  /// UI 갱신용 periodic timer (시간 계산에는 사용하지 않음)
  void _startPeriodicUiUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // elapsed getter가 DateTime.now() 기반으로 정확한 값 반환
      // Freezed copyWith()는 동일 객체를 반환하므로 notifyListeners로 강제 리빌드
      ref.notifyListeners();
    });
  }

  Future<int?> _updateTodoActualMinutes(
    String todoId,
    int additionalMinutes,
  ) async {
    final todoNotifier = ref.read(todoListNotifierProvider.notifier);
    final todos = ref.read(todoListNotifierProvider).valueOrNull ?? [];
    final todo = todos.where((t) => t.id == todoId).firstOrNull;

    if (todo != null) {
      final currentMinutes = todo.actualMinutes ?? 0;
      final newTotal = currentMinutes + additionalMinutes;
      await todoNotifier.updateTodo(todo.copyWith(actualMinutes: newTotal));
      return newTotal;
    }
    return null;
  }
}
