import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/fuel_local_datasource.dart';
import '../../data/repositories/fuel_repository_impl.dart';
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/repositories/fuel_repository.dart';

part 'fuel_provider.g.dart';

// === DataSource & Repository ===

@riverpod
FuelLocalDataSource fuelLocalDataSource(Ref ref) {
  throw StateError(
    'FuelLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
FuelRepository fuelRepository(Ref ref) {
  final dataSource = ref.watch(fuelLocalDataSourceProvider);
  return FuelRepositoryImpl(dataSource);
}

// === Fuel State ===

@Riverpod(keepAlive: true)
class FuelNotifier extends _$FuelNotifier {
  @override
  FuelEntity build() {
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getFuel();
  }

  /// 공부 시간으로 연료 충전 (30분 = 1통, 잔여분 누적)
  Future<void> chargeFuel({
    required int studyMinutes,
    String? sessionId,
  }) async {
    if (studyMinutes <= 0) return;
    final totalMinutes = state.pendingMinutes + studyMinutes;
    final amount = totalMinutes ~/ 30;
    final newPendingMinutes = totalMinutes % 30;
    final repository = ref.read(fuelRepositoryProvider);
    state = await repository.chargeFuel(
      amount,
      newPendingMinutes,
      FuelTransactionReason.studySession,
      sessionId,
    );
    // 이력도 갱신
    ref.invalidate(fuelTransactionListNotifierProvider);
  }

  /// 탐험 해금 등으로 연료 소비
  ///
  /// 잔량 부족 시 [InsufficientFuelException] 발생.
  Future<void> consumeFuel({required int amount, String? nodeId}) async {
    final repository = ref.read(fuelRepositoryProvider);
    state = await repository.consumeFuel(
      amount,
      FuelTransactionReason.explorationUnlock,
      nodeId,
    );
    // 이력도 갱신
    ref.invalidate(fuelTransactionListNotifierProvider);
  }
}

// === Transaction History ===

@riverpod
class FuelTransactionListNotifier extends _$FuelTransactionListNotifier {
  @override
  List<FuelTransactionEntity> build() {
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getTransactions();
  }
}

// === Convenience Providers ===

@riverpod
int currentFuel(Ref ref) {
  return ref.watch(fuelNotifierProvider).currentFuel;
}
