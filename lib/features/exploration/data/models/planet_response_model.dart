import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';

part 'planet_response_model.freezed.dart';
part 'planet_response_model.g.dart';

/// GET /api/explorations/planets 응답 항목 DTO
@freezed
class PlanetResponseModel with _$PlanetResponseModel {
  const PlanetResponseModel._();

  const factory PlanetResponseModel({
    required String id,
    required String name,
    required String nodeType,
    required int depth,
    required String icon,
    String? parentId,
    String? prerequisiteId,
    required int requiredFuel,
    required bool isUnlocked,
    required bool isCleared,
    required int sortOrder,
    @Default('') String description,
    @Default(0.5) double mapX,
    @Default(0.0) double mapY,
    DateTime? unlockedAt,
    ProgressResponseModel? progress,
  }) = _PlanetResponseModel;

  factory PlanetResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PlanetResponseModelFromJson(json);

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

  ExplorationProgressEntity progressEntity() => ExplorationProgressEntity(
    nodeId: id,
    clearedChildren: progress?.clearedChildren ?? 0,
    totalChildren: progress?.totalChildren ?? 0,
  );
}

/// 행성 진행도 중첩 DTO
@freezed
class ProgressResponseModel with _$ProgressResponseModel {
  const factory ProgressResponseModel({
    required int clearedChildren,
    required int totalChildren,
    @Default(0.0) double progressRatio,
  }) = _ProgressResponseModel;

  factory ProgressResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressResponseModelFromJson(json);
}

/// 서버 nodeType 문자열 → enum 매핑 (재사용)
ExplorationNodeType nodeTypeFromString(String raw) {
  switch (raw) {
    case 'galaxy':
      return ExplorationNodeType.galaxy;
    case 'starSystem':
    case 'star_system':
      return ExplorationNodeType.starSystem;
    case 'planet':
      return ExplorationNodeType.planet;
    case 'region':
      return ExplorationNodeType.region;
    default:
      return ExplorationNodeType.region;
  }
}
