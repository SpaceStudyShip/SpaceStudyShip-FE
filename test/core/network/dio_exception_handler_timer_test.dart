import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/network/dio_exception_handler.dart';
import 'package:space_study_ship/features/timer/domain/exceptions/timer_session_exceptions.dart';

void main() {
  DioException buildErr(int status, String code) => DioException(
        requestOptions: RequestOptions(path: '/api/timer-sessions'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/timer-sessions'),
          statusCode: status,
          data: {'code': code, 'message': 'msg'},
        ),
        type: DioExceptionType.badResponse,
      );

  test('400 INVALID_SESSION_TIME → InvalidSessionTime', () {
    expect(DioExceptionHandler.handle(buildErr(400, 'INVALID_SESSION_TIME')),
        isA<InvalidSessionTime>());
  });
  test('400 INVALID_DURATION → InvalidDuration', () {
    expect(DioExceptionHandler.handle(buildErr(400, 'INVALID_DURATION')),
        isA<InvalidDuration>());
  });
  test('400 SESSION_TOO_LONG → SessionTooLong', () {
    expect(DioExceptionHandler.handle(buildErr(400, 'SESSION_TOO_LONG')),
        isA<SessionTooLong>());
  });
  test('400 FUTURE_SESSION → FutureSession', () {
    expect(DioExceptionHandler.handle(buildErr(400, 'FUTURE_SESSION')),
        isA<FutureSession>());
  });
  test('404 TODO_NOT_FOUND → LinkedTodoNotFound', () {
    expect(DioExceptionHandler.handle(buildErr(404, 'TODO_NOT_FOUND')),
        isA<LinkedTodoNotFound>());
  });
  test('400 SESSION_TOO_SHORT (안전망 — 클라가 사전 차단하지만 매핑 유지)', () {
    expect(DioExceptionHandler.handle(buildErr(400, 'SESSION_TOO_SHORT')),
        isA<InvalidDuration>());
  });
}
