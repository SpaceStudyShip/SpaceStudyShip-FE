import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'timer_session_provider.dart';

part 'study_stats_provider.g.dart';

// === 공통 유틸 ===

DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

// === 일별/주별 통계 ===

/// 오늘 공부 시간 (분)
@riverpod
int todayStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final today = _normalizeDate(DateTime.now());

  return sessions
      .where((s) => _normalizeDate(s.startedAt) == today)
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 이번 주 공부 시간 (분) — 최근 7일
@riverpod
int weeklyStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final now = DateTime.now();
  final weekStart = _normalizeDate(now.subtract(const Duration(days: 6)));

  return sessions
      .where((s) => !_normalizeDate(s.startedAt).isBefore(weekStart))
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

// === 월별/전체 통계 ===

/// 이번 달 공부 시간 (분)
@riverpod
int monthlyStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  return sessions
      .where((s) => !s.startedAt.isBefore(monthStart))
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 전체 총 공부 시간 (분)
@riverpod
int totalStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 전체 세션 수
@riverpod
int totalSessionCount(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  return sessions.length;
}

// === Streak ===

/// 연속 공부 일수 (streak)
@riverpod
int currentStreak(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  if (sessions.isEmpty) return 0;

  // 세션이 있는 날짜 집합
  final studyDates =
      sessions.map((s) => _normalizeDate(s.startedAt)).toSet().toList()
        ..sort((a, b) => b.compareTo(a)); // 최신순

  final today = _normalizeDate(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));

  // 오늘 또는 어제 공부하지 않았으면 streak 0
  if (studyDates.first != today && studyDates.first != yesterday) return 0;

  int streak = 1;
  for (int i = 1; i < studyDates.length; i++) {
    final diff = studyDates[i - 1].difference(studyDates[i]).inDays;
    if (diff == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
