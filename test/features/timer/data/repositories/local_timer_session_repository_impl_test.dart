import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/features/timer/data/datasources/timer_session_local_datasource.dart';
import 'package:space_study_ship/features/timer/data/models/timer_session_model.dart';
import 'package:space_study_ship/features/timer/data/repositories/local_timer_session_repository_impl.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_entity.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_filter.dart';

class _MockLocal extends Mock implements TimerSessionLocalDataSource {}

void main() {
  late _MockLocal local;
  late LocalTimerSessionRepositoryImpl repo;

  setUp(() {
    local = _MockLocal();
    repo = LocalTimerSessionRepositoryImpl(local);
    registerFallbackValue(
      TimerSessionModel(
        id: 'x',
        startedAt: DateTime.utc(2026, 1, 1),
        endedAt: DateTime.utc(2026, 1, 1, 1),
        durationMinutes: 60,
      ),
    );
  });

  group('LocalTimerSessionRepositoryImpl', () {
    test('getSessions → local datasource에 위임', () {
      when(() => local.getSessions()).thenReturn([
        TimerSessionModel(
          id: 's1',
          startedAt: DateTime.utc(2026, 5, 25),
          endedAt: DateTime.utc(2026, 5, 25, 1),
          durationMinutes: 60,
        ),
      ]);

      final result = repo.getSessions();

      expect(result, hasLength(1));
      expect(result.first.id, 's1');
      expect(result.first.durationMinutes, 60);
      verify(() => local.getSessions()).called(1);
    });

    test('addSession → local datasource에 위임', () async {
      when(() => local.addSession(any())).thenAnswer((_) async {});

      await repo.addSession(
        TimerSessionEntity(
          id: 's2',
          startedAt: DateTime.utc(2026, 5, 25),
          endedAt: DateTime.utc(2026, 5, 25, 1),
          durationMinutes: 60,
        ),
      );

      verify(() => local.addSession(any())).called(1);
    });

    test('clearAll → local datasource에 위임', () async {
      when(() => local.clearAll()).thenAnswer((_) async {});

      await repo.clearAll();

      verify(() => local.clearAll()).called(1);
    });

    test('createSession → UnsupportedError 던짐', () {
      expect(
        () => repo.createSession(
          startedAt: DateTime.utc(2026, 5, 25),
          endedAt: DateTime.utc(2026, 5, 25, 1),
          durationMinutes: 60,
          idempotencyKey: 'k',
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getSessionsPage → UnsupportedError 던짐', () {
      expect(
        () => repo.getSessionsPage(const TimerSessionFilter()),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getTodayStats → UnsupportedError 던짐', () async {
      expect(
        () async => await repo.getTodayStats(),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
