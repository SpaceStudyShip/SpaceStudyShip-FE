import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/exceptions/timer_session_exceptions.dart';

void main() {
  group('TimerSessionException', () {
    test('서브타입들이 sealed class 의 일원이다', () {
      expect(const InvalidSessionTime(), isA<TimerSessionException>());
      expect(const InvalidDuration(), isA<TimerSessionException>());
      expect(const SessionTooLong(), isA<TimerSessionException>());
      expect(const FutureSession(), isA<TimerSessionException>());
      expect(const LinkedTodoNotFound(), isA<TimerSessionException>());
    });

    test('Exception 인터페이스를 구현한다', () {
      expect(const InvalidSessionTime(), isA<Exception>());
    });

    test('각 서브타입은 const 생성자를 가진다', () {
      const a = InvalidSessionTime();
      const b = InvalidSessionTime();
      expect(identical(a, b), isTrue); // const canonicalization
    });
  });
}
