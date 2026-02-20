// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_entity.dart';

part 'fuel_model.freezed.dart';
part 'fuel_model.g.dart';

@freezed
class FuelModel with _$FuelModel {
  const factory FuelModel({
    @Default(0) @JsonKey(name: 'current_fuel') int currentFuel,
    @Default(0) @JsonKey(name: 'total_charged') int totalCharged,
    @Default(0) @JsonKey(name: 'total_consumed') int totalConsumed,
    @Default(0) @JsonKey(name: 'pending_minutes') int pendingMinutes,
    @JsonKey(name: 'last_updated_at') required DateTime lastUpdatedAt,
  }) = _FuelModel;

  factory FuelModel.fromJson(Map<String, dynamic> json) =>
      _$FuelModelFromJson(json);
}

extension FuelModelX on FuelModel {
  FuelEntity toEntity() => FuelEntity(
    currentFuel: currentFuel,
    totalCharged: totalCharged,
    totalConsumed: totalConsumed,
    pendingMinutes: pendingMinutes,
    lastUpdatedAt: lastUpdatedAt,
  );
}

extension FuelEntityX on FuelEntity {
  FuelModel toModel() => FuelModel(
    currentFuel: currentFuel,
    totalCharged: totalCharged,
    totalConsumed: totalConsumed,
    pendingMinutes: pendingMinutes,
    lastUpdatedAt: lastUpdatedAt,
  );
}
