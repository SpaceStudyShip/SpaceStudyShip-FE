import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_transaction_entity.dart';

part 'fuel_transaction_response_model.freezed.dart';
part 'fuel_transaction_response_model.g.dart';

/// 서버 wire 포맷 (SCREAMING_SNAKE_CASE) 와 도메인 enum 의 매핑 계층.
/// 도메인 enum 은 camelCase 를 유지하기 위해 wire 전용 enum 을 둔다.
enum FuelTransactionTypeWire {
  @JsonValue('charge')
  charge,
  @JsonValue('consume')
  consume,
}

enum FuelTransactionReasonWire {
  @JsonValue('STUDY_SESSION')
  studySession,
  @JsonValue('EXPLORATION_UNLOCK')
  explorationUnlock,
}

/// GET /api/fuel/transactions 응답 항목 DTO
@freezed
class FuelTransactionResponseModel with _$FuelTransactionResponseModel {
  const FuelTransactionResponseModel._();

  const factory FuelTransactionResponseModel({
    required String id,
    @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
    required FuelTransactionTypeWire type,
    required int amount,
    @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
    required FuelTransactionReasonWire reason,
    String? referenceId,
    required int balanceAfter,
    required DateTime createdAt,
  }) = _FuelTransactionResponseModel;

  factory FuelTransactionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FuelTransactionResponseModelFromJson(json);

  FuelTransactionEntity toEntity() => FuelTransactionEntity(
        id: id,
        type: switch (type) {
          FuelTransactionTypeWire.charge => FuelTransactionType.charge,
          FuelTransactionTypeWire.consume => FuelTransactionType.consume,
        },
        amount: amount,
        reason: switch (reason) {
          FuelTransactionReasonWire.studySession =>
            FuelTransactionReason.studySession,
          FuelTransactionReasonWire.explorationUnlock =>
            FuelTransactionReason.explorationUnlock,
        },
        referenceId: referenceId,
        balanceAfter: balanceAfter,
        createdAt: createdAt,
      );
}
