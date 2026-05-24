import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_create_request_model.dart';

void main() {
  group('TodoCreateRequestModel', () {
    test('필수 필드(title) 포함 직렬화', () {
      const model = TodoCreateRequestModel(title: '수학');
      final json = model.toJson();
      expect(json['title'], '수학');
      expect(json.containsKey('id'), isFalse); // null 제외
    });

    test('전체 필드 직렬화', () {
      final model = TodoCreateRequestModel(
        id: 'id-1',
        title: '수학',
        categoryIds: const ['cat-1'],
        estimatedMinutes: 60,
        scheduledDates: const ['2026-04-16'],
      );
      final json = model.toJson();
      expect(json['id'], 'id-1');
      expect(json['categoryIds'], ['cat-1']);
      expect(json['estimatedMinutes'], 60);
      expect(json['scheduledDates'], ['2026-04-16']);
    });
  });
}
