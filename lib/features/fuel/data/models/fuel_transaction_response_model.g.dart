// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_transaction_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FuelTransactionResponseModelImpl _$$FuelTransactionResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$FuelTransactionResponseModelImpl(
  id: json['id'] as String,
  type: $enumDecode(
    _$FuelTransactionTypeWireEnumMap,
    json['type'],
    unknownValue: FuelTransactionTypeWire.charge,
  ),
  amount: (json['amount'] as num).toInt(),
  reason: $enumDecode(
    _$FuelTransactionReasonWireEnumMap,
    json['reason'],
    unknownValue: FuelTransactionReasonWire.studySession,
  ),
  referenceId: json['referenceId'] as String?,
  balanceAfter: (json['balanceAfter'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$FuelTransactionResponseModelImplToJson(
  _$FuelTransactionResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$FuelTransactionTypeWireEnumMap[instance.type]!,
  'amount': instance.amount,
  'reason': _$FuelTransactionReasonWireEnumMap[instance.reason]!,
  'referenceId': instance.referenceId,
  'balanceAfter': instance.balanceAfter,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$FuelTransactionTypeWireEnumMap = {
  FuelTransactionTypeWire.charge: 'charge',
  FuelTransactionTypeWire.consume: 'consume',
};

const _$FuelTransactionReasonWireEnumMap = {
  FuelTransactionReasonWire.studySession: 'STUDY_SESSION',
  FuelTransactionReasonWire.explorationUnlock: 'EXPLORATION_UNLOCK',
};
