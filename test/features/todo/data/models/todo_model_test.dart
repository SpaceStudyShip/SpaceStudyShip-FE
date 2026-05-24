import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_model.dart';

void main() {
  group('TodoModel.fromJson (camelCase)', () {
    test('camelCase JSON 을 파싱한다', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'title': '수학 문제 풀기',
        'scheduledDates': ['2026-04-16'],
        'completedDates': ['2026-04-16'],
        'categoryIds': ['cat-1'],
        'estimatedMinutes': 60,
        'actualMinutes': 45,
        'createdAt': '2026-04-15T10:00:00Z',
        'updatedAt': '2026-04-16T09:30:00Z',
      };

      final model = TodoModel.fromJson(json);

      expect(model.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(model.title, '수학 문제 풀기');
      expect(model.scheduledDates.first, DateTime.parse('2026-04-16'));
      expect(model.completedDates.first, DateTime.parse('2026-04-16'));
      expect(model.categoryIds, ['cat-1']);
      expect(model.estimatedMinutes, 60);
      expect(model.actualMinutes, 45);
    });

    test('toJson 결과가 camelCase 키를 사용한다', () {
      final model = TodoModel(
        id: 'id-1',
        title: 't',
        scheduledDates: const [],
        completedDates: const [],
        categoryIds: const [],
        createdAt: DateTime.parse('2026-04-15T10:00:00Z'),
        updatedAt: DateTime.parse('2026-04-15T10:00:00Z'),
      );

      final json = model.toJson();

      expect(
        json.keys,
        containsAll([
          'id',
          'title',
          'scheduledDates',
          'completedDates',
          'categoryIds',
          'createdAt',
          'updatedAt',
        ]),
      );
      expect(json.containsKey('scheduled_dates'), isFalse);
      expect(json.containsKey('category_ids'), isFalse);
    });
  });

  group('TodoModel._migrateJson (구버전 snake_case 캐시 호환)', () {
    test('snake_case 키 → camelCase 키 변환', () {
      final oldJson = {
        'id': 'id-1',
        'title': 't',
        'scheduled_dates': ['2026-04-16'],
        'completed_dates': [],
        'category_ids': ['cat-1'],
        'estimated_minutes': 30,
        'actual_minutes': null,
        'created_at': '2026-04-15T10:00:00Z',
        'updated_at': '2026-04-15T10:00:00Z',
      };

      final model = TodoModel.fromJson(oldJson);

      expect(model.scheduledDates, isNotEmpty);
      expect(model.categoryIds, ['cat-1']);
      expect(model.estimatedMinutes, 30);
    });
  });
}
