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
          (json['scheduled_dates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
      completedDates:
          (json['completed_dates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
      categoryIds:
          (json['category_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt(),
      actualMinutes: (json['actual_minutes'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TodoModelImplToJson(_$TodoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'scheduled_dates': instance.scheduledDates
          .map((e) => e.toIso8601String())
          .toList(),
      'completed_dates': instance.completedDates
          .map((e) => e.toIso8601String())
          .toList(),
      'category_ids': instance.categoryIds,
      'estimated_minutes': instance.estimatedMinutes,
      'actual_minutes': instance.actualMinutes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
