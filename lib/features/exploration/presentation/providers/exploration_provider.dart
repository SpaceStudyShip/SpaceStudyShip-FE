import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/exploration_local_datasource.dart';
import '../../data/repositories/exploration_repository_impl.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../../domain/repositories/exploration_repository.dart';
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

// === Repository (auth 기반 스왑) ===

/// 현재: 게스트/소셜 로그인 모두 로컬 Repository 사용
/// 향후: isGuest == false 시 ExplorationRemoteRepositoryImpl로 교체
@riverpod
ExplorationRepository explorationRepository(Ref ref) {
  // 향후 백엔드 연동 시:
  // final isGuest = ref.watch(isGuestProvider);
  // if (!isGuest) {
  //   return ExplorationRemoteRepositoryImpl(
  //     ref.watch(explorationRemoteDataSourceProvider),
  //   );
  // }
  final dataSource = ref.watch(explorationLocalDataSourceProvider);
  return ExplorationLocalRepositoryImpl(dataSource);
}

// === State Notifiers ===

/// 행성 목록 상태
///
/// 게스트/소셜 로그인 모두 전체 행성을 표시합니다.
/// 게스트의 비-지구 행성 접근 제한은 UI(explore_screen)에서 처리합니다.
@Riverpod(keepAlive: true)
class ExplorationNotifier extends _$ExplorationNotifier {
  @override
  List<ExplorationNodeEntity> build() {
    final repository = ref.watch(explorationRepositoryProvider);
    return repository.getPlanets();
  }

  /// 이전 행성이 해금되었는지 확인
  ///
  /// sortOrder 기준으로 바로 앞 행성이 해금 상태여야 true.
  /// 첫 번째 행성(sortOrder 0)은 항상 true.
  bool canUnlockPlanet(String planetId) {
    final planets = state;
    final targetIndex = planets.indexWhere((p) => p.id == planetId);
    if (targetIndex <= 0) return true;
    return planets[targetIndex - 1].isUnlocked;
  }

  bool _isUnlocking = false;

  /// 행성 해금 (순서 검증 + 연료 소비 + 상태 저장)
  ///
  /// 이전 행성 미해금 시 [StateError] throw.
  /// 연료 부족 시 [InsufficientFuelException] throw.
  Future<void> unlockPlanet(String planetId, int requiredFuel) async {
    if (_isUnlocking) return;
    _isUnlocking = true;
    try {
      // 0. 순서 검증: 이전 행성이 해금되어야 함
      if (!canUnlockPlanet(planetId)) {
        throw StateError('이전 행성을 먼저 해금해야 합니다.');
      }

      // 1. 연료 차감
      await ref
          .read(fuelNotifierProvider.notifier)
          .consumeFuel(amount: requiredFuel, nodeId: planetId);

      // 2. 해금 상태 저장
      final repository = ref.read(explorationRepositoryProvider);
      await repository.unlockPlanet(planetId);

      // 3. 상태 갱신
      _reload();
    } finally {
      _isUnlocking = false;
    }
  }

  /// 상태 새로고침 (지역 해금 후 행성 목록도 갱신)
  void refresh() => _reload();

  void _reload() {
    final repository = ref.read(explorationRepositoryProvider);
    state = repository.getPlanets();
  }
}

/// 특정 행성의 지역 목록 (행성 ID 기반 family)
@riverpod
class RegionListNotifier extends _$RegionListNotifier {
  @override
  List<ExplorationNodeEntity> build(String planetId) {
    final repository = ref.watch(explorationRepositoryProvider);
    return repository.getRegions(planetId);
  }

  bool _isUnlocking = false;

  /// 지역 해금 (연료 소비 + 상태 저장 + 자동 클리어)
  ///
  /// 연료 부족 시 [InsufficientFuelException] throw.
  Future<void> unlockRegion(String regionId, int requiredFuel) async {
    if (_isUnlocking) return;
    _isUnlocking = true;
    try {
      // 1. 연료 차감
      await ref
          .read(fuelNotifierProvider.notifier)
          .consumeFuel(amount: requiredFuel, nodeId: regionId);

      // 2. 해금 + 클리어 상태 저장
      final repository = ref.read(explorationRepositoryProvider);
      await repository.unlockRegion(regionId);

      // 3. 지역 목록 갱신
      state = repository.getRegions(planetId);

      // 4. 행성 목록도 갱신 (자동 클리어 반영)
      ref.read(explorationNotifierProvider.notifier).refresh();
    } finally {
      _isUnlocking = false;
    }
  }
}

/// 특정 행성의 진행도
@riverpod
ExplorationProgressEntity explorationProgress(Ref ref, String planetId) {
  // regionListNotifier를 watch하여 지역 상태 변경 시 자동 갱신
  ref.watch(regionListNotifierProvider(planetId));
  final repository = ref.watch(explorationRepositoryProvider);
  return repository.getProgress(planetId);
}
