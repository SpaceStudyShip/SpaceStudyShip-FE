import 'package:flutter/foundation.dart';

import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../../domain/entities/unlock_result_entities.dart';
import '../../domain/repositories/exploration_repository.dart';
import '../datasources/exploration_local_datasource.dart';
import '../seed/exploration_seed_data.dart';

/// 로컬 탐험 Repository 구현체 (게스트).
///
/// 시드 데이터(정적) + SharedPreferences(상태)를 머지. 연료 차감은 Notifier가
/// 별도 수행하므로 결과 엔티티의 currentFuel은 -1 센티넬.
class ExplorationLocalRepositoryImpl implements ExplorationRepository {
  final ExplorationLocalDataSource _localDataSource;

  ExplorationLocalRepositoryImpl(this._localDataSource);

  @override
  Future<List<ExplorationNodeEntity>> getPlanets() async {
    final states = _localDataSource.getAllStates();
    return ExplorationSeedData.planets.map((planet) {
      final state = states[planet.id];
      if (state == null) return planet;
      return planet.copyWith(
        isUnlocked: state.isUnlocked || planet.isUnlocked,
        isCleared: state.isCleared || planet.isCleared,
        unlockedAt: state.unlockedAt,
      );
    }).toList();
  }

  @override
  Future<ExplorationNodeEntity> getPlanet(String planetId) async {
    final planet = ExplorationSeedData.getPlanet(planetId);
    final states = _localDataSource.getAllStates();
    final state = states[planetId];
    if (state == null) return planet;
    return planet.copyWith(
      isUnlocked: state.isUnlocked || planet.isUnlocked,
      isCleared: state.isCleared || planet.isCleared,
      unlockedAt: state.unlockedAt,
    );
  }

  @override
  Future<List<ExplorationNodeEntity>> getRegions(String planetId) async {
    final states = _localDataSource.getAllStates();
    return ExplorationSeedData.getRegions(planetId).map((region) {
      final state = states[region.id];
      if (state == null) return region;
      return region.copyWith(
        isUnlocked: state.isUnlocked || region.isUnlocked,
        isCleared: state.isCleared || region.isCleared,
        unlockedAt: state.unlockedAt,
      );
    }).toList();
  }

  @override
  Future<RegionUnlockResultEntity> unlockRegion(String regionId) async {
    final now = DateTime.now();
    await _localDataSource.saveNodeState(
      ExplorationNodeState(
        nodeId: regionId,
        isUnlocked: true,
        isCleared: true,
        unlockedAt: now,
      ),
    );
    final planetCleared = await _checkPlanetAutoComplete(regionId);
    return RegionUnlockResultEntity(
      planetCleared: planetCleared,
      currentFuel: -1,
    );
  }

  @override
  Future<PlanetUnlockResultEntity> unlockPlanet(String planetId) async {
    await _localDataSource.saveNodeState(
      ExplorationNodeState(
        nodeId: planetId,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      ),
    );
    return const PlanetUnlockResultEntity(currentFuel: -1);
  }

  @override
  Future<ExplorationProgressEntity> getProgress(String planetId) async {
    final regions = await getRegions(planetId);
    final cleared = regions.where((r) => r.isCleared).length;
    return ExplorationProgressEntity(
      nodeId: planetId,
      clearedChildren: cleared,
      totalChildren: regions.length,
    );
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }

  /// 부모 행성 자동 클리어 체크. 새로 클리어되면 true.
  Future<bool> _checkPlanetAutoComplete(String regionId) async {
    String? parentPlanetId;
    for (final entry in ExplorationSeedData.regions.entries) {
      if (entry.value.any((r) => r.id == regionId)) {
        parentPlanetId = entry.key;
        break;
      }
    }
    if (parentPlanetId == null) return false;

    final regions = await getRegions(parentPlanetId);
    final allCleared = regions.every((r) => r.isCleared);
    if (allCleared) {
      await _localDataSource.saveNodeState(
        ExplorationNodeState(
          nodeId: parentPlanetId,
          isUnlocked: true,
          isCleared: true,
          unlockedAt: DateTime.now(),
        ),
      );
      debugPrint('행성 $parentPlanetId 자동 클리어');
    }
    return allCleared;
  }
}
