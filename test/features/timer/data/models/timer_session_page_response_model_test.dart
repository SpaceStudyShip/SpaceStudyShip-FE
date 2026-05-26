import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_page_response_model.dart';

void main() {
  test('fromJson + toEntity (TimerSessionPage)', () {
    final json = {
      'content': [
        {
          'id': 's1',
          'todoId': null,
          'todoTitle': null,
          'startedAt': '2026-05-25T00:00:00Z',
          'endedAt': '2026-05-25T00:30:00Z',
          'durationMinutes': 30,
        },
      ],
      'page': 0,
      'size': 20,
      'totalElements': 1,
      'totalPages': 1,
    };
    final m = TimerSessionPageResponseModel.fromJson(json);
    expect(m.content, hasLength(1));

    final page = m.toEntity();
    expect(page.items, hasLength(1));
    expect(page.items.first.id, 's1');
    expect(page.page, 0);
    expect(page.totalElements, 1);
    expect(page.hasNext, isFalse);
  });

  test('빈 content', () {
    final m = TimerSessionPageResponseModel.fromJson({
      'content': [],
      'page': 0,
      'size': 20,
      'totalElements': 0,
      'totalPages': 0,
    });
    expect(m.toEntity().items, isEmpty);
  });
}
