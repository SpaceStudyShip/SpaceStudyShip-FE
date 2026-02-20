import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_entity.freezed.dart';

@freezed
class FuelEntity with _$FuelEntity {
  const factory FuelEntity({
    @Default(0) int currentFuel,
    @Default(0) int totalCharged,
    @Default(0) int totalConsumed,
    @Default(0) int pendingMinutes,
    required DateTime lastUpdatedAt,
  }) = _FuelEntity;
}
