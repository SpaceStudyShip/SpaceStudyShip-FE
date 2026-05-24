import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/todo/data/models/todo_update_request_model.dart';

void main() {
  group('TodoUpdateRequestModel', () {
    test('빈 객체 직렬화 → 빈 JSON', () {
      const model = TodoUpdateRequestModel();
      expect(model.toJson(), isEmpty);
    });

    test('title 만 변경 — null 필드 제외 (PATCH semantics)', () {
      const model = TodoUpdateRequestModel(title: '새 제목');
      final json = model.toJson();
      expect(json, {'title': '새 제목'});
      expect(json.containsKey('completedDates'), isFalse);
      expect(json.containsKey('estimatedMinutes'), isFalse);
    });

    test('completedDates 를 빈 배열로 전송 → 명시적 모두 제거', () {
      const model = TodoUpdateRequestModel(completedDates: []);
      final json = model.toJson();
      expect(json, {'completedDates': <String>[]});
    });

    test('전체 필드 직렬화', () {
      const model = TodoUpdateRequestModel(
        title: 't',
        scheduledDates: ['2026-04-16'],
        completedDates: ['2026-04-16'],
        categoryIds: ['cat-1'],
        estimatedMinutes: 30,
        actualMinutes: 25,
      );
      final json = model.toJson();
      expect(json.keys, hasLength(6));
    });
  });
}
