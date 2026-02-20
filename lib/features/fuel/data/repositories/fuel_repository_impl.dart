import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/exceptions/fuel_exceptions.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../datasources/fuel_local_datasource.dart';
import '../models/fuel_model.dart';
import '../models/fuel_transaction_model.dart';

class FuelRepositoryImpl implements FuelRepository {
  final FuelLocalDataSource _localDataSource;

  FuelRepositoryImpl(this._localDataSource);

  @override
  FuelEntity getFuel() {
    return _localDataSource.getFuel().toEntity();
  }

  @override
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) async {
    final current = _localDataSource.getFuel();
    final now = DateTime.now();
    final newFuel = FuelModel(
      currentFuel: current.currentFuel + amount,
      totalCharged: current.totalCharged + amount,
      totalConsumed: current.totalConsumed,
      pendingMinutes: pendingMinutes,
      lastUpdatedAt: now,
    );

    await _localDataSource.saveFuel(newFuel);

    // 실제 충전량이 있을 때만 트랜잭션 기록
    if (amount > 0) {
      final transaction = FuelTransactionModel(
        id: 'charge_${now.millisecondsSinceEpoch}',
        type: FuelTransactionType.charge.name,
        amount: amount,
        reason: reason.name,
        referenceId: referenceId,
        balanceAfter: newFuel.currentFuel,
        createdAt: now,
      );
      await _localDataSource.addTransaction(transaction);
    }

    return newFuel.toEntity();
  }

  @override
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) async {
    final current = _localDataSource.getFuel();
    if (current.currentFuel < amount) {
      throw InsufficientFuelException(
        required: amount,
        available: current.currentFuel,
      );
    }

    final now = DateTime.now();
    final newFuel = FuelModel(
      currentFuel: current.currentFuel - amount,
      totalCharged: current.totalCharged,
      totalConsumed: current.totalConsumed + amount,
      pendingMinutes: current.pendingMinutes,
      lastUpdatedAt: now,
    );

    await _localDataSource.saveFuel(newFuel);

    final transaction = FuelTransactionModel(
      id: 'consume_${now.millisecondsSinceEpoch}',
      type: FuelTransactionType.consume.name,
      amount: amount,
      reason: reason.name,
      referenceId: referenceId,
      balanceAfter: newFuel.currentFuel,
      createdAt: now,
    );
    await _localDataSource.addTransaction(transaction);

    return newFuel.toEntity();
  }

  @override
  List<FuelTransactionEntity> getTransactions({int? limit}) {
    final transactions =
        _localDataSource.getTransactions().map((m) => m.toEntity()).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && transactions.length > limit) {
      return transactions.sublist(0, limit);
    }
    return transactions;
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }
}
