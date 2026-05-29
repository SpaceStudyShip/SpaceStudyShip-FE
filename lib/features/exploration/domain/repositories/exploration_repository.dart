import '../entities/exploration_node_entity.dart';
import '../entities/exploration_progress_entity.dart';
import '../entities/unlock_result_entities.dart';

/// 탐험 Repository 인터페이스
///
/// 게스트: [ExplorationLocalRepositoryImpl] (SharedPreferences)
/// 인증: [ExplorationRemoteRepositoryImpl] (Backend API)
abstract class ExplorationRepository {
  Future<List<ExplorationNodeEntity>> getPlanets();
  Future<ExplorationNodeEntity> getPlanet(String planetId);
  Future<List<ExplorationNodeEntity>> getRegions(String planetId);

  /// 지역 해금 (해금 = 클리어). 게스트 구현의 [RegionUnlockResultEntity.currentFuel]은 -1.
  Future<RegionUnlockResultEntity> unlockRegion(String regionId);

  /// 행성 해금. 게스트 구현의 [PlanetUnlockResultEntity.currentFuel]은 -1.
  Future<PlanetUnlockResultEntity> unlockPlanet(String planetId);

  Future<ExplorationProgressEntity> getProgress(String planetId);

  /// 전체 삭제 (게스트 로그아웃 시)
  Future<void> clearAll();
}
