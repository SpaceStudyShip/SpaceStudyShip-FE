import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'today_stats_provider.dart';

part 'study_stats_provider.g.dart';

// === 일별 통계 ===

/// 오늘 공부 시간 (분) — todayStats 위임
@riverpod
int todayStudyMinutes(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.totalMinutes ?? 0;
}

// === 월별/전체 통계 ===

/// 이번 달 공부 시간 (분) — todayStats 위임
@riverpod
int monthlyStudyMinutes(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.monthlyMinutes ?? 0;
}

/// 전체 총 공부 시간 (분) — todayStats 위임
@riverpod
int totalStudyMinutes(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeMinutes ?? 0;
}

/// 전체 세션 수 — todayStats 위임
@riverpod
int totalSessionCount(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeSessionCount ?? 0;
}

// === Streak ===

/// 연속 공부 일수 (streak) — todayStats 위임
@riverpod
int currentStreak(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.streak ?? 0;
}
