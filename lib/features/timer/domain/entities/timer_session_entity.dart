import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_session_entity.freezed.dart';

@freezed
class TimerSessionEntity with _$TimerSessionEntity {
  const factory TimerSessionEntity({
    required String id,
    String? todoId,
    String? todoTitle,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
  }) = _TimerSessionEntity;
}
