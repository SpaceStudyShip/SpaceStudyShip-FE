// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegionResponseModelImpl _$$RegionResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$RegionResponseModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  nodeType: json['nodeType'] as String,
  depth: (json['depth'] as num).toInt(),
  icon: json['icon'] as String,
  parentId: json['parentId'] as String?,
  requiredFuel: (json['requiredFuel'] as num).toInt(),
  isUnlocked: json['isUnlocked'] as bool,
  isCleared: json['isCleared'] as bool,
  sortOrder: (json['sortOrder'] as num).toInt(),
  description: json['description'] as String? ?? '',
  mapX: (json['mapX'] as num?)?.toDouble() ?? 0.5,
  mapY: (json['mapY'] as num?)?.toDouble() ?? 0.0,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
);

Map<String, dynamic> _$$RegionResponseModelImplToJson(
  _$RegionResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nodeType': instance.nodeType,
  'depth': instance.depth,
  'icon': instance.icon,
  'parentId': instance.parentId,
  'requiredFuel': instance.requiredFuel,
  'isUnlocked': instance.isUnlocked,
  'isCleared': instance.isCleared,
  'sortOrder': instance.sortOrder,
  'description': instance.description,
  'mapX': instance.mapX,
  'mapY': instance.mapY,
  'unlockedAt': instance.unlockedAt?.toIso8601String(),
};
