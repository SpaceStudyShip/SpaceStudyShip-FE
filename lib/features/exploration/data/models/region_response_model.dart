import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/exploration_node_entity.dart';
import 'planet_response_model.dart' show nodeTypeFromString;

part 'region_response_model.freezed.dart';
part 'region_response_model.g.dart';

/// GET /api/explorations/planets/{planetId}/regions 응답 항목 DTO
@freezed
class RegionResponseModel with _$RegionResponseModel {
  const RegionResponseModel._();

  const factory RegionResponseModel({
    required String id,
    required String name,
    required String nodeType,
    required int depth,
    required String icon,
    String? parentId,
    required int requiredFuel,
    required bool isUnlocked,
    required bool isCleared,
    required int sortOrder,
    @Default('') String description,
    @Default(0.5) double mapX,
    @Default(0.0) double mapY,
    DateTime? unlockedAt,
  }) = _RegionResponseModel;

  factory RegionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegionResponseModelFromJson(json);

  ExplorationNodeEntity toEntity() => ExplorationNodeEntity(
    id: id,
    name: name,
    nodeType: nodeTypeFromString(nodeType),
    depth: depth,
    icon: icon,
    parentId: parentId,
    requiredFuel: requiredFuel,
    isUnlocked: isUnlocked,
    isCleared: isCleared,
    sortOrder: sortOrder,
    description: description,
    mapX: mapX,
    mapY: mapY,
    unlockedAt: unlockedAt,
  );
}
