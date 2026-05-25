import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_category_model.dart';

void main() {
  group('TodoCategoryModel.fromJson (camelCase)', () {
    test('camelCase JSON 을 파싱한다', () {
      final json = {
        'id': 'cat-1',
        'name': '수학',
        'iconId': 'math_icon',
        'positionX': 0.3,
        'positionY': 0.5,
        'createdAt': '2026-04-01T00:00:00Z',
        'updatedAt': null,
      };

      final model = TodoCategoryModel.fromJson(json);

      expect(model.id, 'cat-1');
      expect(model.name, '수학');
      expect(model.iconId, 'math_icon');
      expect(model.positionX, 0.3);
      expect(model.positionY, 0.5);
      expect(model.updatedAt, isNull);
    });

    test('toJson 결과가 camelCase 키를 사용한다', () {
      final model = TodoCategoryModel(
        id: 'cat-1',
        name: '수학',
        createdAt: DateTime.parse('2026-04-01T00:00:00Z'),
      );

      final json = model.toJson();

      expect(json.keys, containsAll(['id', 'name', 'createdAt']));
      expect(json.containsKey('icon_id'), isFalse);
      expect(json.containsKey('position_x'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });
  });

  group('TodoCategoryModel snake_case 캐시 마이그레이션', () {
    test('snake_case 키 → camelCase 키 변환', () {
      final oldJson = {
        'id': 'cat-1',
        'name': '수학',
        'icon_id': 'math_icon',
        'position_x': 0.3,
        'position_y': 0.5,
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': null,
      };

      final model = TodoCategoryModel.fromJson(oldJson);

      expect(model.iconId, 'math_icon');
      expect(model.positionX, 0.3);
      expect(model.updatedAt, isNull);
    });
  });
}
