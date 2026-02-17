// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/timer_session_entity.dart';

part 'timer_session_model.freezed.dart';
part 'timer_session_model.g.dart';

@freezed
class TimerSessionModel with _$TimerSessionModel {
  const factory TimerSessionModel({
    required String id,
    @JsonKey(name: 'todo_id') String? todoId,
    @JsonKey(name: 'todo_title') String? todoTitle,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'ended_at') required DateTime endedAt,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
  }) = _TimerSessionModel;

  factory TimerSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TimerSessionModelFromJson(json);
}

extension TimerSessionModelX on TimerSessionModel {
  TimerSessionEntity toEntity() => TimerSessionEntity(
        id: id,
        todoId: todoId,
        todoTitle: todoTitle,
        startedAt: startedAt,
        endedAt: endedAt,
        durationMinutes: durationMinutes,
      );
}

extension TimerSessionEntityX on TimerSessionEntity {
  TimerSessionModel toModel() => TimerSessionModel(
        id: id,
        todoId: todoId,
        todoTitle: todoTitle,
        startedAt: startedAt,
        endedAt: endedAt,
        durationMinutes: durationMinutes,
      );
}
