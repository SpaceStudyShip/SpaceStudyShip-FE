// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_stats_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodayStatsResponseModelImpl _$$TodayStatsResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$TodayStatsResponseModelImpl(
  totalMinutes: (json['totalMinutes'] as num).toInt(),
  sessionCount: (json['sessionCount'] as num).toInt(),
  streak: (json['streak'] as num).toInt(),
  lifetimeMinutes: (json['lifetimeMinutes'] as num).toInt(),
  lifetimeSessionCount: (json['lifetimeSessionCount'] as num).toInt(),
  monthlyMinutes: (json['monthlyMinutes'] as num).toInt(),
);

Map<String, dynamic> _$$TodayStatsResponseModelImplToJson(
  _$TodayStatsResponseModelImpl instance,
) => <String, dynamic>{
  'totalMinutes': instance.totalMinutes,
  'sessionCount': instance.sessionCount,
  'streak': instance.streak,
  'lifetimeMinutes': instance.lifetimeMinutes,
  'lifetimeSessionCount': instance.lifetimeSessionCount,
  'monthlyMinutes': instance.monthlyMinutes,
};
