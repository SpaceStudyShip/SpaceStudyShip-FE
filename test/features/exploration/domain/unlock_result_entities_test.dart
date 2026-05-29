import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/domain/entities/unlock_result_entities.dart';

void main() {
  test('RegionUnlockResultEntity — 필드 보관', () {
    const r = RegionUnlockResultEntity(planetCleared: true, currentFuel: 42);
    expect(r.planetCleared, true);
    expect(r.currentFuel, 42);
  });

  test('PlanetUnlockResultEntity — 필드 보관', () {
    const p = PlanetUnlockResultEntity(currentFuel: 7);
    expect(p.currentFuel, 7);
  });

  test('게스트 센티넬 currentFuel = -1 허용', () {
    const r = RegionUnlockResultEntity(planetCleared: false, currentFuel: -1);
    expect(r.currentFuel, -1);
  });
}
