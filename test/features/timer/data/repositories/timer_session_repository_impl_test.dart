import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/features/timer/data/datasources/timer_session_local_datasource.dart';
import 'package:space_study_ship/features/timer/data/datasources/timer_session_remote_datasource.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_create_request_model.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_create_response_model.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_page_response_model.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_response_model.dart';
import 'package:space_study_ship/features/timer/data/models/today_stats_response_model.dart';
import 'package:space_study_ship/features/timer/data/repositories/timer_session_repository_impl.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_entity.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_filter.dart';
import 'package:space_study_ship/features/timer/domain/exceptions/timer_session_exceptions.dart';

class _MockRemote extends Mock implements TimerSessionRemoteDataSource {}

class _MockLocal extends Mock implements TimerSessionLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal cache;
  late TimerSessionRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    cache = _MockLocal();
    repo = TimerSessionRepositoryImpl(remote: remote, cache: cache);
    registerFallbackValue(
      TimerSessionCreateRequestModel(
        startedAt: DateTime.utc(2026, 1, 1),
        endedAt: DateTime.utc(2026, 1, 1, 1),
        durationMinutes: 60,
      ),
    );
  });

  group('createSession', () {
    test('성공: TimerSessionCreateResult 반환', () async {
      when(
        () => remote.createSession(
          idempotencyKey: any(named: 'idempotencyKey'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => TimerSessionCreateResponseModel(
          session: TimerSessionResponseModel(
            id: 'sess1',
            startedAt: DateTime.utc(2026, 5, 25, 1),
            endedAt: DateTime.utc(2026, 5, 25, 2),
            durationMinutes: 60,
          ),
          fuelCharged: 60,
        ),
      );

      final result = await repo.createSession(
        startedAt: DateTime.utc(2026, 5, 25, 1),
        endedAt: DateTime.utc(2026, 5, 25, 2),
        durationMinutes: 60,
        idempotencyKey: 'IDEM-1',
      );

      expect(result.session.id, 'sess1');
      expect(result.fuelCharged, 60);
    });

    test('400 INVALID_SESSION_TIME → InvalidSessionTime throw', () async {
      when(
        () => remote.createSession(
          idempotencyKey: any(named: 'idempotencyKey'),
          body: any(named: 'body'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/timer-sessions'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/timer-sessions'),
            statusCode: 400,
            data: {'code': 'INVALID_SESSION_TIME', 'message': '...'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      await expectLater(
        repo.createSession(
          startedAt: DateTime.utc(2026, 5, 25, 2),
          endedAt: DateTime.utc(2026, 5, 25, 1),
          durationMinutes: 60,
          idempotencyKey: 'IDEM-X',
        ),
        throwsA(isA<InvalidSessionTime>()),
      );
    });

    test('404 TODO_NOT_FOUND → LinkedTodoNotFound throw', () async {
      when(
        () => remote.createSession(
          idempotencyKey: any(named: 'idempotencyKey'),
          body: any(named: 'body'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/timer-sessions'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/timer-sessions'),
            statusCode: 404,
            data: {'code': 'TODO_NOT_FOUND', 'message': '...'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      await expectLater(
        repo.createSession(
          startedAt: DateTime.utc(2026, 5, 25, 1),
          endedAt: DateTime.utc(2026, 5, 25, 2),
          durationMinutes: 60,
          todoId: 'todo-missing',
          idempotencyKey: 'IDEM-Y',
        ),
        throwsA(isA<LinkedTodoNotFound>()),
      );
    });
  });

  group('getSessionsPage', () {
    test('성공: filter 가 query 로 전달됨', () async {
      when(
        () => remote.getSessions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          todoId: any(named: 'todoId'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => const TimerSessionPageResponseModel(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
        ),
      );

      await repo.getSessionsPage(
        TimerSessionFilter(
          startDate: DateTime.utc(2026, 5, 1),
          endDate: DateTime.utc(2026, 5, 31),
          todoId: 'todo-1',
          page: 2,
          size: 50,
        ),
      );

      verify(
        () => remote.getSessions(
          startDate: '2026-05-01',
          endDate: '2026-05-31',
          todoId: 'todo-1',
          page: 2,
          size: 50,
        ),
      ).called(1);
    });
  });

  group('getTodayStats', () {
    test('성공: TodayStats 반환', () async {
      when(() => remote.getTodayStats()).thenAnswer(
        (_) async => const TodayStatsResponseModel(
          totalMinutes: 180,
          sessionCount: 3,
          streak: 7,
        ),
      );
      final stats = await repo.getTodayStats();
      expect(stats.totalMinutes, 180);
      expect(stats.streak, 7);
    });
  });

  group('guest-only methods throw UnsupportedError', () {
    test('getSessions', () {
      expect(repo.getSessions, throwsA(isA<UnsupportedError>()));
    });
    test('addSession', () {
      expect(
        () => repo.addSession(
          TimerSessionEntity(
            id: 'dummy',
            startedAt: DateTime.utc(2026, 1, 1),
            endedAt: DateTime.utc(2026, 1, 1, 1),
            durationMinutes: 60,
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
