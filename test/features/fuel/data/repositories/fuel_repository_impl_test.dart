import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_local_datasource.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_remote_datasource.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_model.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_response_model.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_transaction_page_response_model.dart';
import 'package:space_study_ship/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:space_study_ship/features/fuel/domain/entities/fuel_transaction_entity.dart';
import 'package:space_study_ship/features/fuel/domain/entities/fuel_transaction_filter.dart';

class _MockRemote extends Mock implements FuelRemoteDataSource {}

class _MockCache extends Mock implements FuelLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late FuelRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    repo = FuelRepositoryImpl(remote: remote, cache: cache);

    registerFallbackValue(
      FuelModel(lastUpdatedAt: DateTime.utc(2026, 1, 1)),
    );
  });

  DioException _connectionError() => DioException.connectionError(
        requestOptions: RequestOptions(path: '/api/fuel'),
        reason: 'no network',
      );

  group('getFuel', () {
    test('remote 성공 → entity 반환 + 캐시 저장', () async {
      when(() => remote.getFuel()).thenAnswer(
        (_) async => FuelResponseModel(
          currentFuel: 350,
          totalCharged: 1200,
          totalConsumed: 850,
          pendingMinutes: 0,
          lastUpdatedAt: DateTime.utc(2026, 4, 16, 10, 30),
        ),
      );
      when(() => cache.saveFuel(any())).thenAnswer((_) async {});

      final result = await repo.getFuel();

      expect(result.currentFuel, 350);
      verify(() => cache.saveFuel(any())).called(1);
    });

    test('네트워크 실패 → 캐시 폴백', () async {
      when(() => remote.getFuel()).thenThrow(_connectionError());
      when(() => cache.getFuel()).thenReturn(
        FuelModel(
          currentFuel: 100,
          totalCharged: 200,
          totalConsumed: 100,
          lastUpdatedAt: DateTime.utc(2026, 4, 15),
        ),
      );

      final result = await repo.getFuel();

      expect(result.currentFuel, 100);
      verifyNever(() => cache.saveFuel(any()));
    });

    test('네트워크 외 DioException → DioExceptionHandler 통한 AppException throw', () async {
      when(() => remote.getFuel()).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/fuel'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/fuel'),
          statusCode: 401,
          data: {'code': 'UNAUTHENTICATED_REQUEST', 'message': '로그인이 필요합니다.'},
        ),
        type: DioExceptionType.badResponse,
      ));

      await expectLater(
        repo.getFuel(),
        throwsA(isA<UnauthenticatedRequestException>()),
      );
    });
  });

  group('getTransactionsPage', () {
    test('remote 성공 → Page entity 반환', () async {
      when(() => remote.getTransactions(
            type: any(named: 'type'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer(
        (_) async => const FuelTransactionPageResponseModel(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
        ),
      );

      final page = await repo.getTransactionsPage(
        const FuelTransactionFilter(),
      );
      expect(page.items, isEmpty);
      expect(page.hasNext, isFalse);
    });

    test('네트워크 실패 → AppException 전파 (캐시 폴백 없음)', () async {
      when(() => remote.getTransactions(
            type: any(named: 'type'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenThrow(_connectionError());

      await expectLater(
        repo.getTransactionsPage(const FuelTransactionFilter()),
        throwsA(isA<NetworkException>()),
      );
    });

    test('filter type / dates 가 query 로 전달됨', () async {
      when(() => remote.getTransactions(
            type: any(named: 'type'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer(
        (_) async => const FuelTransactionPageResponseModel(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
        ),
      );

      await repo.getTransactionsPage(FuelTransactionFilter(
        type: FuelTransactionType.charge,
        startDate: DateTime.utc(2026, 4, 1),
        endDate: DateTime.utc(2026, 4, 30),
        page: 2,
        size: 50,
      ));

      verify(() => remote.getTransactions(
            type: 'charge',
            startDate: '2026-04-01',
            endDate: '2026-04-30',
            page: 2,
            size: 50,
          )).called(1);
    });
  });

  group('mutation 메서드', () {
    test('chargeFuel → UnsupportedError', () async {
      expect(
        () => repo.chargeFuel(10, 0, FuelTransactionReason.studySession),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('consumeFuel → UnsupportedError', () async {
      expect(
        () => repo.consumeFuel(5, FuelTransactionReason.explorationUnlock),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getTransactions(limit) → UnsupportedError', () async {
      expect(
        () => repo.getTransactions(limit: 10),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('clearAll', () {
    test('cache.clearAll 위임', () async {
      when(() => cache.clearAll()).thenAnswer((_) async {});
      await repo.clearAll();
      verify(() => cache.clearAll()).called(1);
    });
  });
}
