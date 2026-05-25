// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoCreateRequestModelImpl _$$TodoCreateRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$TodoCreateRequestModelImpl(
  id: json['id'] as String?,
  title: json['title'] as String,
  categoryIds: (json['categoryIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
  scheduledDates: (json['scheduledDates'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$TodoCreateRequestModelImplToJson(
  _$TodoCreateRequestModelImpl instance,
) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  'title': instance.title,
  if (instance.categoryIds case final value?) 'categoryIds': value,
  if (instance.estimatedMinutes case final value?) 'estimatedMinutes': value,
  if (instance.scheduledDates case final value?) 'scheduledDates': value,
};
