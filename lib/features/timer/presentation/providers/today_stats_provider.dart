import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/today_stats.dart';
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

    final todayMinutes =
        todaySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final lifetimeMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final monthlyMinutes = sessions
        .where((s) => !s.startedAt.isBefore(monthStart))
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return TodayStats(
      totalMinutes: todayMinutes,
      sessionCount: todaySessions.length,
      streak: todaySessions.isEmpty ? 0 : 1,
      lifetimeMinutes: lifetimeMinutes,
      lifetimeSessionCount: sessions.length,
      monthlyMinutes: monthlyMinutes,
    );
  }
}
