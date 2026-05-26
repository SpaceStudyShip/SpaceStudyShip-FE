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
      'endedAt': '2026-05-25T02:30:00.000Z',
      'durationMinutes': 90,
    });
  });

  test('toJson: todoId/todoTitle null 인 경우 키 자체가 생략됨', () {
    final m = TimerSessionCreateRequestModel(
      startedAt: DateTime.utc(2026, 5, 25, 1),
      endedAt: DateTime.utc(2026, 5, 25, 2),
      durationMinutes: 60,
    );
    final json = m.toJson();
    expect(json.containsKey('todoId'), isFalse);
    expect(json.containsKey('todoTitle'), isFalse);
    expect(json['durationMinutes'], 60);
  });

  // 회귀 가드: local DateTime 입력도 UTC `Z` 접미사로 직렬화돼야 한다.
  // Spring Boot Jackson 의 Instant 파서가 타임존 없는 문자열을 거부하기 때문.
  test('toJson: local DateTime 입력 → UTC Z 접미사 강제', () {
    // DateTime.now() 와 동일한 local DateTime 을 인위적으로 만든다.
    final localStart = DateTime(2026, 5, 26, 14, 30); // isUtc = false
    final localEnd = DateTime(2026, 5, 26, 15, 30);

    final m = TimerSessionCreateRequestModel(
      startedAt: localStart,
      endedAt: localEnd,
      durationMinutes: 60,
    );
    final json = m.toJson();

    expect(
      json['startedAt'],
      endsWith('Z'),
      reason: '서버 Instant 파서가 Z 없는 문자열을 거부함',
    );
    expect(json['endedAt'], endsWith('Z'));
    expect(json['startedAt'], localStart.toUtc().toIso8601String());
    expect(json['endedAt'], localEnd.toUtc().toIso8601String());
  });
}
