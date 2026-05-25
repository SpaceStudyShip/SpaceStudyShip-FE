// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimerSessionResponseModelImpl _$$TimerSessionResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$TimerSessionResponseModelImpl(
  id: json['id'] as String,
  todoId: json['todoId'] as String?,
  todoTitle: json['todoTitle'] as String?,
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt: DateTime.parse(json['endedAt'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
);

Map<String, dynamic> _$$TimerSessionResponseModelImplToJson(
  _$TimerSessionResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'todoId': instance.todoId,
  'todoTitle': instance.todoTitle,
  'startedAt': instance.startedAt.toIso8601String(),
  'endedAt': instance.endedAt.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
};
