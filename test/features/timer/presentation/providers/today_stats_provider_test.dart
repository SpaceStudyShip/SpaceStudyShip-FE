import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_entity.dart';
import 'package:space_study_ship/features/timer/domain/entities/today_stats.dart';
import 'package:space_study_ship/features/timer/domain/repositories/timer_session_repository.dart';
import 'package:space_study_ship/features/timer/presentation/providers/timer_session_provider.dart';
import 'package:space_study_ship/features/timer/presentation/providers/today_stats_provider.dart';

class _MockRepo extends Mock implements TimerSessionRepository {}

void main() {
  late ProviderContainer container;
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  tearDown(() => container.dispose());

  test('인증 모드: repo.getTodayStats() 결과 그대로 반환', () async {
    when(() => repo.getTodayStats()).thenAnswer(
      (_) async =>
          const TodayStats(totalMinutes: 180, sessionCount: 3, streak: 7),
    );
    container = ProviderContainer(
      overrides: [
        isAuthenticatedProvider.overrideWith((ref) => true),
        timerSessionRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    final stats = await container.read(todayStatsNotifierProvider.future);
    expect(stats.totalMinutes, 180);
    expect(stats.streak, 7);
  });

  test('게스트 모드: 로컬 세션으로 직접 계산 (오늘 KST 기준)', () async {
    // 오늘 정오(12:00)를 기준점으로 사용 — 자정 경계 문제 방지
    final now = DateTime.now();
    final todayNoon = DateTime(now.year, now.month, now.day, 12, 0);
    when(() => repo.getSessions()).thenReturn([
      TimerSessionEntity(
        id: 's1',
        startedAt: todayNoon.subtract(const Duration(hours: 2)),
        endedAt: todayNoon.subtract(const Duration(hours: 1)),
        durationMinutes: 60,
      ),
      TimerSessionEntity(
        id: 's2',
        startedAt: todayNoon.subtract(const Duration(hours: 1)),
        endedAt: todayNoon,
        durationMinutes: 30,
      ),
    ]);

    container = ProviderContainer(
      overrides: [
        isAuthenticatedProvider.overrideWith((ref) => false),
        timerSessionRepositoryProvider.overrideWith((ref) => repo),
      ],
    );

    final stats = await container.read(todayStatsNotifierProvider.future);
    expect(stats.sessionCount, 2);
    expect(stats.totalMinutes, 90);
    expect(stats.streak, 1);
  });
}
