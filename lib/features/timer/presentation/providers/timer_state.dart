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
    /// 인증 모드에서 stop() 시 POST 헤더로 전송할 idempotency key.
    /// start() 시 발급, stop() 성공 시 null 로 폐기, 실패 시 유지 (재시도용).
    String? idempotencyKey,
  }) = _TimerState;

  /// 실시간 경과 시간 계산
  Duration get elapsed {
    if (status == TimerStatus.running && startTime != null) {
      return accumulatedBeforePause + DateTime.now().difference(startTime!);
    }
    return accumulatedBeforePause;
  }
}
