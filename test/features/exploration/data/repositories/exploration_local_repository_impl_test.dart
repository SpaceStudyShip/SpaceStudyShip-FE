import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/exploration/data/datasources/exploration_local_datasource.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_repository_impl.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ExplorationLocalRepositoryImpl> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ExplorationLocalRepositoryImpl(ExplorationLocalDataSource(prefs));
  }

  test('getPlanets — 시드 반환 (지구 해금 상태)', () async {
    final repo = await build();
    final planets = await repo.getPlanets();
    expect(planets, isNotEmpty);
    expect(planets.first.id, 'earth');
    expect(planets.first.isUnlocked, true);
  });

  test('unlockRegion — currentFuel 센티넬 -1, 상태 저장', () async {
    final repo = await build();
    final result = await repo.unlockRegion('japan');
    expect(result.currentFuel, -1);
    final regions = await repo.getRegions('earth');
    expect(regions.firstWhere((r) => r.id == 'japan').isCleared, true);
  });
}
