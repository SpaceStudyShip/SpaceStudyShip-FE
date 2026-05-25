import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/entities/fuel_transaction_filter.dart';
import '../../domain/entities/fuel_transaction_page.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../datasources/fuel_local_datasource.dart';
import '../datasources/fuel_remote_datasource.dart';
import '../models/fuel_model.dart';
import '../models/fuel_response_model.dart';

/// 서버 source-of-truth + 로컬 캐시 폴백 (server-backed).
///
/// 변동 mutation (`chargeFuel`/`consumeFuel`) 은 서버에 직접 API 가 없으므로
/// UnsupportedError 를 던진다. 호출자 (FuelNotifier) 가 isAuthenticated 분기로
/// 흡수하여 도메인 액션 API 호출 → 잔량 재조회 흐름을 사용한다.
class FuelRepositoryImpl implements FuelRepository {
  final FuelRemoteDataSource remote;
  final FuelLocalDataSource cache;

  FuelRepositoryImpl({required this.remote, required this.cache});

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  Future<FuelEntity> getFuel() async {
    try {
      final model = await remote.getFuel();
      await cache.saveFuel(_toCacheModel(model));
      return model.toEntity();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        return cache.getFuel().toEntity();
      }
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<FuelTransactionPage> getTransactionsPage(
    FuelTransactionFilter filter,
  ) async {
    try {
      final response = await remote.getTransactions(
        type: switch (filter.type) {
          FuelTransactionType.charge => 'charge',
          FuelTransactionType.consume => 'consume',
          null => null,
        },
        startDate: filter.startDate != null
            ? _dateFmt.format(filter.startDate!)
            : null,
        endDate: filter.endDate != null
            ? _dateFmt.format(filter.endDate!)
            : null,
        page: filter.page,
        size: filter.size,
      );
      return response.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) {
    throw UnsupportedError(
      'Server mutates fuel via timer/exploration actions. '
      'Notifier should invalidate fuelRepositoryProvider after action API.',
    );
  }

  @override
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) {
    throw UnsupportedError(
      'Server mutates fuel via exploration unlock action. '
      'Notifier should invalidate fuelRepositoryProvider after action API.',
    );
  }

  @override
  Future<List<FuelTransactionEntity>> getTransactions({int? limit}) {
    throw UnsupportedError(
      'Server-backed repository uses pagination — call getTransactionsPage.',
    );
  }

  @override
  Future<void> clearAll() async {
    await cache.clearAll();
  }

  static bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  /// 서버 응답을 LocalDataSource 가 쓰는 영속 모델 형태로 변환.
  static FuelModel _toCacheModel(FuelResponseModel m) => FuelModel(
    currentFuel: m.currentFuel,
    totalCharged: m.totalCharged,
    totalConsumed: m.totalConsumed,
    pendingMinutes: m.pendingMinutes,
    lastUpdatedAt: m.lastUpdatedAt,
  );
}
