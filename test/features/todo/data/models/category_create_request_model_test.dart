import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/category_create_request_model.dart';

void main() {
  group('CategoryCreateRequestModel', () {
    test('필수 필드(name) 포함 직렬화', () {
      const model = CategoryCreateRequestModel(name: '수학');
      final json = model.toJson();
      expect(json, {'name': '수학'});
    });

    test('전체 필드 직렬화', () {
      const model = CategoryCreateRequestModel(
        id: 'cat-1',
        name: '수학',
        iconId: 'math_icon',
        positionX: 0.3,
        positionY: 0.5,
      );
      final json = model.toJson();
      expect(json['iconId'], 'math_icon');
      expect(json['positionX'], 0.3);
      expect(json['positionY'], 0.5);
    });
  });
}
