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
  iconId: json['icon_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$TodoCategoryModelImplToJson(
  _$TodoCategoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon_id': instance.iconId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
