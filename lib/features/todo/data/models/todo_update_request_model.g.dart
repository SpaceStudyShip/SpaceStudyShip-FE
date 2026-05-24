// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_update_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoUpdateRequestModelImpl _$$TodoUpdateRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$TodoUpdateRequestModelImpl(
  title: json['title'] as String?,
  scheduledDates: (json['scheduledDates'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  completedDates: (json['completedDates'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  categoryIds: (json['categoryIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
  actualMinutes: (json['actualMinutes'] as num?)?.toInt(),
);

Map<String, dynamic> _$$TodoUpdateRequestModelImplToJson(
  _$TodoUpdateRequestModelImpl instance,
) => <String, dynamic>{
  if (instance.title case final value?) 'title': value,
  if (instance.scheduledDates case final value?) 'scheduledDates': value,
  if (instance.completedDates case final value?) 'completedDates': value,
  if (instance.categoryIds case final value?) 'categoryIds': value,
  if (instance.estimatedMinutes case final value?) 'estimatedMinutes': value,
  if (instance.actualMinutes case final value?) 'actualMinutes': value,
};
