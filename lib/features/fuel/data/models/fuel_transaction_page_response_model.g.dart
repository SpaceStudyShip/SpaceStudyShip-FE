// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_transaction_page_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FuelTransactionPageResponseModelImpl
_$$FuelTransactionPageResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$FuelTransactionPageResponseModelImpl(
      content: (json['content'] as List<dynamic>)
          .map(
            (e) => FuelTransactionResponseModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$$FuelTransactionPageResponseModelImplToJson(
  _$FuelTransactionPageResponseModelImpl instance,
) => <String, dynamic>{
  'content': instance.content,
  'page': instance.page,
  'size': instance.size,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
};
