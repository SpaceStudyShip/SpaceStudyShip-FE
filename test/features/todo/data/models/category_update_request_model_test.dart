import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/category_update_request_model.dart';

void main() {
  group('CategoryUpdateRequestModel', () {
    test('빈 객체 → 빈 JSON', () {
      const model = CategoryUpdateRequestModel();
      expect(model.toJson(), isEmpty);
    });

    test('name 만 변경 — null 필드 제외', () {
      const model = CategoryUpdateRequestModel(name: '수학(심화)');
      expect(model.toJson(), {'name': '수학(심화)'});
    });

    test('positionX/Y 만 변경 — 드래그앤드롭 케이스', () {
      const model = CategoryUpdateRequestModel(positionX: 0.4, positionY: 0.6);
      final json = model.toJson();
      expect(json, {'positionX': 0.4, 'positionY': 0.6});
    });
  });
}
