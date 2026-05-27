import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/constants/api_endpoints.dart';
import 'package:space_study_ship/features/timer/data/datasources/timer_session_remote_datasource.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_create_request_model.dart';

class _MockHttpAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late Dio dio;
  late _MockHttpAdapter adapter;
  late TimerSessionRemoteDataSource api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    adapter = _MockHttpAdapter();
    dio.httpClientAdapter = adapter;
    api = TimerSessionRemoteDataSource(dio);
    registerFallbackValue(RequestOptions(path: '/'));
  });

  ResponseBody jsonBody(int status, String body) => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  test('createSession: Idempotency-Key 헤더 전달 + body JSON 직렬화', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (inv) async => jsonBody(
        201,
        '{"session":{"id":"sess1","startedAt":"2026-05-25T01:00:00Z","endedAt":"2026-05-25T02:00:00Z","durationMinutes":60},"fuelCharged":60}',
      ),
    );

    await api.createSession(
      idempotencyKey: 'IDEM-KEY-123',
      body: TimerSessionCreateRequestModel(
        startedAt: DateTime.utc(2026, 5, 25, 1),
        endedAt: DateTime.utc(2026, 5, 25, 2),
        durationMinutes: 60,
      ),
    );

    final captured =
        verify(() => adapter.fetch(captureAny(), any(), any())).captured.single
            as RequestOptions;
    expect(captured.method, 'POST');
    expect(captured.path, ApiEndpoints.timerSessions);
    expect(captured.headers['Idempotency-Key'], 'IDEM-KEY-123');
  });

  test('getSessions: query 파라미터 전달', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (inv) async => jsonBody(
        200,
        '{"content":[],"page":2,"size":50,"totalElements":0,"totalPages":0}',
      ),
    );

    await api.getSessions(
      startDate: '2026-05-01',
      endDate: '2026-05-31',
      todoId: 'todo-1',
      page: 2,
      size: 50,
    );

    final captured =
        verify(() => adapter.fetch(captureAny(), any(), any())).captured.single
            as RequestOptions;
    expect(captured.method, 'GET');
    expect(captured.queryParameters['startDate'], '2026-05-01');
    expect(captured.queryParameters['endDate'], '2026-05-31');
    expect(captured.queryParameters['todoId'], 'todo-1');
    expect(captured.queryParameters['page'], 2);
    expect(captured.queryParameters['size'], 50);
  });

  test('getTodayStats: GET 호출', () async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (inv) async => jsonBody(
        200,
        '{"totalMinutes":180,"sessionCount":3,"streak":7,"lifetimeMinutes":12450,"lifetimeSessionCount":287,"monthlyMinutes":1820}',
      ),
    );

    final res = await api.getTodayStats();
    expect(res.totalMinutes, 180);
    expect(res.streak, 7);
    expect(res.lifetimeMinutes, 12450);
    expect(res.lifetimeSessionCount, 287);
    expect(res.monthlyMinutes, 1820);
  });
}
