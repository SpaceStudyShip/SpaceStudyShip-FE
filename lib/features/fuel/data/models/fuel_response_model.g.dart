// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FuelResponseModelImpl _$$FuelResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$FuelResponseModelImpl(
  currentFuel: (json['currentFuel'] as num).toInt(),
  totalCharged: (json['totalCharged'] as num).toInt(),
  totalConsumed: (json['totalConsumed'] as num).toInt(),
  pendingMinutes: (json['pendingMinutes'] as num).toInt(),
  lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
);

Map<String, dynamic> _$$FuelResponseModelImplToJson(
  _$FuelResponseModelImpl instance,
) => <String, dynamic>{
  'currentFuel': instance.currentFuel,
  'totalCharged': instance.totalCharged,
  'totalConsumed': instance.totalConsumed,
  'pendingMinutes': instance.pendingMinutes,
  'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
};
