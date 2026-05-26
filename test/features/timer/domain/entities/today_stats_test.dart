import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/today_stats.dart';

void main() {
  test('TodayStats 필드 보유', () {
    const stats = TodayStats(totalMinutes: 180, sessionCount: 3, streak: 7);
    expect(stats.totalMinutes, 180);
    expect(stats.sessionCount, 3);
    expect(stats.streak, 7);
  });

  test('TodayStats.empty: 모두 0', () {
    expect(
      TodayStats.empty(),
      const TodayStats(totalMinutes: 0, sessionCount: 0, streak: 0),
    );
  });
}
