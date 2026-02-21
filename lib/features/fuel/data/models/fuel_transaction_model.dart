// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_transaction_entity.dart';

part 'fuel_transaction_model.freezed.dart';
part 'fuel_transaction_model.g.dart';

/// DateTime 안전 파싱 컨버터
///
/// `DateTime.tryParse` 실패 시 epoch(1970-01-01)을 sentinel로 사용합니다.
/// 저장 시 UTC로 변환하여 타임존 불일치를 방지합니다.
class SafeDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const SafeDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is String) {
      return DateTime.tryParse(json) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  String toJson(DateTime date) => date.toUtc().toIso8601String();
}

@freezed
class FuelTransactionModel with _$FuelTransactionModel {
  const factory FuelTransactionModel({
    required String id,
    required String type,
    required int amount,
    required String reason,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'balance_after') required int balanceAfter,
    @SafeDateTimeConverter()
    @JsonKey(name: 'created_at')
    required DateTime createdAt,
  }) = _FuelTransactionModel;

  factory FuelTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$FuelTransactionModelFromJson(json);
}

extension FuelTransactionModelX on FuelTransactionModel {
  FuelTransactionEntity toEntity() => FuelTransactionEntity(
    id: id,
    type:
        FuelTransactionType.values.where((e) => e.name == type).firstOrNull ??
        FuelTransactionType.charge,
    amount: amount,
    reason:
        FuelTransactionReason.values
            .where((e) => e.name == reason)
            .firstOrNull ??
        FuelTransactionReason.studySession,
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
