import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_create_response_model.dart';

void main() {
  test('fromJson + toEntity (TimerSessionCreateResult)', () {
    final json = {
      'session': {
        'id': 'sess-uuid',
        'todoId': 'todo-1',
        'todoTitle': '수학',
        'startedAt': '2026-05-25T01:00:00Z',
        'endedAt':   '2026-05-25T02:30:00Z',
        'durationMinutes': 90,
      },
      'fuelCharged': 90,
    };
    final m = TimerSessionCreateResponseModel.fromJson(json);
    expect(m.fuelCharged, 90);

    final result = m.toEntity();
    expect(result.session.id, 'sess-uuid');
    expect(result.session.durationMinutes, 90);
    expect(result.fuelCharged, 90);
  });
}
