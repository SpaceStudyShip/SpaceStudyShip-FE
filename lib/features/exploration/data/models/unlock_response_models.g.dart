// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_response_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnlockedNodeModelImpl _$$UnlockedNodeModelImplFromJson(
  Map<String, dynamic> json,
) => _$UnlockedNodeModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  isUnlocked: json['isUnlocked'] as bool,
  isCleared: json['isCleared'] as bool,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
);

Map<String, dynamic> _$$UnlockedNodeModelImplToJson(
  _$UnlockedNodeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isUnlocked': instance.isUnlocked,
  'isCleared': instance.isCleared,
  'unlockedAt': instance.unlockedAt?.toIso8601String(),
};

_$RegionUnlockResponseModelImpl _$$RegionUnlockResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$RegionUnlockResponseModelImpl(
  region: json['region'] == null
      ? null
      : UnlockedNodeModel.fromJson(json['region'] as Map<String, dynamic>),
  fuelConsumed: (json['fuelConsumed'] as num).toInt(),
  currentFuel: (json['currentFuel'] as num).toInt(),
  planetCleared: json['planetCleared'] as bool,
);

Map<String, dynamic> _$$RegionUnlockResponseModelImplToJson(
  _$RegionUnlockResponseModelImpl instance,
) => <String, dynamic>{
  'region': instance.region,
  'fuelConsumed': instance.fuelConsumed,
  'currentFuel': instance.currentFuel,
  'planetCleared': instance.planetCleared,
};

_$PlanetUnlockResponseModelImpl _$$PlanetUnlockResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$PlanetUnlockResponseModelImpl(
  planet: json['planet'] == null
      ? null
      : UnlockedNodeModel.fromJson(json['planet'] as Map<String, dynamic>),
  fuelConsumed: (json['fuelConsumed'] as num).toInt(),
  currentFuel: (json['currentFuel'] as num).toInt(),
);

Map<String, dynamic> _$$PlanetUnlockResponseModelImplToJson(
  _$PlanetUnlockResponseModelImpl instance,
) => <String, dynamic>{
  'planet': instance.planet,
  'fuelConsumed': instance.fuelConsumed,
  'currentFuel': instance.currentFuel,
};
