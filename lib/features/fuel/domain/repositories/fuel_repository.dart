import '../entities/fuel_entity.dart';
import '../entities/fuel_transaction_entity.dart';

abstract class FuelRepository {
  FuelEntity getFuel();
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);
  List<FuelTransactionEntity> getTransactions({int? limit});
  Future<void> clearAll();
}
