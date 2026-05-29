import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/data/models/planet_response_model.dart';
import 'package:space_study_ship/features/exploration/domain/entities/exploration_node_entity.dart';

void main() {
  group('PlanetResponseModel', () {
    test('fromJson + toEntity — 해금된 행성 (progress 포함)', () {
      final json = {
        'id': 'mars',
        'name': '화성',
        'nodeType': 'planet',
        'depth': 2,
        'icon': 'mars',
        'parentId': null,
        'prerequisiteId': 'venus',
        'requiredFuel': 10,
        'isUnlocked': true,
        'isCleared': false,
        'sortOrder': 3,
        'description': '붉은 행성',
        'mapX': 0.25,
        'mapY': 0.44,
        'unlockedAt': '2026-04-01T00:00:00Z',
        'progress': {
          'clearedChildren': 3,
          'totalChildren': 5,
          'progressRatio': 0.6,
        },
      };
      final model = PlanetResponseModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.id, 'mars');
      expect(entity.nodeType, ExplorationNodeType.planet);
      expect(entity.requiredFuel, 10);
      expect(entity.isUnlocked, true);
      expect(entity.unlockedAt, DateTime.utc(2026, 4, 1));

      final progress = model.progressEntity();
      expect(progress.clearedChildren, 3);
      expect(progress.totalChildren, 5);
      expect(progress.progressRatio, closeTo(0.6, 0.001));
    });

    test('fromJson — 잠긴 행성 (unlockedAt/progress 없음)', () {
      final json = {
        'id': 'neptune',
        'name': '해왕성',
        'nodeType': 'planet',
        'depth': 2,
        'icon': 'neptune',
        'requiredFuel': 60,
        'isUnlocked': false,
        'isCleared': false,
        'sortOrder': 7,
      };
      final model = PlanetResponseModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.unlockedAt, isNull);
      expect(entity.isUnlocked, false);
      expect(model.progressEntity().totalChildren, 0);
    });
  });
}
