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
  iconId: json['iconId'] as String?,
  positionX: (json['positionX'] as num?)?.toDouble(),
  positionY: (json['positionY'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$TodoCategoryModelImplToJson(
  _$TodoCategoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'iconId': instance.iconId,
  'positionX': instance.positionX,
  'positionY': instance.positionY,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
