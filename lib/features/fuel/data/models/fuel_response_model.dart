import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_entity.dart';

part 'fuel_response_model.freezed.dart';
part 'fuel_response_model.g.dart';

/// GET /api/fuel 응답 DTO
@freezed
class FuelResponseModel with _$FuelResponseModel {
  const FuelResponseModel._();

  const factory FuelResponseModel({
    required int currentFuel,
    required int totalCharged,
    required int totalConsumed,
    required int pendingMinutes,
    required DateTime lastUpdatedAt,
  }) = _FuelResponseModel;

  factory FuelResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FuelResponseModelFromJson(json);

  FuelEntity toEntity() => FuelEntity(
    currentFuel: currentFuel,
    totalCharged: totalCharged,
    totalConsumed: totalConsumed,
    pendingMinutes: pendingMinutes,
    lastUpdatedAt: lastUpdatedAt,
  );
}
