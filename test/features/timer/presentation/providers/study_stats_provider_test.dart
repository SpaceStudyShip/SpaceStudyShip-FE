import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/today_stats.dart';
import 'package:space_study_ship/features/timer/presentation/providers/study_stats_provider.dart';
import 'package:space_study_ship/features/timer/presentation/providers/today_stats_provider.dart';

void main() {
  test('todayStats 로드 완료 → 3 provider 가 lifetime/monthly 값 위임', () async {
    const stats = TodayStats(
      totalMinutes: 180,
      sessionCount: 3,
      streak: 7,
      lifetimeMinutes: 12450,
      lifetimeSessionCount: 287,
      monthlyMinutes: 1820,
    );

    final container = ProviderContainer(
      overrides: [
        todayStatsNotifierProvider.overrideWith(() {
          return _StubTodayStatsNotifier(stats);
        }),
      ],
    );
    addTearDown(container.dispose);

    // todayStats 비동기 로드 완료 대기
    await container.read(todayStatsNotifierProvider.future);

    expect(container.read(totalStudyMinutesProvider), 12450);
    expect(container.read(totalSessionCountProvider), 287);
    expect(container.read(monthlyStudyMinutesProvider), 1820);
  });
}

class _StubTodayStatsNotifier extends TodayStatsNotifier {
  _StubTodayStatsNotifier(this._stats);
  final TodayStats _stats;

  @override
  Future<TodayStats> build() async => _stats;
}
