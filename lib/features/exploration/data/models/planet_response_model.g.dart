// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planet_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanetResponseModelImpl _$$PlanetResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$PlanetResponseModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  nodeType: json['nodeType'] as String,
  depth: (json['depth'] as num).toInt(),
  icon: json['icon'] as String,
  parentId: json['parentId'] as String?,
  prerequisiteId: json['prerequisiteId'] as String?,
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
  progress: json['progress'] == null
      ? null
      : ProgressResponseModel.fromJson(
          json['progress'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$PlanetResponseModelImplToJson(
  _$PlanetResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nodeType': instance.nodeType,
  'depth': instance.depth,
  'icon': instance.icon,
  'parentId': instance.parentId,
  'prerequisiteId': instance.prerequisiteId,
  'requiredFuel': instance.requiredFuel,
  'isUnlocked': instance.isUnlocked,
  'isCleared': instance.isCleared,
  'sortOrder': instance.sortOrder,
  'description': instance.description,
  'mapX': instance.mapX,
  'mapY': instance.mapY,
  'unlockedAt': instance.unlockedAt?.toIso8601String(),
  'progress': instance.progress,
};

_$ProgressResponseModelImpl _$$ProgressResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProgressResponseModelImpl(
  clearedChildren: (json['clearedChildren'] as num).toInt(),
  totalChildren: (json['totalChildren'] as num).toInt(),
  progressRatio: (json['progressRatio'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$ProgressResponseModelImplToJson(
  _$ProgressResponseModelImpl instance,
) => <String, dynamic>{
  'clearedChildren': instance.clearedChildren,
  'totalChildren': instance.totalChildren,
  'progressRatio': instance.progressRatio,
};
