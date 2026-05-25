import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_create_request_model.dart';

void main() {
  test('toJson: required + optional 필드 모두 직렬화', () {
    final m = TimerSessionCreateRequestModel(
      todoId: 'todo-1',
      todoTitle: '수학',
      startedAt: DateTime.utc(2026, 5, 25, 1),
      endedAt: DateTime.utc(2026, 5, 25, 2, 30),
      durationMinutes: 90,
    );
    expect(m.toJson(), {
      'todoId': 'todo-1',
      'todoTitle': '수학',
      'startedAt': '2026-05-25T01:00:00.000Z',
      'endedAt':   '2026-05-25T02:30:00.000Z',
      'durationMinutes': 90,
    });
  });

  test('toJson: todoId/todoTitle null 인 경우 키 자체가 생략됨', () {
    final m = TimerSessionCreateRequestModel(
      startedAt: DateTime.utc(2026, 5, 25, 1),
      endedAt:   DateTime.utc(2026, 5, 25, 2),
      durationMinutes: 60,
    );
    final json = m.toJson();
    expect(json.containsKey('todoId'),    isFalse);
    expect(json.containsKey('todoTitle'), isFalse);
    expect(json['durationMinutes'], 60);
  });
}
