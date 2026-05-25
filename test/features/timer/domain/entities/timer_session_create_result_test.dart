import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_entity.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_create_result.dart';

void main() {
  test('TimerSessionCreateResult 는 session 과 fuelCharged 를 보유한다', () {
    final session = TimerSessionEntity(
      id: 'sess-1',
      todoId: 'todo-1',
      todoTitle: '수학',
      startedAt: DateTime.utc(2026, 5, 25, 1),
      endedAt: DateTime.utc(2026, 5, 25, 2, 30),
      durationMinutes: 90,
    );
    final result = TimerSessionCreateResult(session: session, fuelCharged: 90);

    expect(result.session, session);
    expect(result.fuelCharged, 90);
  });
}
