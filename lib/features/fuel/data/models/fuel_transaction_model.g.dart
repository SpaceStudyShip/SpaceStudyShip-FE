// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FuelTransactionModelImpl _$$FuelTransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$FuelTransactionModelImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toInt(),
  reason: json['reason'] as String,
  referenceId: json['reference_id'] as String?,
  balanceAfter: (json['balance_after'] as num).toInt(),
  createdAt: const SafeDateTimeConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$$FuelTransactionModelImplToJson(
  _$FuelTransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'amount': instance.amount,
  'reason': instance.reason,
  'reference_id': instance.referenceId,
  'balance_after': instance.balanceAfter,
  'created_at': const SafeDateTimeConverter().toJson(instance.createdAt),
};
