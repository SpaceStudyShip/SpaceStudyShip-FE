import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/timer_session_entity.dart';
import '../../../todo/presentation/providers/todo_provider.dart';
import 'timer_session_provider.dart';
import 'timer_state.dart';

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
    );

    _startPeriodicUiUpdate();
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

  /// 타이머 정지 + 할일 시간 업데이트
  /// 반환: ({Duration sessionDuration, String? todoTitle, int? totalMinutes})
  Future<({Duration sessionDuration, String? todoTitle, int? totalMinutes})?>
  stop() async {
    _timer?.cancel();

    final todoId = state.linkedTodoId;
    final todoTitle = state.linkedTodoTitle;
    final sessionDuration = state.elapsed;
    final elapsedMinutes = sessionDuration.inMinutes;
    final endedAt = DateTime.now();

    int? totalMinutes;

    try {
      // 연동된 할일이 있고 1분 이상 측정 시 actualMinutes 누적
      if (todoId != null && elapsedMinutes > 0) {
        totalMinutes = await _updateTodoActualMinutes(todoId, elapsedMinutes);
      }

      // 1분 이상 세션이면 기록 저장
      if (sessionDuration.inMinutes >= 1) {
        final session = TimerSessionEntity(
          id: endedAt.millisecondsSinceEpoch.toString(),
          todoId: todoId,
          todoTitle: todoTitle,
          startedAt: endedAt.subtract(sessionDuration),
          endedAt: endedAt,
          durationMinutes: elapsedMinutes,
        );
        await ref
            .read(timerSessionListNotifierProvider.notifier)
            .addSession(session);
      }
    } finally {
      state = const TimerState();
    }

    // 1분 미만 세션은 null 반환 (다이얼로그 생략)
    return sessionDuration.inMinutes >= 1
        ? (
            sessionDuration: sessionDuration,
            todoTitle: todoTitle,
            totalMinutes: totalMinutes,
          )
        : null;
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
