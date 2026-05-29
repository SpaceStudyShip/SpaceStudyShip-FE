import 'package:dio/dio.dart';

import '../../../../core/network/dio_exception_handler.dart';
import '../../../fuel/domain/exceptions/fuel_exceptions.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../../domain/entities/unlock_result_entities.dart';
import '../../domain/exceptions/exploration_exceptions.dart';
import '../datasources/exploration_remote_datasource.dart';

/// 서버 source-of-truth 탐험 Repository (인증 사용자).
///
/// 행성 목록을 받을 때 progress를 in-memory 캐시에 저장해, getProgress가
/// 추가 네트워크 호출 없이 반환하도록 한다.
class ExplorationRemoteRepositoryImpl {
  final ExplorationRemoteDataSource _remote;

  ExplorationRemoteRepositoryImpl(this._remote);

  List<ExplorationNodeEntity> _planetsCache = const [];
  final Map<String, ExplorationProgressEntity> _progressCache = {};

  Future<List<ExplorationNodeEntity>> getPlanets() async {
    try {
      final models = await _remote.getPlanets();
      _planetsCache = models.map((m) => m.toEntity()).toList(growable: false);
      _progressCache
        ..clear()
        ..addEntries(models.map((m) => MapEntry(m.id, m.progressEntity())));
      return _planetsCache;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  Future<ExplorationNodeEntity> getPlanet(String planetId) async {
    final cached = _findById(_planetsCache, planetId);
    if (cached != null) return cached;
    final found = _findById(await getPlanets(), planetId);
    if (found == null) throw const ExplorationNodeNotFoundException();
    return found;
  }

  ExplorationNodeEntity? _findById(
    List<ExplorationNodeEntity> list,
    String id,
  ) {
    for (final node in list) {
      if (node.id == id) return node;
    }
    return null;
  }

  Future<List<ExplorationNodeEntity>> getRegions(String planetId) async {
    try {
      final models = await _remote.getRegions(planetId);
      return models.map((m) => m.toEntity()).toList(growable: false);
    } on DioException catch (e) {
      throw _mapUnlockError(e);
    }
  }

  Future<RegionUnlockResultEntity> unlockRegion(String regionId) async {
    try {
      final res = await _remote.unlockRegion(regionId);
      return res.toEntity();
    } on DioException catch (e) {
      throw _mapUnlockError(e);
    }
  }

  Future<PlanetUnlockResultEntity> unlockPlanet(String planetId) async {
    try {
      final res = await _remote.unlockPlanet(planetId);
      return res.toEntity();
    } on DioException catch (e) {
      throw _mapUnlockError(e);
    }
  }

  Future<ExplorationProgressEntity> getProgress(String planetId) async {
    final cached = _progressCache[planetId];
    if (cached != null) return cached;
    await getPlanets();
    return _progressCache[planetId] ??
        ExplorationProgressEntity(
          nodeId: planetId,
          clearedChildren: 0,
          totalChildren: 0,
        );
  }

  /// 서버 데이터는 탈퇴/로그아웃 API가 정리. 캐시만 비운다 (호출 경로 없음).
  Future<void> clearAll() async {
    _planetsCache = const [];
    _progressCache.clear();
  }

  /// unlock/regions 에러 본문 code → 도메인 예외 매핑.
  Object _mapUnlockError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      switch (data['code']) {
        case 'INSUFFICIENT_FUEL':
          return InsufficientFuelException(
            requiredAmount: (data['requiredFuel'] as num?)?.toInt() ?? 0,
            available: (data['currentFuel'] as num?)?.toInt() ?? 0,
          );
        case 'ALREADY_UNLOCKED':
          return const NodeAlreadyUnlockedException();
        case 'PLANET_LOCKED':
          return const PlanetLockedException();
        case 'PREREQUISITE_NOT_CLEARED':
          return const PrerequisiteNotClearedException();
        case 'REGION_NOT_FOUND':
        case 'PLANET_NOT_FOUND':
          return const ExplorationNodeNotFoundException();
      }
    }
    return DioExceptionHandler.handle(e);
  }
}
