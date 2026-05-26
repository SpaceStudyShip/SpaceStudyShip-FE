import '../../../../core/errors/app_exception.dart';

/// Timer 세션 저장 API 가 반환할 수 있는 검증 실패를 도메인 예외로 표현.
sealed class TimerSessionException extends AppException {
  const TimerSessionException({required super.message, super.code});
}

/// 시작 시각이 종료 시각보다 늦거나 같음.
class InvalidSessionTime extends TimerSessionException {
  const InvalidSessionTime()
    : super(
        message: '세션 시작 시각이 종료 시각보다 늦거나 같습니다.',
        code: 'INVALID_SESSION_TIME',
      );
}

/// durationMinutes 가 (endedAt - startedAt) 보다 큼.
class InvalidDuration extends TimerSessionException {
  const InvalidDuration()
    : super(message: '세션 시간이 유효하지 않습니다.', code: 'INVALID_DURATION');
}

/// durationMinutes > 1440 (24시간).
class SessionTooLong extends TimerSessionException {
  const SessionTooLong()
    : super(message: '세션이 24시간을 초과합니다.', code: 'SESSION_TOO_LONG');
}

/// startedAt / endedAt 이 서버 현재 시각보다 미래.
class FutureSession extends TimerSessionException {
  const FutureSession()
    : super(message: '미래 시각의 세션은 저장할 수 없습니다.', code: 'FUTURE_SESSION');
}

/// 연결된 Todo 가 본인 소유 아님 / 존재하지 않음.
class LinkedTodoNotFound extends TimerSessionException {
  const LinkedTodoNotFound()
    : super(message: '연결된 할 일을 찾을 수 없습니다.', code: 'TODO_NOT_FOUND');
}
