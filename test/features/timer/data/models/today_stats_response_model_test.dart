import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/data/models/today_stats_response_model.dart';

void main() {
  test('fromJson + toEntity', () {
    final m = TodayStatsResponseModel.fromJson({
      'totalMinutes': 180,
      'sessionCount': 3,
      'streak': 7,
    });
    expect(m.totalMinutes, 180);
    final entity = m.toEntity();
    expect(entity.totalMinutes, 180);
    expect(entity.sessionCount, 3);
    expect(entity.streak, 7);
  });
}
