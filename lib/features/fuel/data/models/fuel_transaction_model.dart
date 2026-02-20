// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_transaction_entity.dart';

part 'fuel_transaction_model.freezed.dart';
part 'fuel_transaction_model.g.dart';

@freezed
class FuelTransactionModel with _$FuelTransactionModel {
  const factory FuelTransactionModel({
    required String id,
    required String type,
    required int amount,
    required String reason,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'balance_after') required int balanceAfter,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FuelTransactionModel;

  factory FuelTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$FuelTransactionModelFromJson(json);
}

extension FuelTransactionModelX on FuelTransactionModel {
  FuelTransactionEntity toEntity() => FuelTransactionEntity(
    id: id,
    type: FuelTransactionType.values.byName(type),
    amount: amount,
    reason: FuelTransactionReason.values.byName(reason),
    referenceId: referenceId,
    balanceAfter: balanceAfter,
    createdAt: createdAt,
  );
}

extension FuelTransactionEntityX on FuelTransactionEntity {
  FuelTransactionModel toModel() => FuelTransactionModel(
    id: id,
    type: type.name,
    amount: amount,
    reason: reason.name,
    referenceId: referenceId,
    balanceAfter: balanceAfter,
    createdAt: createdAt,
  );
}
