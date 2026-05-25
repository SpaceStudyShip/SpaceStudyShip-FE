import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_transaction_page.dart';
import 'fuel_transaction_response_model.dart';

part 'fuel_transaction_page_response_model.freezed.dart';
part 'fuel_transaction_page_response_model.g.dart';

/// GET /api/fuel/transactions 페이지 응답 DTO
@freezed
class FuelTransactionPageResponseModel with _$FuelTransactionPageResponseModel {
  const FuelTransactionPageResponseModel._();

  const factory FuelTransactionPageResponseModel({
    required List<FuelTransactionResponseModel> content,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
  }) = _FuelTransactionPageResponseModel;

  factory FuelTransactionPageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$FuelTransactionPageResponseModelFromJson(json);

  FuelTransactionPage toEntity() => FuelTransactionPage(
    items: content.map((m) => m.toEntity()).toList(growable: false),
    page: page,
    size: size,
    totalElements: totalElements,
    totalPages: totalPages,
  );
}
