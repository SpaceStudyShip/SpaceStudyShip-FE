// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_update_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryUpdateRequestModelImpl _$$CategoryUpdateRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$CategoryUpdateRequestModelImpl(
  name: json['name'] as String?,
  iconId: json['iconId'] as String?,
  positionX: (json['positionX'] as num?)?.toDouble(),
  positionY: (json['positionY'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$CategoryUpdateRequestModelImplToJson(
  _$CategoryUpdateRequestModelImpl instance,
) => <String, dynamic>{
  if (instance.name case final value?) 'name': value,
  if (instance.iconId case final value?) 'iconId': value,
  if (instance.positionX case final value?) 'positionX': value,
  if (instance.positionY case final value?) 'positionY': value,
};
