import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/data/models/unlock_response_models.dart';

void main() {
  test('RegionUnlockResponseModel — toEntity', () {
    final json = {
      'region': {
        'id': 'japan',
        'name': '일본',
        'isUnlocked': true,
        'isCleared': true,
        'unlockedAt': '2026-04-16T11:00:00Z',
      },
      'fuelConsumed': 5,
      'currentFuel': 95,
      'planetCleared': false,
    };
    final entity = RegionUnlockResponseModel.fromJson(json).toEntity();
    expect(entity.planetCleared, false);
    expect(entity.currentFuel, 95);
  });

  test('PlanetUnlockResponseModel — toEntity', () {
    final json = {
      'planet': {
        'id': 'mars',
        'name': '화성',
        'isUnlocked': true,
        'isCleared': false,
      },
      'fuelConsumed': 10,
      'currentFuel': 40,
    };
    final entity = PlanetUnlockResponseModel.fromJson(json).toEntity();
    expect(entity.currentFuel, 40);
  });
}
