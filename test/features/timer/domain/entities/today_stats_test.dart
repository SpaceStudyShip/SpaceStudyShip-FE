import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/today_stats.dart';

void main() {
  test('TodayStats — 6필드 생성', () {
    const stats = TodayStats(
      totalMinutes: 180,
      sessionCount: 3,
      streak: 7,
      lifetimeMinutes: 12450,
      lifetimeSessionCount: 287,
      monthlyMinutes: 1820,
    );
    expect(stats.totalMinutes, 180);
    expect(stats.lifetimeMinutes, 12450);
    expect(stats.monthlyMinutes, 1820);
  });

  test('TodayStats.empty(): 6필드 모두 0', () {
    expect(
      TodayStats.empty(),
      const TodayStats(
        totalMinutes: 0,
        sessionCount: 0,
        streak: 0,
        lifetimeMinutes: 0,
        lifetimeSessionCount: 0,
        monthlyMinutes: 0,
      ),
    );
  });
}
