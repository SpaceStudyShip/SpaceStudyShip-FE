import 'package:flutter/foundation.dart';

import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../../domain/repositories/exploration_repository.dart';
import '../datasources/exploration_local_datasource.dart';
import '../seed/exploration_seed_data.dart';

/// 로컬 탐험 Repository 구현체
///
/// 시드 데이터(정적) + SharedPreferences(상태)를 머지하여 완성된 Entity를 반환.
/// 향후 백엔드 연동 시 ExplorationRemoteRepositoryImpl로 교체.
class ExplorationLocalRepositoryImpl implements ExplorationRepository {
  final ExplorationLocalDataSource _localDataSource;

  ExplorationLocalRepositoryImpl(this._localDataSource);

  @override
  List<ExplorationNodeEntity> getPlanets() {
    final states = _localDataSource.getAllStates();
    return ExplorationSeedData.planets.map((planet) {
      final state = states[planet.id];
      if (state == null) return planet;
      return planet.copyWith(
        isUnlocked: state.isUnlocked || planet.isUnlocked,
        isCleared: state.isCleared || planet.isCleared,
      );
    }).toList();
  }

  @override
  ExplorationNodeEntity getPlanet(String planetId) {
    final planet = ExplorationSeedData.getPlanet(planetId);
    final states = _localDataSource.getAllStates();
    final state = states[planetId];
    if (state == null) return planet;
    return planet.copyWith(
      isUnlocked: state.isUnlocked || planet.isUnlocked,
      isCleared: state.isCleared || planet.isCleared,
    );
  }

  @override
  List<ExplorationNodeEntity> getRegions(String planetId) {
    final states = _localDataSource.getAllStates();
    return ExplorationSeedData.getRegions(planetId).map((region) {
      final state = states[region.id];
      if (state == null) return region;
      return region.copyWith(
        isUnlocked: state.isUnlocked || region.isUnlocked,
        isCleared: state.isCleared || region.isCleared,
      );
    }).toList();
  }

  @override
  Future<void> unlockRegion(String regionId) async {
    final now = DateTime.now();
    // Region은 해금 = 클리어 (연료 소비만으로 탐험 완료)
    await _localDataSource.saveNodeState(
      ExplorationNodeState(
        nodeId: regionId,
        isUnlocked: true,
        isCleared: true,
        unlockedAt: now,
      ),
    );

    // 부모 행성의 자동 클리어 체크
    await _checkPlanetAutoComplete(regionId);
  }

  @override
  Future<void> unlockPlanet(String planetId) async {
    await _localDataSource.saveNodeState(
      ExplorationNodeState(
        nodeId: planetId,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      ),
    );
  }

  @override
  ExplorationProgressEntity getProgress(String planetId) {
    final regions = getRegions(planetId);
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

  /// 부모 행성 자동 클리어 체크
  ///
  /// 모든 하위 지역이 클리어되면 행성도 자동으로 클리어 처리.
  Future<void> _checkPlanetAutoComplete(String regionId) async {
    String? parentPlanetId;
    for (final entry in ExplorationSeedData.regions.entries) {
      if (entry.value.any((r) => r.id == regionId)) {
        parentPlanetId = entry.key;
        break;
      }
    }
    if (parentPlanetId == null) return;

    final regions = getRegions(parentPlanetId);
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
      debugPrint('🎉 행성 $parentPlanetId 자동 클리어!');
    }
  }
}
