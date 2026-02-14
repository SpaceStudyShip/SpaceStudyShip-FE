import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

enum TimerStatus { idle, running, paused }

@freezed
class TimerState with _$TimerState {
  const TimerState._();

  const factory TimerState({
    @Default(TimerStatus.idle) TimerStatus status,
    @Default(Duration.zero) Duration accumulatedBeforePause,
    DateTime? startTime,
    String? linkedTodoId,
    String? linkedTodoTitle,
  }) = _TimerState;

  /// 실시간 경과 시간 계산
  Duration get elapsed {
    if (status == TimerStatus.running && startTime != null) {
      return accumulatedBeforePause + DateTime.now().difference(startTime!);
    }
    return accumulatedBeforePause;
  }
}
