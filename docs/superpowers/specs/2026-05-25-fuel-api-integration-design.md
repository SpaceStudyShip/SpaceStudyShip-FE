# Fuel API 연동 설계 (server-first + 인증 분기) — #79

**Status:** Approved (v2)
**Date:** 2026-05-25
**Owner:** EM-H20
**Related:** #77 (Todo·Category API 연동, 동일 패턴 적용)

**Changelog**
- v1 → v2 (2026-05-25):
  - F1: 인증 분기 코드 예시를 실제 `isAuthenticatedProvider` 사용으로 정정
  - F2: `FuelRepository.getFuel()` / `getTransactions()` 시그니처를 sync → `Future` 로 변경. consumer 7 파일 영향 반영
  - F4: `clearAll()` 인터페이스 "승격" 표현 → "이미 존재, 그대로 사용" 정정
  - 명명 컨벤션 정정: `ServerBackedFuelRepositoryImpl` → `FuelRepositoryImpl` (Todo 패턴과 일치). 기존 구현체는 `LocalFuelRepositoryImpl` 로 rename
  - 작업 분량 재산정: 2일 → 3일 내외
  - F3 (브랜치 base): rebase 완료, "사전 작업" 섹션에서 ✅ 표시

---

## 1. 배경 & 목표

### 배경
- `api-docs.json` 에 `Fuel` 태그가 신설되며 다음 2 엔드포인트가 확정됨
  - `GET /api/fuel` — 연료 잔량 조회
  - `GET /api/fuel/transactions` — 거래 내역 페이지네이션 조회
- 현재 `lib/features/fuel/` 는 LocalDataSource + local 전용 Repository 만 존재 → 디바이스 간 동기화·다중 기기 시나리오·서버 트리거 이벤트 결과를 앱이 받지 못함
- 직전 #77 Todo 가 동일 server-first + cache 폴백 패턴으로 정리됨 → Fuel 도 같은 규약을 따라가야 일관성 유지

### 목표
- 로그인 사용자: 서버를 Source of Truth 로 두고 잔량/거래 내역을 조회
- 게스트: 기존 LocalFuelRepository 동작 그대로 보존
- 본 이슈는 **API 계층 + Repository 분기 + 로그아웃 캐시 정리 + 인터페이스 async 전환** 까지. 거래 내역 UI 는 후속 이슈

### 비-목표 (Non-Goals)
- 거래 내역 화면 (필터·페이지네이션 UI) — 후속 이슈
- 게스트 → 로그인 시 로컬 fuel 마이그레이션 — 백엔드 mutation API 부재로 불가, 별도 정책 결정
- 타이머/탐험 액션 후 invalidate 호출 — 본 이슈는 훅만 노출, 호출은 각 도메인 액션 이슈의 책임
- `pendingMinutes` 활용 — 백엔드도 "향후 확장용, 현재 0" 명시

---

## 2. 사전 작업 (Prerequisites)

| 항목 | 상태 | 비고 |
|---|---|---|
| #77 인증 분기 (`isAuthenticatedProvider`) 가 reachable | ✅ 완료 | 2026-05-25 rebase 로 origin/main(`2f57aa8`) 위로 정렬 |
| #77 Todo Remote DataSource·ApiEndpoints 인프라 | ✅ 완료 | 동일 rebase 로 반영 |
| `docs/api-docs.json` Fuel 엔드포인트 명세 | ✅ 완료 | `9092cca docs : api-docs.json 갱신 #79` |
| 로컬 코드 분석 검증 (실제 메서드명·시그니처) | ✅ 완료 | §6 참조 |

---

## 3. 의사결정 요약

| # | 결정 사항 | 근거 |
|---|---|---|
| D1 | 로그인 사용자 mutation 은 read-only + 재조회 | 백엔드 mutation API 없음. 연료 변동은 도메인 액션(타이머/탐험)의 부수효과. 옵티미스틱은 정각 보너스 등 서버 가산 로직과 충돌 |
| D2 | 게스트는 기존 LocalFuelRepository 유지 | Todo #77 분기 모델과 일관. 학습 타이머는 비로그인 진입 보장 |
| D3 | `chargeFuel`/`consumeFuel` 인터페이스 유지, 서버 구현은 `UnsupportedError` throw | 인터페이스 분리(`ReadOnlyFuelRepository`)보다 단순. 잘못된 호출이 즉시 잡힘 |
| D4 | 잔량 캐시 O / 거래 내역 캐시 X | `FuelGauge` 가 상시 노출 → 잔량 오프라인 폴백 필수. 페이지네이션 캐시는 동기화 복잡도 > 효용 |
| D5 | enum SCREAMING_SNAKE 매핑은 DTO 계층에서만 처리 | 도메인 enum 변경 없음. 와이어 포맷이 변해도 DTO 만 수정 |
| D6 | 거래 내역 UI 는 후속 이슈로 분리 | 필터·무한스크롤·빈 상태 등 디자인 결정 다수 필요. 본 이슈는 인프라 중심 |
| D7 (v2 신규) | **`FuelRepository.getFuel/getTransactions` 시그니처를 sync → `Future` 로 변경** | server-backed 구현은 본질적으로 async. 인터페이스 통합 필수 |
| D8 (v2 신규) | 명명 컨벤션은 Todo 와 동일 — server-backed = `FuelRepositoryImpl`, local = `LocalFuelRepositoryImpl` | 코드베이스 일관성. 기존 파일 rename + 신규 작성 |

---

## 4. 아키텍처

```
┌────────────────────────────────────────────────────┐
│  fuelRepositoryProvider (인증 상태 기반 분기)         │
│                                                    │
│  ref.watch(isAuthenticatedProvider) ?              │
│    YES → FuelRepositoryImpl       (server-backed)  │
│    NO  → LocalFuelRepositoryImpl  (기존 그대로)     │
│                                                    │
│  ┌──────────────────┬────────────────────────┐     │
│  │ Local            │ Server-backed           │    │
│  │ - charge/consume │ - getFuel: 서버+캐시폴백  │    │
│  │ - getTxs(local)  │ - getTxsPage(filter)    │    │
│  │ - clearAll       │ - charge/consume: throw │    │
│  │                  │ - clearAll              │    │
│  └──────────────────┴────────────────────────┘     │
│           │                    │                    │
│           ▼                    ▼                    │
│   LocalFuelDataSource   FuelRemoteDataSource        │
│   (SharedPreferences)   (Retrofit, /api/fuel)       │
└────────────────────────────────────────────────────┘
```

**핵심 원칙**
- `FuelRepository` 인터페이스를 두 구현체가 만족 → consumer 는 분기를 인식 못 함 (단, async 시그니처 전환으로 호출 코드는 `await` / `AsyncValue` 처리 필요)
- 연료 변동은 외부 도메인 액션(추후 타이머/탐험 API) 의 응답 후 `ref.invalidate(fuelRepositoryProvider)` 로 동기화 (본 이슈는 호출 안 함, 훅만 마련)
- 로그아웃·탈퇴 시 server-backed 캐시 invalidate (#77 패턴 재사용, `CircularDependencyError` 회피 포함)

---

## 5. 레이어별 변경

### 5.1 Data Layer

**신규 파일**
- `lib/features/fuel/data/datasources/fuel_remote_datasource.dart` (Retrofit)
  ```dart
  @RestApi()
  abstract class FuelRemoteDataSource {
    factory FuelRemoteDataSource(Dio dio) = _FuelRemoteDataSource;

    @GET(ApiEndpoints.fuel)
    Future<FuelResponseModel> getFuel();

    @GET(ApiEndpoints.fuelTransactions)
    Future<FuelTransactionPageResponseModel> getTransactions({
      @Query('type')      String? type,        // 'charge' | 'consume'
      @Query('startDate') String? startDate,   // YYYY-MM-DD
      @Query('endDate')   String? endDate,
      @Query('page')      int? page,
      @Query('size')      int? size,
    });
  }
  ```
- `lib/features/fuel/data/models/fuel_response_model.dart` (Freezed + JsonSerializable)
  - 필드: `currentFuel`, `totalCharged`, `totalConsumed`, `pendingMinutes`, `lastUpdatedAt`
  - `toEntity()` 확장 제공
- `lib/features/fuel/data/models/fuel_transaction_response_model.dart`
  - 필드: `id`, `type`, `amount`, `reason`, `referenceId?`, `balanceAfter`, `createdAt`
  - `type` / `reason` 은 wire enum (`@JsonValue` 매핑)
  - `toEntity()` 확장 제공
- `lib/features/fuel/data/models/fuel_transaction_page_response_model.dart`
  - 필드: `content[]`, `page`, `size`, `totalElements` (int64), `totalPages`
  - `toEntity()` → `FuelTransactionPage`

**신규 → server-backed Repository**
- `lib/features/fuel/data/repositories/fuel_repository_impl.dart` (신규 작성)
  - 이름은 Todo 와 동일하게 `FuelRepositoryImpl` (server-backed 의 default 명명)
  - `Future<FuelEntity> getFuel()`: remote 호출 → 성공 시 LocalDataSource.saveFuel → entity. DioException → 캐시 폴백 → 캐시도 없으면 `FuelNetworkException`
  - `Future<FuelTransactionPage> getTransactionsPage(filter)`: remote 호출 → 페이지 entity. 캐시 X. 실패 시 예외 전파(`FuelNetworkException`/`FuelServerException`/`InvalidFuelFilterException`)
  - `Future<List<FuelTransactionEntity>> getTransactions({int? limit})`: `UnsupportedError` throw (LocalRepo 전용. 후속에서 server-backed UI 가 페이지 API 직접 사용)
  - `Future<FuelEntity> chargeFuel(...)` / `consumeFuel(...)`: `UnsupportedError('Server mutates fuel via timer/exploration actions')` throw
  - `Future<void> clearAll()`: LocalDataSource.clearAll() 위임

**Rename**
- 기존 `lib/features/fuel/data/repositories/fuel_repository_impl.dart` → `lib/features/fuel/data/repositories/local_fuel_repository_impl.dart`
- 클래스명 `FuelRepositoryImpl` → `LocalFuelRepositoryImpl`. 내부 로직 변경 없음 (단, async 시그니처 전환 한정 — §5.2 인터페이스 변경 참조)
- 이 rename → 신규 server-backed 작성 순서로 진행해야 파일 경로 충돌 안 남

**상수 추가**
- `lib/core/constants/api_endpoints.dart` 에 `fuel`, `fuelTransactions` 추가
  ```dart
  static const String fuel = '/api/fuel';
  static const String fuelTransactions = '/api/fuel/transactions';
  ```

### 5.2 Domain Layer

**신규**
- `lib/features/fuel/domain/entities/fuel_transaction_page.dart` (Freezed)
  ```dart
  @freezed
  class FuelTransactionPage with _$FuelTransactionPage {
    const factory FuelTransactionPage({
      required List<FuelTransactionEntity> items,
      required int page,
      required int size,
      required int totalElements,
      required int totalPages,
    }) = _FuelTransactionPage;
    const FuelTransactionPage._();
    bool get hasNext => page + 1 < totalPages;
  }
  ```
- `lib/features/fuel/domain/entities/fuel_transaction_filter.dart`
  ```dart
  @freezed
  class FuelTransactionFilter with _$FuelTransactionFilter {
    const factory FuelTransactionFilter({
      FuelTransactionType? type,
      DateTime? startDate,
      DateTime? endDate,
      @Default(0) int page,
      @Default(20) int size,
    }) = _FuelTransactionFilter;
  }
  ```
- `lib/features/fuel/domain/usecases/get_fuel_transactions_page_usecase.dart`

**수정 (v2 핵심)**
- `lib/features/fuel/domain/repositories/fuel_repository.dart` — sync → async 일괄 전환
  ```dart
  abstract class FuelRepository {
    Future<FuelEntity> getFuel();                                        // sync → async
    Future<FuelEntity> chargeFuel(int amount, int pendingMinutes,
        FuelTransactionReason reason, [String? referenceId]);            // 시그니처 동일
    Future<FuelEntity> consumeFuel(int amount,
        FuelTransactionReason reason, [String? referenceId]);            // 시그니처 동일
    Future<List<FuelTransactionEntity>> getTransactions({int? limit});   // sync → async
    Future<FuelTransactionPage> getTransactionsPage(FuelTransactionFilter filter); // 신규
    Future<void> clearAll();                                             // 기존 그대로
  }
  ```
- `LocalFuelRepositoryImpl` 도 sync → async 로 변경 (실제 작업은 `Future.value(...)` 래핑 정도, 트리비얼)

**미수정**
- `FuelEntity`, `FuelTransactionEntity`, `FuelTransactionType`, `FuelTransactionReason` — 변경 없음

### 5.3 Presentation Layer

**`lib/features/fuel/presentation/providers/fuel_provider.dart`**
- `fuelRemoteDataSourceProvider` 신규
- `fuelRepositoryProvider` 를 `isAuthenticatedProvider` watch 하여 분기 반환 (Todo 패턴 그대로)
  ```dart
  @riverpod
  FuelRepository fuelRepository(Ref ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (isAuthenticated) {
      return FuelRepositoryImpl(
        remote: ref.watch(fuelRemoteDataSourceProvider),
        local: ref.watch(localFuelDataSourceProvider),
      );
    }
    return LocalFuelRepositoryImpl(ref.watch(localFuelDataSourceProvider));
  }
  ```
- `fuelTransactionsPageProvider.family((FuelTransactionFilter f) => ...)` 신규 — 후속 UI 가 바로 사용 가능
- 로그아웃 훅: Todo 패턴(`f8cdd97`의 `CircularDependencyError` 회피) 그대로 — try/catch + `Future.microtask` 로 `clearAll()` 호출 후 invalidate

**Consumer 변경 (v2 — sync → async 영향)**
다음 7 파일이 `FuelRepository.getFuel()` / `getTransactions()` 결과를 동기로 받고 있음. 모두 `AsyncValue<...>` 처리로 변경 필요.

| 파일 | 변경 내용 |
|---|---|
| `lib/features/fuel/presentation/providers/fuel_provider.dart` | `fuelProvider` 가 `FuelEntity` 반환 → `Future<FuelEntity>` 또는 `@riverpod` async notifier 로 전환 |
| `lib/core/widgets/space/fuel_gauge.dart` | `ref.watch(fuelProvider)` 결과를 `AsyncValue.when` 으로 분기. loading/error 상태 처리 추가 |
| `lib/core/widgets/space/status_card.dart` | 동일 |
| `lib/features/exploration/presentation/screens/exploration_detail_screen.dart` | 동일 |
| `lib/features/exploration/presentation/screens/location_detail_screen.dart` | 동일 |
| `lib/features/exploration/presentation/widgets/boarding_pass_ticket.dart` | 동일 |
| `lib/features/explore/presentation/screens/explore_screen.dart` | 동일 |

**Loading/Error UI 정책**
- `FuelGauge` 등 상시 노출 위젯: loading 시 마지막 캐시 값으로 그대로 표시 (서버 성공 시 갱신). error 시 동일하게 캐시 표시 + 디버그 로그
- 상세 화면 (`exploration_detail_screen` 등): 진입 시 `AsyncValue.when` loading → 작은 spinner, error → 토스트/배지

---

## 6. 캐시 정책

| 데이터 | 캐시 | 폴백 | 비고 |
|---|---|---|---|
| `GET /api/fuel` | O (LocalDataSource write-through) | 네트워크 실패 시 캐시 반환, 없으면 `FuelNetworkException` | FuelGauge 상시 노출 |
| `GET /api/fuel/transactions` | X | 실패 시 예외 전파 → UI 가 안내 | 페이지네이션 캐시는 동기화 비용 > 효용 |

- 로그아웃 시 `clearAll()` 로 캐시 비움 → 다른 계정 데이터 노출 방지
- 캐시는 항상 도메인 enum.name 형식으로 영속 (`studySession`), 와이어 매핑은 DTO 가 담당

---

## 7. DTO ↔ Domain 매핑

### enum 매핑 (SCREAMING_SNAKE ↔ camelCase)

서버 `reason` 은 `STUDY_SESSION` / `EXPLORATION_UNLOCK`, Dart enum 은 `studySession` / `explorationUnlock`. **DTO 측에서만 처리**.

```dart
enum FuelTransactionReasonWire {
  @JsonValue('STUDY_SESSION') studySession,
  @JsonValue('EXPLORATION_UNLOCK') explorationUnlock,
}
```

DTO → Entity 변환 시 wire enum → 도메인 enum 매핑.

`type` 은 `charge` / `consume` 으로 양쪽 동일 → 추가 매핑 불필요.

### 미지 enum 값 폴백

서버가 향후 새 reason (예: `MISSION_REWARD`) 을 추가하면 `JsonValueOutOfRange` 예외 발생 가능 → `unknownEnumValue: FuelTransactionReasonWire.studySession` 지정 + `debugPrint('⚠️ Unknown fuel reason: $raw')` 로그. 클라 크래시 방지.

### 캐시-와이어 분리

- 영속 (LocalDataSource): `enum.name` (`studySession`)
- 와이어 (Remote DTO): `@JsonValue` 매핑 (`STUDY_SESSION`)

→ 기존 게스트 사용자의 로컬 캐시 마이그레이션 불필요.

---

## 8. 에러 처리

| 상황 | 서버 Repository 동작 | UI 노출 |
|---|---|---|
| 401 UNAUTHENTICATED_REQUEST | `AuthInterceptor` 가 reissue → 성공 시 재요청, 실패 시 강제 로그아웃 | 사용자 무감지 / 로그인 화면 이동 |
| 400 INVALID_INPUT_VALUE (transactions query) | `InvalidFuelFilterException` throw | 호출부 책임 (필터 UI 후속) |
| 500 INTERNAL_SERVER_ERROR | `FuelServerException` throw. `getFuel` 은 캐시 폴백 우선 시도 | 에러 상태 표시 |
| DioException (네트워크/타임아웃) | `getFuel`: 캐시 폴백 / 없으면 `FuelNetworkException`. `getTransactionsPage`: 즉시 `FuelNetworkException` | 오프라인 안내 |
| `UnsupportedError` (mutation 시도) | 즉시 throw | 개발 단계 차단, 프로덕션엔 노출 X |

**예외 클래스** (`lib/features/fuel/domain/exceptions/fuel_exceptions.dart` 추가)
- `FuelServerException`
- `FuelNetworkException`
- `InvalidFuelFilterException`
- 기존 `InsufficientFuelException` 는 LocalRepo 전용으로 유지

---

## 9. 테스트 계획 (TDD: RED → GREEN → REFACTOR)

### Unit Tests

| 대상 | 케이스 |
|---|---|
| `FuelResponseModel.fromJson / toEntity` | 정상 파싱, `pendingMinutes=0`, ISO 8601 `lastUpdatedAt` 파싱 |
| `FuelTransactionResponseModel.fromJson` | `STUDY_SESSION` → `studySession`, `EXPLORATION_UNLOCK` → `explorationUnlock`, 미지 enum → fallback + 경고 로그 |
| `FuelTransactionPageResponseModel.fromJson` | `content[]` empty / 다중 항목 / `totalElements` int64 경계값 |
| `FuelRepositoryImpl` (server-backed) | `getFuel`: (1) remote 성공 → entity + 캐시 저장 verify, (2) DioException → 캐시 반환, (3) 캐시도 없음 → `FuelNetworkException` |
| `FuelRepositoryImpl.getTransactionsPage` | (1) 정상 페이지 반환, (2) `hasNext` 계산, (3) DioException → `FuelNetworkException`, (4) 500 → `FuelServerException` |
| `FuelRepositoryImpl.chargeFuel/consumeFuel` | `UnsupportedError` throw |
| `FuelRepositoryImpl.clearAll` | LocalDataSource.clearAll 위임 verify |
| `LocalFuelRepositoryImpl` | 기존 테스트 유지 (회귀 방지) + async 시그니처 적응 |

### Provider Tests

| 대상 | 케이스 |
|---|---|
| `fuelRepositoryProvider` | (1) `isAuthenticated=false` → `LocalFuelRepositoryImpl`, (2) `isAuthenticated=true` → `FuelRepositoryImpl`, (3) 상태 전환 시 invalidate |
| 로그아웃 캐시 정리 훅 | signOut → `clearAll` 호출, `CircularDependencyError` 미발생 (#77 회귀 방지) |

### Consumer 회귀 테스트 (v2 신규)
- `FuelGauge`, `status_card`, `exploration_detail_screen` 등 7 consumer 가 `AsyncValue` 로딩/에러 상태에서 깨지지 않고 fallback UI 표시하는지 widget test 로 검증

### Mock 전략
`mocktail` + `MockFuelRemoteDataSource` 직접 모킹 (Retrofit 어댑터 모킹은 verbose).

### 커버리지
Fuel 모듈 신규 코드 80% 이상 (글로벌 testing.md 기준).

### 범위 외
E2E 테스트는 후속 UI 이슈에서 다룸.

---

## 10. 위험과 대응

| 위험 | 가능성 | 영향 | 대응 |
|---|---|---|---|
| 백엔드 enum 값 추가 (`MISSION_REWARD` 등) | 중 | 클라 크래시 | `unknownEnumValue` fallback + 경고 로그 |
| 잔량 SoT 불일치 (다른 디바이스 충전) | 중 | 옛 캐시 표시 | 화면 진입마다 invalidate, pull-to-refresh (후속 UI 이슈) |
| `AuthInterceptor` reissue 큐 동시 호출 | 낮 | 중복 401 처리 | 기존 인터셉터 큐잉 (#77 검증) |
| 로그아웃 `CircularDependencyError` 재발 | 중 | signOut 실패 | #77 fix 패턴 (try/catch + `Future.microtask`) |
| baseUrl 플레이스홀더 `백엔드주소` | 낮 | 빌드/런타임 실패 | 본 이슈 코드는 `ApiEndpoints.*` 상수만 사용. baseUrl 확정은 별도 인프라 작업 |
| sync → async 전환으로 인한 consumer 회귀 (v2 신규) | 중 | UI loading/error 상태 누락 | 7 consumer 모두 widget test 추가, `AsyncValue.when` 패턴 표준화 |

---

## 11. 후속 이슈 (이 이슈 머지 후 별도 티켓)

1. **거래 내역 화면** — 필터 UI + 무한 스크롤 + 빈 상태 + 오프라인 안내
2. **타이머 완료 → 연료 동기화 연결** — 타이머 액션 이슈에서 `ref.invalidate(fuelRepositoryProvider)` 호출
3. **장소 해금 → 연료 동기화 연결** — 동일 패턴
4. **fuel mutation API 협의** — 클라 mutation use case 추가 시 백엔드 협의

---

## 12. 작업 분량 추정 (참고) — v2 갱신

| 단계 | 분량 |
|---|---|
| Data layer (Remote DataSource + 3 DTO + server-backed Repo + rename) | 1일 |
| Domain layer (Page entity + Filter VO + Repository 인터페이스 async 전환 + UseCase) | 3-4 시간 |
| Presentation layer (provider 분기 + 로그아웃 훅 + **consumer 7 파일 AsyncValue 처리**) | 1일 |
| TDD 테스트 작성 (3 DTO + 2 Repo + 2 Provider + 7 consumer widget test) | 1일 |
| `flutter analyze` / `flutter test` 통과 + 회귀 검증 | 2-3 시간 |
| **총합 (혼자 작업 기준)** | **3일 내외** |

---

## 13. 파일 변경 요약

**신규**
- `lib/features/fuel/data/datasources/fuel_remote_datasource.dart`
- `lib/features/fuel/data/models/fuel_response_model.dart`
- `lib/features/fuel/data/models/fuel_transaction_response_model.dart`
- `lib/features/fuel/data/models/fuel_transaction_page_response_model.dart`
- `lib/features/fuel/data/repositories/fuel_repository_impl.dart` (server-backed, 신규 작성)
- `lib/features/fuel/domain/entities/fuel_transaction_page.dart`
- `lib/features/fuel/domain/entities/fuel_transaction_filter.dart`
- `lib/features/fuel/domain/usecases/get_fuel_transactions_page_usecase.dart`
- 테스트 파일 다수 (§9 참조)

**Rename**
- 기존 `lib/features/fuel/data/repositories/fuel_repository_impl.dart` → `local_fuel_repository_impl.dart` (`FuelRepositoryImpl` → `LocalFuelRepositoryImpl`)

**수정**
- `lib/features/fuel/domain/repositories/fuel_repository.dart` (sync → async 시그니처 일괄 변경, `getTransactionsPage` 추가)
- `lib/features/fuel/domain/exceptions/fuel_exceptions.dart` (예외 3 종 추가)
- `lib/features/fuel/presentation/providers/fuel_provider.dart` (분기 + 로그아웃 훅 + async notifier 전환)
- `lib/core/constants/api_endpoints.dart` (fuel 상수 추가)
- Consumer 7 파일 (§5.3 표 참조) — `AsyncValue` 처리

**미수정**
- `lib/features/fuel/domain/entities/fuel_entity.dart`
- `lib/features/fuel/domain/entities/fuel_transaction_entity.dart`
- `lib/features/fuel/data/datasources/fuel_local_datasource.dart`

---

**End of spec (v2).**
