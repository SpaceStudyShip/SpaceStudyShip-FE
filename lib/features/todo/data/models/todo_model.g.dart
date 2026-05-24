// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoModelImpl _$$TodoModelImplFromJson(Map<String, dynamic> json) =>
    _$TodoModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      scheduledDates:
          (json['scheduledDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
      completedDates:
          (json['completedDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
      categoryIds:
          (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
      actualMinutes: (json['actualMinutes'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TodoModelImplToJson(_$TodoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'scheduledDates': instance.scheduledDates
          .map((e) => e.toIso8601String())
          .toList(),
      'completedDates': instance.completedDates
          .map((e) => e.toIso8601String())
          .toList(),
      'categoryIds': instance.categoryIds,
      'estimatedMinutes': instance.estimatedMinutes,
      'actualMinutes': instance.actualMinutes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
