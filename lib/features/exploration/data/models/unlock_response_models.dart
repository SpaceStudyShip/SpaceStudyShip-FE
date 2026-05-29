import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/unlock_result_entities.dart';

part 'unlock_response_models.freezed.dart';
part 'unlock_response_models.g.dart';

/// 해금된 노드 요약 (중첩)
@freezed
class UnlockedNodeModel with _$UnlockedNodeModel {
  const factory UnlockedNodeModel({
    required String id,
    required String name,
    required bool isUnlocked,
    required bool isCleared,
    DateTime? unlockedAt,
  }) = _UnlockedNodeModel;

  factory UnlockedNodeModel.fromJson(Map<String, dynamic> json) =>
      _$UnlockedNodeModelFromJson(json);
}

/// POST /api/explorations/regions/{regionId}/unlock 응답
@freezed
class RegionUnlockResponseModel with _$RegionUnlockResponseModel {
  const RegionUnlockResponseModel._();

  const factory RegionUnlockResponseModel({
    UnlockedNodeModel? region,
    required int fuelConsumed,
    required int currentFuel,
    required bool planetCleared,
  }) = _RegionUnlockResponseModel;

  factory RegionUnlockResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegionUnlockResponseModelFromJson(json);

  RegionUnlockResultEntity toEntity() => RegionUnlockResultEntity(
    planetCleared: planetCleared,
    currentFuel: currentFuel,
  );
}

/// POST /api/explorations/planets/{planetId}/unlock 응답
@freezed
class PlanetUnlockResponseModel with _$PlanetUnlockResponseModel {
  const PlanetUnlockResponseModel._();

  const factory PlanetUnlockResponseModel({
    UnlockedNodeModel? planet,
    required int fuelConsumed,
    required int currentFuel,
  }) = _PlanetUnlockResponseModel;

  factory PlanetUnlockResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PlanetUnlockResponseModelFromJson(json);

  PlanetUnlockResultEntity toEntity() =>
      PlanetUnlockResultEntity(currentFuel: currentFuel);
}
