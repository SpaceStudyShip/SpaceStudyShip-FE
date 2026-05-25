import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_response_model.dart';

void main() {
  test('fromJson + toEntity', () {
    final json = {
      'id': 'sess-uuid',
      'todoId': 'todo-1',
      'todoTitle': '수학',
      'startedAt': '2026-05-25T01:00:00Z',
      'endedAt':   '2026-05-25T02:30:00Z',
      'durationMinutes': 90,
    };
    final m = TimerSessionResponseModel.fromJson(json);
    expect(m.id, 'sess-uuid');
    expect(m.durationMinutes, 90);

    final entity = m.toEntity();
    expect(entity.id, 'sess-uuid');
    expect(entity.todoId, 'todo-1');
    expect(entity.startedAt, DateTime.utc(2026, 5, 25, 1));
    expect(entity.endedAt,   DateTime.utc(2026, 5, 25, 2, 30));
    expect(entity.durationMinutes, 90);
  });

  test('todoId / todoTitle 누락 허용', () {
    final m = TimerSessionResponseModel.fromJson({
      'id': 's1',
      'startedAt': '2026-05-25T00:00:00Z',
      'endedAt':   '2026-05-25T00:30:00Z',
      'durationMinutes': 30,
    });
    expect(m.todoId, isNull);
    expect(m.todoTitle, isNull);
  });
}
