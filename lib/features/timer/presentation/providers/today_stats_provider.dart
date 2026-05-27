import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../../domain/entities/today_stats.dart';
import '../utils/timer_format_utils.dart';
import 'timer_session_provider.dart';

part 'today_stats_provider.g.dart';

/// 오늘 공부 통계 provider.
/// 인증 모드: 서버 GET /api/timer-sessions/today-stats 결과 신뢰.
/// 게스트 모드: 로컬 세션 리스트로 클라이언트 계산.
@riverpod
class TodayStatsNotifier extends _$TodayStatsNotifier {
  @override
  Future<TodayStats> build() async {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final repository = ref.watch(timerSessionRepositoryProvider);

    if (isAuthenticated) {
      return repository.getTodayStats();
    }

    // 게스트 모드: 로컬 세션 fold (전체가 메모리에 있어 정확)
    final sessions = repository.getSessions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final todaySessions = sessions.where((s) {
      return s.startedAt.isAfter(today.subtract(const Duration(seconds: 1))) &&
          s.startedAt.isBefore(tomorrow);
    }).toList();

    final todayMinutes = todaySessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );
    final lifetimeMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );
    final monthlyMinutes = sessions
        .where((s) => !s.startedAt.isBefore(monthStart))
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return TodayStats(
      totalMinutes: todayMinutes,
      sessionCount: todaySessions.length,
      streak: _calculateStreak(sessions),
      lifetimeMinutes: lifetimeMinutes,
      lifetimeSessionCount: sessions.length,
      monthlyMinutes: monthlyMinutes,
    );
  }

  /// 연속 공부 일수 계산 (오늘 또는 어제 공부했어야 streak 유지).
  int _calculateStreak(List<TimerSessionEntity> sessions) {
    if (sessions.isEmpty) return 0;

    final studyDates =
        sessions.map((s) => normalizeDate(s.startedAt)).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    final today = normalizeDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

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
}
