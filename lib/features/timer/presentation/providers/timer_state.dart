import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

enum TimerStatus { idle, running, paused }

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    @Default(TimerStatus.idle) TimerStatus status,
    @Default(Duration.zero) Duration elapsed,
    String? linkedTodoId,
    String? linkedTodoTitle,
  }) = _TimerState;
}
