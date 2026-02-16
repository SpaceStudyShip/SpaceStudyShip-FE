// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoModelImpl _$$TodoModelImplFromJson(Map<String, dynamic> json) =>
    _$TodoModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      categoryId: json['category_id'] as String?,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt(),
      actualMinutes: (json['actual_minutes'] as num?)?.toInt(),
      scheduledDate: json['scheduled_date'] == null
          ? null
          : DateTime.parse(json['scheduled_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TodoModelImplToJson(_$TodoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'completed': instance.completed,
      'category_id': instance.categoryId,
      'estimated_minutes': instance.estimatedMinutes,
      'actual_minutes': instance.actualMinutes,
      'scheduled_date': instance.scheduledDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
