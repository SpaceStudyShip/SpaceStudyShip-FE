# 탐험 해금 상태 영속화 + 게스트/소셜 로그인 분리 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 탐험 노드(행성/지역) 해금 상태를 영속화하고, 게스트 모드는 지구 탐험만 허용하며, 소셜 로그인 시 백엔드 API 연동이 바로 가능한 Clean Architecture를 구축한다.

**Architecture:** Domain 레이어에 `ExplorationRepository` 인터페이스를 두고, 게스트용 `ExplorationLocalRepositoryImpl`(SharedPreferences)을 구현한다. Provider에서 `isGuestProvider`를 확인하여 게스트는 지구만 탐험 가능하도록 필터링한다. 향후 소셜 로그인 시 `ExplorationRemoteRepositoryImpl`(Retrofit)으로 교체만 하면 되는 구조.

**Tech Stack:** Flutter, Riverpod Generator, SharedPreferences, 기존 ExplorationNodeEntity 재사용

---

## 핵심 설계 결정

### 1. 게스트 vs 소셜 로그인 분리 전략

| 구분 | 게스트 모드 | 소셜 로그인 (향후) |
|------|-----------|------------------|
| 데이터 소스 | SharedPreferences (로컬) | 백엔드 API (Retrofit) |
| 탐험 범위 | 지구 행성만 | 전체 태양계 |
| Repository | `ExplorationLocalRepositoryImpl` | `ExplorationRemoteRepositoryImpl` (미구현) |
| 시드 데이터 | Dart 상수 (`seed_data.dart`) | 서버 응답 |
| 상태 저장 | SharedPreferences JSON | 서버 DB |

### 2. Repository 스왑 패턴 (기존 fuel 시스템과 동일)

```
Domain:  ExplorationRepository (abstract interface)
           ↑                        ↑
Data:    ExplorationLocalRepoImpl  ExplorationRemoteRepoImpl (향후)
           ↓                        ↓
         SharedPreferences         Retrofit API
```

Provider에서 `isGuestProvider`로 분기:
```dart
@riverpod
ExplorationRepository explorationRepository(Ref ref) {
  final isGuest = ref.watch(isGuestProvider);
  if (isGuest) {
    return ExplorationLocalRepositoryImpl(ref.watch(explorationLocalDataSourceProvider));
  }
  // 향후: return ExplorationRemoteRepositoryImpl(ref.watch(explorationRemoteDataSourceProvider));
  // 현재: 소셜 로그인도 로컬 사용 (백엔드 미연동)
  return ExplorationLocalRepositoryImpl(ref.watch(explorationLocalDataSourceProvider));
}
```

### 3. 게스트 지구 제한 — Provider 레이어 필터링

Repository는 auth-agnostic (인증 상태를 모름). Provider에서 게스트 여부를 확인하여 행성 목록을 필터링:

```dart
// ExplorationNotifier.build()
final allPlanets = repository.getPlanets();
final isGuest = ref.watch(isGuestProvider);
if (isGuest) {
  return allPlanets.where((p) => p.id == 'earth').toList();
}
return allPlanets;
```

**이유:** Repository에 인증 로직을 넣지 않아 관심사 분리 유지. 백엔드 연동 시 서버가 접근 가능한 행성만 반환하므로 이 필터 제거.

### 4. 시드 데이터 vs 영속 데이터 분리

| 구분 | 데이터 | 저장 위치 |
|------|--------|----------|
| 시드(정적) | id, name, icon, requiredFuel, parentId, depth, sortOrder, description, mapX, mapY | Dart 상수 (seed_data.dart) |
| 상태(변동) | isUnlocked, isCleared, unlockedAt | SharedPreferences (JSON) |

### 5. 지구 지역 확장 (게스트 콘텐츠 충실화)

기존 5개 → 12개 지역으로 확대. 총 필요 연료 ~23통.

| 지역 | 국기 | 연료 | 대륙 | 설명 |
|------|------|------|------|------|
| 대한민국 | KR | 0 (시작) | 아시아 | 시작 지역 |
| 일본 | JP | 1 | 아시아 | - |
| 태국 | TH | 1 | 아시아 | - |
| 중국 | CN | 2 | 아시아 | - |
| 인도 | IN | 2 | 아시아 | - |
| 영국 | GB | 2 | 유럽 | - |
| 프랑스 | FR | 2 | 유럽 | - |
| 캐나다 | CA | 2 | 북미 | - |
| 미국 | US | 3 | 북미 | - |
| 브라질 | BR | 3 | 남미 | - |
| 호주 | AU | 3 | 오세아니아 | - |
| 이집트 | EG | 2 | 아프리카 | - |

### 6. 해금 플로우

```
사용자 "해금" 탭
  → ExplorationNotifier.unlockRegion(regionId, requiredFuel)
    → FuelNotifier.consumeFuel(amount, nodeId)  // 연료 차감 (기존)
    → ExplorationLocalDataSource.saveNodeState(id, unlocked+cleared)  // 상태 저장
    → state 갱신 → UI 리빌드
    → 모든 지역 클리어 시 → 부모 행성 자동 클리어
```

---

## 변경 파일 목록

### 신규 생성 (6개 소스 + 1개 생성파일)
| 파일 | 역할 |
|------|------|
| `exploration/data/datasources/exploration_local_datasource.dart` | SharedPreferences CRUD (ExplorationNodeState 포함) |
| `exploration/data/repositories/exploration_repository_impl.dart` | 시드 + 영속 상태 머지 |
| `exploration/data/seed/exploration_seed_data.dart` | 정적 노드 정의 (지구 12개 지역 포함) |
| `exploration/domain/repositories/exploration_repository.dart` | Repository 인터페이스 |
| `exploration/presentation/providers/exploration_provider.dart` | Riverpod Notifier (게스트 필터링 포함) |
| `exploration/presentation/providers/exploration_provider.g.dart` | build_runner 생성 |

### 수정 (4개)
| 파일 | 변경 |
|------|------|
| `exploration/presentation/screens/exploration_detail_screen.dart` | 샘플 데이터 → Provider 연결, handleUnlock → Notifier 호출 |
| `explore/presentation/screens/explore_screen.dart` | 샘플 데이터 → Provider 연결 |
| `auth/presentation/providers/auth_provider.dart` | 게스트 로그인/로그아웃 시 exploration clearAll + invalidate 추가 |
| `main.dart` | ExplorationLocalDataSource 초기화 (ProviderScope override) |

---

## Task 1: 시드 데이터 파일 생성

기존 `explore_screen.dart`와 `exploration_detail_screen.dart`에 흩어진 샘플 데이터를 하나의 시드 파일로 통합. 지구 지역을 12개로 확대.

**Files:**
- Create: `lib/features/exploration/data/seed/exploration_seed_data.dart`

**Step 1: 시드 데이터 파일 작성**

```dart
import '../../domain/entities/exploration_node_entity.dart';

/// 탐험 노드 시드 데이터
///
/// 정적 노드 정의. 해금/클리어 상태는 기본값(false).
/// 서버 연동 시 API 응답으로 교체 예정.
class ExplorationSeedData {
  ExplorationSeedData._();

  static const List<ExplorationNodeEntity> planets = [
    ExplorationNodeEntity(
      id: 'earth',
      name: '지구',
      nodeType: ExplorationNodeType.planet,
      depth: 2,
      icon: '🌍',
      requiredFuel: 0,
      isUnlocked: true, // 시작 행성
      sortOrder: 0,
      description: '우리의 출발지, 고향 행성',
      mapX: 0.5,
      mapY: 0.08,
    ),
    ExplorationNodeEntity(
      id: 'moon',
      name: '달',
      nodeType: ExplorationNodeType.planet,
      depth: 2,
      icon: '🌙',
      requiredFuel: 5,
      sortOrder: 1,
      description: '지구의 유일한 자연 위성',
      mapX: 0.15,
      mapY: 0.30,
    ),
    ExplorationNodeEntity(
      id: 'mars',
      name: '화성',
      nodeType: ExplorationNodeType.planet,
      depth: 2,
      icon: '🔴',
      requiredFuel: 15,
      sortOrder: 2,
      description: '붉은 행성, 탐험의 꿈',
      mapX: 0.75,
      mapY: 0.55,
    ),
    ExplorationNodeEntity(
      id: 'jupiter',
      name: '목성',
      nodeType: ExplorationNodeType.planet,
      depth: 2,
      icon: '🟤',
      requiredFuel: 30,
      sortOrder: 3,
      description: '태양계 최대의 가스 행성',
      mapX: 0.3,
      mapY: 0.78,
    ),
  ];

  static const Map<String, List<ExplorationNodeEntity>> regions = {
    'earth': [
      // === 아시아 ===
      ExplorationNodeEntity(
        id: 'korea',
        name: '대한민국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'KR',
        parentId: 'earth',
        requiredFuel: 0,
        isUnlocked: true,
        isCleared: true, // 시작 지역
        sortOrder: 0,
        description: '한반도 남쪽, K-컬쳐의 중심',
      ),
      ExplorationNodeEntity(
        id: 'japan',
        name: '일본',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'JP',
        parentId: 'earth',
        requiredFuel: 1,
        sortOrder: 1,
        description: '벚꽃과 기술의 나라',
      ),
      ExplorationNodeEntity(
        id: 'thailand',
        name: '태국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'TH',
        parentId: 'earth',
        requiredFuel: 1,
        sortOrder: 2,
        description: '미소의 나라, 동남아의 허브',
      ),
      ExplorationNodeEntity(
        id: 'china',
        name: '중국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'CN',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 3,
        description: '세계 최대 인구 대국',
      ),
      ExplorationNodeEntity(
        id: 'india',
        name: '인도',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'IN',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 4,
        description: 'IT 강국, 다양한 문화의 보고',
      ),
      // === 유럽 ===
      ExplorationNodeEntity(
        id: 'uk',
        name: '영국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'GB',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 5,
        description: '해가 지지 않는 나라',
      ),
      ExplorationNodeEntity(
        id: 'france',
        name: '프랑스',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'FR',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 6,
        description: '예술과 낭만의 나라',
      ),
      // === 북미 ===
      ExplorationNodeEntity(
        id: 'canada',
        name: '캐나다',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'CA',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 7,
        description: '단풍과 자연의 나라',
      ),
      ExplorationNodeEntity(
        id: 'usa',
        name: '미국',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'US',
        parentId: 'earth',
        requiredFuel: 3,
        sortOrder: 8,
        description: '자유의 나라, 기회의 땅',
      ),
      // === 남미 ===
      ExplorationNodeEntity(
        id: 'brazil',
        name: '브라질',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'BR',
        parentId: 'earth',
        requiredFuel: 3,
        sortOrder: 9,
        description: '삼바와 축구의 나라',
      ),
      // === 오세아니아 ===
      ExplorationNodeEntity(
        id: 'australia',
        name: '호주',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'AU',
        parentId: 'earth',
        requiredFuel: 3,
        sortOrder: 10,
        description: '코알라와 캥거루의 대륙',
      ),
      // === 아프리카 ===
      ExplorationNodeEntity(
        id: 'egypt',
        name: '이집트',
        nodeType: ExplorationNodeType.region,
        depth: 3,
        icon: 'EG',
        parentId: 'earth',
        requiredFuel: 2,
        sortOrder: 11,
        description: '피라미드와 나일강의 나라',
      ),
    ],
    // 달, 화성, 목성의 지역은 향후 백엔드 API에서 제공
    // 게스트 모드에서는 접근 불가
  };

  /// 특정 행성의 지역 목록 반환
  static List<ExplorationNodeEntity> getRegions(String planetId) {
    return regions[planetId] ?? [];
  }

  /// 특정 행성 반환
  static ExplorationNodeEntity getPlanet(String planetId) {
    return planets.firstWhere(
      (p) => p.id == planetId,
      orElse: () => planets.first,
    );
  }
}
```

---

## Task 2: DataSource 생성 (SharedPreferences)

노드별 해금/클리어 상태만 영속화. FuelLocalDataSource와 동일한 패턴.

**Files:**
- Create: `lib/features/exploration/data/datasources/exploration_local_datasource.dart`

**Step 1: DataSource 작성**

```dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 탐험 노드 상태 (영속화 대상)
///
/// 시드 데이터의 정적 정보를 제외한 변동 상태만 저장.
/// 향후 백엔드 연동 시 서버 DB로 교체.
class ExplorationNodeState {
  const ExplorationNodeState({
    required this.nodeId,
    this.isUnlocked = false,
    this.isCleared = false,
    this.unlockedAt,
  });

  final String nodeId;
  final bool isUnlocked;
  final bool isCleared;
  final DateTime? unlockedAt;

  Map<String, dynamic> toJson() => {
    'node_id': nodeId,
    'is_unlocked': isUnlocked,
    'is_cleared': isCleared,
    'unlocked_at': unlockedAt?.toIso8601String(),
  };

  factory ExplorationNodeState.fromJson(Map<String, dynamic> json) {
    return ExplorationNodeState(
      nodeId: json['node_id'] as String,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      isCleared: json['is_cleared'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }
}

/// 탐험 상태 로컬 DataSource
///
/// SharedPreferences에 노드별 해금/클리어 상태를 저장합니다.
/// 향후 백엔드 연동 시 ExplorationRemoteDataSource로 교체 예정.
class ExplorationLocalDataSource {
  static const _stateKey = 'guest_exploration_states';

  final SharedPreferences _prefs;

  ExplorationLocalDataSource(this._prefs);

  /// 모든 노드 상태 조회
  Map<String, ExplorationNodeState> getAllStates() {
    final jsonString = _prefs.getString(_stateKey);
    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonMap.map(
        (key, value) => MapEntry(
          key,
          ExplorationNodeState.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Exploration 상태 파싱 실패, 초기화합니다: $e');
      _prefs.remove(_stateKey);
      return {};
    }
  }

  /// 특정 노드 상태 저장
  Future<void> saveNodeState(ExplorationNodeState state) async {
    final states = getAllStates();
    states[state.nodeId] = state;
    await _saveAll(states);
  }

  /// 전체 상태 저장
  Future<void> _saveAll(Map<String, ExplorationNodeState> states) async {
    final jsonMap = states.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _prefs.setString(_stateKey, jsonEncode(jsonMap));
  }

  /// 전체 삭제 (게스트 로그아웃 시)
  Future<void> clearAll() async {
    final count = getAllStates().length;
    await _prefs.remove(_stateKey);
    debugPrint('🧹 Exploration 상태 삭제 완료 (노드: $count건)');
  }
}
```

---

## Task 3: Repository 인터페이스 생성

백엔드 API 연동 시 구현체만 교체할 수 있도록 인터페이스를 Domain 레이어에 정의.

**Files:**
- Create: `lib/features/exploration/domain/repositories/exploration_repository.dart`

```dart
import '../entities/exploration_node_entity.dart';
import '../entities/exploration_progress_entity.dart';

/// 탐험 Repository 인터페이스
///
/// 게스트: ExplorationLocalRepositoryImpl (SharedPreferences)
/// 소셜 로그인(향후): ExplorationRemoteRepositoryImpl (Backend API)
abstract class ExplorationRepository {
  /// 전체 행성 목록 (해금 상태 반영)
  List<ExplorationNodeEntity> getPlanets();

  /// 특정 행성 조회
  ExplorationNodeEntity getPlanet(String planetId);

  /// 특정 행성의 지역 목록 (해금 상태 반영)
  List<ExplorationNodeEntity> getRegions(String planetId);

  /// 지역 해금 (해금 = 클리어)
  void unlockRegion(String regionId);

  /// 행성 해금
  void unlockPlanet(String planetId);

  /// 진행도 계산
  ExplorationProgressEntity getProgress(String planetId);

  /// 전체 삭제 (게스트 로그아웃 시)
  Future<void> clearAll();
}
```

---

## Task 4: Repository 구현체 생성 (로컬)

시드 데이터 + 영속 상태를 머지하여 완성된 Entity 반환.

**Files:**
- Create: `lib/features/exploration/data/repositories/exploration_repository_impl.dart`

```dart
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
  void unlockRegion(String regionId) {
    final now = DateTime.now();
    // Region은 해금 = 클리어 (연료 소비만으로 탐험 완료)
    _localDataSource.saveNodeState(
      ExplorationNodeState(
        nodeId: regionId,
        isUnlocked: true,
        isCleared: true,
        unlockedAt: now,
      ),
    ).catchError(
      (e) => debugPrint('⚠️ Exploration 상태 저장 실패: $e'),
    );

    // 부모 행성의 자동 클리어 체크
    _checkPlanetAutoComplete(regionId);
  }

  @override
  void unlockPlanet(String planetId) {
    _localDataSource.saveNodeState(
      ExplorationNodeState(
        nodeId: planetId,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      ),
    ).catchError(
      (e) => debugPrint('⚠️ Exploration 상태 저장 실패: $e'),
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
  void _checkPlanetAutoComplete(String regionId) {
    // 시드에서 부모 행성 ID 찾기
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
      _localDataSource.saveNodeState(
        ExplorationNodeState(
          nodeId: parentPlanetId,
          isUnlocked: true,
          isCleared: true,
          unlockedAt: DateTime.now(),
        ),
      ).catchError(
        (e) => debugPrint('⚠️ 행성 자동 클리어 저장 실패: $e'),
      );
      debugPrint('🎉 행성 $parentPlanetId 자동 클리어!');
    }
  }
}
```

---

## Task 5: Exploration Provider 생성

게스트 모드 행성 필터링 + Repository 스왑 로직 포함.

**Files:**
- Create: `lib/features/exploration/presentation/providers/exploration_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/exploration_local_datasource.dart';
import '../../data/repositories/exploration_repository_impl.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
import '../../domain/repositories/exploration_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fuel/domain/exceptions/fuel_exceptions.dart';
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

/// 행성 목록 상태 (게스트: 지구만 / 소셜 로그인: 전체)
@Riverpod(keepAlive: true)
class ExplorationNotifier extends _$ExplorationNotifier {
  @override
  List<ExplorationNodeEntity> build() {
    final repository = ref.watch(explorationRepositoryProvider);
    final allPlanets = repository.getPlanets();

    // 게스트 모드: 지구만 탐험 가능
    final isGuest = ref.watch(isGuestProvider);
    if (isGuest) {
      return allPlanets.where((p) => p.id == 'earth').toList();
    }

    return allPlanets;
  }

  /// 행성 해금 (연료 소비 + 상태 저장)
  ///
  /// 연료 부족 시 [InsufficientFuelException] throw.
  void unlockPlanet(String planetId, int requiredFuel) {
    // 1. 연료 차감
    ref.read(fuelNotifierProvider.notifier).consumeFuel(
      amount: requiredFuel,
      nodeId: planetId,
    );

    // 2. 해금 상태 저장
    final repository = ref.read(explorationRepositoryProvider);
    repository.unlockPlanet(planetId);

    // 3. 상태 갱신
    _reload();
  }

  /// 상태 새로고침 (지역 해금 후 행성 목록도 갱신)
  void refresh() => _reload();

  void _reload() {
    final repository = ref.read(explorationRepositoryProvider);
    final allPlanets = repository.getPlanets();
    final isGuest = ref.read(isGuestProvider);
    if (isGuest) {
      state = allPlanets.where((p) => p.id == 'earth').toList();
    } else {
      state = allPlanets;
    }
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

  /// 지역 해금 (연료 소비 + 상태 저장 + 자동 클리어)
  ///
  /// 연료 부족 시 [InsufficientFuelException] throw.
  void unlockRegion(String regionId, int requiredFuel) {
    // 1. 연료 차감
    ref.read(fuelNotifierProvider.notifier).consumeFuel(
      amount: requiredFuel,
      nodeId: regionId,
    );

    // 2. 해금 + 클리어 상태 저장
    final repository = ref.read(explorationRepositoryProvider);
    repository.unlockRegion(regionId);

    // 3. 지역 목록 갱신
    state = repository.getRegions(planetId);

    // 4. 행성 목록도 갱신 (자동 클리어 반영)
    ref.read(explorationNotifierProvider.notifier).refresh();
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
```

---

## Task 6: main.dart에 DataSource 초기화 추가

FuelLocalDataSource와 동일한 패턴으로 ProviderScope override.

**Files:**
- Modify: `lib/main.dart`

**변경 내용:**
- `import` 추가: `exploration_local_datasource.dart`, `exploration_provider.dart`
- `providerOverrides`에 `explorationLocalDataSourceProvider` 추가

```dart
// 기존 fuel override 아래에 추가:
if (prefs != null)
  explorationLocalDataSourceProvider.overrideWithValue(
    ExplorationLocalDataSource(prefs),
  ),
```

---

## Task 7: exploration_detail_screen.dart 리팩토링

샘플 데이터 제거 → Provider 연결, handleUnlock → Notifier 호출.

**Files:**
- Modify: `lib/features/exploration/presentation/screens/exploration_detail_screen.dart`

**주요 변경:**
1. `_getSamplePlanet`, `_getSampleRegions`, `_getSampleProgress` 삭제
2. Provider watch:
   ```dart
   final planet = ref.watch(explorationRepositoryProvider).getPlanet(planetId);
   final regions = ref.watch(regionListNotifierProvider(planetId));
   final progress = ref.watch(explorationProgressProvider(planetId));
   final currentFuel = ref.watch(currentFuelProvider);
   ```
3. `_handleUnlock` 수정:
   ```dart
   void _handleUnlock(context, region, currentFuel, ref, planetId) {
     if (currentFuel < region.requiredFuel) {
       AppSnackBar.error(context, '연료가 부족합니다! (필요: ${region.requiredFuel}통)');
       return;
     }
     AppDialog.show(
       context: context,
       title: '${region.name} 해금',
       message: '연료 ${region.requiredFuel}통을 소비하여\n${region.name}을(를) 해금하시겠습니까?',
       emotion: AppDialogEmotion.info,
       confirmText: '해금하기',
       cancelText: '취소',
       onConfirm: () {
         try {
           ref.read(regionListNotifierProvider(planetId).notifier)
               .unlockRegion(region.id, region.requiredFuel);
           AppSnackBar.success(context, '${region.name}이(가) 해금되었습니다!');
         } on InsufficientFuelException catch (e) {
           AppSnackBar.error(context, e.toString());
         }
       },
     );
   }
   ```

---

## Task 8: explore_screen.dart 리팩토링

샘플 데이터 제거 → Provider 연결. 잠긴 행성 탭 시 해금 다이얼로그 추가.

**Files:**
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart`

**주요 변경:**
1. `_samplePlanets`, `_sampleProgressMap` 삭제
2. Provider watch:
   ```dart
   final planets = ref.watch(explorationNotifierProvider);
   final currentFuel = ref.watch(currentFuelProvider);
   ```
3. 각 행성별 진행도:
   ```dart
   final progress = ref.watch(explorationProgressProvider(planet.id));
   ```
4. `_handlePlanetTap` 수정: 잠긴 행성 탭 시 해금 다이얼로그 (연료 충분할 때만)
   ```dart
   void _handlePlanetTap(context, planet, currentFuel, ref) {
     if (planet.isUnlocked) {
       context.push('/explore/planet/${planet.id}');
       return;
     }
     if (currentFuel < planet.requiredFuel) {
       AppSnackBar.warning(context, '연료가 부족합니다! (필요: ${planet.requiredFuel}통)');
       return;
     }
     AppDialog.show(
       context: context,
       title: '${planet.name} 해금',
       message: '연료 ${planet.requiredFuel}통을 소비하여\n${planet.name}을(를) 해금하시겠습니까?',
       emotion: AppDialogEmotion.info,
       confirmText: '해금하기',
       cancelText: '취소',
       onConfirm: () {
         try {
           ref.read(explorationNotifierProvider.notifier)
               .unlockPlanet(planet.id, planet.requiredFuel);
           AppSnackBar.success(context, '${planet.name}이(가) 해금되었습니다!');
         } on InsufficientFuelException catch (e) {
           AppSnackBar.error(context, e.toString());
         }
       },
     );
   }
   ```
5. 지역이 없는 행성(달, 화성, 목성) 탭 시: 해금만 되고, 상세 화면에서 빈 지역 목록 표시 (SpaceEmptyState 사용)

---

## Task 9: 게스트 인증 시 탐험 데이터 관리

기존 fuel/todo/timer와 동일한 패턴으로 exploration 정리 추가.

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

**변경 내용:**
- `import` 추가: `exploration_provider.dart`
- `signInAsGuest()` 내 정리 블록에 추가:
  ```dart
  final explorationRepo = ref.read(explorationRepositoryProvider);
  await explorationRepo.clearAll();
  ```
- `signInAsGuest()` 내 invalidate 블록에 추가:
  ```dart
  ref.invalidate(explorationNotifierProvider);
  ```
- `signOut()` 게스트 분기에 동일하게 추가

---

## Task 10: build_runner + flutter analyze

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
```

**예상 생성 파일:** `exploration_provider.g.dart`

---

## Task 11: 커밋

```bash
git add lib/features/exploration/data/ lib/features/exploration/domain/repositories/ \
  lib/features/exploration/presentation/providers/ \
  lib/features/exploration/presentation/screens/ \
  lib/features/explore/presentation/screens/ \
  lib/features/auth/presentation/providers/ \
  lib/main.dart

git commit -m "feat: 탐험 해금 상태 영속화 및 게스트 지구 제한 구현 #41"
```

---

## 향후 백엔드 연동 가이드 (소셜 로그인 시)

### 1. ExplorationRemoteDataSource 생성
```dart
// lib/features/exploration/data/datasources/exploration_remote_datasource.dart
@RestApi()
abstract class ExplorationRemoteDataSource {
  factory ExplorationRemoteDataSource(Dio dio) = _ExplorationRemoteDataSource;

  @GET('/exploration/planets')
  Future<List<ExplorationNodeModel>> getPlanets();

  @GET('/exploration/planets/{planetId}/regions')
  Future<List<ExplorationNodeModel>> getRegions(@Path() String planetId);

  @POST('/exploration/regions/{regionId}/unlock')
  Future<void> unlockRegion(@Path() String regionId);

  @POST('/exploration/planets/{planetId}/unlock')
  Future<void> unlockPlanet(@Path() String planetId);
}
```

### 2. ExplorationRemoteRepositoryImpl 생성
```dart
// lib/features/exploration/data/repositories/exploration_remote_repository_impl.dart
class ExplorationRemoteRepositoryImpl implements ExplorationRepository {
  final ExplorationRemoteDataSource _remoteDataSource;
  // 서버가 해금 상태 포함하여 반환하므로 시드 데이터/로컬 상태 불필요
}
```

### 3. Provider 스왑 활성화
```dart
// exploration_provider.dart
@riverpod
ExplorationRepository explorationRepository(Ref ref) {
  final isGuest = ref.watch(isGuestProvider);
  if (!isGuest) {
    return ExplorationRemoteRepositoryImpl(
      ref.watch(explorationRemoteDataSourceProvider),
    );
  }
  return ExplorationLocalRepositoryImpl(
    ref.watch(explorationLocalDataSourceProvider),
  );
}
```

게스트 행성 필터링도 불필요해짐 (서버가 접근 가능한 행성만 반환).

---

## 검증 체크리스트

- [ ] 게스트 로그인 → 지구만 표시 (달/화성/목성 안 보임)
- [ ] 일본 해금 → 연료 1통 차감 + isUnlocked+isCleared 표시
- [ ] 앱 재시작 → 일본 여전히 해금/클리어 상태
- [ ] 지구 12개 지역 전부 클리어 → 지구 행성 자동 클리어
- [ ] 게스트 로그아웃 → 탐험 상태 초기화
- [ ] 게스트 재로그인 → 대한민국만 해금/클리어 상태
- [ ] 연료 부족 시 해금 거부 + 에러 스낵바
- [ ] 소셜 로그인(현재) → 전체 행성 표시 (로컬 저장소 사용)
- [ ] flutter analyze 통과
