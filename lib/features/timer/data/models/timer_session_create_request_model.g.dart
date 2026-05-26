// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimerSessionCreateRequestModelImpl
_$$TimerSessionCreateRequestModelImplFromJson(Map<String, dynamic> json) =>
    _$TimerSessionCreateRequestModelImpl(
      todoId: json['todoId'] as String?,
      todoTitle: json['todoTitle'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$$TimerSessionCreateRequestModelImplToJson(
  _$TimerSessionCreateRequestModelImpl instance,
) => <String, dynamic>{
  if (instance.todoId case final value?) 'todoId': value,
  if (instance.todoTitle case final value?) 'todoTitle': value,
  'startedAt': _toUtcIso(instance.startedAt),
  'endedAt': _toUtcIso(instance.endedAt),
  'durationMinutes': instance.durationMinutes,
};
