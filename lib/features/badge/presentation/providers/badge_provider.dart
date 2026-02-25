import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/badge_local_datasource.dart';
import '../../data/repositories/badge_repository_impl.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/repositories/badge_repository.dart';
import '../../../timer/presentation/providers/study_stats_provider.dart';
import '../../../timer/presentation/providers/timer_session_provider.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../../exploration/presentation/providers/exploration_provider.dart';

part 'badge_provider.g.dart';

// === DataSource & Repository ===

@Riverpod(keepAlive: true)
BadgeLocalDataSource badgeLocalDataSource(Ref ref) {
  throw StateError(
    'BadgeLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@Riverpod(keepAlive: true)
BadgeRepository badgeRepository(Ref ref) {
  final dataSource = ref.watch(badgeLocalDataSourceProvider);
  return BadgeRepositoryImpl(dataSource);
}

// === Badge State ===

@Riverpod(keepAlive: true)
class BadgeNotifier extends _$BadgeNotifier {
  @override
  List<BadgeEntity> build() {
    final repository = ref.watch(badgeRepositoryProvider);
    return repository.getAllBadges();
  }

  /// 통계 기반 배지 해금 체크
  ///
  /// 타이머 세션 종료 시 호출.
  /// 반환: 새로 해금된 배지 목록 (팝업 표시용)
  Future<List<BadgeEntity>> checkAndUnlock() async {
    final repository = ref.read(badgeRepositoryProvider);
    final currentBadges = repository.getAllBadges();
    final locked = currentBadges.where((b) => !b.isUnlocked).toList();

    if (locked.isEmpty) return [];

    // 현재 통계 수집
    final totalMinutes = ref.read(totalStudyMinutesProvider);
    final streak = ref.read(currentStreakProvider);
    final sessionCount = ref.read(totalSessionCountProvider);
    final fuelState = ref.read(fuelNotifierProvider);
    final planets = ref.read(explorationNotifierProvider);
    final unlockedPlanets = planets.where((p) => p.isUnlocked).length;

    // 지역 해금 수 계산
    int unlockedRegions = 0;
    for (final planet in planets) {
      final regions = ref.read(regionListNotifierProvider(planet.id));
      unlockedRegions += regions.where((r) => r.isUnlocked).length;
    }

    // 히든 배지: 현재 시간 체크
    final currentHour = DateTime.now().hour;

    // 세션 목록 (히든 배지 체크용)
    final sessions = ref.read(timerSessionListNotifierProvider);

    final newlyUnlocked = <BadgeEntity>[];

    for (final badge in locked) {
      final shouldUnlock = _checkCondition(
        badge: badge,
        totalMinutes: totalMinutes,
        streak: streak,
        sessionCount: sessionCount,
        totalCharged: fuelState.totalCharged,
        unlockedPlanets: unlockedPlanets,
        unlockedRegions: unlockedRegions,
        currentHour: currentHour,
        hasSessionAtHour: (int hour) => sessions.any(
          (s) => s.startedAt.hour == hour || s.endedAt.hour == hour,
        ),
      );

      if (shouldUnlock) {
        await repository.unlockBadge(badge.id);
        newlyUnlocked.add(badge);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      state = repository.getAllBadges();
    }

    return newlyUnlocked;
  }

  bool _checkCondition({
    required BadgeEntity badge,
    required int totalMinutes,
    required int streak,
    required int sessionCount,
    required int totalCharged,
    required int unlockedPlanets,
    required int unlockedRegions,
    required int currentHour,
    required bool Function(int hour) hasSessionAtHour,
  }) {
    switch (badge.category) {
      case BadgeCategory.studyTime:
        return totalMinutes >= badge.requiredValue;
      case BadgeCategory.streak:
        return streak >= badge.requiredValue;
      case BadgeCategory.session:
        return sessionCount >= badge.requiredValue;
      case BadgeCategory.exploration:
        if (badge.id.contains('planet')) {
          return unlockedPlanets >= badge.requiredValue;
        }
        if (badge.id.contains('region')) {
          return unlockedRegions >= badge.requiredValue;
        }
        return false;
      case BadgeCategory.fuel:
        return totalCharged >= badge.requiredValue;
      case BadgeCategory.hidden:
        return hasSessionAtHour(badge.requiredValue);
    }
  }
}

// === Convenience Providers ===

/// 해금된 배지 수
@riverpod
int unlockedBadgeCount(Ref ref) {
  return ref.watch(badgeNotifierProvider).where((b) => b.isUnlocked).length;
}

/// 전체 배지 수
@riverpod
int totalBadgeCount(Ref ref) {
  return ref.watch(badgeNotifierProvider).length;
}

/// 신규(New) 배지 존재 여부
@riverpod
bool hasNewBadge(Ref ref) {
  final dataSource = ref.watch(badgeLocalDataSourceProvider);
  final unlocked = dataSource.getUnlockedBadges();
  return unlocked.values.any((m) => m.isNew);
}
