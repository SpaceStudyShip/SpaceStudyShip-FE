// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryCreateRequestModelImpl _$$CategoryCreateRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$CategoryCreateRequestModelImpl(
  id: json['id'] as String?,
  name: json['name'] as String,
  iconId: json['iconId'] as String?,
  positionX: (json['positionX'] as num?)?.toDouble(),
  positionY: (json['positionY'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$CategoryCreateRequestModelImplToJson(
  _$CategoryCreateRequestModelImpl instance,
) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  'name': instance.name,
  if (instance.iconId case final value?) 'iconId': value,
  if (instance.positionX case final value?) 'positionX': value,
  if (instance.positionY case final value?) 'positionY': value,
};
