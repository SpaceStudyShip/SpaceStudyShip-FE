import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../todo/presentation/providers/todo_provider.dart';
import 'timer_state.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;

  @override
  TimerState build() => const TimerState();

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
  Future<void> stop() async {
    _timer?.cancel();

    final todoId = state.linkedTodoId;
    final elapsedMinutes = state.elapsed.inMinutes;

    // 연동된 할일이 있고 1분 이상 측정 시 actualMinutes 누적
    if (todoId != null && elapsedMinutes > 0) {
      await _updateTodoActualMinutes(todoId, elapsedMinutes);
    }

    state = const TimerState();
  }

  /// UI 갱신용 periodic timer (시간 계산에는 사용하지 않음)
  void _startPeriodicUiUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // state를 다시 설정하여 UI 리빌드 트리거
      // elapsed getter가 DateTime.now() 기반으로 정확한 값 반환
      state = state.copyWith();
    });
  }

  Future<void> _updateTodoActualMinutes(
    String todoId,
    int additionalMinutes,
  ) async {
    final todoNotifier = ref.read(todoListNotifierProvider.notifier);
    final todos = ref.read(todoListNotifierProvider).valueOrNull ?? [];
    final todo = todos.where((t) => t.id == todoId).firstOrNull;

    if (todo != null) {
      final currentMinutes = todo.actualMinutes ?? 0;
      await todoNotifier.updateTodo(
        todo.copyWith(actualMinutes: currentMinutes + additionalMinutes),
      );
    }
  }
}
