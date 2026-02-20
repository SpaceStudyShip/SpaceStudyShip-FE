// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FuelModelImpl _$$FuelModelImplFromJson(Map<String, dynamic> json) =>
    _$FuelModelImpl(
      currentFuel: (json['current_fuel'] as num?)?.toInt() ?? 0,
      totalCharged: (json['total_charged'] as num?)?.toInt() ?? 0,
      totalConsumed: (json['total_consumed'] as num?)?.toInt() ?? 0,
      pendingMinutes: (json['pending_minutes'] as num?)?.toInt() ?? 0,
      lastUpdatedAt: DateTime.parse(json['last_updated_at'] as String),
    );

Map<String, dynamic> _$$FuelModelImplToJson(_$FuelModelImpl instance) =>
    <String, dynamic>{
      'current_fuel': instance.currentFuel,
      'total_charged': instance.totalCharged,
      'total_consumed': instance.totalConsumed,
      'pending_minutes': instance.pendingMinutes,
      'last_updated_at': instance.lastUpdatedAt.toIso8601String(),
    };
