import '../entities/exploration_node_entity.dart';
import '../entities/exploration_progress_entity.dart';

/// 탐험 Repository 인터페이스
///
/// 게스트: [ExplorationLocalRepositoryImpl] (SharedPreferences)
/// 소셜 로그인(향후): ExplorationRemoteRepositoryImpl (Backend API)
abstract class ExplorationRepository {
  /// 전체 행성 목록 (해금 상태 반영)
  List<ExplorationNodeEntity> getPlanets();

  /// 특정 행성 조회
  ExplorationNodeEntity getPlanet(String planetId);

  /// 특정 행성의 지역 목록 (해금 상태 반영)
  List<ExplorationNodeEntity> getRegions(String planetId);

  /// 지역 해금 (해금 = 클리어)
  Future<void> unlockRegion(String regionId);

  /// 행성 해금
  Future<void> unlockPlanet(String planetId);

  /// 진행도 계산
  ExplorationProgressEntity getProgress(String planetId);

  /// 전체 삭제 (게스트 로그아웃 시)
  Future<void> clearAll();
}
