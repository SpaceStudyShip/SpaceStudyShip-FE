// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoCategoryModelImpl _$$TodoCategoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$TodoCategoryModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$TodoCategoryModelImplToJson(
  _$TodoCategoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'emoji': instance.emoji,
  'created_at': instance.createdAt.toIso8601String(),
};
