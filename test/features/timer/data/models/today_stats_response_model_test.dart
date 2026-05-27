import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/data/models/today_stats_response_model.dart';

void main() {
  test('fromJson + toEntity — 6필드 모두 매핑', () {
    final m = TodayStatsResponseModel.fromJson({
      'totalMinutes': 180,
      'sessionCount': 3,
      'streak': 7,
      'lifetimeMinutes': 12450,
      'lifetimeSessionCount': 287,
      'monthlyMinutes': 1820,
    });
    expect(m.totalMinutes, 180);
    expect(m.sessionCount, 3);
    expect(m.streak, 7);
    expect(m.lifetimeMinutes, 12450);
    expect(m.lifetimeSessionCount, 287);
    expect(m.monthlyMinutes, 1820);

    final e = m.toEntity();
    expect(e.totalMinutes, 180);
    expect(e.sessionCount, 3);
    expect(e.streak, 7);
    expect(e.lifetimeMinutes, 12450);
    expect(e.lifetimeSessionCount, 287);
    expect(e.monthlyMinutes, 1820);
  });
}
