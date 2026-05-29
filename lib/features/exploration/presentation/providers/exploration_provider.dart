import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/exploration_local_datasource.dart';
import '../../data/datasources/exploration_remote_datasource.dart';
import '../../data/repositories/exploration_remote_repository_impl.dart';
import '../../data/repositories/exploration_repository_impl.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../../domain/repositories/exploration_repository.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';

part 'exploration_provider.g.dart';

// === DataSource ===

/// 기본값: StateError (main.dart에서 SharedPreferences로 override 필수)
@riverpod
ExplorationLocalDataSource explorationLocalDataSource(Ref ref) {
  throw StateError(
    'ExplorationLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

// === Remote DataSource ===

@Riverpod(keepAlive: true)
ExplorationRemoteDataSource explorationRemoteDataSource(Ref ref) {
  return ExplorationRemoteDataSource(ref.watch(dioProvider));
}

// === Repository (auth 기반 스왑) ===

/// 인증 사용자는 서버, 게스트는 로컬 Repository.
@Riverpod(keepAlive: true)
ExplorationRepository explorationRepository(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return ExplorationRemoteRepositoryImpl(
      ref.watch(explorationRemoteDataSourceProvider),
    );
  }
  return ExplorationLocalRepositoryImpl(
    ref.watch(explorationLocalDataSourceProvider),
  );
}

// === State Notifiers ===

/// 행성 목록 상태
///
/// 게스트/소셜 로그인 모두 전체 행성을 표시합니다.
/// 게스트의 비-지구 행성 접근 제한은 UI(explore_screen)에서 처리합니다.
@Riverpod(keepAlive: true)
class ExplorationNotifier extends _$ExplorationNotifier {
  @override
  Future<List<ExplorationNodeEntity>> build() async {
    return ref.watch(explorationRepositoryProvider).getPlanets();
  }

  /// 이전 행성이 해금되었는지 (sortOrder 기준 바로 앞 행성 클리어 필요).
  bool canUnlockPlanet(String planetId) {
    final planets = state.valueOrNull ?? const <ExplorationNodeEntity>[];
    final targetIndex = planets.indexWhere((p) => p.id == planetId);
    if (targetIndex < 0) return false;
    if (targetIndex == 0) return true;
    return planets[targetIndex - 1].isCleared;
  }

  bool _isUnlocking = false;

  /// 행성 해금 (순서 검증 + 연료 + 상태).
  Future<void> unlockPlanet(String planetId, int requiredFuel) async {
    if (_isUnlocking) return;
    _isUnlocking = true;
    try {
      if (!canUnlockPlanet(planetId)) {
        throw StateError('이전 행성을 먼저 해금해야 합니다.');
      }

      final repository = ref.read(explorationRepositoryProvider);
      if (ref.read(isAuthenticatedProvider)) {
        // 서버가 원자적으로 연료 차감 → 잔량 재조회만.
        await repository.unlockPlanet(planetId);
        ref.invalidate(fuelNotifierProvider);
      } else {
        // 게스트: 로컬 연료 차감 후 해금.
        await ref
            .read(fuelNotifierProvider.notifier)
            .consumeFuel(amount: requiredFuel, nodeId: planetId);
        await repository.unlockPlanet(planetId);
      }

      await _reload();

      try {
        await ref.read(badgeNotifierProvider.notifier).checkAndUnlock();
      } catch (e) {
        debugPrint('탐험 후 배지 해금 체크 실패: $e');
      }
    } finally {
      _isUnlocking = false;
    }
  }

  /// 상태 새로고침 (지역 해금 후 행성 목록 갱신).
  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    state = await AsyncValue.guard(
      () => ref.read(explorationRepositoryProvider).getPlanets(),
    );
  }
}

/// 특정 행성의 지역 목록 (행성 ID 기반 family)
@riverpod
class RegionListNotifier extends _$RegionListNotifier {
  @override
  Future<List<ExplorationNodeEntity>> build(String planetId) async {
    return ref.watch(explorationRepositoryProvider).getRegions(planetId);
  }

  bool _isUnlocking = false;

  /// 지역 해금 (연료 + 상태 + 자동 클리어).
  Future<void> unlockRegion(String regionId, int requiredFuel) async {
    if (_isUnlocking) return;
    _isUnlocking = true;
    try {
      final repository = ref.read(explorationRepositoryProvider);
      if (ref.read(isAuthenticatedProvider)) {
        await repository.unlockRegion(regionId);
        ref.invalidate(fuelNotifierProvider);
      } else {
        await ref
            .read(fuelNotifierProvider.notifier)
            .consumeFuel(amount: requiredFuel, nodeId: regionId);
        await repository.unlockRegion(regionId);
      }

      state = await AsyncValue.guard(() => repository.getRegions(planetId));

      // 행성 목록 갱신 (자동 클리어/progress 반영)
      await ref.read(explorationNotifierProvider.notifier).refresh();

      try {
        await ref.read(badgeNotifierProvider.notifier).checkAndUnlock();
      } catch (e) {
        debugPrint('탐험 후 배지 해금 체크 실패: $e');
      }
    } finally {
      _isUnlocking = false;
    }
  }
}

/// 특정 행성의 진행도.
///
/// 행성 목록 변경 시 갱신. (regionListNotifier를 watch하면 인증 모드에서
/// 행성마다 지역 API가 호출되므로 행성 목록만 watch한다 — 서버 progress는
/// 행성 응답에 내장.)
@riverpod
Future<ExplorationProgressEntity> explorationProgress(
  Ref ref,
  String planetId,
) {
  ref.watch(explorationNotifierProvider);
  return ref.watch(explorationRepositoryProvider).getProgress(planetId);
}
