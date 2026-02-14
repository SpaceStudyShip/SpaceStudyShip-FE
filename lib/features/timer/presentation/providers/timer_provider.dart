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
      linkedTodoId: todoId,
      linkedTodoTitle: todoTitle,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  /// 타이머 일시정지
  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// 타이머 재개
  void resume() {
    if (state.status != TimerStatus.paused) return;

    state = state.copyWith(status: TimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
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
