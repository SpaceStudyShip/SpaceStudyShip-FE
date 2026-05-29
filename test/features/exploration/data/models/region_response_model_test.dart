import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/data/models/region_response_model.dart';
import 'package:space_study_ship/features/exploration/domain/entities/exploration_node_entity.dart';

void main() {
  test('RegionResponseModel — fromJson + toEntity', () {
    final json = {
      'id': 'japan',
      'name': '일본',
      'nodeType': 'region',
      'depth': 3,
      'icon': 'JP',
      'parentId': 'earth',
      'requiredFuel': 5,
      'isUnlocked': true,
      'isCleared': true,
      'sortOrder': 1,
      'description': '이웃 섬나라',
      'unlockedAt': '2026-04-05T15:30:00Z',
    };
    final entity = RegionResponseModel.fromJson(json).toEntity();
    expect(entity.id, 'japan');
    expect(entity.nodeType, ExplorationNodeType.region);
    expect(entity.parentId, 'earth');
    expect(entity.isCleared, true);
    expect(entity.unlockedAt, DateTime.utc(2026, 4, 5, 15, 30));
  });
}
