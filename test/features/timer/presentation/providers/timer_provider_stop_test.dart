import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/badge/data/datasources/badge_local_datasource.dart';
import 'package:space_study_ship/features/badge/presentation/providers/badge_provider.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_local_datasource.dart';
import 'package:space_study_ship/features/fuel/domain/entities/fuel_entity.dart';
import 'package:space_study_ship/features/fuel/domain/repositories/fuel_repository.dart';
import 'package:space_study_ship/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:space_study_ship/features/timer/data/datasources/timer_session_local_datasource.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_create_result.dart';
import 'package:space_study_ship/features/timer/domain/entities/timer_session_entity.dart';
import 'package:space_study_ship/features/timer/domain/exceptions/timer_session_exceptions.dart';
import 'package:space_study_ship/features/timer/domain/repositories/timer_session_repository.dart';
import 'package:space_study_ship/features/timer/presentation/providers/timer_provider.dart';
import 'package:space_study_ship/features/timer/presentation/providers/timer_session_provider.dart';
import 'package:space_study_ship/features/timer/presentation/providers/timer_state.dart';
import 'package:space_study_ship/features/todo/data/datasources/local_todo_datasource.dart';
import 'package:space_study_ship/features/todo/domain/repositories/todo_repository.dart';
import 'package:space_study_ship/features/todo/presentation/providers/todo_provider.dart';

class _MockTimerRepo extends Mock implements TimerSessionRepository {}

class _MockFuelRepo extends Mock implements FuelRepository {}

class _MockTodoRepo extends Mock implements TodoRepository {}

// 위젯 바인딩 초기화 (TimerNotifier가 WidgetsBindingObserver를 사용하므로 필요)
void _ensureBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// TimerSessionCreateResult 더미 — 1분 세션용.
TimerSessionCreateResult _dummyResult({String id = 'sess-1'}) =>
    TimerSessionCreateResult(
      session: TimerSessionEntity(
        id: id,
        startedAt: DateTime.utc(2026, 5, 25, 10),
        endedAt: DateTime.utc(2026, 5, 25, 10, 1),
        durationMinutes: 1,
      ),
      fuelCharged: 0,
    );

/// FuelEntity 기본값 (잔량 0).
FuelEntity _zeroFuel() => FuelEntity(
  currentFuel: 0,
  pendingMinutes: 0,
  lastUpdatedAt: DateTime.utc(2026, 5, 25),
);

/// 1분 이상 경과 상태를 주입한 TimerNotifier (setSessionForTest 사용).
void _seedOneMinuteSession(
  TimerNotifier notifier, {
  String todoId = 'todo-1',
  String todoTitle = '수학',
  String idempotencyKey = 'IDEM-TEST-123',
}) {
  notifier.setSessionForTest(
    status:
        TimerStatus.paused, // paused → elapsed = accumulated (deterministic)
    startTime: DateTime.now().subtract(const Duration(minutes: 5)),
    accumulatedBeforePause: const Duration(minutes: 1),
    linkedTodoId: todoId,
    linkedTodoTitle: todoTitle,
    idempotencyKey: idempotencyKey,
  );
}

void main() {
  // TimerNotifier 가 WidgetsBindingObserver 를 사용하므로 초기화 필요
  _ensureBinding();

  late ProviderContainer container;
  late _MockTimerRepo mockTimerRepo;
  late _MockFuelRepo mockFuelRepo;
  late _MockTodoRepo mockTodoRepo;
  late SharedPreferences prefs;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue('');
    // addSession(any()) 을 위한 TimerSessionEntity fallback
    registerFallbackValue(
      TimerSessionEntity(
        id: 'fallback',
        startedAt: DateTime.utc(2026),
        endedAt: DateTime.utc(2026, 1, 1, 0, 1),
        durationMinutes: 1,
      ),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockTimerRepo = _MockTimerRepo();
    mockFuelRepo = _MockFuelRepo();
    mockTodoRepo = _MockTodoRepo();
  });

  tearDown(() => container.dispose());

  /// 인증 모드 오버라이드: fuel/todo repository 도 mock 으로 교체하여
  /// invalidate 이후 Dio / SecureStorage 호출을 차단.
  List<Override> authOverrides() => [
    isAuthenticatedProvider.overrideWith((ref) => true),
    timerSessionRepositoryProvider.overrideWith((ref) => mockTimerRepo),
    timerSessionLocalDataSourceProvider.overrideWithValue(
      TimerSessionLocalDataSource(prefs),
    ),
    fuelRepositoryProvider.overrideWith((ref) => mockFuelRepo),
    fuelLocalDataSourceProvider.overrideWithValue(FuelLocalDataSource(prefs)),
    todoRepositoryProvider.overrideWith((ref) => mockTodoRepo),
    badgeLocalDataSourceProvider.overrideWithValue(BadgeLocalDataSource(prefs)),
    localTodoDataSourceProvider.overrideWithValue(LocalTodoDataSource(prefs)),
  ];

  /// 게스트 모드 오버라이드: 로컬 datasource 만 주입.
  List<Override> guestOverrides() => [
    isAuthenticatedProvider.overrideWith((ref) => false),
    timerSessionRepositoryProvider.overrideWith((ref) => mockTimerRepo),
    timerSessionLocalDataSourceProvider.overrideWithValue(
      TimerSessionLocalDataSource(prefs),
    ),
    fuelLocalDataSourceProvider.overrideWithValue(FuelLocalDataSource(prefs)),
    badgeLocalDataSourceProvider.overrideWithValue(BadgeLocalDataSource(prefs)),
    localTodoDataSourceProvider.overrideWithValue(LocalTodoDataSource(prefs)),
  ];

  group('TimerNotifier.stop() — 인증 모드', () {
    test('인증 모드 stop: repo.createSession 이 idempotencyKey 포함하여 호출됨 '
        '+ 정지 후 상태 초기화 (idempotencyKey 폐기)', () async {
      when(
        () => mockTimerRepo.createSession(
          startedAt: any(named: 'startedAt'),
          endedAt: any(named: 'endedAt'),
          durationMinutes: any(named: 'durationMinutes'),
          todoId: any(named: 'todoId'),
          todoTitle: any(named: 'todoTitle'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => _dummyResult());
      // invalidate 후 rebuild 시 getFuel() 호출될 수 있으므로 mock
      when(() => mockFuelRepo.getFuel()).thenAnswer((_) async => _zeroFuel());
      // invalidate 후 rebuild 시 getTodoList() 호출될 수 있으므로 mock
      when(
        () => mockTodoRepo.getTodoList(
          date: any(named: 'date'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async => []);

      container = ProviderContainer(overrides: authOverrides());

      final notifier = container.read(timerNotifierProvider.notifier);
      _seedOneMinuteSession(notifier, idempotencyKey: 'IDEM-AUTH-1');

      final result = await notifier.stop();

      // 반환값 존재 (1분 이상이므로)
      expect(result, isNotNull);
      expect(result!.todoTitle, '수학');
      expect(result.sessionDuration.inMinutes, greaterThanOrEqualTo(1));

      // createSession 1회 호출 + idempotencyKey 전달 확인
      final captured = verify(
        () => mockTimerRepo.createSession(
          startedAt: any(named: 'startedAt'),
          endedAt: any(named: 'endedAt'),
          durationMinutes: any(named: 'durationMinutes'),
          todoId: any(named: 'todoId'),
          todoTitle: any(named: 'todoTitle'),
          idempotencyKey: captureAny(named: 'idempotencyKey'),
        ),
      ).captured;
      expect(captured.first, 'IDEM-AUTH-1');

      // 정지 후 상태 초기화 (idempotencyKey 폐기)
      expect(container.read(timerNotifierProvider).status, TimerStatus.idle);
      expect(container.read(timerNotifierProvider).idempotencyKey, isNull);
    });

    test('인증 모드 stop: 404 LinkedTodoNotFound 시 todoId=null 로 1회 재시도', () async {
      var callCount = 0;
      when(
        () => mockTimerRepo.createSession(
          startedAt: any(named: 'startedAt'),
          endedAt: any(named: 'endedAt'),
          durationMinutes: any(named: 'durationMinutes'),
          todoId: any(named: 'todoId'),
          todoTitle: any(named: 'todoTitle'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) throw const LinkedTodoNotFound();
        return _dummyResult();
      });
      when(() => mockFuelRepo.getFuel()).thenAnswer((_) async => _zeroFuel());
      when(
        () => mockTodoRepo.getTodoList(
          date: any(named: 'date'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async => []);

      container = ProviderContainer(overrides: authOverrides());

      final notifier = container.read(timerNotifierProvider.notifier);
      _seedOneMinuteSession(
        notifier,
        todoId: 'todo-missing',
        idempotencyKey: 'IDEM-RETRY-1',
      );

      // stop() 이 예외 없이 완료돼야 함 (retry 경로)
      final result = await notifier.stop();
      expect(result, isNotNull);

      // 총 2회 호출됨
      expect(callCount, 2);

      // 두 번째 호출의 todoId 가 null 인지 검증 (captured 값 순서)
      final calls = verify(
        () => mockTimerRepo.createSession(
          startedAt: any(named: 'startedAt'),
          endedAt: any(named: 'endedAt'),
          durationMinutes: any(named: 'durationMinutes'),
          todoId: captureAny(named: 'todoId'),
          todoTitle: any(named: 'todoTitle'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).captured;
      expect(calls.length, 2);
      expect(calls[0], 'todo-missing'); // 첫 번째 호출: 원래 todoId
      expect(calls[1], isNull); // 두 번째 호출: null (재시도)
    });
  });

  group('TimerNotifier.stop() — 게스트 모드', () {
    test('게스트 모드 stop: repo.createSession 호출 안 됨, '
        '로컬 세션 저장 + fuelNotifier.chargeFuel 경로 통과', () async {
      // 게스트 모드에서 timerSessionRepositoryProvider 는 mockTimerRepo 를 반환하지만,
      // addSession / getSessions 는 stub 해줘야 `type 'Null' is not a subtype of Future<void>` 방지.
      when(() => mockTimerRepo.addSession(any())).thenAnswer((_) async {});
      when(() => mockTimerRepo.getSessions()).thenReturn([]);

      container = ProviderContainer(overrides: guestOverrides());

      final notifier = container.read(timerNotifierProvider.notifier);
      notifier.setSessionForTest(
        status: TimerStatus.paused,
        startTime: DateTime.now().subtract(const Duration(minutes: 5)),
        accumulatedBeforePause: const Duration(minutes: 1),
        idempotencyKey: 'IDEM-GUEST-1',
      );

      // fuel provider 가 로컬 repo 를 사용할 수 있도록 build 완료 대기
      await container.read(fuelNotifierProvider.future);

      final result = await notifier.stop();

      // 결과 존재
      expect(result, isNotNull);
      expect(result!.sessionDuration.inMinutes, greaterThanOrEqualTo(1));

      // 서버 createSession 호출 없음 (핵심 검증)
      verifyNever(
        () => mockTimerRepo.createSession(
          startedAt: any(named: 'startedAt'),
          endedAt: any(named: 'endedAt'),
          durationMinutes: any(named: 'durationMinutes'),
          todoId: any(named: 'todoId'),
          todoTitle: any(named: 'todoTitle'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      );

      // 로컬 addSession 이 1회 호출됐는지 확인
      verify(() => mockTimerRepo.addSession(any())).called(1);

      // 정지 후 상태 초기화
      expect(container.read(timerNotifierProvider).status, TimerStatus.idle);
    });
  });

  group('TimerNotifier.stop() — 1분 미만 세션', () {
    test('1분 미만 세션은 null 반환 + 상태 초기화 (createSession 미호출)', () async {
      container = ProviderContainer(overrides: guestOverrides());

      final notifier = container.read(timerNotifierProvider.notifier);
      // accumulatedBeforePause = 30초 → elapsed < 1분
      notifier.setSessionForTest(
        status: TimerStatus.paused,
        startTime: DateTime.now(),
        accumulatedBeforePause: const Duration(seconds: 30),
        idempotencyKey: 'IDEM-SHORT',
      );

      final result = await notifier.stop();

      // null 반환 (다이얼로그 생략)
      expect(result, isNull);

      // createSession 호출 없음
      verifyNever(
        () => mockTimerRepo.createSession(
          startedAt: any(named: 'startedAt'),
          endedAt: any(named: 'endedAt'),
          durationMinutes: any(named: 'durationMinutes'),
          todoId: any(named: 'todoId'),
          todoTitle: any(named: 'todoTitle'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      );

      // 상태 초기화
      expect(container.read(timerNotifierProvider).status, TimerStatus.idle);
    });
  });
}
