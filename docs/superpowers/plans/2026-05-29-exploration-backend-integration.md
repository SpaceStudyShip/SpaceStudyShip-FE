# 행성/지역 해금(Exploration) 백엔드 연동 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 인증(소셜 로그인) 사용자의 행성/지역 해금을 백엔드 API에 연동하고, 게스트는 기존 로컬 경로를 그대로 유지한다.

**Architecture:** fuel feature 패턴 복제 — `explorationRepositoryProvider`가 `isAuthenticatedProvider`로 분기(인증→Remote, 게스트→Local). 서버가 카탈로그·상태의 source of truth. 동기 `ExplorationNotifier`를 AsyncNotifier로 전환하고 소비 화면 4곳을 `AsyncValue` 언랩으로 조정. unlock은 서버가 원자적으로 연료 차감.

**Tech Stack:** Flutter · Riverpod 2.6 (generator) · Freezed + JsonSerializable · Dio + Retrofit · mocktail · flutter_test

---

## 파일 구조

**신규 (Data Layer):**
- `lib/features/exploration/data/models/planet_response_model.dart` — `PlanetResponse` DTO + 중첩 `ProgressResponseModel`
- `lib/features/exploration/data/models/region_response_model.dart` — `RegionResponse` DTO
- `lib/features/exploration/data/models/unlock_response_models.dart` — `RegionUnlockResponseModel`/`PlanetUnlockResponseModel` + 중첩 `UnlockedNodeModel`
- `lib/features/exploration/data/datasources/exploration_remote_datasource.dart` — Retrofit 4 엔드포인트
- `lib/features/exploration/data/repositories/exploration_remote_repository_impl.dart` — 원격 구현 + 에러 매핑 + progress 캐시

**신규 (Domain Layer):**
- `lib/features/exploration/domain/entities/unlock_result_entities.dart` — `RegionUnlockResultEntity`/`PlanetUnlockResultEntity` (plain class)
- `lib/features/exploration/domain/exceptions/exploration_exceptions.dart` — plain Exception 4종

**변경:**
- `lib/core/constants/api_endpoints.dart` — Exploration 경로 추가
- `lib/features/exploration/domain/repositories/exploration_repository.dart` — 전 메서드 async + 결과 엔티티 반환
- `lib/features/exploration/data/repositories/exploration_repository_impl.dart` — async 래핑(로컬)
- `lib/features/exploration/presentation/providers/exploration_provider.dart` — 원격 DS provider + repo 분기 + AsyncNotifier
- `lib/features/auth/presentation/providers/auth_provider.dart` — `_clearGuestData` 한 줄
- `lib/features/explore/presentation/screens/explore_screen.dart`
- `lib/features/exploration/presentation/screens/exploration_detail_screen.dart`
- `lib/features/exploration/presentation/screens/location_detail_screen.dart`
- `lib/features/exploration/presentation/widgets/planet_node.dart`

**중요 — 빌드 그린 경계:** Task 1~7(가산적 신규 코드)은 각각 독립 컴파일·커밋 가능. Task 8~15(인터페이스 async 전환 → 로컬 repo → provider → 화면 4곳)는 **함께 컴파일되어야** 하므로 하나의 묶음으로 진행하고 Task 15 끝에서 build_runner+analyze+test 통과 후 커밋한다.

---

## Phase 1 — Domain & 상수 (가산적, 독립 커밋)

### Task 1: ApiEndpoints에 Exploration 경로 추가

**Files:**
- Modify: `lib/core/constants/api_endpoints.dart`

- [ ] **Step 1: 상수 추가**

`api_endpoints.dart`의 Timer 섹션 끝(`timerSessionsTodayStats` 줄 다음, 클래스 닫는 `}` 직전)에 추가:

```dart

  // ============================================
  // Exploration
  // ============================================

  /// 전체 행성 목록
  static const explorationPlanets = '/api/explorations/planets';

  /// 특정 행성 하위 지역 목록
  static String explorationRegions(String planetId) =>
      '/api/explorations/planets/$planetId/regions';

  /// 지역 해금 (연료 소비)
  static String explorationUnlockRegion(String regionId) =>
      '/api/explorations/regions/$regionId/unlock';

  /// 행성 해금 (연료 소비)
  static String explorationUnlockPlanet(String planetId) =>
      '/api/explorations/planets/$planetId/unlock';
```

- [ ] **Step 2: analyze 확인**

Run: `flutter analyze lib/core/constants/api_endpoints.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/api_endpoints.dart
git commit -m "feat : Exploration API 엔드포인트 상수 추가"
```

---

### Task 2: 결과 엔티티 + 예외 정의

**Files:**
- Create: `lib/features/exploration/domain/entities/unlock_result_entities.dart`
- Create: `lib/features/exploration/domain/exceptions/exploration_exceptions.dart`
- Test: `test/features/exploration/domain/unlock_result_entities_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/features/exploration/domain/unlock_result_entities_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/domain/entities/unlock_result_entities.dart';

void main() {
  test('RegionUnlockResultEntity — 필드 보관', () {
    const r = RegionUnlockResultEntity(planetCleared: true, currentFuel: 42);
    expect(r.planetCleared, true);
    expect(r.currentFuel, 42);
  });

  test('PlanetUnlockResultEntity — 필드 보관', () {
    const p = PlanetUnlockResultEntity(currentFuel: 7);
    expect(p.currentFuel, 7);
  });

  test('게스트 센티넬 currentFuel = -1 허용', () {
    const r = RegionUnlockResultEntity(planetCleared: false, currentFuel: -1);
    expect(r.currentFuel, -1);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/exploration/domain/unlock_result_entities_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'unlock_result_entities.dart'`

- [ ] **Step 3: 엔티티 구현**

`lib/features/exploration/domain/entities/unlock_result_entities.dart`:

```dart
/// 지역 해금 결과
///
/// 게스트는 연료를 Notifier가 별도 차감하므로 [currentFuel]은 `-1`(미사용 센티넬).
/// 인증(서버) 경로는 서버가 차감 후 반환한 잔량을 담는다.
class RegionUnlockResultEntity {
  const RegionUnlockResultEntity({
    required this.planetCleared,
    required this.currentFuel,
  });

  /// 이 지역 해금으로 상위 행성이 모두 클리어되었는지
  final bool planetCleared;

  /// 해금 후 잔여 연료 (게스트: -1 센티넬)
  final int currentFuel;
}

/// 행성 해금 결과
class PlanetUnlockResultEntity {
  const PlanetUnlockResultEntity({required this.currentFuel});

  /// 해금 후 잔여 연료 (게스트: -1 센티넬)
  final int currentFuel;
}
```

- [ ] **Step 4: 예외 구현**

`lib/features/exploration/domain/exceptions/exploration_exceptions.dart`:

```dart
/// 탐험 해금 도메인 예외.
///
/// 연료 부족(`INSUFFICIENT_FUEL`)은 별도 클래스를 만들지 않고 fuel 도메인의
/// 기존 `InsufficientFuelException`을 재사용한다 (showUnlockDialog가 이미 catch).
/// 아래 예외들은 화면 사전검증을 통과한 레이스 상황의 안전망이다.

/// 이미 해금된 노드 (`ALREADY_UNLOCKED`)
class NodeAlreadyUnlockedException implements Exception {
  const NodeAlreadyUnlockedException([this.message = '이미 해금된 곳입니다.']);
  final String message;
  @override
  String toString() => 'NodeAlreadyUnlockedException: $message';
}

/// 상위 행성이 잠겨 지역을 해금할 수 없음 (`PLANET_LOCKED`)
class PlanetLockedException implements Exception {
  const PlanetLockedException([this.message = '먼저 행성을 해금해야 합니다.']);
  final String message;
  @override
  String toString() => 'PlanetLockedException: $message';
}

/// 선행 행성 미클리어로 해금 불가 (`PREREQUISITE_NOT_CLEARED`)
class PrerequisiteNotClearedException implements Exception {
  const PrerequisiteNotClearedException([
    this.message = '이전 행성을 먼저 클리어해야 합니다.',
  ]);
  final String message;
  @override
  String toString() => 'PrerequisiteNotClearedException: $message';
}

/// 노드 미존재 (`REGION_NOT_FOUND` / `PLANET_NOT_FOUND`)
class ExplorationNodeNotFoundException implements Exception {
  const ExplorationNodeNotFoundException([
    this.message = '해당 탐험 지점을 찾을 수 없습니다.',
  ]);
  final String message;
  @override
  String toString() => 'ExplorationNodeNotFoundException: $message';
}
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/features/exploration/domain/unlock_result_entities_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 6: Commit**

```bash
git add lib/features/exploration/domain/entities/unlock_result_entities.dart lib/features/exploration/domain/exceptions/exploration_exceptions.dart test/features/exploration/domain/unlock_result_entities_test.dart
git commit -m "feat : 탐험 해금 결과 엔티티 및 도메인 예외 추가"
```

---

## Phase 2 — Data 모델 (Freezed DTO, 가산적)

### Task 3: PlanetResponseModel + ProgressResponseModel

**Files:**
- Create: `lib/features/exploration/data/models/planet_response_model.dart`
- Test: `test/features/exploration/data/models/planet_response_model_test.dart`

- [ ] **Step 1: 모델 작성 (codegen 대상)**

`lib/features/exploration/data/models/planet_response_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';

part 'planet_response_model.freezed.dart';
part 'planet_response_model.g.dart';

/// GET /api/explorations/planets 응답 항목 DTO
@freezed
class PlanetResponseModel with _$PlanetResponseModel {
  const PlanetResponseModel._();

  const factory PlanetResponseModel({
    required String id,
    required String name,
    required String nodeType,
    required int depth,
    required String icon,
    String? parentId,
    String? prerequisiteId,
    required int requiredFuel,
    required bool isUnlocked,
    required bool isCleared,
    required int sortOrder,
    @Default('') String description,
    @Default(0.5) double mapX,
    @Default(0.0) double mapY,
    DateTime? unlockedAt,
    ProgressResponseModel? progress,
  }) = _PlanetResponseModel;

  factory PlanetResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PlanetResponseModelFromJson(json);

  ExplorationNodeEntity toEntity() => ExplorationNodeEntity(
    id: id,
    name: name,
    nodeType: nodeTypeFromString(nodeType),
    depth: depth,
    icon: icon,
    parentId: parentId,
    requiredFuel: requiredFuel,
    isUnlocked: isUnlocked,
    isCleared: isCleared,
    sortOrder: sortOrder,
    description: description,
    mapX: mapX,
    mapY: mapY,
    unlockedAt: unlockedAt,
  );

  ExplorationProgressEntity progressEntity() => ExplorationProgressEntity(
    nodeId: id,
    clearedChildren: progress?.clearedChildren ?? 0,
    totalChildren: progress?.totalChildren ?? 0,
  );
}

/// 행성 진행도 중첩 DTO
@freezed
class ProgressResponseModel with _$ProgressResponseModel {
  const factory ProgressResponseModel({
    required int clearedChildren,
    required int totalChildren,
    @Default(0.0) double progressRatio,
  }) = _ProgressResponseModel;

  factory ProgressResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressResponseModelFromJson(json);
}

/// 서버 nodeType 문자열 → enum 매핑 (재사용)
ExplorationNodeType nodeTypeFromString(String raw) {
  switch (raw) {
    case 'galaxy':
      return ExplorationNodeType.galaxy;
    case 'starSystem':
    case 'star_system':
      return ExplorationNodeType.starSystem;
    case 'planet':
      return ExplorationNodeType.planet;
    case 'region':
      return ExplorationNodeType.region;
    default:
      return ExplorationNodeType.region;
  }
}
```

- [ ] **Step 2: 코드 생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `planet_response_model.freezed.dart`, `planet_response_model.g.dart` 생성, 빌드 성공.

- [ ] **Step 3: 테스트 작성**

`test/features/exploration/data/models/planet_response_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/data/models/planet_response_model.dart';
import 'package:space_study_ship/features/exploration/domain/entities/exploration_node_entity.dart';

void main() {
  group('PlanetResponseModel', () {
    test('fromJson + toEntity — 해금된 행성 (progress 포함)', () {
      final json = {
        'id': 'mars',
        'name': '화성',
        'nodeType': 'planet',
        'depth': 2,
        'icon': 'mars',
        'parentId': null,
        'prerequisiteId': 'venus',
        'requiredFuel': 10,
        'isUnlocked': true,
        'isCleared': false,
        'sortOrder': 3,
        'description': '붉은 행성',
        'mapX': 0.25,
        'mapY': 0.44,
        'unlockedAt': '2026-04-01T00:00:00Z',
        'progress': {
          'clearedChildren': 3,
          'totalChildren': 5,
          'progressRatio': 0.6,
        },
      };
      final model = PlanetResponseModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.id, 'mars');
      expect(entity.nodeType, ExplorationNodeType.planet);
      expect(entity.requiredFuel, 10);
      expect(entity.isUnlocked, true);
      expect(entity.unlockedAt, DateTime.utc(2026, 4, 1));

      final progress = model.progressEntity();
      expect(progress.clearedChildren, 3);
      expect(progress.totalChildren, 5);
      expect(progress.progressRatio, closeTo(0.6, 0.001));
    });

    test('fromJson — 잠긴 행성 (unlockedAt/progress 없음)', () {
      final json = {
        'id': 'neptune',
        'name': '해왕성',
        'nodeType': 'planet',
        'depth': 2,
        'icon': 'neptune',
        'requiredFuel': 60,
        'isUnlocked': false,
        'isCleared': false,
        'sortOrder': 7,
      };
      final model = PlanetResponseModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.unlockedAt, isNull);
      expect(entity.isUnlocked, false);
      expect(model.progressEntity().totalChildren, 0);
    });
  });
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/exploration/data/models/planet_response_model_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/exploration/data/models/planet_response_model.dart lib/features/exploration/data/models/planet_response_model.freezed.dart lib/features/exploration/data/models/planet_response_model.g.dart test/features/exploration/data/models/planet_response_model_test.dart
git commit -m "feat : PlanetResponseModel DTO 및 enum 매핑 추가"
```

---

### Task 4: RegionResponseModel

**Files:**
- Create: `lib/features/exploration/data/models/region_response_model.dart`
- Test: `test/features/exploration/data/models/region_response_model_test.dart`

- [ ] **Step 1: 모델 작성**

`lib/features/exploration/data/models/region_response_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/exploration_node_entity.dart';
import 'planet_response_model.dart' show nodeTypeFromString;

part 'region_response_model.freezed.dart';
part 'region_response_model.g.dart';

/// GET /api/explorations/planets/{planetId}/regions 응답 항목 DTO
@freezed
class RegionResponseModel with _$RegionResponseModel {
  const RegionResponseModel._();

  const factory RegionResponseModel({
    required String id,
    required String name,
    required String nodeType,
    required int depth,
    required String icon,
    String? parentId,
    required int requiredFuel,
    required bool isUnlocked,
    required bool isCleared,
    required int sortOrder,
    @Default('') String description,
    @Default(0.5) double mapX,
    @Default(0.0) double mapY,
    DateTime? unlockedAt,
  }) = _RegionResponseModel;

  factory RegionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegionResponseModelFromJson(json);

  ExplorationNodeEntity toEntity() => ExplorationNodeEntity(
    id: id,
    name: name,
    nodeType: nodeTypeFromString(nodeType),
    depth: depth,
    icon: icon,
    parentId: parentId,
    requiredFuel: requiredFuel,
    isUnlocked: isUnlocked,
    isCleared: isCleared,
    sortOrder: sortOrder,
    description: description,
    mapX: mapX,
    mapY: mapY,
    unlockedAt: unlockedAt,
  );
}
```

- [ ] **Step 2: 코드 생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 빌드 성공, `region_response_model.*` 생성.

- [ ] **Step 3: 테스트 작성**

`test/features/exploration/data/models/region_response_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/data/models/region_response_model.dart';
import 'package:space_study_ship/features/exploration/domain/entities/exploration_node_entity.dart';

void main() {
  test('RegionResponseModel — fromJson + toEntity', () {
    final json = {
      'id': 'japan',
      'name': '일본',
      'nodeType': 'region',
      'depth': 3,
      'icon': 'JP',
      'parentId': 'earth',
      'requiredFuel': 5,
      'isUnlocked': true,
      'isCleared': true,
      'sortOrder': 1,
      'description': '이웃 섬나라',
      'unlockedAt': '2026-04-05T15:30:00Z',
    };
    final entity = RegionResponseModel.fromJson(json).toEntity();
    expect(entity.id, 'japan');
    expect(entity.nodeType, ExplorationNodeType.region);
    expect(entity.parentId, 'earth');
    expect(entity.isCleared, true);
    expect(entity.unlockedAt, DateTime.utc(2026, 4, 5, 15, 30));
  });
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/exploration/data/models/region_response_model_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/exploration/data/models/region_response_model.dart lib/features/exploration/data/models/region_response_model.freezed.dart lib/features/exploration/data/models/region_response_model.g.dart test/features/exploration/data/models/region_response_model_test.dart
git commit -m "feat : RegionResponseModel DTO 추가"
```

---

### Task 5: Unlock 응답 모델 (region + planet + UnlockedNode)

**Files:**
- Create: `lib/features/exploration/data/models/unlock_response_models.dart`
- Test: `test/features/exploration/data/models/unlock_response_models_test.dart`

- [ ] **Step 1: 모델 작성**

`lib/features/exploration/data/models/unlock_response_models.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/unlock_result_entities.dart';

part 'unlock_response_models.freezed.dart';
part 'unlock_response_models.g.dart';

/// 해금된 노드 요약 (중첩)
@freezed
class UnlockedNodeModel with _$UnlockedNodeModel {
  const factory UnlockedNodeModel({
    required String id,
    required String name,
    required bool isUnlocked,
    required bool isCleared,
    DateTime? unlockedAt,
  }) = _UnlockedNodeModel;

  factory UnlockedNodeModel.fromJson(Map<String, dynamic> json) =>
      _$UnlockedNodeModelFromJson(json);
}

/// POST /api/explorations/regions/{regionId}/unlock 응답
@freezed
class RegionUnlockResponseModel with _$RegionUnlockResponseModel {
  const RegionUnlockResponseModel._();

  const factory RegionUnlockResponseModel({
    UnlockedNodeModel? region,
    required int fuelConsumed,
    required int currentFuel,
    required bool planetCleared,
  }) = _RegionUnlockResponseModel;

  factory RegionUnlockResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegionUnlockResponseModelFromJson(json);

  RegionUnlockResultEntity toEntity() => RegionUnlockResultEntity(
    planetCleared: planetCleared,
    currentFuel: currentFuel,
  );
}

/// POST /api/explorations/planets/{planetId}/unlock 응답
@freezed
class PlanetUnlockResponseModel with _$PlanetUnlockResponseModel {
  const PlanetUnlockResponseModel._();

  const factory PlanetUnlockResponseModel({
    UnlockedNodeModel? planet,
    required int fuelConsumed,
    required int currentFuel,
  }) = _PlanetUnlockResponseModel;

  factory PlanetUnlockResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PlanetUnlockResponseModelFromJson(json);

  PlanetUnlockResultEntity toEntity() =>
      PlanetUnlockResultEntity(currentFuel: currentFuel);
}
```

- [ ] **Step 2: 코드 생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 빌드 성공.

- [ ] **Step 3: 테스트 작성**

`test/features/exploration/data/models/unlock_response_models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/exploration/data/models/unlock_response_models.dart';

void main() {
  test('RegionUnlockResponseModel — toEntity', () {
    final json = {
      'region': {
        'id': 'japan',
        'name': '일본',
        'isUnlocked': true,
        'isCleared': true,
        'unlockedAt': '2026-04-16T11:00:00Z',
      },
      'fuelConsumed': 5,
      'currentFuel': 95,
      'planetCleared': false,
    };
    final entity = RegionUnlockResponseModel.fromJson(json).toEntity();
    expect(entity.planetCleared, false);
    expect(entity.currentFuel, 95);
  });

  test('PlanetUnlockResponseModel — toEntity', () {
    final json = {
      'planet': {
        'id': 'mars',
        'name': '화성',
        'isUnlocked': true,
        'isCleared': false,
      },
      'fuelConsumed': 10,
      'currentFuel': 40,
    };
    final entity = PlanetUnlockResponseModel.fromJson(json).toEntity();
    expect(entity.currentFuel, 40);
  });
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/exploration/data/models/unlock_response_models_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/exploration/data/models/unlock_response_models.dart lib/features/exploration/data/models/unlock_response_models.freezed.dart lib/features/exploration/data/models/unlock_response_models.g.dart test/features/exploration/data/models/unlock_response_models_test.dart
git commit -m "feat : 행성/지역 해금 응답 모델 추가"
```

---

## Phase 3 — Remote DataSource & Repository (가산적)

### Task 6: ExplorationRemoteDataSource (Retrofit)

**Files:**
- Create: `lib/features/exploration/data/datasources/exploration_remote_datasource.dart`

- [ ] **Step 1: 데이터소스 작성**

`lib/features/exploration/data/datasources/exploration_remote_datasource.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/planet_response_model.dart';
import '../models/region_response_model.dart';
import '../models/unlock_response_models.dart';

part 'exploration_remote_datasource.g.dart';

/// Exploration 백엔드 API 클라이언트 (api-docs.json Exploration 태그 4 엔드포인트).
@RestApi()
abstract class ExplorationRemoteDataSource {
  factory ExplorationRemoteDataSource(Dio dio) = _ExplorationRemoteDataSource;

  /// 전체 행성 목록 — 200
  @GET(ApiEndpoints.explorationPlanets)
  Future<List<PlanetResponseModel>> getPlanets();

  /// 행성 하위 지역 목록 — 200 / 404 PLANET_NOT_FOUND
  @GET('/api/explorations/planets/{planetId}/regions')
  Future<List<RegionResponseModel>> getRegions(@Path('planetId') String planetId);

  /// 지역 해금 — 200 / 400 / 404
  @POST('/api/explorations/regions/{regionId}/unlock')
  Future<RegionUnlockResponseModel> unlockRegion(@Path('regionId') String regionId);

  /// 행성 해금 — 200 / 400 / 404
  @POST('/api/explorations/planets/{planetId}/unlock')
  Future<PlanetUnlockResponseModel> unlockPlanet(@Path('planetId') String planetId);
}
```

> Retrofit `@Path` 사용 메서드는 경로 리터럴이 필요하므로 `ApiEndpoints`의 함수형 상수 대신 경로 문자열을 직접 사용한다(엔드포인트 함수는 호출부 가독성용으로 유지).

- [ ] **Step 2: 코드 생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `exploration_remote_datasource.g.dart` 생성, 빌드 성공.

- [ ] **Step 3: analyze 확인**

Run: `flutter analyze lib/features/exploration/data/datasources/exploration_remote_datasource.dart`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/exploration/data/datasources/exploration_remote_datasource.dart lib/features/exploration/data/datasources/exploration_remote_datasource.g.dart
git commit -m "feat : ExplorationRemoteDataSource 추가"
```

---

### Task 7: ExplorationRemoteRepositoryImpl (에러 매핑 + progress 캐시)

> 이 Repository는 **아직 인터페이스가 sync**이므로, 지금은 인터페이스를 implements 하지 않고 독립 클래스로 작성·테스트한다. Task 8에서 인터페이스가 async로 바뀌면 `implements ExplorationRepository`를 붙인다. (이렇게 해야 Phase 3까지 빌드 그린 유지)

**Files:**
- Create: `lib/features/exploration/data/repositories/exploration_remote_repository_impl.dart`
- Test: `test/features/exploration/data/repositories/exploration_remote_repository_impl_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/features/exploration/data/repositories/exploration_remote_repository_impl_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/features/exploration/data/datasources/exploration_remote_datasource.dart';
import 'package:space_study_ship/features/exploration/data/models/planet_response_model.dart';
import 'package:space_study_ship/features/exploration/data/models/unlock_response_models.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_remote_repository_impl.dart';
import 'package:space_study_ship/features/exploration/domain/exceptions/exploration_exceptions.dart';
import 'package:space_study_ship/features/fuel/domain/exceptions/fuel_exceptions.dart';

class _MockRemote extends Mock implements ExplorationRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late ExplorationRemoteRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    repo = ExplorationRemoteRepositoryImpl(remote);
  });

  PlanetResponseModel planet(String id) => PlanetResponseModel(
    id: id,
    name: id,
    nodeType: 'planet',
    depth: 2,
    icon: id,
    requiredFuel: 10,
    isUnlocked: false,
    isCleared: false,
    sortOrder: 0,
    progress: const ProgressResponseModel(clearedChildren: 1, totalChildren: 4),
  );

  DioException unlockError(String code, {int? requiredFuel, int? currentFuel}) =>
      DioException(
        requestOptions: RequestOptions(path: '/api/explorations/regions/x/unlock'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 400,
          data: {
            'code': code,
            'message': 'msg',
            if (requiredFuel != null) 'requiredFuel': requiredFuel,
            if (currentFuel != null) 'currentFuel': currentFuel,
          },
        ),
      );

  test('getPlanets — 매핑 + getProgress 캐시 사용', () async {
    when(() => remote.getPlanets()).thenAnswer((_) async => [planet('mars')]);

    final planets = await repo.getPlanets();
    expect(planets.single.id, 'mars');

    // getProgress는 추가 fetch 없이 캐시에서 반환
    final progress = await repo.getProgress('mars');
    expect(progress.clearedChildren, 1);
    expect(progress.totalChildren, 4);
    verify(() => remote.getPlanets()).called(1); // 단 1회
  });

  test('unlockRegion INSUFFICIENT_FUEL → fuel InsufficientFuelException', () async {
    when(() => remote.unlockRegion('seoul')).thenThrow(
      unlockError('INSUFFICIENT_FUEL', requiredFuel: 10, currentFuel: 3),
    );

    expect(
      () => repo.unlockRegion('seoul'),
      throwsA(
        isA<InsufficientFuelException>()
            .having((e) => e.requiredAmount, 'requiredAmount', 10)
            .having((e) => e.available, 'available', 3),
      ),
    );
  });

  test('unlockRegion ALREADY_UNLOCKED → NodeAlreadyUnlockedException', () async {
    when(() => remote.unlockRegion('seoul'))
        .thenThrow(unlockError('ALREADY_UNLOCKED'));
    expect(
      () => repo.unlockRegion('seoul'),
      throwsA(isA<NodeAlreadyUnlockedException>()),
    );
  });

  test('unlockPlanet 성공 → 결과 엔티티', () async {
    when(() => remote.unlockPlanet('mars')).thenAnswer(
      (_) async => const PlanetUnlockResponseModel(fuelConsumed: 10, currentFuel: 40),
    );
    final result = await repo.unlockPlanet('mars');
    expect(result.currentFuel, 40);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/exploration/data/repositories/exploration_remote_repository_impl_test.dart`
Expected: FAIL — `exploration_remote_repository_impl.dart` 없음.

- [ ] **Step 3: Repository 구현**

`lib/features/exploration/data/repositories/exploration_remote_repository_impl.dart`:

```dart
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
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/features/exploration/data/repositories/exploration_remote_repository_impl_test.dart`
Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/exploration/data/repositories/exploration_remote_repository_impl.dart test/features/exploration/data/repositories/exploration_remote_repository_impl_test.dart
git commit -m "feat : ExplorationRemoteRepositoryImpl 및 에러 매핑 추가"
```

---

## Phase 4 — async 전환 묶음 (Task 8~15 함께 컴파일, Task 15 끝에 커밋)

> **주의:** Task 8에서 인터페이스가 async로 바뀌는 순간 provider·화면이 깨진다. Task 8~15는 중간 커밋 없이 진행하고, Task 15의 build_runner+analyze+test 통과 후 한 번에 커밋한다. 진행 중에는 `flutter analyze`로 남은 컴파일 오류를 추적한다.

### Task 8: Repository 인터페이스 async 전환 + 로컬 구현 + remote implements

**Files:**
- Modify: `lib/features/exploration/domain/repositories/exploration_repository.dart`
- Modify: `lib/features/exploration/data/repositories/exploration_repository_impl.dart`
- Modify: `lib/features/exploration/data/repositories/exploration_remote_repository_impl.dart`
- Test: `test/features/exploration/data/repositories/exploration_local_repository_impl_test.dart`

- [ ] **Step 1: 인터페이스 교체**

`lib/features/exploration/domain/repositories/exploration_repository.dart` 전체를 교체:

```dart
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
```

- [ ] **Step 2: 로컬 구현 async 전환**

`lib/features/exploration/data/repositories/exploration_repository_impl.dart` 전체를 교체:

```dart
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
```

- [ ] **Step 3: 원격 구현에 `implements` 부착**

`exploration_remote_repository_impl.dart`에서 import에 인터페이스를 추가하고 클래스 선언과 메서드에 override를 단다.

import 블록에 추가:
```dart
import '../../domain/repositories/exploration_repository.dart';
```
클래스 선언 변경:
```dart
class ExplorationRemoteRepositoryImpl implements ExplorationRepository {
```
그리고 `getPlanets`/`getPlanet`/`getRegions`/`unlockRegion`/`unlockPlanet`/`getProgress`/`clearAll` 각 메서드 위에 `@override`를 추가한다. (시그니처는 이미 인터페이스와 동일하므로 본문 변경 없음)

- [ ] **Step 4: 로컬 repo 회귀 테스트 작성**

`test/features/exploration/data/repositories/exploration_local_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/exploration/data/datasources/exploration_local_datasource.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_repository_impl.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ExplorationLocalRepositoryImpl> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ExplorationLocalRepositoryImpl(ExplorationLocalDataSource(prefs));
  }

  test('getPlanets — 시드 반환 (지구 해금 상태)', () async {
    final repo = await build();
    final planets = await repo.getPlanets();
    expect(planets, isNotEmpty);
    expect(planets.first.id, 'earth');
    expect(planets.first.isUnlocked, true);
  });

  test('unlockRegion — currentFuel 센티넬 -1, 상태 저장', () async {
    final repo = await build();
    final result = await repo.unlockRegion('japan');
    expect(result.currentFuel, -1);
    final regions = await repo.getRegions('earth');
    expect(regions.firstWhere((r) => r.id == 'japan').isCleared, true);
  });
}
```

- [ ] **Step 5: 로컬 repo 테스트 통과 확인**

Run: `flutter test test/features/exploration/data/repositories/exploration_local_repository_impl_test.dart`
Expected: PASS (2 tests). (이 시점에 provider/화면은 아직 깨져 있으나 이 테스트 파일은 통과)

> 커밋은 Task 15에서 일괄. 다음 Task로 진행.

---

### Task 9: Provider — 원격 DS provider + repo 분기

**Files:**
- Modify: `lib/features/exploration/presentation/providers/exploration_provider.dart`

- [ ] **Step 1: import 추가**

파일 상단 import 블록에 추가:

```dart
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/exploration_remote_datasource.dart';
import '../../data/repositories/exploration_remote_repository_impl.dart';
import '../../domain/entities/unlock_result_entities.dart';
```

- [ ] **Step 2: 원격 DS provider 추가 + repo 분기 교체**

기존 `explorationRepository` provider 블록(주석 포함)을 아래로 교체:

```dart
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
```

> 본 Task는 Task 10과 함께 빌드되어야 컴파일된다. 계속 진행.

---

### Task 10: Provider — AsyncNotifier 전환 + 해금 분기 + progress

**Files:**
- Modify: `lib/features/exploration/presentation/providers/exploration_provider.dart`

- [ ] **Step 1: `ExplorationNotifier`를 AsyncNotifier로 교체**

기존 `ExplorationNotifier` 클래스 전체를 교체:

```dart
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
```

- [ ] **Step 2: `RegionListNotifier`를 AsyncNotifier로 교체**

기존 `RegionListNotifier` 클래스 전체를 교체:

```dart
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
```

- [ ] **Step 3: progress provider를 async로 교체**

기존 `explorationProgress` provider를 교체:

```dart
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
```

- [ ] **Step 4: 코드 생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `exploration_provider.g.dart` 재생성. (화면 미수정으로 analyze는 아직 오류 — 정상)

> 커밋은 Task 15. 다음 Task로 진행.

---

### Task 11: auth_provider `_clearGuestData` 순환참조 회피

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

- [ ] **Step 1: clearAll 호출을 datasource 직접 호출로 변경**

`_clearGuestData`의 `clearTasks` 리스트에서 아래 줄을:

```dart
      () => ref.read(explorationRepositoryProvider).clearAll(),
```

다음으로 교체:

```dart
      () => ref.read(explorationLocalDataSourceProvider).clearAll(),
```

- [ ] **Step 2: import 확인/추가**

`explorationLocalDataSourceProvider`가 import되어 있지 않으면 import 블록에 추가:

```dart
import '../../../exploration/presentation/providers/exploration_provider.dart';
```

> (기존에 `explorationRepositoryProvider`를 쓰고 있었으므로 동일 파일 import가 이미 존재할 가능성이 높다. 중복 import 금지 — 없을 때만 추가.)

> 커밋은 Task 15. 다음 Task로 진행.

---

### Task 12: explore_screen — AsyncValue 대응

**Files:**
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart`

- [ ] **Step 1: import 추가**

import 블록에 로딩 위젯 추가(미존재 시):

```dart
import '../../../../core/widgets/feedback/app_loading.dart';
```

- [ ] **Step 2: `build()`를 AsyncValue 분기로 교체**

`build()` 내부에서 기존:

```dart
    final planets = ref.watch(explorationNotifierProvider);

    // 현재 위치: 가장 마지막으로 해금된 행성
    var currentPlanetId = '';
    for (int i = planets.length - 1; i >= 0; i--) {
      if (planets[i].isUnlocked) {
        currentPlanetId = planets[i].id;
        break;
      }
    }
```

를 다음으로 교체(여기서 `planets` 지역변수 선언 제거, AsyncValue만 보관):

```dart
    final planetsAsync = ref.watch(explorationNotifierProvider);
```

그리고 `mapHeight` 계산 블록과 `body:` 를 아래 형태로 바꾼다. 즉 `Scaffold`의 `body:` 를:

```dart
      body: planetsAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, __) => _buildEmptyState(),
        data: (planets) {
          if (planets.isEmpty) return _buildEmptyState();

          var currentPlanetId = '';
          for (int i = planets.length - 1; i >= 0; i--) {
            if (planets[i].isUnlocked) {
              currentPlanetId = planets[i].id;
              break;
            }
          }

          final topInset =
              MediaQuery.of(context).padding.top + kToolbarHeight;
          final bottomInset = MediaQuery.of(context).padding.bottom +
              FloatingNavMetrics.totalHeight;
          final mapHeight = topInset +
              _mapTopPadding +
              (planets.length - 1) * _planetSpacing +
              _mapBottomPadding +
              bottomInset;

          return _buildSpaceMap(
            context,
            ref,
            planets,
            currentPlanetId,
            currentFuel,
            isGuest,
            mapHeight,
            topInset,
          );
        },
      ),
```

으로 교체한다. (기존 `build()`에서 `topInset`/`bottomInset`/`mapHeight`를 바깥에서 계산하던 코드와 `body: planets.isEmpty ? ... : _buildSpaceMap(...)` 블록은 위 `data:` 콜백 안으로 이동했으므로 **바깥 선언은 삭제**한다. `currentFuel`/`isGuest`는 기존대로 `build()` 상단에서 계산한 값을 사용.)

- [ ] **Step 3: `_handlePlanetTap`의 목록 read 수정**

`_handlePlanetTap` 내부의 두 곳:

```dart
    final canUnlock = ref
        .read(explorationNotifierProvider.notifier)
        .canUnlockPlanet(planet.id);
    if (!canUnlock) {
      final planets = ref.read(explorationNotifierProvider);
```

에서 `ref.read(explorationNotifierProvider)`를:

```dart
      final planets =
          ref.read(explorationNotifierProvider).valueOrNull ?? const [];
```

로 교체한다. (`canUnlockPlanet`은 notifier 메서드라 변경 불필요)

- [ ] **Step 4: analyze (이 파일)**

Run: `flutter analyze lib/features/explore/presentation/screens/explore_screen.dart`
Expected: 이 파일 자체 오류 0 (다른 미수정 화면 오류는 남아 있을 수 있음).

> 커밋은 Task 15.

---

### Task 13: exploration_detail_screen — AsyncValue 언랩

**Files:**
- Modify: `lib/features/exploration/presentation/screens/exploration_detail_screen.dart`

- [ ] **Step 1: planet select + regions/progress 언랩**

`build()`의 다음 블록:

```dart
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (planets) => planets.where((p) => p.id == widget.planetId).firstOrNull,
      ),
    );
    if (planet == null) {
      return const Scaffold(backgroundColor: AppColors.spaceBackground);
    }
    final regions = ref.watch(regionListNotifierProvider(widget.planetId));
    final progress = ref.watch(explorationProgressProvider(widget.planetId));
```

을 다음으로 교체:

```dart
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (async) =>
            async.valueOrNull?.where((p) => p.id == widget.planetId).firstOrNull,
      ),
    );
    if (planet == null) {
      return const Scaffold(backgroundColor: AppColors.spaceBackground);
    }
    final regions =
        ref.watch(regionListNotifierProvider(widget.planetId)).valueOrNull ??
        const <ExplorationNodeEntity>[];
    final progress =
        ref.watch(explorationProgressProvider(widget.planetId)).valueOrNull ??
        ExplorationProgressEntity(
          nodeId: widget.planetId,
          clearedChildren: 0,
          totalChildren: 0,
        );
```

- [ ] **Step 2: import 확인**

`ExplorationProgressEntity`/`ExplorationNodeEntity` import가 없으면 추가:

```dart
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';
```

- [ ] **Step 3: analyze (이 파일)**

Run: `flutter analyze lib/features/exploration/presentation/screens/exploration_detail_screen.dart`
Expected: 이 파일 자체 오류 0.

> 커밋은 Task 15.

---

### Task 14: location_detail_screen — initState 동기 read 제거 + 언랩

**Files:**
- Modify: `lib/features/exploration/presentation/screens/location_detail_screen.dart`

- [ ] **Step 1: initState에서 동기 read 제거**

기존 `initState`:

```dart
  @override
  void initState() {
    super.initState();
    // regionListNotifierProvider는 동기 StateNotifier로 항상 즉시 데이터 반환
    final regions = ref.read(regionListNotifierProvider(widget.planetId));
    final initialIndex = regions.indexWhere(
      (r) => r.id == widget.initialRegionId,
    );
    _currentPage = initialIndex >= 0 ? initialIndex : 0;
    _pageController = PageController(initialPage: _currentPage);
  }
```

을 다음으로 교체(데이터 미준비 가능 → 0으로 시작, 로드 후 점프):

```dart
  bool _didSetInitialPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  /// regions 로드 후 initialRegionId 페이지로 1회 점프.
  void _maybeSetInitialPage(List<ExplorationNodeEntity> regions) {
    if (_didSetInitialPage || regions.isEmpty) return;
    _didSetInitialPage = true;
    final initialIndex = regions.indexWhere(
      (r) => r.id == widget.initialRegionId,
    );
    if (initialIndex > 0) {
      _currentPage = initialIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(initialIndex);
        }
      });
    }
  }
```

- [ ] **Step 2: build()의 언랩 + 초기 페이지 호출**

`build()`의 다음 블록:

```dart
    final regions = ref.watch(regionListNotifierProvider(widget.planetId));
    final progress = ref.watch(explorationProgressProvider(widget.planetId));
    final currentFuelAsync = ref.watch(currentFuelProvider);
    final currentFuel = currentFuelAsync.valueOrNull ?? 0;
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (planets) => planets.where((p) => p.id == widget.planetId).firstOrNull,
      ),
    );
```

을 다음으로 교체:

```dart
    final regions =
        ref.watch(regionListNotifierProvider(widget.planetId)).valueOrNull ??
        const <ExplorationNodeEntity>[];
    _maybeSetInitialPage(regions);
    final progress =
        ref.watch(explorationProgressProvider(widget.planetId)).valueOrNull ??
        ExplorationProgressEntity(
          nodeId: widget.planetId,
          clearedChildren: 0,
          totalChildren: 0,
        );
    final currentFuelAsync = ref.watch(currentFuelProvider);
    final currentFuel = currentFuelAsync.valueOrNull ?? 0;
    final planet = ref.watch(
      explorationNotifierProvider.select(
        (async) =>
            async.valueOrNull?.where((p) => p.id == widget.planetId).firstOrNull,
      ),
    );
```

- [ ] **Step 3: import 확인**

`ExplorationProgressEntity` import 없으면 추가:

```dart
import '../../domain/entities/exploration_progress_entity.dart';
```
(`exploration_node_entity.dart`는 기존 import에 있음 — 중복 추가 금지)

- [ ] **Step 4: analyze (이 파일)**

Run: `flutter analyze lib/features/exploration/presentation/screens/location_detail_screen.dart`
Expected: 이 파일 자체 오류 0.

> 커밋은 Task 15.

---

### Task 15: planet_node 언랩 + 전체 검증 + 커밋

**Files:**
- Modify: `lib/features/exploration/presentation/widgets/planet_node.dart`

- [ ] **Step 1: progress 언랩**

`planet_node.dart` `build()`의:

```dart
    final progress = ref.watch(explorationProgressProvider(widget.node.id));
```

을 다음으로 교체:

```dart
    final progress =
        ref.watch(explorationProgressProvider(widget.node.id)).valueOrNull ??
        ExplorationProgressEntity(
          nodeId: widget.node.id,
          clearedChildren: 0,
          totalChildren: 0,
        );
```

- [ ] **Step 2: import 확인**

`ExplorationProgressEntity` import 없으면 추가:

```dart
import '../../domain/entities/exploration_progress_entity.dart';
```

- [ ] **Step 3: 코드 생성 + 전체 analyze**

Run: `flutter pub run build_runner build --delete-conflicting-outputs && flutter analyze`
Expected: **No issues found.** (전 파일 컴파일 그린)

- [ ] **Step 4: 전체 테스트**

Run: `flutter test`
Expected: 전체 PASS (신규 + 기존 회귀 포함)

- [ ] **Step 5: 일괄 Commit (Task 8~15)**

```bash
git add lib/features/exploration/domain/repositories/exploration_repository.dart \
  lib/features/exploration/data/repositories/exploration_repository_impl.dart \
  lib/features/exploration/data/repositories/exploration_remote_repository_impl.dart \
  lib/features/exploration/presentation/providers/exploration_provider.dart \
  lib/features/exploration/presentation/providers/exploration_provider.g.dart \
  lib/features/auth/presentation/providers/auth_provider.dart \
  lib/features/explore/presentation/screens/explore_screen.dart \
  lib/features/exploration/presentation/screens/exploration_detail_screen.dart \
  lib/features/exploration/presentation/screens/location_detail_screen.dart \
  lib/features/exploration/presentation/widgets/planet_node.dart \
  test/features/exploration/data/repositories/exploration_local_repository_impl_test.dart
git commit -m "feat : 탐험 Repository async 전환 및 서버 연동 (provider·화면)"
```

---

## Phase 5 — Provider 분기/회귀 테스트

### Task 16: explorationRepository 분기 + 게스트 로그아웃 회귀 테스트

**Files:**
- Test: `test/features/exploration/presentation/exploration_provider_test.dart`

- [ ] **Step 1: 테스트 작성**

`test/features/exploration/presentation/exploration_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/exploration/data/datasources/exploration_local_datasource.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_remote_repository_impl.dart';
import 'package:space_study_ship/features/exploration/data/repositories/exploration_repository_impl.dart';
import 'package:space_study_ship/features/exploration/presentation/providers/exploration_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> container({required bool authed}) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        explorationLocalDataSourceProvider.overrideWithValue(
          ExplorationLocalDataSource(prefs),
        ),
        isAuthenticatedProvider.overrideWith((ref) => authed),
      ],
    );
  }

  test('게스트 → Local repo 주입', () async {
    final c = await container(authed: false);
    addTearDown(c.dispose);
    expect(
      c.read(explorationRepositoryProvider),
      isA<ExplorationLocalRepositoryImpl>(),
    );
  });

  test('인증 → Remote repo 주입', () async {
    final c = await container(authed: true);
    addTearDown(c.dispose);
    expect(
      c.read(explorationRepositoryProvider),
      isA<ExplorationRemoteRepositoryImpl>(),
    );
  });

  test('게스트 정리: localDataSource.clearAll 직접 호출 — 순환참조 없음', () async {
    // 8.1 회귀: repo 분기 추가 후에도 localDataSource 직접 경로가 동작.
    final c = await container(authed: false);
    addTearDown(c.dispose);
    final ds = c.read(explorationLocalDataSourceProvider);
    await ds.saveNodeState(
      const ExplorationNodeState(nodeId: 'japan', isUnlocked: true, isCleared: true),
    );
    await ds.clearAll();
    expect(ds.getAllStates(), isEmpty);
  });
}
```

- [ ] **Step 2: 테스트 통과 확인**

Run: `flutter test test/features/exploration/presentation/exploration_provider_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 3: Commit**

```bash
git add test/features/exploration/presentation/exploration_provider_test.dart
git commit -m "test : 탐험 Repository 분기 및 게스트 정리 회귀 테스트"
```

---

## 최종 검증 (verification-before-completion)

- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` 성공
- [ ] `flutter analyze` — **No issues found**
- [ ] `flutter test` — 전체 PASS
- [ ] (가능 시) 실기기/에뮬레이터: 게스트=지구 해금 동작 불변, 인증=서버 행성 목록 로드/해금 동작 확인
- [ ] DESIGN.md/상수 규칙 준수 (하드코딩·이모지 없음), 커밋 메시지 Claude 태그 없음
