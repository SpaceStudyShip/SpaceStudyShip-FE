import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_transaction_entity.freezed.dart';

enum FuelTransactionType { charge, consume }

enum FuelTransactionReason { studySession, explorationUnlock }

@freezed
class FuelTransactionEntity with _$FuelTransactionEntity {
  const factory FuelTransactionEntity({
    required String id,
    required FuelTransactionType type,
    required int amount,
    required FuelTransactionReason reason,
    String? referenceId,
    required int balanceAfter,
    required DateTime createdAt,
  }) = _FuelTransactionEntity;
}
