import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_stats.freezed.dart';

/// KST 기준 오늘 공부 통계 + 누적 통계 (GET /api/timer-sessions/today-stats).
@freezed
class TodayStats with _$TodayStats {
  const factory TodayStats({
    required int totalMinutes,
    required int sessionCount,
    required int streak,
    required int lifetimeMinutes,
    required int lifetimeSessionCount,
    required int monthlyMinutes,
  }) = _TodayStats;

  factory TodayStats.empty() => const TodayStats(
    totalMinutes: 0,
    sessionCount: 0,
    streak: 0,
    lifetimeMinutes: 0,
    lifetimeSessionCount: 0,
    monthlyMinutes: 0,
  );
}
