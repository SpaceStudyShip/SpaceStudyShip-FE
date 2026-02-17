// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimerSessionModelImpl _$$TimerSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TimerSessionModelImpl(
  id: json['id'] as String,
  todoId: json['todo_id'] as String?,
  todoTitle: json['todo_title'] as String?,
  startedAt: DateTime.parse(json['started_at'] as String),
  endedAt: DateTime.parse(json['ended_at'] as String),
  durationMinutes: (json['duration_minutes'] as num).toInt(),
);

Map<String, dynamic> _$$TimerSessionModelImplToJson(
  _$TimerSessionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'todo_id': instance.todoId,
  'todo_title': instance.todoTitle,
  'started_at': instance.startedAt.toIso8601String(),
  'ended_at': instance.endedAt.toIso8601String(),
  'duration_minutes': instance.durationMinutes,
};
