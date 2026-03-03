# 프로필 실데이터 연동 + 배지 시스템 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 프로필 화면의 하드코딩된 통계를 실제 데이터로 연결하고, 배지 시스템을 Clean 3-Layer로 구축하여 배지 컬렉션 화면과 해금 알림을 제공한다.

**Architecture:** 기존 fuel/exploration 패턴을 그대로 따름. `features/badge/` 디렉토리에 data/domain/presentation 레이어를 구성하고, SharedPreferences 기반 로컬 저장. 배지 해금 체크는 타이머 세션 종료 시점에서 수행.

**Tech Stack:** Flutter · Riverpod (Generator) · Freezed · SharedPreferences

---

## Task 1: 배지 Domain 레이어 — Entity + Repository 인터페이스

**Files:**
- Create: `lib/features/badge/domain/entities/badge_entity.dart`
- Create: `lib/features/badge/domain/repositories/badge_repository.dart`

**Step 1: BadgeEntity 작성**

```dart
// lib/features/badge/domain/entities/badge_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_entity.freezed.dart';

/// 배지 해금 조건 카테고리
enum BadgeCategory {
  studyTime,    // 공부 시간 기반
  streak,       // 연속 기록 기반
  session,      // 세션 수 기반
  exploration,  // 탐험 기반
  fuel,         // 연료 기반
  hidden,       // 숨겨진 조건
}

/// 배지 희귀도 (core/widgets/space/badge_card.dart의 BadgeRarity와 동일 매핑)
enum BadgeRarity {
  normal,
  rare,
  epic,
  legendary,
  hidden,
}

@freezed
class BadgeEntity with _$BadgeEntity {
  const factory BadgeEntity({
    required String id,
    required String name,
    required String icon,
    required String description,
    required BadgeCategory category,
    required BadgeRarity rarity,
    /// 해금에 필요한 조건값 (예: 60 = 60분, 7 = 7일)
    required int requiredValue,
    @Default(false) bool isUnlocked,
    /// 해금된 시간
    DateTime? unlockedAt,
  }) = _BadgeEntity;
}
```

**Step 2: BadgeRepository 인터페이스 작성**

```dart
// lib/features/badge/domain/repositories/badge_repository.dart
import '../entities/badge_entity.dart';

abstract class BadgeRepository {
  /// 전체 배지 목록 (시드 + 해금 상태 병합)
  List<BadgeEntity> getAllBadges();

  /// 해금된 배지 목록
  List<BadgeEntity> getUnlockedBadges();

  /// 배지 해금 처리
  Future<void> unlockBadge(String badgeId);

  /// 해금 상태 초기화 (로그아웃 시)
  Future<void> clearAll();
}
```

**Step 3: 코드 생성 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 4: 커밋**

```bash
git add lib/features/badge/domain/
git commit -m "feat: 배지 Domain 레이어 (Entity, Repository 인터페이스)"
```

---

## Task 2: 배지 시드 데이터 정의

**Files:**
- Create: `lib/features/badge/data/seed/badge_seed_data.dart`

**Step 1: 시드 데이터 작성**

```dart
// lib/features/badge/data/seed/badge_seed_data.dart
import '../../domain/entities/badge_entity.dart';

/// 배지 시드 데이터
///
/// 정적 배지 정의. 해금 상태는 기본값(false).
class BadgeSeedData {
  BadgeSeedData._();

  static const List<BadgeEntity> badges = [
    // ═══════════════════════════════
    // 공부 시간 기반 (studyTime)
    // ═══════════════════════════════
    BadgeEntity(
      id: 'study_1h',
      name: '첫 발걸음',
      icon: '👣',
      description: '총 1시간 공부 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.normal,
      requiredValue: 60, // 분
    ),
    BadgeEntity(
      id: 'study_10h',
      name: '꾸준한 학습자',
      icon: '📖',
      description: '총 10시간 공부 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.normal,
      requiredValue: 600,
    ),
    BadgeEntity(
      id: 'study_50h',
      name: '지식 탐험가',
      icon: '🔭',
      description: '총 50시간 공부 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.rare,
      requiredValue: 3000,
    ),
    BadgeEntity(
      id: 'study_100h',
      name: '학문의 별',
      icon: '⭐',
      description: '총 100시간 공부 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.rare,
      requiredValue: 6000,
    ),
    BadgeEntity(
      id: 'study_500h',
      name: '우주 학자',
      icon: '🪐',
      description: '총 500시간 공부 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.epic,
      requiredValue: 30000,
    ),
    BadgeEntity(
      id: 'study_1000h',
      name: '은하의 현자',
      icon: '🌌',
      description: '총 1000시간 공부 달성',
      category: BadgeCategory.studyTime,
      rarity: BadgeRarity.legendary,
      requiredValue: 60000,
    ),

    // ═══════════════════════════════
    // 연속 기록 기반 (streak)
    // ═══════════════════════════════
    BadgeEntity(
      id: 'streak_3',
      name: '3일의 약속',
      icon: '🔥',
      description: '3일 연속 공부',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.normal,
      requiredValue: 3,
    ),
    BadgeEntity(
      id: 'streak_7',
      name: '일주일 파일럿',
      icon: '🚀',
      description: '7일 연속 공부',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.normal,
      requiredValue: 7,
    ),
    BadgeEntity(
      id: 'streak_14',
      name: '2주 항해사',
      icon: '⛵',
      description: '14일 연속 공부',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.rare,
      requiredValue: 14,
    ),
    BadgeEntity(
      id: 'streak_30',
      name: '한 달의 궤도',
      icon: '🌙',
      description: '30일 연속 공부',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requiredValue: 30,
    ),
    BadgeEntity(
      id: 'streak_60',
      name: '60일의 항성',
      icon: '☀️',
      description: '60일 연속 공부',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requiredValue: 60,
    ),
    BadgeEntity(
      id: 'streak_100',
      name: '백일의 전설',
      icon: '💫',
      description: '100일 연속 공부',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.legendary,
      requiredValue: 100,
    ),

    // ═══════════════════════════════
    // 세션 수 기반 (session)
    // ═══════════════════════════════
    BadgeEntity(
      id: 'session_1',
      name: '엔진 점화',
      icon: '🎯',
      description: '첫 번째 공부 세션 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.normal,
      requiredValue: 1,
    ),
    BadgeEntity(
      id: 'session_10',
      name: '열 번의 비행',
      icon: '✈️',
      description: '10회 공부 세션 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.normal,
      requiredValue: 10,
    ),
    BadgeEntity(
      id: 'session_50',
      name: '반백의 여정',
      icon: '🛸',
      description: '50회 공부 세션 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.rare,
      requiredValue: 50,
    ),
    BadgeEntity(
      id: 'session_100',
      name: '백전백승',
      icon: '🏅',
      description: '100회 공부 세션 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.rare,
      requiredValue: 100,
    ),
    BadgeEntity(
      id: 'session_500',
      name: '전설의 조종사',
      icon: '👨‍🚀',
      description: '500회 공부 세션 완료',
      category: BadgeCategory.session,
      rarity: BadgeRarity.epic,
      requiredValue: 500,
    ),

    // ═══════════════════════════════
    // 탐험 기반 (exploration)
    // ═══════════════════════════════
    BadgeEntity(
      id: 'explore_first_planet',
      name: '우주의 문',
      icon: '🌍',
      description: '첫 번째 행성 외 행성 해금',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.normal,
      requiredValue: 2, // 해금된 행성 수 (지구 포함)
    ),
    BadgeEntity(
      id: 'explore_all_planets',
      name: '태양계 정복자',
      icon: '🏆',
      description: '모든 행성 해금',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.epic,
      requiredValue: 4, // 전체 행성 수
    ),
    BadgeEntity(
      id: 'explore_first_region',
      name: '첫 탐사',
      icon: '🗺️',
      description: '첫 번째 지역 해금 (대한민국 제외)',
      category: BadgeCategory.exploration,
      rarity: BadgeRarity.normal,
      requiredValue: 2, // 해금된 지역 수 (대한민국 포함)
    ),

    // ═══════════════════════════════
    // 연료 기반 (fuel)
    // ═══════════════════════════════
    BadgeEntity(
      id: 'fuel_10',
      name: '연료 수집가',
      icon: '⛽',
      description: '총 10통 연료 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.normal,
      requiredValue: 10,
    ),
    BadgeEntity(
      id: 'fuel_50',
      name: '연료 비축대장',
      icon: '🛢️',
      description: '총 50통 연료 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.rare,
      requiredValue: 50,
    ),
    BadgeEntity(
      id: 'fuel_100',
      name: '에너지 마스터',
      icon: '⚡',
      description: '총 100통 연료 충전',
      category: BadgeCategory.fuel,
      rarity: BadgeRarity.epic,
      requiredValue: 100,
    ),

    // ═══════════════════════════════
    // 히든 (hidden)
    // ═══════════════════════════════
    BadgeEntity(
      id: 'hidden_night_owl',
      name: '올빼미',
      icon: '🦉',
      description: '새벽 3시에 공부 세션 진행',
      category: BadgeCategory.hidden,
      rarity: BadgeRarity.hidden,
      requiredValue: 3, // 시간 (24h)
    ),
    BadgeEntity(
      id: 'hidden_early_bird',
      name: '얼리버드',
      icon: '🐦',
      description: '오전 5시에 공부 세션 진행',
      category: BadgeCategory.hidden,
      rarity: BadgeRarity.hidden,
      requiredValue: 5, // 시간 (24h)
    ),
  ];
}
```

**Step 2: 커밋**

```bash
git add lib/features/badge/data/seed/
git commit -m "feat: 배지 시드 데이터 정의 (25개 배지)"
```

---

## Task 3: 배지 Data 레이어 — Model + DataSource + Repository 구현체

**Files:**
- Create: `lib/features/badge/data/models/badge_model.dart`
- Create: `lib/features/badge/data/datasources/badge_local_datasource.dart`
- Create: `lib/features/badge/data/repositories/badge_repository_impl.dart`

**Step 1: BadgeModel 작성**

```dart
// lib/features/badge/data/models/badge_model.dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

/// 배지 해금 상태 저장용 모델 (SharedPreferences JSON)
///
/// 시드 데이터에 없는 필드만 저장 (해금 여부, 해금 시간, 신규 여부)
@freezed
class BadgeUnlockModel with _$BadgeUnlockModel {
  const factory BadgeUnlockModel({
    @JsonKey(name: 'badge_id') required String badgeId,
    @JsonKey(name: 'unlocked_at') required DateTime unlockedAt,
    @Default(true) @JsonKey(name: 'is_new') bool isNew,
  }) = _BadgeUnlockModel;

  factory BadgeUnlockModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeUnlockModelFromJson(json);
}
```

**Step 2: BadgeLocalDataSource 작성**

```dart
// lib/features/badge/data/datasources/badge_local_datasource.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge_model.dart';

class BadgeLocalDataSource {
  static const _unlockedKey = 'badge_unlocked_data';

  final SharedPreferences _prefs;

  BadgeLocalDataSource(this._prefs);

  /// 해금된 배지 ID → UnlockModel 맵
  Map<String, BadgeUnlockModel> getUnlockedBadges() {
    final jsonString = _prefs.getString(_unlockedKey);
    if (jsonString == null) return {};

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final models = jsonList
          .map((e) => BadgeUnlockModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return {for (final m in models) m.badgeId: m};
    } catch (e) {
      debugPrint('⚠️ Badge 데이터 파싱 실패, 초기화합니다: $e');
      _prefs.remove(_unlockedKey);
      return {};
    }
  }

  /// 배지 해금 저장
  Future<void> unlockBadge(BadgeUnlockModel model) async {
    final current = getUnlockedBadges();
    current[model.badgeId] = model;
    await _saveAll(current.values.toList());
  }

  /// 신규 표시 제거
  Future<void> markSeen(String badgeId) async {
    final current = getUnlockedBadges();
    final model = current[badgeId];
    if (model != null && model.isNew) {
      current[badgeId] = model.copyWith(isNew: false);
      await _saveAll(current.values.toList());
    }
  }

  /// 전체 초기화
  Future<void> clearAll() async {
    await _prefs.remove(_unlockedKey);
    debugPrint('🧹 Badge 캐시 삭제 완료');
  }

  Future<void> _saveAll(List<BadgeUnlockModel> models) async {
    final jsonString = jsonEncode(models.map((e) => e.toJson()).toList());
    await _prefs.setString(_unlockedKey, jsonString);
  }
}
```

**Step 3: BadgeRepositoryImpl 작성**

```dart
// lib/features/badge/data/repositories/badge_repository_impl.dart
import '../../domain/entities/badge_entity.dart';
import '../../domain/repositories/badge_repository.dart';
import '../datasources/badge_local_datasource.dart';
import '../models/badge_model.dart';
import '../seed/badge_seed_data.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeLocalDataSource _localDataSource;

  BadgeRepositoryImpl(this._localDataSource);

  @override
  List<BadgeEntity> getAllBadges() {
    final unlocked = _localDataSource.getUnlockedBadges();
    return BadgeSeedData.badges.map((badge) {
      final unlock = unlocked[badge.id];
      if (unlock != null) {
        return badge.copyWith(
          isUnlocked: true,
          unlockedAt: unlock.unlockedAt,
        );
      }
      return badge;
    }).toList();
  }

  @override
  List<BadgeEntity> getUnlockedBadges() {
    return getAllBadges().where((b) => b.isUnlocked).toList();
  }

  @override
  Future<void> unlockBadge(String badgeId) async {
    final unlocked = _localDataSource.getUnlockedBadges();
    if (unlocked.containsKey(badgeId)) return; // 이미 해금됨

    await _localDataSource.unlockBadge(
      BadgeUnlockModel(
        badgeId: badgeId,
        unlockedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }
}
```

**Step 4: 코드 생성 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 5: 커밋**

```bash
git add lib/features/badge/data/
git commit -m "feat: 배지 Data 레이어 (Model, DataSource, Repository)"
```

---

## Task 4: 배지 Provider + 해금 체크 로직

**Files:**
- Create: `lib/features/badge/presentation/providers/badge_provider.dart`

**Step 1: Badge Provider 작성**

```dart
// lib/features/badge/presentation/providers/badge_provider.dart
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
        // id로 행성/지역 구분
        if (badge.id.contains('planet')) return unlockedPlanets >= badge.requiredValue;
        if (badge.id.contains('region')) return unlockedRegions >= badge.requiredValue;
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
```

**Step 2: 코드 생성 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 3: 커밋**

```bash
git add lib/features/badge/presentation/
git commit -m "feat: 배지 Provider + 해금 체크 로직"
```

---

## Task 5: main.dart에 BadgeLocalDataSource 등록

**Files:**
- Modify: `lib/main.dart`

**Step 1: import 추가 + ProviderScope override 추가**

`main.dart`의 import 영역에 추가:
```dart
import 'features/badge/data/datasources/badge_local_datasource.dart';
import 'features/badge/presentation/providers/badge_provider.dart';
```

`ProviderScope.overrides`에 추가:
```dart
if (prefs != null)
  badgeLocalDataSourceProvider.overrideWithValue(
    BadgeLocalDataSource(prefs),
  ),
```

**Step 2: 커밋**

```bash
git add lib/main.dart
git commit -m "feat: main.dart에 BadgeLocalDataSource 등록"
```

---

## Task 6: 타이머 종료 시 배지 체크 연동

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_provider.dart`

**Step 1: import 추가**

```dart
import '../../../badge/presentation/providers/badge_provider.dart';
```

**Step 2: stop() 메서드에 배지 체크 추가**

`stop()` 메서드의 세션 저장 + 연료 충전 로직 뒤, `finally` 블록 전에 배지 체크를 추가:

```dart
// 배지 해금 체크
final newBadges = await ref
    .read(badgeNotifierProvider.notifier)
    .checkAndUnlock();
```

`stop()` 반환 타입에 `newBadges` 추가:

기존 반환 타입:
```dart
Future<({Duration sessionDuration, String? todoTitle, int? totalMinutes})?>
```

변경 후:
```dart
Future<({Duration sessionDuration, String? todoTitle, int? totalMinutes, List<BadgeEntity> newBadges})?>
```

반환값에도 추가:
```dart
return sessionDuration.inMinutes >= 1
    ? (
        sessionDuration: sessionDuration,
        todoTitle: todoTitle,
        totalMinutes: totalMinutes,
        newBadges: newBadges,
      )
    : null;
```

import도 필요:
```dart
import '../../domain/entities/badge_entity.dart'; // 상대경로 조정 필요
```

실제로는 `BadgeEntity`를 직접 import하지 않고 provider에서 간접 참조. 반환 타입에 `List` 사용:

```dart
import '../../../badge/domain/entities/badge_entity.dart';
```

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/providers/timer_provider.dart
git commit -m "feat: 타이머 종료 시 배지 해금 체크 연동"
```

---

## Task 7: 타이머 화면에서 배지 해금 팝업 표시

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart`

**Step 1: `_onStop()`에서 새 배지 처리**

기존 `_onStop`:
```dart
Future<void> _onStop() async {
  final result = await ref.read(timerNotifierProvider.notifier).stop();
  if (!mounted || result == null) return;
  _showResultDialog(result);
}
```

변경 후:
```dart
Future<void> _onStop() async {
  final result = await ref.read(timerNotifierProvider.notifier).stop();
  if (!mounted || result == null) return;
  _showResultDialog(result);

  // 새로 해금된 배지가 있으면 결과 다이얼로그 닫힌 후 배지 팝업
  if (result.newBadges.isNotEmpty) {
    // 약간의 딜레이로 결과 다이얼로그와 겹치지 않게
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    for (final badge in result.newBadges) {
      await _showBadgeUnlockDialog(badge);
      if (!mounted) return;
    }
  }
}
```

**Step 2: 배지 해금 다이얼로그 메서드 추가**

```dart
Future<void> _showBadgeUnlockDialog(BadgeEntity badge) async {
  await AppDialog.show(
    context: context,
    title: '배지 획득!',
    emotion: AppDialogEmotion.success,
    customContent: Column(
      children: [
        Text(badge.icon, style: TextStyle(fontSize: 48.sp)),
        SizedBox(height: AppSpacing.s12),
        Text(
          badge.name,
          style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.s8),
        Text(
          badge.description,
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
```

**Step 3: import 추가**

```dart
import '../../../badge/domain/entities/badge_entity.dart';
```

**Step 4: `_showResultDialog` 반환 타입 매개변수도 업데이트**

`_showResultDialog`의 매개변수 타입을 `stop()` 반환 타입과 일치시킴:

```dart
void _showResultDialog(
  ({Duration sessionDuration, String? todoTitle, int? totalMinutes, List<BadgeEntity> newBadges}) result,
)
```

**Step 5: 커밋**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "feat: 타이머 종료 시 배지 해금 축하 팝업"
```

---

## Task 8: 배지 컬렉션 화면 구현

**Files:**
- Create: `lib/features/badge/presentation/screens/badge_collection_screen.dart`

**Step 1: 배지 컬렉션 화면 작성**

```dart
// lib/features/badge/presentation/screens/badge_collection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/space/badge_card.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../domain/entities/badge_entity.dart';
import '../providers/badge_provider.dart';

class BadgeCollectionScreen extends ConsumerWidget {
  const BadgeCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgeNotifierProvider);
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '배지 컬렉션',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: badges.isEmpty
                ? const Center(
                    child: SpaceEmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: '배지가 없어요',
                      subtitle: '공부를 시작하면 배지를 얻을 수 있어요',
                    ),
                  )
                : SingleChildScrollView(
                    padding: AppPadding.all20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unlockedCount / ${badges.length} 획득',
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.s20),
                        // 카테고리별 그룹
                        ..._buildCategoryGroups(context, badges),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryGroups(
    BuildContext context,
    List<BadgeEntity> badges,
  ) {
    final categories = [
      (BadgeCategory.studyTime, '공부 시간'),
      (BadgeCategory.streak, '연속 기록'),
      (BadgeCategory.session, '세션'),
      (BadgeCategory.exploration, '탐험'),
      (BadgeCategory.fuel, '연료'),
      (BadgeCategory.hidden, '히든'),
    ];

    final widgets = <Widget>[];
    for (final (category, label) in categories) {
      final group = badges.where((b) => b.category == category).toList();
      if (group.isEmpty) continue;

      widgets.add(
        Text(
          label,
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
      );
      widgets.add(SizedBox(height: AppSpacing.s12));
      widgets.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppSpacing.s8,
            mainAxisSpacing: AppSpacing.s8,
            childAspectRatio: 0.75,
          ),
          itemCount: group.length,
          itemBuilder: (context, index) {
            final badge = group[index];
            return BadgeCard(
              icon: badge.icon,
              name: badge.name,
              isUnlocked: badge.isUnlocked,
              rarity: _mapRarity(badge.rarity),
              description: badge.description,
              onTap: () => _showBadgeDetail(context, badge),
            );
          },
        ),
      );
      widgets.add(SizedBox(height: AppSpacing.s24));
    }
    return widgets;
  }

  BadgeRarity _mapRarity(BadgeRarity rarity) {
    // BadgeEntity의 BadgeRarity와 BadgeCard의 BadgeRarity 이름이 동일
    // 다른 패키지이므로 매핑 필요
    switch (rarity) {
      case BadgeRarity.normal:
        return BadgeRarity.normal;
      case BadgeRarity.rare:
        return BadgeRarity.rare;
      case BadgeRarity.epic:
        return BadgeRarity.epic;
      case BadgeRarity.legendary:
        return BadgeRarity.legendary;
      case BadgeRarity.hidden:
        return BadgeRarity.hidden;
    }
  }

  void _showBadgeDetail(BuildContext context, BadgeEntity badge) {
    AppDialog.show(
      context: context,
      title: badge.isUnlocked ? badge.name : '???',
      customContent: Column(
        children: [
          Text(
            badge.isUnlocked ? badge.icon : '🔒',
            style: TextStyle(fontSize: 48.sp),
          ),
          SizedBox(height: AppSpacing.s12),
          Text(
            badge.isUnlocked ? badge.description : '아직 해금되지 않은 배지예요',
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

**주의:** `BadgeRarity`가 `badge_entity.dart`와 `badge_card.dart`에 별도로 정의되어 있음. 구현 시 `badge_card.dart`의 `BadgeRarity`를 사용하고, `badge_entity.dart`의 enum은 동일 이름이므로 import alias 또는 badge_card.dart의 enum을 domain에서도 공유하는 방식으로 해결. **실제 구현 시 `badge_card.dart`의 `BadgeRarity`를 domain entity에서 import하여 단일 enum으로 통합하는 것이 바람직.**

**Step 2: 커밋**

```bash
git add lib/features/badge/presentation/screens/
git commit -m "feat: 배지 컬렉션 화면 구현"
```

---

## Task 9: 라우트 연결 — PlaceholderScreen을 배지 컬렉션으로 교체

**Files:**
- Modify: `lib/routes/app_router.dart`

**Step 1: import 추가**

```dart
import '../features/badge/presentation/screens/badge_collection_screen.dart';
```

**Step 2: badges 라우트의 builder를 교체**

기존:
```dart
builder: (context, state) =>
    const PlaceholderScreen(title: '배지 컬렉션'),
```

변경:
```dart
builder: (context, state) =>
    const BadgeCollectionScreen(),
```

**Step 3: 커밋**

```bash
git add lib/routes/app_router.dart
git commit -m "feat: 배지 컬렉션 라우트 연결 (Placeholder 교체)"
```

---

## Task 10: 프로필 화면 실데이터 연동

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`

**Step 1: import 추가**

```dart
import '../../../timer/presentation/providers/study_stats_provider.dart';
import '../../../timer/presentation/utils/timer_format_utils.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
```

**Step 2: `_buildStatsCard()`를 Consumer로 감싸서 실데이터 연결**

기존 `_buildStatsCard()` 호출 부분:
```dart
_buildStatsCard(),
```

변경:
```dart
Consumer(
  builder: (context, ref, _) {
    final totalMinutes = ref.watch(totalStudyMinutesProvider);
    final streak = ref.watch(currentStreakProvider);
    final unlockedBadges = ref.watch(unlockedBadgeCountProvider);
    return _buildStatsCard(
      studyTime: formatMinutes(totalMinutes),
      streak: '$streak일',
      badgeCount: '$unlockedBadges개',
    );
  },
),
```

**Step 3: `_buildStatsCard` 메서드 시그니처 변경**

기존:
```dart
Widget _buildStatsCard() {
```

변경:
```dart
Widget _buildStatsCard({
  required String studyTime,
  required String streak,
  required String badgeCount,
}) {
```

내부 하드코딩 값도 변경:
```dart
SpaceStatItem(label: '총 공부', value: studyTime, valueFirst: true),
// ...
SpaceStatItem(label: '연속', value: streak, valueFirst: true),
// ...
SpaceStatItem(label: '배지', value: badgeCount, valueFirst: true),
```

**Step 4: 커밋**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "feat: 프로필 화면 통계 실데이터 연동"
```

---

## Task 11: 탐험 해금 시에도 배지 체크

**Files:**
- Modify: `lib/features/exploration/presentation/providers/exploration_provider.dart`

**Step 1: import 추가**

```dart
import '../../../badge/presentation/providers/badge_provider.dart';
```

**Step 2: `unlockPlanet` 메서드 끝에 배지 체크 추가**

`_reload()` 직후, `finally` 블록 전에:

```dart
// 배지 해금 체크 (탐험 기반)
ref.read(badgeNotifierProvider.notifier).checkAndUnlock();
```

**Step 3: `RegionListNotifier.unlockRegion`에도 동일하게 추가**

`ref.read(explorationNotifierProvider.notifier).refresh()` 직후:

```dart
// 배지 해금 체크 (탐험 기반)
ref.read(badgeNotifierProvider.notifier).checkAndUnlock();
```

**참고:** 탐험 해금 시의 배지 팝업은 이번 스코프에서는 타이머처럼 자동 팝업하지 않고, 컬렉션의 "New" 표시로 대체. 탐험 UI에 팝업을 추가하려면 별도 작업 필요.

**Step 4: 커밋**

```bash
git add lib/features/exploration/presentation/providers/exploration_provider.dart
git commit -m "feat: 탐험 해금 시 배지 체크 연동"
```

---

## Task 12: BadgeRarity enum 통합 + 최종 정리

**Files:**
- Modify: `lib/core/widgets/space/badge_card.dart` — 자체 `BadgeRarity` enum 제거, domain entity에서 import
- Modify: `lib/features/badge/domain/entities/badge_entity.dart` — 필요 시 조정
- Modify: `lib/features/profile/presentation/screens/spaceship_collection_screen.dart` — BadgeRarity import 경로 변경 (사용 중인 경우)

**Step 1: `BadgeRarity` enum을 domain entity에서 단일 정의**

`badge_card.dart`의 `BadgeRarity` enum을 제거하고, `badge_entity.dart`의 것을 import하도록 변경.

`badge_card.dart` 변경:
```dart
import '../../../features/badge/domain/entities/badge_entity.dart';
// BadgeRarity enum 정의 제거 (badge_entity.dart에서 가져옴)
```

**Step 2: `badge_card.dart`를 사용하는 모든 파일에서 BadgeRarity import 확인**

- `badge_collection_screen.dart` — entity import로 충분
- `spaceship_collection_screen.dart` — SpaceshipRarity 사용, 영향 없음

**Step 3: 코드 생성 + 분석**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Run: `flutter analyze`

**Step 4: 커밋**

```bash
git add lib/core/widgets/space/badge_card.dart lib/features/badge/
git commit -m "refactor: BadgeRarity enum 단일 소스로 통합"
```

---

## Task 13: flutter analyze 통과 확인 + 최종 커밋

**Step 1: 분석 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 문제 있으면 수정 후 커밋**

```bash
git add -A
git commit -m "fix: flutter analyze 이슈 수정"
```

---

## 구현 순서 요약

| Task | 내용 | 의존 |
|------|------|------|
| 1 | Domain 레이어 (Entity, Repository) | 없음 |
| 2 | 시드 데이터 | Task 1 |
| 3 | Data 레이어 (Model, DataSource, Repo Impl) | Task 1, 2 |
| 4 | Provider + 해금 체크 로직 | Task 3 |
| 5 | main.dart 등록 | Task 4 |
| 6 | 타이머 종료 시 배지 체크 연동 | Task 4 |
| 7 | 배지 해금 팝업 | Task 6 |
| 8 | 배지 컬렉션 화면 | Task 4 |
| 9 | 라우트 연결 | Task 8 |
| 10 | 프로필 화면 실데이터 연동 | Task 4 |
| 11 | 탐험 해금 시 배지 체크 | Task 4 |
| 12 | BadgeRarity enum 통합 | Task 8 |
| 13 | 최종 분석 + 정리 | 전체 |
