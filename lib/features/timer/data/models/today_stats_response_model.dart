import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/today_stats.dart';

part 'today_stats_response_model.freezed.dart';
part 'today_stats_response_model.g.dart';

@freezed
class TodayStatsResponseModel with _$TodayStatsResponseModel {
  const TodayStatsResponseModel._();

  const factory TodayStatsResponseModel({
    required int totalMinutes,
    required int sessionCount,
    required int streak,
  }) = _TodayStatsResponseModel;

  factory TodayStatsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TodayStatsResponseModelFromJson(json);

  TodayStats toEntity() => TodayStats(
    totalMinutes: totalMinutes,
    sessionCount: sessionCount,
    streak: streak,
  );
}
