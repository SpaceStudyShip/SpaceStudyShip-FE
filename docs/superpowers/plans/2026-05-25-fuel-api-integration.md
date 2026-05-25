# Fuel API 백엔드 연동 Implementation Plan (#79)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fuel 도메인 Data Layer 를 `docs/api-docs.json` 의 Fuel 태그 2 엔드포인트(`GET /api/fuel`, `GET /api/fuel/transactions`)와 정렬하고, Todo #77 패턴(server-first + cache 폴백 + 인증 분기 + 로그아웃 캐시 정리)을 그대로 적용한다.

**Architecture:** `isAuthenticatedProvider` 값에 따라 `FuelRepositoryImpl`(server-backed, Remote+Cache) 또는 `LocalFuelRepositoryImpl`(게스트 전용) 가 주입된다. 인터페이스의 `getFuel`/`getTransactions` 가 sync → async 로 전환되며, 그 영향으로 `fuelNotifierProvider`/`currentFuelProvider` 및 3개 화면이 `AsyncValue` 처리로 변경된다. mutation(`chargeFuel`/`consumeFuel`)은 server-backed 시 Repository 레벨에서 `UnsupportedError` 를 던지고, Notifier 레벨에서 `ref.invalidate(fuelRepositoryProvider)` 로 우회하여 기존 호출자(timer/exploration) 코드를 보존한다.

**Tech Stack:** Flutter 3.9 · Riverpod 2.6 (generator) · Freezed 2.5 · Dio 5.9 · Retrofit 4.7 · mocktail (테스트)

**Spec:** `docs/superpowers/specs/2026-05-25-fuel-api-integration-design.md` (v2)

---

## Spec 보완 노트 (v2 → 실제 코드 검증)

현행 코드 확인 후 v2 spec 의 가정 중 다음 4 가지를 plan 단위에서 정정한다 (방향성은 동일):

| # | v2 spec 가정 | 실제 코드 | 본 plan 의 처리 |
|---|---|---|---|
| 1 | 로그아웃 시 fuel 캐시 정리 훅을 **신규** 작성 | `auth_provider.dart:_clearGuestData()` 가 이미 `ref.read(fuelRepositoryProvider).clearAll()` + `ref.invalidate(fuelNotifierProvider)` 호출 중 | 기존 훅 유지. 단 `fuelRepositoryProvider` 가 분기로 바뀌면 `read(fuelRepositoryProvider)` 가 `isAuthenticatedProvider` 의존을 끌어와 `CircularDependencyError` 위험 → **`ref.read(fuelLocalDataSourceProvider).clearAll()` 직접 호출로 변경** (Todo 의 `ref.read(localTodoDataSourceProvider).clearAll()` 패턴과 동일) |
| 2 | 신규 Exception 3종 (`FuelServerException`/`FuelNetworkException`/`InvalidFuelFilterException`) | Fuel API 는 표준 401/400/500 만 사용. 기존 `DioExceptionHandler` 의 `NetworkException`/`UnauthenticatedRequestException`/`InvalidInputValueException`/`UnknownException` 으로 충분 | 신규 Exception 작성 안 함. Repository 는 `_isNetworkFailure(e) → 캐시 폴백 / else → DioExceptionHandler.handle(e) throw` (Todo 패턴 그대로) |
| 3 | "consumer 7 파일 모두 `AsyncValue` 처리" | 실제 영향은 두 갈래: (a) `currentFuelProvider` 가 `int → AsyncValue` 로 바뀌면 3 화면 영향, (b) `fuelNotifierProvider` 가 `FuelEntity → AsyncValue<FuelEntity>` 로 바뀌면 `badge_provider.dart:56` 만 영향. `FuelGauge`/`status_card`/`boarding_pass_ticket` 은 stateless prop drilling 이라 provider 직접 사용 안 함 | 영향 파일 5개로 한정 (3 화면 + badge_provider + 자체 fuel_provider). 위젯 prop 시그니처는 변경 없음 |
| 4 | `FuelNotifier.chargeFuel/consumeFuel` 이 mutation API 호출 | server-backed Repository 에서 mutation 은 `UnsupportedError` → 호출 즉시 throw. 호출자(timer, exploration_provider) 가 영향받음 | **Notifier 레벨에서 분기 흡수**: server-backed 시 `chargeFuel/consumeFuel` 본문이 `ref.invalidate(fuelRepositoryProvider)` 만 호출 (실제 서버 mutation 은 후속 이슈인 타이머/탐험 액션 API 연동 시 추가). 게스트는 기존 호출 그대로. 이로써 timer/exploration_provider 호출 코드는 변경 없음 |
| 5 | spec §5.2 의 `GetFuelTransactionsPageUseCase` 별도 UseCase 클래스 | Todo·기존 fuel 도 NotifierProvider 가 Repository 를 직접 호출, UseCase wrapper 없음 (코드베이스 컨벤션) | **UseCase 클래스 작성 생략**. `fuelTransactionsPageProvider.family` 가 Repository.getTransactionsPage 를 직접 호출. UseCase 가 필요해지면 (예: 다중 Repository 조합) 후속에서 추가 |

---

## File Structure

### 신규 파일

| 파일 | 책임 |
|---|---|
| `lib/features/fuel/data/datasources/fuel_remote_datasource.dart` | Retrofit 2 엔드포인트 인터페이스 |
| `lib/features/fuel/data/models/fuel_response_model.dart` | GET /api/fuel 응답 DTO |
| `lib/features/fuel/data/models/fuel_transaction_response_model.dart` | 거래 항목 DTO (wire enum 매핑 포함) |
| `lib/features/fuel/data/models/fuel_transaction_page_response_model.dart` | 페이지 응답 DTO |
| `lib/features/fuel/data/repositories/fuel_repository_impl.dart` | server-backed Repository (신규 — 기존 동명 파일은 rename) |
| `lib/features/fuel/domain/entities/fuel_transaction_page.dart` | 페이지 도메인 모델 (Freezed) |
| `lib/features/fuel/domain/entities/fuel_transaction_filter.dart` | 필터 VO (Freezed) |
| `test/features/fuel/data/models/fuel_response_model_test.dart` | DTO 단위 테스트 |
| `test/features/fuel/data/models/fuel_transaction_response_model_test.dart` | DTO + enum 매핑 테스트 |
| `test/features/fuel/data/models/fuel_transaction_page_response_model_test.dart` | DTO 테스트 |
| `test/features/fuel/data/repositories/fuel_repository_impl_test.dart` | server-backed Repository 테스트 |
| `test/features/fuel/presentation/providers/fuel_provider_test.dart` | 분기 + async notifier 테스트 |

### Rename

| 기존 → 변경 후 | 비고 |
|---|---|
| `lib/features/fuel/data/repositories/fuel_repository_impl.dart` → `lib/features/fuel/data/repositories/local_fuel_repository_impl.dart` | 클래스명 `FuelRepositoryImpl` → `LocalFuelRepositoryImpl`. 내부 로직 동일 + 인터페이스 async 시그니처 적응 |

### 수정 파일

| 파일 | 변경 |
|---|---|
| `lib/core/constants/api_endpoints.dart` | `fuel`, `fuelTransactions` 상수 2 추가 |
| `lib/features/fuel/domain/repositories/fuel_repository.dart` | `getFuel`/`getTransactions` sync → `Future` 일괄 전환 + `getTransactionsPage` 추가 |
| `lib/features/fuel/presentation/providers/fuel_provider.dart` | (1) `fuelRemoteDataSourceProvider` 추가, (2) `fuelRepositoryProvider` 분기, (3) `FuelNotifier.build` async, (4) mutation 분기, (5) `FuelTransactionListNotifier.build` async, (6) `currentFuelProvider` AsyncValue, (7) `fuelTransactionsPageProvider.family` 추가 |
| `lib/features/auth/presentation/providers/auth_provider.dart` | `_clearGuestData` 의 fuel 라인을 `fuelLocalDataSourceProvider.clearAll()` 로 변경 (CircularDep 회피) |
| `lib/features/exploration/presentation/screens/exploration_detail_screen.dart:111` | `ref.watch(currentFuelProvider)` 사용처 `AsyncValue.when` 처리 |
| `lib/features/exploration/presentation/screens/location_detail_screen.dart:83` | 동일 |
| `lib/features/explore/presentation/screens/explore_screen.dart:42` | 동일 |
| `lib/features/badge/presentation/providers/badge_provider.dart:56` | `ref.read(fuelNotifierProvider)` → `AsyncValue.valueOrNull` 패턴 |

### 미수정 (확정)

- `lib/features/fuel/domain/entities/fuel_entity.dart`
- `lib/features/fuel/domain/entities/fuel_transaction_entity.dart` (enum 도메인 케이스 그대로)
- `lib/features/fuel/data/datasources/fuel_local_datasource.dart`
- `lib/features/fuel/data/models/fuel_model.dart` / `fuel_transaction_model.dart` (캐시 영속 포맷 그대로 = `enum.name`)
- `lib/core/widgets/space/fuel_gauge.dart` / `status_card.dart`
- `lib/features/exploration/presentation/widgets/boarding_pass_ticket.dart`
- `lib/core/network/dio_exception_handler.dart` (Fuel 전용 신규 code 없음)
- `lib/core/errors/app_exception.dart` (Fuel 전용 신규 Exception 없음)
- `lib/features/timer/presentation/providers/timer_provider.dart` (FuelNotifier 가 분기 흡수하므로 호출 코드 보존)
- `lib/features/exploration/presentation/providers/exploration_provider.dart` (동일)

---

## Phase 1 — ApiEndpoints 인프라

### Task 1: ApiEndpoints 에 fuel 상수 추가

**Files:**
- Modify: `lib/core/constants/api_endpoints.dart`

- [ ] **Step 1: 현재 ApiEndpoints 파일 확인**

Run: `grep -n 'todos\|todoCategories' lib/core/constants/api_endpoints.dart`
Expected: `static const todos = '/api/todos';` 같은 패턴 확인

- [ ] **Step 2: fuel 상수 추가 (todoCategories 하단에 새 섹션)**

Edit `lib/core/constants/api_endpoints.dart` — `todoCategoryById` 정의 다음에 다음 블록 추가:

```dart
  // === Fuel ===

  /// 연료 잔량 조회
  static const fuel = '/api/fuel';

  /// 연료 거래 내역 조회 (페이지네이션)
  static const fuelTransactions = '/api/fuel/transactions';
```

- [ ] **Step 3: 검증**

Run: `flutter analyze lib/core/constants/api_endpoints.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/core/constants/api_endpoints.dart
git commit -m "feat : ApiEndpoints 에 fuel/fuelTransactions 상수 추가 #79"
```

---

## Phase 2 — DTO (Data Transfer Objects)

### Task 2: FuelResponseModel (잔량 응답)

**Files:**
- Create: `lib/features/fuel/data/models/fuel_response_model.dart`
- Test:   `test/features/fuel/data/models/fuel_response_model_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

Create `test/features/fuel/data/models/fuel_response_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_response_model.dart';

void main() {
  group('FuelResponseModel', () {
    test('fromJson — 정상 파싱', () {
      final json = {
        'currentFuel': 350,
        'totalCharged': 1200,
        'totalConsumed': 850,
        'pendingMinutes': 0,
        'lastUpdatedAt': '2026-04-16T10:30:00Z',
      };
      final model = FuelResponseModel.fromJson(json);
      expect(model.currentFuel, 350);
      expect(model.totalCharged, 1200);
      expect(model.totalConsumed, 850);
      expect(model.pendingMinutes, 0);
      expect(model.lastUpdatedAt, DateTime.utc(2026, 4, 16, 10, 30));
    });

    test('toEntity — 도메인 엔티티 변환', () {
      final model = FuelResponseModel(
        currentFuel: 350,
        totalCharged: 1200,
        totalConsumed: 850,
        pendingMinutes: 0,
        lastUpdatedAt: DateTime.utc(2026, 4, 16, 10, 30),
      );
      final entity = model.toEntity();
      expect(entity.currentFuel, 350);
      expect(entity.totalCharged, 1200);
      expect(entity.totalConsumed, 850);
      expect(entity.pendingMinutes, 0);
      expect(entity.lastUpdatedAt, DateTime.utc(2026, 4, 16, 10, 30));
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/fuel/data/models/fuel_response_model_test.dart`
Expected: 컴파일 실패 — `FuelResponseModel` 미정의

- [ ] **Step 3: 모델 구현**

Create `lib/features/fuel/data/models/fuel_response_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_entity.dart';

part 'fuel_response_model.freezed.dart';
part 'fuel_response_model.g.dart';

/// GET /api/fuel 응답 DTO
@freezed
class FuelResponseModel with _$FuelResponseModel {
  const FuelResponseModel._();

  const factory FuelResponseModel({
    required int currentFuel,
    required int totalCharged,
    required int totalConsumed,
    required int pendingMinutes,
    required DateTime lastUpdatedAt,
  }) = _FuelResponseModel;

  factory FuelResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FuelResponseModelFromJson(json);

  FuelEntity toEntity() => FuelEntity(
        currentFuel: currentFuel,
        totalCharged: totalCharged,
        totalConsumed: totalConsumed,
        pendingMinutes: pendingMinutes,
        lastUpdatedAt: lastUpdatedAt,
      );
}
```

- [ ] **Step 4: build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `Succeeded after ...` + `fuel_response_model.freezed.dart` / `.g.dart` 생성

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/features/fuel/data/models/fuel_response_model_test.dart`
Expected: `All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/fuel/data/models/fuel_response_model.dart \
        lib/features/fuel/data/models/fuel_response_model.freezed.dart \
        lib/features/fuel/data/models/fuel_response_model.g.dart \
        test/features/fuel/data/models/fuel_response_model_test.dart
git commit -m "feat : FuelResponseModel + toEntity 추가 #79"
```

---

### Task 3: FuelTransactionResponseModel (거래 항목 + wire enum 매핑)

**Files:**
- Create: `lib/features/fuel/data/models/fuel_transaction_response_model.dart`
- Test:   `test/features/fuel/data/models/fuel_transaction_response_model_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

Create `test/features/fuel/data/models/fuel_transaction_response_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_transaction_response_model.dart';
import 'package:space_study_ship/features/fuel/domain/entities/fuel_transaction_entity.dart';

void main() {
  group('FuelTransactionResponseModel', () {
    test('fromJson — charge / STUDY_SESSION 매핑', () {
      final json = {
        'id': 'tx-1',
        'type': 'charge',
        'amount': 90,
        'reason': 'STUDY_SESSION',
        'referenceId': 'session-1',
        'balanceAfter': 350,
        'createdAt': '2026-04-16T10:30:00Z',
      };
      final model = FuelTransactionResponseModel.fromJson(json);
      expect(model.id, 'tx-1');
      expect(model.type, FuelTransactionTypeWire.charge);
      expect(model.amount, 90);
      expect(model.reason, FuelTransactionReasonWire.studySession);
      expect(model.referenceId, 'session-1');
      expect(model.balanceAfter, 350);
    });

    test('fromJson — consume / EXPLORATION_UNLOCK 매핑', () {
      final json = {
        'id': 'tx-2',
        'type': 'consume',
        'amount': 5,
        'reason': 'EXPLORATION_UNLOCK',
        'referenceId': null,
        'balanceAfter': 345,
        'createdAt': '2026-04-16T10:35:00Z',
      };
      final model = FuelTransactionResponseModel.fromJson(json);
      expect(model.type, FuelTransactionTypeWire.consume);
      expect(model.reason, FuelTransactionReasonWire.explorationUnlock);
      expect(model.referenceId, isNull);
    });

    test('fromJson — 미지 reason → fallback (studySession)', () {
      final json = {
        'id': 'tx-3',
        'type': 'charge',
        'amount': 10,
        'reason': 'MISSION_REWARD',
        'balanceAfter': 360,
        'createdAt': '2026-04-16T10:40:00Z',
      };
      final model = FuelTransactionResponseModel.fromJson(json);
      expect(model.reason, FuelTransactionReasonWire.studySession);
    });

    test('toEntity — wire enum → 도메인 enum 매핑', () {
      final model = FuelTransactionResponseModel(
        id: 'tx-1',
        type: FuelTransactionTypeWire.charge,
        amount: 90,
        reason: FuelTransactionReasonWire.studySession,
        referenceId: 'session-1',
        balanceAfter: 350,
        createdAt: DateTime.utc(2026, 4, 16, 10, 30),
      );
      final entity = model.toEntity();
      expect(entity.type, FuelTransactionType.charge);
      expect(entity.reason, FuelTransactionReason.studySession);
      expect(entity.id, 'tx-1');
      expect(entity.balanceAfter, 350);
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/fuel/data/models/fuel_transaction_response_model_test.dart`
Expected: 컴파일 실패

- [ ] **Step 3: 모델 구현**

Create `lib/features/fuel/data/models/fuel_transaction_response_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_transaction_entity.dart';

part 'fuel_transaction_response_model.freezed.dart';
part 'fuel_transaction_response_model.g.dart';

/// 서버 wire 포맷 (SCREAMING_SNAKE_CASE) 와 도메인 enum 의 매핑 계층.
/// 도메인 enum 은 camelCase 를 유지하기 위해 wire 전용 enum 을 둔다.
enum FuelTransactionTypeWire {
  @JsonValue('charge') charge,
  @JsonValue('consume') consume,
}

enum FuelTransactionReasonWire {
  @JsonValue('STUDY_SESSION') studySession,
  @JsonValue('EXPLORATION_UNLOCK') explorationUnlock,
}

/// GET /api/fuel/transactions 응답 항목 DTO
@freezed
class FuelTransactionResponseModel with _$FuelTransactionResponseModel {
  const FuelTransactionResponseModel._();

  const factory FuelTransactionResponseModel({
    required String id,
    @JsonKey(unknownEnumValue: FuelTransactionTypeWire.charge)
    required FuelTransactionTypeWire type,
    required int amount,
    @JsonKey(unknownEnumValue: FuelTransactionReasonWire.studySession)
    required FuelTransactionReasonWire reason,
    String? referenceId,
    required int balanceAfter,
    required DateTime createdAt,
  }) = _FuelTransactionResponseModel;

  factory FuelTransactionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FuelTransactionResponseModelFromJson(json);

  FuelTransactionEntity toEntity() => FuelTransactionEntity(
        id: id,
        type: switch (type) {
          FuelTransactionTypeWire.charge => FuelTransactionType.charge,
          FuelTransactionTypeWire.consume => FuelTransactionType.consume,
        },
        amount: amount,
        reason: switch (reason) {
          FuelTransactionReasonWire.studySession =>
            FuelTransactionReason.studySession,
          FuelTransactionReasonWire.explorationUnlock =>
            FuelTransactionReason.explorationUnlock,
        },
        referenceId: referenceId,
        balanceAfter: balanceAfter,
        createdAt: createdAt,
      );
}
```

- [ ] **Step 4: build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 생성 완료

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/features/fuel/data/models/fuel_transaction_response_model_test.dart`
Expected: `All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/fuel/data/models/fuel_transaction_response_model.dart \
        lib/features/fuel/data/models/fuel_transaction_response_model.freezed.dart \
        lib/features/fuel/data/models/fuel_transaction_response_model.g.dart \
        test/features/fuel/data/models/fuel_transaction_response_model_test.dart
git commit -m "feat : FuelTransactionResponseModel + wire enum 매핑 #79"
```

---

### Task 4: FuelTransactionPageResponseModel (페이지)

**Files:**
- Create: `lib/features/fuel/data/models/fuel_transaction_page_response_model.dart`
- Test:   `test/features/fuel/data/models/fuel_transaction_page_response_model_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

Create `test/features/fuel/data/models/fuel_transaction_page_response_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_transaction_page_response_model.dart';

void main() {
  group('FuelTransactionPageResponseModel', () {
    test('fromJson — 다중 항목 페이지 파싱', () {
      final json = {
        'content': [
          {
            'id': 'tx-1',
            'type': 'charge',
            'amount': 90,
            'reason': 'STUDY_SESSION',
            'referenceId': 'session-1',
            'balanceAfter': 350,
            'createdAt': '2026-04-16T10:30:00Z',
          },
        ],
        'page': 0,
        'size': 20,
        'totalElements': 120,
        'totalPages': 6,
      };
      final model = FuelTransactionPageResponseModel.fromJson(json);
      expect(model.content, hasLength(1));
      expect(model.page, 0);
      expect(model.size, 20);
      expect(model.totalElements, 120);
      expect(model.totalPages, 6);
    });

    test('fromJson — content 비어있는 페이지', () {
      final json = {
        'content': <Map<String, dynamic>>[],
        'page': 5,
        'size': 20,
        'totalElements': 100,
        'totalPages': 5,
      };
      final model = FuelTransactionPageResponseModel.fromJson(json);
      expect(model.content, isEmpty);
      expect(model.page, 5);
    });

    test('toEntity — Page 도메인 변환 + hasNext', () {
      final model = FuelTransactionPageResponseModel(
        content: const [],
        page: 0,
        size: 20,
        totalElements: 120,
        totalPages: 6,
      );
      final page = model.toEntity();
      expect(page.items, isEmpty);
      expect(page.hasNext, isTrue);
    });

    test('toEntity — 마지막 페이지 → hasNext false', () {
      final model = FuelTransactionPageResponseModel(
        content: const [],
        page: 5,
        size: 20,
        totalElements: 120,
        totalPages: 6,
      );
      expect(model.toEntity().hasNext, isFalse);
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/fuel/data/models/fuel_transaction_page_response_model_test.dart`
Expected: 컴파일 실패

- [ ] **Step 3: 모델 구현**

Create `lib/features/fuel/data/models/fuel_transaction_page_response_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/fuel_transaction_page.dart';
import 'fuel_transaction_response_model.dart';

part 'fuel_transaction_page_response_model.freezed.dart';
part 'fuel_transaction_page_response_model.g.dart';

/// GET /api/fuel/transactions 페이지 응답 DTO
@freezed
class FuelTransactionPageResponseModel
    with _$FuelTransactionPageResponseModel {
  const FuelTransactionPageResponseModel._();

  const factory FuelTransactionPageResponseModel({
    required List<FuelTransactionResponseModel> content,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
  }) = _FuelTransactionPageResponseModel;

  factory FuelTransactionPageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$FuelTransactionPageResponseModelFromJson(json);

  FuelTransactionPage toEntity() => FuelTransactionPage(
        items: content.map((m) => m.toEntity()).toList(growable: false),
        page: page,
        size: size,
        totalElements: totalElements,
        totalPages: totalPages,
      );
}
```

> NOTE: `FuelTransactionPage` 가 아직 없어서 컴파일 실패할 것이다. Task 5 에서 작성한다. 본 task 의 build_runner 는 Task 5 이후로 미룬다.

- [ ] **Step 4: Task 5 완료 후 build_runner 와 테스트 통과 확인 (Task 5 의 step 에서 함께 처리)**

본 step 은 Task 5 의 build_runner + 테스트 step 에서 동시에 검증되므로, 이 단계에서는 파일만 작성하고 진행. 임시 commit 은 만들지 않는다.

---

## Phase 3 — Domain Entity (Page + Filter)

### Task 5: FuelTransactionPage entity

**Files:**
- Create: `lib/features/fuel/domain/entities/fuel_transaction_page.dart`

- [ ] **Step 1: 엔티티 작성**

Create `lib/features/fuel/domain/entities/fuel_transaction_page.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'fuel_transaction_entity.dart';

part 'fuel_transaction_page.freezed.dart';

/// 거래 내역 페이지 응답 도메인 모델.
///
/// 페이지네이션 메타 (`page`, `size`, `totalElements`, `totalPages`) +
/// 현재 페이지 항목 (`items`) 을 포함한다.
@freezed
class FuelTransactionPage with _$FuelTransactionPage {
  const FuelTransactionPage._();

  const factory FuelTransactionPage({
    required List<FuelTransactionEntity> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
  }) = _FuelTransactionPage;

  /// 다음 페이지가 더 있는지 여부 (`page + 1 < totalPages`)
  bool get hasNext => page + 1 < totalPages;
}
```

- [ ] **Step 2: build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `fuel_transaction_page.freezed.dart` + `fuel_transaction_page_response_model.freezed.dart` + `.g.dart` 모두 생성

- [ ] **Step 3: Task 4 + 5 통합 테스트 통과 확인**

Run: `flutter test test/features/fuel/data/models/fuel_transaction_page_response_model_test.dart`
Expected: `All tests passed!`

- [ ] **Step 4: Commit (Task 4 + 5 묶음)**

```bash
git add lib/features/fuel/data/models/fuel_transaction_page_response_model.dart \
        lib/features/fuel/data/models/fuel_transaction_page_response_model.freezed.dart \
        lib/features/fuel/data/models/fuel_transaction_page_response_model.g.dart \
        lib/features/fuel/domain/entities/fuel_transaction_page.dart \
        lib/features/fuel/domain/entities/fuel_transaction_page.freezed.dart \
        test/features/fuel/data/models/fuel_transaction_page_response_model_test.dart
git commit -m "feat : FuelTransactionPage entity + Page Response DTO #79"
```

---

### Task 6: FuelTransactionFilter VO

**Files:**
- Create: `lib/features/fuel/domain/entities/fuel_transaction_filter.dart`

- [ ] **Step 1: VO 작성**

Create `lib/features/fuel/domain/entities/fuel_transaction_filter.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'fuel_transaction_entity.dart';

part 'fuel_transaction_filter.freezed.dart';

/// 거래 내역 페이지 조회 필터.
///
/// - [type] null → 전체
/// - [startDate] / [endDate] null → 전체 기간 (서버 default)
/// - [page] / [size] 기본값은 서버 default 와 동일 (0 / 20)
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

- [ ] **Step 2: build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `fuel_transaction_filter.freezed.dart` 생성

- [ ] **Step 3: 검증**

Run: `flutter analyze lib/features/fuel/domain/entities/fuel_transaction_filter.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/fuel/domain/entities/fuel_transaction_filter.dart \
        lib/features/fuel/domain/entities/fuel_transaction_filter.freezed.dart
git commit -m "feat : FuelTransactionFilter VO 추가 #79"
```

---

## Phase 4 — Retrofit Remote DataSource

### Task 7: FuelRemoteDataSource

**Files:**
- Create: `lib/features/fuel/data/datasources/fuel_remote_datasource.dart`

- [ ] **Step 1: 인터페이스 작성**

Create `lib/features/fuel/data/datasources/fuel_remote_datasource.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/fuel_response_model.dart';
import '../models/fuel_transaction_page_response_model.dart';

part 'fuel_remote_datasource.g.dart';

/// Fuel 백엔드 API 클라이언트.
///
/// `api-docs.json` 의 Fuel 태그 2 엔드포인트 매핑.
@RestApi()
abstract class FuelRemoteDataSource {
  factory FuelRemoteDataSource(Dio dio) = _FuelRemoteDataSource;

  /// 연료 잔량 조회 — 200
  @GET(ApiEndpoints.fuel)
  Future<FuelResponseModel> getFuel();

  /// 거래 내역 페이지네이션 조회 — 200
  ///
  /// - type: 'charge' | 'consume' (선택)
  /// - startDate / endDate: YYYY-MM-DD (선택)
  /// - page: 기본 0
  /// - size: 기본 20, 최대 100
  @GET(ApiEndpoints.fuelTransactions)
  Future<FuelTransactionPageResponseModel> getTransactions({
    @Query('type') String? type,
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('page') int? page,
    @Query('size') int? size,
  });
}
```

- [ ] **Step 2: build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `fuel_remote_datasource.g.dart` 생성

- [ ] **Step 3: 검증**

Run: `flutter analyze lib/features/fuel/data/datasources/fuel_remote_datasource.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/fuel/data/datasources/fuel_remote_datasource.dart \
        lib/features/fuel/data/datasources/fuel_remote_datasource.g.dart
git commit -m "feat : FuelRemoteDataSource (Retrofit, 2 엔드포인트) #79"
```

---

## Phase 5 — FuelRepository 인터페이스 async 전환 + Local rename

### Task 8: FuelRepository 인터페이스 async 전환

**Files:**
- Modify: `lib/features/fuel/domain/repositories/fuel_repository.dart`

- [ ] **Step 1: 인터페이스 일괄 갱신**

Replace contents of `lib/features/fuel/domain/repositories/fuel_repository.dart`:

```dart
import '../entities/fuel_entity.dart';
import '../entities/fuel_transaction_entity.dart';
import '../entities/fuel_transaction_filter.dart';
import '../entities/fuel_transaction_page.dart';

abstract class FuelRepository {
  /// 현재 연료 잔량 조회. server-backed 구현은 네트워크 호출 + 캐시 폴백.
  Future<FuelEntity> getFuel();

  /// 연료 충전. server-backed 구현은 UnsupportedError 를 던진다 — 서버 변동은
  /// 도메인 액션 (타이머/탐험) 의 부수효과이며, Notifier 레벨에서 분기 흡수한다.
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);

  /// 연료 소비. server-backed 구현은 UnsupportedError 를 던진다.
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]);

  /// 거래 내역 전체 조회 (게스트 전용). server-backed 는
  /// UnsupportedError — 페이지 API ([getTransactionsPage]) 를 사용한다.
  Future<List<FuelTransactionEntity>> getTransactions({int? limit});

  /// 거래 내역 페이지 조회 (server-backed 전용). LocalRepository 는
  /// UnsupportedError 를 던진다.
  Future<FuelTransactionPage> getTransactionsPage(
    FuelTransactionFilter filter,
  );

  /// 로컬 캐시 / 영속 데이터 전체 삭제 (로그아웃·탈퇴 흐름에서 호출).
  Future<void> clearAll();
}
```

> NOTE: 이 시점에서 기존 `fuel_repository_impl.dart` 와 `fuel_provider.dart` 가 컴파일 실패한다. Task 9 / Task 11 에서 함께 정합화한다. **본 task 만 단독 commit 하면 build break** → Task 9, 10 까지 묶어서 한 commit.

- [ ] **Step 2: Task 9 / 10 까지 진행 후 검증 (skip commit)**

본 task 는 인터페이스 정의만 갱신, 단독 검증 불가. 다음 task 들과 한 묶음으로 처리.

---

### Task 9: 기존 FuelRepositoryImpl → LocalFuelRepositoryImpl rename + async 적응

**Files:**
- Delete (rename): `lib/features/fuel/data/repositories/fuel_repository_impl.dart`
- Create:          `lib/features/fuel/data/repositories/local_fuel_repository_impl.dart`

- [ ] **Step 1: 기존 파일 내용 백업 (참조용 출력)**

Run: `cat lib/features/fuel/data/repositories/fuel_repository_impl.dart`
Expected: 110 줄 내외, `FuelRepositoryImpl implements FuelRepository`

- [ ] **Step 2: 파일 git mv**

```bash
git mv lib/features/fuel/data/repositories/fuel_repository_impl.dart \
       lib/features/fuel/data/repositories/local_fuel_repository_impl.dart
```

- [ ] **Step 3: 클래스명 변경 + async 시그니처 적응**

Replace contents of `lib/features/fuel/data/repositories/local_fuel_repository_impl.dart`:

```dart
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/entities/fuel_transaction_filter.dart';
import '../../domain/entities/fuel_transaction_page.dart';
import '../../domain/exceptions/fuel_exceptions.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../datasources/fuel_local_datasource.dart';
import '../models/fuel_model.dart';
import '../models/fuel_transaction_model.dart';

/// 게스트 전용 Local Repository. SharedPreferences 캐시만 사용한다.
class LocalFuelRepositoryImpl implements FuelRepository {
  final FuelLocalDataSource _localDataSource;

  LocalFuelRepositoryImpl(this._localDataSource);

  @override
  Future<FuelEntity> getFuel() async {
    return _localDataSource.getFuel().toEntity();
  }

  @override
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) async {
    final current = _localDataSource.getFuel();
    final now = DateTime.now();
    final newFuel = FuelModel(
      currentFuel: current.currentFuel + amount,
      totalCharged: current.totalCharged + amount,
      totalConsumed: current.totalConsumed,
      pendingMinutes: pendingMinutes,
      lastUpdatedAt: now,
    );

    await _localDataSource.saveFuel(newFuel);

    if (amount > 0) {
      final transaction = FuelTransactionModel(
        id: 'charge_${now.millisecondsSinceEpoch}',
        type: FuelTransactionType.charge.name,
        amount: amount,
        reason: reason.name,
        referenceId: referenceId,
        balanceAfter: newFuel.currentFuel,
        createdAt: now,
      );
      await _localDataSource.addTransaction(transaction);
    }

    return newFuel.toEntity();
  }

  @override
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) async {
    final current = _localDataSource.getFuel();
    if (current.currentFuel < amount) {
      throw InsufficientFuelException(
        requiredAmount: amount,
        available: current.currentFuel,
      );
    }

    final now = DateTime.now();
    final newFuel = FuelModel(
      currentFuel: current.currentFuel - amount,
      totalCharged: current.totalCharged,
      totalConsumed: current.totalConsumed + amount,
      pendingMinutes: current.pendingMinutes,
      lastUpdatedAt: now,
    );

    await _localDataSource.saveFuel(newFuel);

    final transaction = FuelTransactionModel(
      id: 'consume_${now.millisecondsSinceEpoch}',
      type: FuelTransactionType.consume.name,
      amount: amount,
      reason: reason.name,
      referenceId: referenceId,
      balanceAfter: newFuel.currentFuel,
      createdAt: now,
    );
    await _localDataSource.addTransaction(transaction);

    return newFuel.toEntity();
  }

  @override
  Future<List<FuelTransactionEntity>> getTransactions({int? limit}) async {
    final transactions =
        _localDataSource.getTransactions().map((m) => m.toEntity()).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && transactions.length > limit) {
      return transactions.sublist(0, limit);
    }
    return transactions;
  }

  @override
  Future<FuelTransactionPage> getTransactionsPage(
    FuelTransactionFilter filter,
  ) async {
    throw UnsupportedError(
      'LocalFuelRepositoryImpl does not support page query. '
      'Use FuelRepositoryImpl (server-backed) for authenticated users.',
    );
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
  }
}
```

- [ ] **Step 4: 검증 (전체 컴파일은 아직 실패 — fuel_provider 갱신 후 확인)**

Run: `flutter analyze lib/features/fuel/data/repositories/local_fuel_repository_impl.dart`
Expected: 자체 파일은 통과 (단, fuel_provider 에서 import 가 깨져 있을 것 — Task 11 에서 정합화)

- [ ] **Step 5: Task 10 까지 진행 후 한 묶음 commit**

본 task 단독 commit 안 함.

---

### Task 10: 신규 server-backed FuelRepositoryImpl 작성

**Files:**
- Create: `lib/features/fuel/data/repositories/fuel_repository_impl.dart`
- Test:   `test/features/fuel/data/repositories/fuel_repository_impl_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

Create `test/features/fuel/data/repositories/fuel_repository_impl_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_local_datasource.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_remote_datasource.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_model.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_response_model.dart';
import 'package:space_study_ship/features/fuel/data/models/fuel_transaction_page_response_model.dart';
import 'package:space_study_ship/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:space_study_ship/features/fuel/domain/entities/fuel_transaction_entity.dart';
import 'package:space_study_ship/features/fuel/domain/entities/fuel_transaction_filter.dart';

class _MockRemote extends Mock implements FuelRemoteDataSource {}

class _MockCache extends Mock implements FuelLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late FuelRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    repo = FuelRepositoryImpl(remote: remote, cache: cache);

    registerFallbackValue(
      FuelModel(lastUpdatedAt: DateTime.utc(2026, 1, 1)),
    );
  });

  DioException _connectionError() => DioException.connectionError(
        requestOptions: RequestOptions(path: '/api/fuel'),
        reason: 'no network',
      );

  group('getFuel', () {
    test('remote 성공 → entity 반환 + 캐시 저장', () async {
      when(() => remote.getFuel()).thenAnswer(
        (_) async => FuelResponseModel(
          currentFuel: 350,
          totalCharged: 1200,
          totalConsumed: 850,
          pendingMinutes: 0,
          lastUpdatedAt: DateTime.utc(2026, 4, 16, 10, 30),
        ),
      );
      when(() => cache.saveFuel(any())).thenAnswer((_) async {});

      final result = await repo.getFuel();

      expect(result.currentFuel, 350);
      verify(() => cache.saveFuel(any())).called(1);
    });

    test('네트워크 실패 → 캐시 폴백', () async {
      when(() => remote.getFuel()).thenThrow(_connectionError());
      when(() => cache.getFuel()).thenReturn(
        FuelModel(
          currentFuel: 100,
          totalCharged: 200,
          totalConsumed: 100,
          lastUpdatedAt: DateTime.utc(2026, 4, 15),
        ),
      );

      final result = await repo.getFuel();

      expect(result.currentFuel, 100);
      verifyNever(() => cache.saveFuel(any()));
    });

    test('네트워크 외 DioException → DioExceptionHandler 통한 AppException throw', () async {
      when(() => remote.getFuel()).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/fuel'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/fuel'),
          statusCode: 401,
          data: {'code': 'UNAUTHENTICATED_REQUEST', 'message': '로그인이 필요합니다.'},
        ),
        type: DioExceptionType.badResponse,
      ));

      await expectLater(
        repo.getFuel(),
        throwsA(isA<UnauthenticatedRequestException>()),
      );
    });
  });

  group('getTransactionsPage', () {
    test('remote 성공 → Page entity 반환', () async {
      when(() => remote.getTransactions(
            type: any(named: 'type'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer(
        (_) async => const FuelTransactionPageResponseModel(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
        ),
      );

      final page = await repo.getTransactionsPage(
        const FuelTransactionFilter(),
      );
      expect(page.items, isEmpty);
      expect(page.hasNext, isFalse);
    });

    test('네트워크 실패 → AppException 전파 (캐시 폴백 없음)', () async {
      when(() => remote.getTransactions(
            type: any(named: 'type'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenThrow(_connectionError());

      await expectLater(
        repo.getTransactionsPage(const FuelTransactionFilter()),
        throwsA(isA<NetworkException>()),
      );
    });

    test('filter type / dates 가 query 로 전달됨', () async {
      when(() => remote.getTransactions(
            type: any(named: 'type'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer(
        (_) async => const FuelTransactionPageResponseModel(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
        ),
      );

      await repo.getTransactionsPage(FuelTransactionFilter(
        type: FuelTransactionType.charge,
        startDate: DateTime.utc(2026, 4, 1),
        endDate: DateTime.utc(2026, 4, 30),
        page: 2,
        size: 50,
      ));

      verify(() => remote.getTransactions(
            type: 'charge',
            startDate: '2026-04-01',
            endDate: '2026-04-30',
            page: 2,
            size: 50,
          )).called(1);
    });
  });

  group('mutation 메서드', () {
    test('chargeFuel → UnsupportedError', () async {
      expect(
        () => repo.chargeFuel(10, 0, FuelTransactionReason.studySession),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('consumeFuel → UnsupportedError', () async {
      expect(
        () => repo.consumeFuel(5, FuelTransactionReason.explorationUnlock),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getTransactions(limit) → UnsupportedError', () async {
      expect(
        () => repo.getTransactions(limit: 10),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('clearAll', () {
    test('cache.clearAll 위임', () async {
      when(() => cache.clearAll()).thenAnswer((_) async {});
      await repo.clearAll();
      verify(() => cache.clearAll()).called(1);
    });
  });
}
```

- [ ] **Step 2: 실패 확인 (컴파일 에러 — FuelRepositoryImpl 미정의)**

Run: `flutter test test/features/fuel/data/repositories/fuel_repository_impl_test.dart`
Expected: 컴파일 실패

- [ ] **Step 3: 구현 작성**

Create `lib/features/fuel/data/repositories/fuel_repository_impl.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/entities/fuel_transaction_filter.dart';
import '../../domain/entities/fuel_transaction_page.dart';
import '../../domain/repositories/fuel_repository.dart';
import '../datasources/fuel_local_datasource.dart';
import '../datasources/fuel_remote_datasource.dart';
import '../models/fuel_response_model.dart';

/// 서버 source-of-truth + 로컬 캐시 폴백 (server-backed).
///
/// 변동 mutation (`chargeFuel`/`consumeFuel`) 은 서버에 직접 API 가 없으므로
/// UnsupportedError 를 던진다. 호출자 (FuelNotifier) 가 isAuthenticated 분기로
/// 흡수하여 도메인 액션 API 호출 → 잔량 재조회 흐름을 사용한다.
class FuelRepositoryImpl implements FuelRepository {
  final FuelRemoteDataSource remote;
  final FuelLocalDataSource cache;

  FuelRepositoryImpl({required this.remote, required this.cache});

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  Future<FuelEntity> getFuel() async {
    try {
      final model = await remote.getFuel();
      await cache.saveFuel(_toCacheModel(model));
      return model.toEntity();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        return cache.getFuel().toEntity();
      }
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<FuelTransactionPage> getTransactionsPage(
    FuelTransactionFilter filter,
  ) async {
    try {
      final response = await remote.getTransactions(
        type: switch (filter.type) {
          FuelTransactionType.charge => 'charge',
          FuelTransactionType.consume => 'consume',
          null => null,
        },
        startDate:
            filter.startDate != null ? _dateFmt.format(filter.startDate!) : null,
        endDate:
            filter.endDate != null ? _dateFmt.format(filter.endDate!) : null,
        page: filter.page,
        size: filter.size,
      );
      return response.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<FuelEntity> chargeFuel(
    int amount,
    int pendingMinutes,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) {
    throw UnsupportedError(
      'Server mutates fuel via timer/exploration actions. '
      'Notifier should invalidate fuelRepositoryProvider after action API.',
    );
  }

  @override
  Future<FuelEntity> consumeFuel(
    int amount,
    FuelTransactionReason reason, [
    String? referenceId,
  ]) {
    throw UnsupportedError(
      'Server mutates fuel via exploration unlock action. '
      'Notifier should invalidate fuelRepositoryProvider after action API.',
    );
  }

  @override
  Future<List<FuelTransactionEntity>> getTransactions({int? limit}) {
    throw UnsupportedError(
      'Server-backed repository uses pagination — call getTransactionsPage.',
    );
  }

  @override
  Future<void> clearAll() async {
    await cache.clearAll();
  }

  static bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  /// 서버 응답을 LocalDataSource 가 쓰는 영속 모델 형태로 변환.
  /// (현행 `FuelModel` 은 도메인과 동일 필드를 갖는다.)
  static dynamic _toCacheModel(FuelResponseModel m) =>
      m.toEntity().toCacheModel();
}
```

> NOTE: `FuelEntity.toCacheModel()` 확장 메서드를 다음 step 에서 추가한다.

- [ ] **Step 4: FuelEntity → FuelModel 변환 확장 추가**

Append to `lib/features/fuel/domain/entities/fuel_entity.dart` (또는 별도 `extensions/` 파일 생성).
파일 끝에 다음 import + 확장 추가:

```dart
// 파일 상단 기존 import 유지, 아래 추가
import '../../data/models/fuel_model.dart';

extension FuelEntityCache on FuelEntity {
  /// 캐시 영속용 변환 (LocalDataSource 가 쓰는 FuelModel 로).
  FuelModel toCacheModel() => FuelModel(
        currentFuel: currentFuel,
        totalCharged: totalCharged,
        totalConsumed: totalConsumed,
        pendingMinutes: pendingMinutes,
        lastUpdatedAt: lastUpdatedAt,
      );
}
```

> NOTE: domain → data 역방향 import 가 생긴다. 본 프로젝트 규약상 일반적 금지 사항이나, 캐시 변환은 한정적 예외로 한다. 대안으로 변환 로직을 `fuel_repository_impl.dart` 안의 private static 헬퍼로 옮겨도 동일 효과 (이쪽이 더 깨끗하면 그쪽 선택). **권장: Repository 의 private 헬퍼로** — extension 대신:

Replace `_toCacheModel` 헬퍼 본문 (Repository 의 마지막 static 메서드):

```dart
  static FuelModel _toCacheModel(FuelResponseModel m) => FuelModel(
        currentFuel: m.currentFuel,
        totalCharged: m.totalCharged,
        totalConsumed: m.totalConsumed,
        pendingMinutes: m.pendingMinutes,
        lastUpdatedAt: m.lastUpdatedAt,
      );
```

그리고 `_toCacheModel` 의 반환 타입을 `dynamic` → `FuelModel` 로 수정, `import '../models/fuel_model.dart';` 추가, FuelEntity 의 확장은 추가하지 않는다.

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/features/fuel/data/repositories/fuel_repository_impl_test.dart`
Expected: `All tests passed!`

- [ ] **Step 6: 전체 분석 (Task 8 + 9 + 10 묶음 컴파일 확인)**

Run: `flutter analyze lib/features/fuel/`
Expected: `No issues found!` (단 fuel_provider.dart 가 아직 본 인터페이스에 맞춰지지 않았다면 그 파일만 에러. 그 경우 Task 11 진행 후 다시 확인)

- [ ] **Step 7: Commit (Task 8 + 9 + 10 묶음)**

```bash
git add lib/features/fuel/domain/repositories/fuel_repository.dart \
        lib/features/fuel/data/repositories/local_fuel_repository_impl.dart \
        lib/features/fuel/data/repositories/fuel_repository_impl.dart \
        test/features/fuel/data/repositories/fuel_repository_impl_test.dart
git commit -m "feat : Fuel Repository 인터페이스 async 전환 + server-backed 구현 #79

- FuelRepository: getFuel/getTransactions sync → async, getTransactionsPage 추가
- LocalFuelRepositoryImpl: 기존 FuelRepositoryImpl rename + async 적응
- FuelRepositoryImpl (server-backed) 신규: getFuel server-first + cache 폴백,
  getTransactionsPage, mutation 은 UnsupportedError"
```

---

## Phase 6 — Provider 분기 + FuelNotifier async 전환

### Task 11: fuel_provider.dart 전면 갱신

**Files:**
- Modify: `lib/features/fuel/presentation/providers/fuel_provider.dart`
- Test:   `test/features/fuel/presentation/providers/fuel_provider_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

Create `test/features/fuel/presentation/providers/fuel_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/fuel/data/datasources/fuel_local_datasource.dart';
import 'package:space_study_ship/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:space_study_ship/features/fuel/data/repositories/local_fuel_repository_impl.dart';
import 'package:space_study_ship/features/fuel/presentation/providers/fuel_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> _containerWithAuth({required bool authed}) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(overrides: [
      fuelLocalDataSourceProvider.overrideWithValue(FuelLocalDataSource(prefs)),
      isAuthenticatedProvider.overrideWith((ref) => authed),
    ]);
  }

  test('isAuthenticated=false → LocalFuelRepositoryImpl 주입', () async {
    final container = await _containerWithAuth(authed: false);
    addTearDown(container.dispose);
    final repo = container.read(fuelRepositoryProvider);
    expect(repo, isA<LocalFuelRepositoryImpl>());
  });

  test('isAuthenticated=true → FuelRepositoryImpl 주입', () async {
    final container = await _containerWithAuth(authed: true);
    addTearDown(container.dispose);
    final repo = container.read(fuelRepositoryProvider);
    expect(repo, isA<FuelRepositoryImpl>());
  });

  test('인증 상태 전환 시 repo 인스턴스 invalidate', () async {
    final container = await _containerWithAuth(authed: false);
    addTearDown(container.dispose);
    final repo1 = container.read(fuelRepositoryProvider);
    container.read(isAuthenticatedProvider.notifier).state = true;
    final repo2 = container.read(fuelRepositoryProvider);
    expect(repo1.runtimeType, isNot(equals(repo2.runtimeType)));
  });
}
```

> NOTE: `isAuthenticatedProvider` 가 `@riverpod bool` 함수형이면 `overrideWith((ref) => authed)` 사용. notifier 형태가 아닐 경우 `notifier.state = true` 방식이 안 되므로, 그 부분은 두 개의 container 로 분리하여 검증 (아래 Step 2 에서 실제 시그니처 확인 후 조정).

- [ ] **Step 2: 실제 isAuthenticatedProvider 시그니처 확인**

Run: `grep -B2 -A5 'bool isAuthenticated(Ref ref)' lib/features/auth/presentation/providers/auth_provider.dart`
Expected: `@riverpod\nbool isAuthenticated(Ref ref) { ... }` (함수형 provider)

함수형이므로 위 테스트의 `notifier.state = true` 부분은 작동하지 않는다. 해당 케이스는 다음과 같이 두 container 비교로 변경:

```dart
test('인증 상태에 따라 repo 인스턴스 종류가 다름', () async {
  final guestContainer = await _containerWithAuth(authed: false);
  final authedContainer = await _containerWithAuth(authed: true);
  addTearDown(guestContainer.dispose);
  addTearDown(authedContainer.dispose);
  expect(guestContainer.read(fuelRepositoryProvider).runtimeType,
      isNot(equals(authedContainer.read(fuelRepositoryProvider).runtimeType)));
});
```

3번째 테스트를 위 코드로 교체.

- [ ] **Step 3: 실패 확인 (Notifier·DataSource provider 미정의)**

Run: `flutter test test/features/fuel/presentation/providers/fuel_provider_test.dart`
Expected: 컴파일 실패

- [ ] **Step 4: fuel_provider 전면 갱신**

Replace contents of `lib/features/fuel/presentation/providers/fuel_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/fuel_local_datasource.dart';
import '../../data/datasources/fuel_remote_datasource.dart';
import '../../data/repositories/fuel_repository_impl.dart';
import '../../data/repositories/local_fuel_repository_impl.dart';
import '../../domain/entities/fuel_entity.dart';
import '../../domain/entities/fuel_transaction_entity.dart';
import '../../domain/entities/fuel_transaction_filter.dart';
import '../../domain/entities/fuel_transaction_page.dart';
import '../../domain/repositories/fuel_repository.dart';

part 'fuel_provider.g.dart';

// === DataSource ===

@Riverpod(keepAlive: true)
FuelLocalDataSource fuelLocalDataSource(Ref ref) {
  throw StateError(
    'FuelLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@Riverpod(keepAlive: true)
FuelRemoteDataSource fuelRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FuelRemoteDataSource(dio);
}

// === Repository 분기 ===

@Riverpod(keepAlive: true)
FuelRepository fuelRepository(Ref ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (isAuthenticated) {
    return FuelRepositoryImpl(
      remote: ref.watch(fuelRemoteDataSourceProvider),
      cache: ref.watch(fuelLocalDataSourceProvider),
    );
  }
  return LocalFuelRepositoryImpl(ref.watch(fuelLocalDataSourceProvider));
}

// === Fuel State (async) ===

@Riverpod(keepAlive: true)
class FuelNotifier extends _$FuelNotifier {
  @override
  Future<FuelEntity> build() async {
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getFuel();
  }

  /// 공부 시간으로 연료 충전. server-backed 사용자는 도메인 액션 API 가
  /// 서버 쪽에서 잔량을 변동시키므로, 본 메서드는 잔량 재조회만 수행한다.
  Future<void> chargeFuel({
    required int studyMinutes,
    String? sessionId,
  }) async {
    if (studyMinutes <= 0) return;

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      // Notifier 레벨 분기 흡수: 서버 mutation 은 timer/exploration 도메인
      // 액션 API 가 담당. 본 메서드는 재조회로 동기화.
      ref.invalidateSelf();
      ref.invalidate(fuelTransactionListNotifierProvider);
      return;
    }

    // 게스트: 기존 로컬 mutation 그대로
    final current = state.valueOrNull;
    if (current == null) return;
    final totalMinutes = current.pendingMinutes + studyMinutes;
    final amount = totalMinutes ~/ 30;
    final newPendingMinutes = totalMinutes % 30;
    final repository = ref.read(fuelRepositoryProvider);
    final updated = await repository.chargeFuel(
      amount,
      newPendingMinutes,
      FuelTransactionReason.studySession,
      sessionId,
    );
    state = AsyncValue.data(updated);
    if (amount > 0) {
      ref.invalidate(fuelTransactionListNotifierProvider);
    }
  }

  /// 탐험 해금 등으로 연료 소비. server-backed 는 재조회만.
  Future<void> consumeFuel({required int amount, String? nodeId}) async {
    if (amount <= 0) return;

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      ref.invalidateSelf();
      ref.invalidate(fuelTransactionListNotifierProvider);
      return;
    }

    final repository = ref.read(fuelRepositoryProvider);
    final updated = await repository.consumeFuel(
      amount,
      FuelTransactionReason.explorationUnlock,
      nodeId,
    );
    state = AsyncValue.data(updated);
    ref.invalidate(fuelTransactionListNotifierProvider);
  }
}

// === Transaction History (게스트 전용 단순 목록) ===

@riverpod
class FuelTransactionListNotifier extends _$FuelTransactionListNotifier {
  @override
  Future<List<FuelTransactionEntity>> build() async {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (isAuthenticated) {
      // server-backed 는 페이지 API 만 지원 → 단순 목록은 빈 결과.
      // 후속 거래 내역 UI 에서 fuelTransactionsPageProvider 사용.
      return [];
    }
    final repository = ref.watch(fuelRepositoryProvider);
    return repository.getTransactions();
  }
}

// === Server-backed 거래 내역 페이지 ===

@riverpod
Future<FuelTransactionPage> fuelTransactionsPage(
  Ref ref,
  FuelTransactionFilter filter,
) async {
  final repository = ref.watch(fuelRepositoryProvider);
  return repository.getTransactionsPage(filter);
}

// === Convenience ===

@riverpod
AsyncValue<int> currentFuel(Ref ref) {
  return ref.watch(fuelNotifierProvider).whenData((fuel) => fuel.currentFuel);
}
```

- [ ] **Step 5: build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 생성 완료

- [ ] **Step 6: 테스트 통과 확인**

Run: `flutter test test/features/fuel/presentation/providers/fuel_provider_test.dart`
Expected: `All tests passed!`

- [ ] **Step 7: 전체 분석**

Run: `flutter analyze lib/features/fuel/`
Expected: `No issues found!` (단 currentFuelProvider 의 반환 타입 변경 (`int → AsyncValue<int>`) 으로 consumer 3 화면에서 에러 — Phase 7 에서 정합화)

- [ ] **Step 8: Commit (Phase 6 묶음)**

```bash
git add lib/features/fuel/presentation/providers/fuel_provider.dart \
        lib/features/fuel/presentation/providers/fuel_provider.g.dart \
        test/features/fuel/presentation/providers/fuel_provider_test.dart
git commit -m "feat : fuel_provider 인증 분기 + FuelNotifier async 전환 #79

- fuelRepositoryProvider: isAuthenticatedProvider watch → 분기
- FuelNotifier.build async, mutation 은 server-backed 시 invalidate 흡수
- FuelTransactionListNotifier async + 인증 분기
- fuelTransactionsPageProvider.family 추가
- currentFuelProvider 반환 타입: int → AsyncValue<int>"
```

---

## Phase 7 — Consumer 적응

### Task 12: auth_provider 로그아웃 훅 CircularDep 회피

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

- [ ] **Step 1: 현재 코드 확인**

Run: `grep -n 'fuelRepositoryProvider).clearAll\|fuelLocalDataSourceProvider' lib/features/auth/presentation/providers/auth_provider.dart`
Expected: `() => ref.read(fuelRepositoryProvider).clearAll(),` 라인 발견

- [ ] **Step 2: fuelLocalDataSourceProvider 직접 호출로 변경**

`_clearGuestData` 의 `clearTasks` 리스트 중 fuel 라인 교체:

```dart
// before
() => ref.read(fuelRepositoryProvider).clearAll(),
// after
() => ref.read(fuelLocalDataSourceProvider).clearAll(),
```

import 추가 (이미 있으면 skip):

```dart
import '../../../fuel/data/datasources/fuel_local_datasource.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
```

- [ ] **Step 3: 회귀 — auth 관련 테스트 통과 확인**

Run: `flutter test test/features/auth/`
Expected: 기존 테스트 모두 통과 (실패 시 fuel 관련 mock 누락 가능 — fuel mock 추가)

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "fix : 로그아웃 시 fuel 캐시 정리 CircularDep 회피 (datasource 직접 호출) #79"
```

---

### Task 13: explore_screen — currentFuelProvider AsyncValue 처리

**Files:**
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart`

- [ ] **Step 1: 현재 사용처 확인**

Run: `sed -n '40,55p' lib/features/explore/presentation/screens/explore_screen.dart`
Expected: `final currentFuel = ref.watch(currentFuelProvider);` 라인 + 이후 currentFuel int 사용처

- [ ] **Step 2: AsyncValue.when 패턴으로 교체**

`final currentFuel = ref.watch(currentFuelProvider);` 가 있던 위치를:

```dart
final currentFuelAsync = ref.watch(currentFuelProvider);
final currentFuel = currentFuelAsync.valueOrNull ?? 0;
```

`currentFuel` 변수의 이후 사용처는 그대로 (int).

> RATIONALE: 화면에서 loading/error 별도 UI 가 없고, 잔량 0 으로 fallback 표시가 자연스럽다 (FuelGauge 가 0 이면 빈 칸으로 표시).

- [ ] **Step 3: 검증**

Run: `flutter analyze lib/features/explore/presentation/screens/explore_screen.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit (Task 14, 15 와 묶음 — 동일 패턴이므로 다음 task 들 진행 후 한 묶음 commit)**

본 task 는 단독 commit 안 함.

---

### Task 14: exploration_detail_screen — currentFuelProvider AsyncValue 처리

**Files:**
- Modify: `lib/features/exploration/presentation/screens/exploration_detail_screen.dart`

- [ ] **Step 1: 동일 패턴 적용**

Line 111 부근의 `final currentFuel = ref.watch(currentFuelProvider);` 를:

```dart
final currentFuelAsync = ref.watch(currentFuelProvider);
final currentFuel = currentFuelAsync.valueOrNull ?? 0;
```

- [ ] **Step 2: 검증**

Run: `flutter analyze lib/features/exploration/presentation/screens/exploration_detail_screen.dart`
Expected: `No issues found!`

---

### Task 15: location_detail_screen — currentFuelProvider AsyncValue 처리

**Files:**
- Modify: `lib/features/exploration/presentation/screens/location_detail_screen.dart`

- [ ] **Step 1: 동일 패턴 적용**

Line 83 부근:

```dart
final currentFuelAsync = ref.watch(currentFuelProvider);
final currentFuel = currentFuelAsync.valueOrNull ?? 0;
```

- [ ] **Step 2: 검증**

Run: `flutter analyze lib/features/exploration/presentation/screens/location_detail_screen.dart`
Expected: `No issues found!`

- [ ] **Step 3: Task 13 + 14 + 15 묶음 commit**

```bash
git add lib/features/explore/presentation/screens/explore_screen.dart \
        lib/features/exploration/presentation/screens/exploration_detail_screen.dart \
        lib/features/exploration/presentation/screens/location_detail_screen.dart
git commit -m "feat : currentFuelProvider AsyncValue 적응 (3 화면) #79"
```

---

### Task 16: badge_provider — fuelNotifierProvider AsyncValue 처리

**Files:**
- Modify: `lib/features/badge/presentation/providers/badge_provider.dart`

- [ ] **Step 1: 현재 사용처 확인**

Run: `grep -n 'fuelNotifierProvider\|fuelState' lib/features/badge/presentation/providers/badge_provider.dart`
Expected: `final fuelState = ref.read(fuelNotifierProvider);` 라인

- [ ] **Step 2: AsyncValue 처리**

해당 라인을:

```dart
final fuelStateAsync = ref.read(fuelNotifierProvider);
final fuelState = fuelStateAsync.valueOrNull;
if (fuelState == null) return [];  // 잔량 아직 로드 전이면 배지 해금 평가 skip
```

이후 `fuelState.currentFuel` 등의 사용은 그대로 (이제 non-null).

- [ ] **Step 3: 검증**

Run: `flutter analyze lib/features/badge/presentation/providers/badge_provider.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/badge/presentation/providers/badge_provider.dart
git commit -m "feat : badge_provider 의 fuelNotifierProvider AsyncValue 적응 #79"
```

---

## Phase 8 — 최종 검증

### Task 17: 전체 분석 + 테스트 + 회귀

**Files:** (none — 검증만)

- [ ] **Step 1: 전체 flutter analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: 전체 flutter test**

Run: `flutter test`
Expected: `All tests passed!`

문제 발생 시 — 가장 흔한 회귀 케이스:
- `fuelNotifierProvider` 가 `AsyncValue<FuelEntity>` 가 되면서 `.notifier.chargeFuel(...)` 호출하는 기존 timer/exploration 코드가 `state` 직접 접근하던 부분이 없는지 → 이번 plan 에서 Notifier 가 분기 흡수하므로 호출 코드는 변경 없음. mock 만 갱신 필요할 수 있음.
- `currentFuelProvider` 가 `int → AsyncValue<int>` 가 되어 기존 widget 테스트에서 `int` 가 와야 하는 곳에 `AsyncValue` 가 와서 깨질 수 있음 → mock 응답에 `AsyncValue.data(...)` 사용.

- [ ] **Step 3: 커버리지 확인 (선택)**

Run: `flutter test --coverage && lcov --summary coverage/lcov.info 2>/dev/null | tail -3`
Expected: Fuel 모듈 80% 이상

- [ ] **Step 4: 최종 검증 commit (선택 — 코드 변경 없으면 skip)**

분석/테스트 결과 fix 가 필요했다면 그 변경을 별도 commit:

```bash
git add <fixed files>
git commit -m "fix : Fuel API 연동 회귀 수정 (analyze/test 통과) #79"
```

---

## 검증 체크리스트 (PR 전)

- [ ] `flutter analyze` 통과 (경고 0)
- [ ] `flutter test` 전 테스트 통과
- [ ] Fuel 모듈 커버리지 80%+ (신규 코드 기준)
- [ ] 로그아웃 흐름 수동 확인 — 게스트 → 로그인 → 로그아웃 시 fuel 캐시 비워짐 + 다음 게스트 진입 시 0/0/0 표시
- [ ] 인증 상태 전환 시 fuelRepositoryProvider 가 다른 구현체로 교체됨 (`isA<FuelRepositoryImpl>()` / `isA<LocalFuelRepositoryImpl>()`)
- [ ] DESIGN.md 9.C "제출 전 최종 검증" 적용 항목 통과 (UI 변경 없음이라 design-guardian 자동 통과 예상)

---

**End of plan.**
