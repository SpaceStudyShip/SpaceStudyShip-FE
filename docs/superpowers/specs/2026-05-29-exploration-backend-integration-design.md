# 행성/지역 해금(Exploration) 백엔드 연동 설계

**작성일:** 2026-05-29
**대상 도메인:** `lib/features/exploration` + 소비처 `lib/features/explore`
**참조 API:** `docs/api-docs.json` — `Exploration` 태그 4개 엔드포인트

---

## 1. 목표

`api-docs.json`에 추가된 Exploration 도메인(행성/지역 해금)을 클라이언트에 연동한다.
**fuel feature와 동일한 패턴**으로, 인증(소셜 로그인) 사용자는 서버를, 게스트는 기존 로컬을 사용한다.

### 핵심 결정
- **서버가 source of truth** — 인증 사용자는 카탈로그(이름/아이콘/위치/필요연료)와 해금 상태를 모두 서버에서 받는다. 시드 데이터(`exploration_seed_data.dart`)는 **게스트 전용**으로 남긴다.
- **게스트 독립성** — 로그인 시 마이그레이션/동기화 **없음**. `guest_exploration_states`(SharedPreferences)는 그대로 별개 유지. (fuel/todo와 동일)
- **동기 → async 전환** — 현재 `ExplorationNotifier`는 동기 Notifier(`List` 즉시 반환). 서버 fetch를 위해 AsyncNotifier(`Future<List>`)로 전환하고, 소비 화면 4곳을 `AsyncValue.when()`으로 리팩터한다.

---

## 2. 백엔드 API 매핑

| 메서드 | 경로 | 응답 | 비고 |
|---|---|---|---|
| GET | `/api/explorations/planets` | `PlanetResponse[]` | 전체 행성 + 해금/클리어 상태 + `progress`(ProgressDto). sortOrder 오름차순 |
| GET | `/api/explorations/planets/{planetId}/regions` | `RegionResponse[]` | 행성 하위 지역 + 해금 상태. 404 `PLANET_NOT_FOUND` |
| POST | `/api/explorations/regions/{regionId}/unlock` | `RegionUnlockResponse` | 원자적 연료 확인+차감+해금(=클리어). `{region, fuelConsumed, currentFuel, planetCleared}` |
| POST | `/api/explorations/planets/{planetId}/unlock` | `PlanetUnlockResponse` | 원자적. 선행 행성 클리어 필요. `{planet, fuelConsumed, currentFuel}` |

### unlock 에러 코드 (400/404)
- `INSUFFICIENT_FUEL` — 본문에 `requiredFuel`/`currentFuel` 동봉
- `ALREADY_UNLOCKED`
- region: `PLANET_LOCKED` / planet: `PREREQUISITE_NOT_CLEARED`
- `REGION_NOT_FOUND` / `PLANET_NOT_FOUND`

### 서버 응답 ↔ 엔티티 매핑
- `PlanetResponse`/`RegionResponse` → `ExplorationNodeEntity`
  - `nodeType`(string) → `ExplorationNodeType` enum
  - `unlockedAt`(string, nullable) → `DateTime?`
  - 나머지(name, icon, depth, parentId, requiredFuel, isUnlocked, isCleared, sortOrder, description, mapX, mapY) 1:1
- `PlanetResponse.progress`(ProgressDto) → `ExplorationProgressEntity`
  - 행성 목록 응답에 progress가 내장되므로, 인증 모드 progress는 **지역 재조회 없이** 행성 목록에서 읽는다.

---

## 3. 추가/변경 파일

### 3.1 신규 (Data Layer)
```
data/datasources/exploration_remote_datasource.dart   # Retrofit, 4 엔드포인트
data/models/planet_response_model.dart                 # + ProgressDto 중첩, toEntity()
data/models/region_response_model.dart                 # toEntity()
data/models/region_unlock_response_model.dart          # + UnlockedNodeDto 중첩
data/models/planet_unlock_response_model.dart
data/repositories/exploration_remote_repository_impl.dart
```
모델은 프로젝트 표준대로 **Freezed + JsonSerializable** 사용 (fuel 모델과 동일 스타일).

### 3.2 신규 (Domain Layer)
```
domain/entities/region_unlock_result_entity.dart       # { planetCleared, currentFuel }
domain/entities/planet_unlock_result_entity.dart       # { currentFuel }
domain/exceptions/exploration_exceptions.dart          # 아래 4) 참조
```
> **엔티티 스타일:** 기존 `ExplorationNodeEntity`/`ExplorationProgressEntity`는 **plain class**(Freezed 아님, 수기 `copyWith`). 신규 result 엔티티 2개도 **plain class**로 맞춘다. DTO 응답 모델(3.1)만 Freezed + JsonSerializable.

### 3.3 변경
- `core/constants/api_endpoints.dart` — Exploration 경로 5개 상수 추가
  ```dart
  static const explorationPlanets = '/api/explorations/planets';
  static String explorationRegions(String planetId) => '/api/explorations/planets/$planetId/regions';
  static String explorationUnlockRegion(String regionId) => '/api/explorations/regions/$regionId/unlock';
  static String explorationUnlockPlanet(String planetId) => '/api/explorations/planets/$planetId/unlock';
  ```
- `domain/repositories/exploration_repository.dart` — **전 메서드 async 화** (아래 5)
- `data/repositories/exploration_repository_impl.dart`(로컬) — async 시그니처에 맞춰 `Future`로 래핑 (로직 동일)
- `presentation/providers/exploration_provider.dart` — repo 분기 + AsyncNotifier 전환
- **`auth/presentation/providers/auth_provider.dart` `_clearGuestData`(~355줄)** — `ref.read(explorationRepositoryProvider).clearAll()` → **`ref.read(explorationLocalDataSourceProvider).clearAll()`** 로 변경 (아래 8.1, 순환참조 회피)
- 소비 화면 4곳 — `AsyncValue` 리팩터 (아래 6·7)

---

## 4. 예외 처리

서버 unlock 실패는 **exploration_remote_repository_impl 내부**에서 `DioException` 본문의 `code`를 보고 매핑한다(중앙 `DioExceptionHandler` 대신 도메인 국소 처리 — fuel과 동일 철학).

### 4.1 연료 부족은 기존 fuel 예외 재사용 (중요)
`INSUFFICIENT_FUEL`은 **새 예외를 만들지 않고** fuel 도메인의 기존 `InsufficientFuelException`(`lib/features/fuel/domain/exceptions/fuel_exceptions.dart`)을 **재사용**한다.

이유: 해금 UI 공통 진입점 `showUnlockDialog`(`core/utils/unlock_dialog_helper.dart`)가 이미
```dart
} on InsufficientFuelException catch (e) {
  AppSnackBar.error(context, e.toString()); // "연료가 부족합니다 (필요:.., 보유:..)"
```
로 잡는다. 새 타입을 만들면 이 catch를 타지 못하고 `catch(_)` "해금에 실패했습니다" generic 메시지로 떨어진다.

```dart
// remote repo 매핑
throw InsufficientFuelException(
  requiredAmount: body['requiredFuel'] as int,
  available: body['currentFuel'] as int,
);
```
> `InsufficientFuelException`은 plain `Exception`(AppException 아님), 필드명은 `requiredAmount`/`available`.

### 4.2 나머지 exploration 코드
`domain/exceptions/exploration_exceptions.dart` (plain `Exception` 또는 AppException — UI 표시만 하므로 plain으로 충분):
| 클래스 | 매핑 코드 | 비고 |
|---|---|---|
| `NodeAlreadyUnlockedException` | `ALREADY_UNLOCKED` | |
| `PlanetLockedException` | `PLANET_LOCKED` | 지역 해금 시 상위 행성 잠김 |
| `PrerequisiteNotClearedException` | `PREREQUISITE_NOT_CLEARED` | 선행 행성 미클리어 |
| `ExplorationNodeNotFoundException` | `REGION_NOT_FOUND`/`PLANET_NOT_FOUND` | |

화면은 두 경로(게스트/서버) 모두 unlock 전 **사전 검증**(연료/순서)으로 이미 차단하므로, 이 예외들은 **레이스 상황의 안전망**이다.

### 4.3 다이얼로그 에러 처리는 이미 존재 (신규 작업 아님)
`showUnlockDialog`가 `onUnlock` 호출을 이미 try/catch로 감싼다. 신규 예외(`ALREADY_UNLOCKED` 등)는 현재 `catch(_)` → "해금에 실패했습니다"로 떨어지며, 더 친절한 안내가 필요하면 `showUnlockDialog`에 `on NodeAlreadyUnlockedException` 등 케이스를 **추가**한다(화면 코드 변경 아님).

매핑 외 DioException은 기존 `DioExceptionHandler.handle(e)`로 위임(네트워크/타임아웃/401 등 일관 처리).

---

## 5. Repository 인터페이스 (async 전환)

```dart
abstract class ExplorationRepository {
  Future<List<ExplorationNodeEntity>> getPlanets();
  Future<ExplorationNodeEntity> getPlanet(String planetId);
  Future<List<ExplorationNodeEntity>> getRegions(String planetId);
  Future<RegionUnlockResultEntity> unlockRegion(String regionId);
  Future<PlanetUnlockResultEntity> unlockPlanet(String planetId);
  Future<ExplorationProgressEntity> getProgress(String planetId);
  Future<void> clearAll();
}
```

### 로컬 구현 (게스트)
- 기존 동기 로직을 `Future`로 래핑 (시드 + SharedPreferences 머지).
- `unlockRegion`: 기존처럼 해금=클리어 저장 + 행성 자동 클리어 체크 → `RegionUnlockResultEntity(planetCleared, currentFuel: -1)`. 게스트는 연료를 Notifier가 별도 차감하므로 `currentFuel`은 미사용(센티넬).
- `unlockPlanet` → `PlanetUnlockResultEntity(currentFuel: -1)`.

### 원격 구현 (인증)
- `getPlanets`/`getRegions`: API fetch → `toEntity()`. 네트워크 실패 시 정책은 **6.4** 참조.
- `getProgress(planetId)`: **최근 getPlanets 결과(in-memory 캐시)의 해당 행성 progress**를 반환. 캐시 미스 시 `getPlanets()` 1회 호출 후 조회.
- `unlockRegion`/`unlockPlanet`: API 호출 → 결과 엔티티. 실패 시 4) 매핑.
- `clearAll`: in-memory 캐시만 비움. **호출 경로 없음(dead)** — 회원 로그아웃/탈퇴는 서버가 데이터 정리, 게스트 정리는 localDataSource 직접(8.1). 인터페이스 만족을 위해 둔다.

---

## 6. Provider & 해금 흐름

### 6.1 Repository 분기 (fuel 패턴 복제)
```dart
@Riverpod(keepAlive: true)
ExplorationRemoteDataSource explorationRemoteDataSource(Ref ref) =>
    ExplorationRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
ExplorationRepository explorationRepository(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return ExplorationRemoteRepositoryImpl(ref.watch(explorationRemoteDataSourceProvider));
  }
  return ExplorationLocalRepositoryImpl(ref.watch(explorationLocalDataSourceProvider));
}
```
> `isAuthenticatedProvider`는 게스트면 false. 로그인 상태 변화 시 repo가 자동 스왑되고 Notifier가 재빌드된다.

### 6.2 ExplorationNotifier (동기 → AsyncNotifier)
```dart
@Riverpod(keepAlive: true)
class ExplorationNotifier extends _$ExplorationNotifier {
  @override
  Future<List<ExplorationNodeEntity>> build() async =>
      ref.watch(explorationRepositoryProvider).getPlanets();
  // ...
}
```
- `canUnlockPlanet`: `state.valueOrNull ?? []`에서 sortOrder 검증.
- `unlockPlanet(planetId, requiredFuel)` — isAuthenticated 분기:
  - **게스트:** 기존 그대로 — `fuelNotifier.consumeFuel()`(로컬 차감) → `repo.unlockPlanet()` → reload.
  - **인증:** 사전 차감 없음 — `repo.unlockPlanet()`(서버 원자 차감) → `ref.invalidate(fuelNotifierProvider)`(잔량 재조회) → reload.
  - 공통: 성공 후 배지 체크(`badgeNotifier.checkAndUnlock`, 실패 무시), `ref.invalidateSelf()`로 목록 재조회.

### 6.3 RegionListNotifier (family, async 전환)
```dart
Future<List<ExplorationNodeEntity>> build(String planetId) async =>
    ref.watch(explorationRepositoryProvider).getRegions(planetId);
```
- `unlockRegion(regionId, requiredFuel)` — 게스트/인증 분기는 `unlockPlanet`과 동일 원칙.
  - 성공 후 지역 목록 재조회 + `explorationNotifier` 재조회(행성 자동 클리어/progress 반영).

### 6.4 progress provider (async 전환)
```dart
@riverpod
Future<ExplorationProgressEntity> explorationProgress(Ref ref, String planetId) {
  ref.watch(explorationNotifierProvider); // 행성 목록 변경 시 갱신
  return ref.watch(explorationRepositoryProvider).getProgress(planetId);
}
```
> **주의:** 그리드의 `planet_node`가 행성마다 progress를 조회한다. `regionListNotifier`를 watch하면 **인증 모드에서 행성 수만큼 지역 API가 호출**된다(서버 progress는 행성 목록에 내장되어 불필요). 대신 `explorationNotifierProvider`(행성 목록)를 watch한다 — 인증 모드는 목록 재조회로 progress 갱신, 게스트는 지역 unlock 후 `explorationNotifier.refresh()`(6.3)가 호출되므로 동일하게 재계산된다. 인증 `getProgress`는 행성 캐시에서 즉시 반환(추가 fetch 없음).

### 6.5 네트워크 실패 정책 (인증 모드)
- `getPlanets`/`getRegions` 실패 → 예외 전파 → 화면 `.when(error:)`에서 재시도 UI 노출. (랭킹 등 Tier 3와 동일하게 "서버 우선, 실패 시 사용자 안내")
- unlock 실패 → 4) 예외 → 화면에서 SnackBar 안내, 상태 미변경.

---

## 7. 화면 리팩터 (4곳) — 단순 `.when()` 이상, 동기 의존 제거 포함

`ExplorationNotifier`/`RegionListNotifier`/`explorationProgress`가 `AsyncValue`로 바뀌면서, 화면들이 **동기 List/progress에 의존하던 지점**을 모두 풀어야 한다. 단순 래핑보다 범위가 크다.

| 파일 | 변경 |
|---|---|
| `explore/.../explore_screen.dart` | `build()`가 `planets`로 `currentPlanetId` 루프 + `mapHeight` 계산 + `planets.isEmpty`를 함 → **데이터 분기 전체를 `.when()` 안으로** 이동. `canUnlockPlanet`/목록 read는 `state.valueOrNull ?? []`. (unlock 예외 처리는 `showUnlockDialog`가 이미 담당 — 화면 추가 불필요) |
| `exploration/.../exploration_detail_screen.dart` | `explorationNotifierProvider.select((planets)=>...)` → **`AsyncValue` 기준 셀렉터**(`.select((a)=>a.valueOrNull?.where(...).firstOrNull)`). `regions`/`progress`를 빌더(`_buildTicketFront(planet, progress)` 등)에 직접 넘기던 것 → **언랩 후 전달**(`.valueOrNull`/`.when()`) |
| `exploration/.../location_detail_screen.dart` | **`initState()`의 동기 `ref.read(regionListNotifierProvider)`로 PageController 초기 페이지 계산 → 재구성 필요**(async라 initState 시점에 데이터 없음). 데이터 로드 후 `initialRegionId`로 페이지 설정(`ref.listen` 또는 `.when` data 콜백에서 `jumpToPage`). regions/progress/`.select` 동일 언랩 |
| `exploration/.../widgets/planet_node.dart` | `progress` → `AsyncValue` 언랩 (로딩 시 0 진행도 placeholder) |

로딩/에러 UI는 기존 공통 위젯(`AppLoading`, `SpaceEmptyState`/SnackBar) 재사용. **하드코딩·이모지 금지** 규칙 준수.

---

## 8. 게스트 모드 보장 (회귀 방지)

### 8.1 게스트 로그아웃 정리 — 순환참조 회피 (필수)
`auth_provider.dart`의 `_clearGuestData`는 현재 게스트 정리에서
```dart
() => ref.read(explorationRepositoryProvider).clearAll(),
```
를 호출한다. `explorationRepositoryProvider`에 `isAuthenticatedProvider` watch를 추가하면, `authNotifier` 내부에서 이 repo를 read할 때 **CircularDependencyError**가 발생한다(같은 파일 주석이 todo/fuel에서 이미 경고 — 그래서 그들은 `localTodoDataSourceProvider`/`fuelLocalDataSourceProvider`를 **직접** 호출).

**변경:** 해당 줄을 datasource 직접 호출로 교체한다.
```dart
() => ref.read(explorationLocalDataSourceProvider).clearAll(),
```
> 게스트 정리는 로컬 상태만 지우면 되므로 datasource 직접 호출이 의미상으로도 정확하다. (이 변경 없이 분기 추가 시 기존 게스트 로그아웃이 즉시 깨짐)

### 8.2 기타
- 게스트(`isAuthenticated == false`)는 기존 `ExplorationLocalRepositoryImpl` 경로 100% 유지. unlock 흐름·시드·SharedPreferences 동작 불변.
- 게스트는 지구만 접근 가능(비-지구 행성은 로그인 유도) — 기존 explore_screen 로직 유지.
- 로그인↔게스트 전환 시 데이터 교차 없음.

---

## 9. 테스트 계획 (TDD)

**Data Layer (unit):**
- `planet_response_model`/`region_response_model` `fromJson`/`toEntity` 매핑 (nodeType enum, unlockedAt null/non-null, progress).
- `region_unlock_response_model`/`planet_unlock_response_model` 파싱.
- `ExplorationRemoteRepositoryImpl`: 성공 매핑, unlock 에러코드→예외 매핑 — 특히 **`INSUFFICIENT_FUEL` → 기존 `InsufficientFuelException(requiredAmount, available)`** 재사용 검증(본문 `requiredFuel`/`currentFuel` 파싱), getProgress 캐시 동작 (mocktail로 DataSource mock).
- `ExplorationLocalRepositoryImpl`: async 시그니처 회귀 (기존 동작 유지).

**Provider (unit):**
- `explorationRepository` 분기 (인증 true→Remote, false→Local) — auth override.
- `ExplorationNotifier`/`RegionListNotifier` 인증/게스트 unlock 분기 (게스트=consumeFuel 호출, 인증=fuel invalidate, consumeFuel 미호출).
- **게스트 로그아웃 회귀(8.1):** repo 분기 추가 후에도 게스트 `signOut`이 CircularDependencyError 없이 exploration 로컬 상태를 비우는지 (auth_provider `_clearGuestData` 통합 테스트 또는 datasource 직접 호출 검증).

**검증:** `flutter analyze` 0 경고, `flutter test` 전체 통과, 게스트 회귀 통과.

---

## 10. 범위 외 (YAGNI)
- 게스트→서버 데이터 마이그레이션
- 오프라인 unlock 큐잉/재시도
- galaxy/starSystem 계층 (확장용 enum만 존재, 미사용)
- 서버 카탈로그 변경 실시간 푸시
