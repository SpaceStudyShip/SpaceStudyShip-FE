# CodeRabbit PR #42 2차 리뷰 수정 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit 2차 리뷰에서 실익 있는 코드 수정 6건 + 문서 동기화 3건을 적용하여 PR 품질 확정.

**Architecture:** 기존 Clean Architecture 3-Layer 유지. 런타임 방어 코드 강화 + 문서-코드 정합성 확보.

**Tech Stack:** Flutter, Riverpod 2.6 (Generator), Freezed 2.5, SharedPreferences, build_runner

---

## 적용/스킵 판단 요약

| # | 항목 | 판단 | 근거 |
|---|------|------|------|
| 1 | SafeDateTimeConverter fallback 개선 | **적용** | DateTime.now() 폴백은 트랜잭션 데이터 무음 손상 |
| 2 | consumeFuel amount <= 0 가드 | **적용** | 음수 소비로 연료 증가 가능한 실제 버그 |
| 3 | chargeFuel invalidate 조건부 | **적용** | amount == 0일 때 불필요한 상태 갱신 방지 |
| 4 | unlock 롤백 처리 | **적용** | consumeFuel 성공 후 unlock 실패 시 연료 소실 |
| 5 | _handlePlanetTap async + await | **적용** | signOut 예외 누락되는 실제 버그 |
| 6 | toEntity() byName 방어적 파싱 | **적용** | enum 이름 변경 시 크래시 방지 |
| 7 | exitGuestMode() 메서드 추가 | **스킵** | signOut()은 게스트/소셜 모두 동일 로직, 과잉 추상화 |
| 8 | saveFuel+addTransaction 원자적 쓰기 | **스킵** | SharedPreferences 쓰기 실패 현실에서 발생 불가 |
| 9 | UUID 트랜잭션 ID | **스킵** | 싱글 스레드 Flutter에서 ms 충돌 불가, 의존성 추가 불필요 |
| 10 | guest-explore 문서 다이얼로그 텍스트 | **적용** | 문서-코드 불일치 |
| 11 | fuel-system-design 문서 동기화 | **적용** | pendingMinutes, chargeFuel 시그니처, provider 체인 전체 |
| 12 | fuel-system-implementation 문서 동기화 | **적용** | async/await, canConsume 제거 |
| 13 | fuel_provider.g.dart/keepAlive 확인 | **스킵** | 이전 커밋에서 이미 완료 |

---

## Task 1: SafeDateTimeConverter fallback → epoch sentinel + UTC 저장

**Files:**
- Modify: `lib/features/fuel/data/models/fuel_transaction_model.dart:12-25`
- Regenerate: `lib/features/fuel/data/models/fuel_transaction_model.g.dart`

**변경:**

```dart
class SafeDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const SafeDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is String) {
      return DateTime.tryParse(json) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  String toJson(DateTime date) => date.toUtc().toIso8601String();
}
```

- `DateTime.now()` → `DateTime.fromMillisecondsSinceEpoch(0)` (1970-01-01 sentinel)
- `toIso8601String()` → `toUtc().toIso8601String()` (타임존 중립)
- `build_runner` 재생성 필요

---

## Task 2: consumeFuel amount <= 0 가드 추가

**Files:**
- Modify: `lib/features/fuel/presentation/providers/fuel_provider.dart:61-70`

**변경:**

```dart
  Future<void> consumeFuel({required int amount, String? nodeId}) async {
    if (amount <= 0) return;
    final repository = ref.read(fuelRepositoryProvider);
    state = await repository.consumeFuel(
      amount,
      FuelTransactionReason.explorationUnlock,
      nodeId,
    );
    // 이력도 갱신
    ref.invalidate(fuelTransactionListNotifierProvider);
  }
```

- `if (amount <= 0) return;` 한 줄 추가

---

## Task 3: chargeFuel invalidate 조건부 실행

**Files:**
- Modify: `lib/features/fuel/presentation/providers/fuel_provider.dart:43-56`

**변경:**

```dart
    if (studyMinutes <= 0) return;
    final totalMinutes = state.pendingMinutes + studyMinutes;
    final amount = totalMinutes ~/ 30;
    final newPendingMinutes = totalMinutes % 30;
    final repository = ref.read(fuelRepositoryProvider);
    state = await repository.chargeFuel(
      amount,
      newPendingMinutes,
      FuelTransactionReason.studySession,
      sessionId,
    );
    // 실제 충전이 발생한 경우에만 이력 갱신
    if (amount > 0) {
      ref.invalidate(fuelTransactionListNotifierProvider);
    }
```

- `ref.invalidate`를 `if (amount > 0)` 조건으로 감싸기

---

## Task 4: unlockPlanet/unlockRegion 연료 롤백 처리

**Files:**
- Modify: `lib/features/exploration/presentation/providers/exploration_provider.dart:73-96,121-142`

**변경 (unlockPlanet):**

```dart
  Future<void> unlockPlanet(String planetId, int requiredFuel) async {
    if (_isUnlocking) return;
    _isUnlocking = true;
    try {
      if (!canUnlockPlanet(planetId)) {
        throw StateError('이전 행성을 먼저 해금해야 합니다.');
      }

      // 1. 연료 차감
      await ref
          .read(fuelNotifierProvider.notifier)
          .consumeFuel(amount: requiredFuel, nodeId: planetId);

      // 2. 해금 상태 저장 (실패 시 연료 환불)
      try {
        final repository = ref.read(explorationRepositoryProvider);
        await repository.unlockPlanet(planetId);
      } catch (e) {
        // 연료 환불
        await ref
            .read(fuelNotifierProvider.notifier)
            .chargeFuel(studyMinutes: 0, sessionId: null);
        // chargeFuel은 studyMinutes 기반이라 직접 환불 불가
        // → refundFuel 메서드 필요 없음: SharedPreferences unlock 실패 자체가 거의 불가능
        // → 대신 rethrow로 사용자에게 에러 노출
        rethrow;
      }

      // 3. 상태 갱신
      _reload();
    } finally {
      _isUnlocking = false;
    }
  }
```

**재고:** SharedPreferences `unlockPlanet`/`unlockRegion`은 단순 JSON 쓰기라 실패할 가능성이 거의 없다. 또한 현재 chargeFuel은 studyMinutes 기반이라 직접적인 연료 환불 메서드가 없어 롤백 구현이 자연스럽지 않다.

**최종 판단:** 이 태스크는 **스킵**한다. SharedPreferences 쓰기 실패는 현실적으로 발생하지 않으며, 환불 메서드를 별도로 만드는 것은 YAGNI 위반이다. CodeRabbit 리뷰에서 이론적으로 맞지만 실익이 없다.

---

## Task 5: _handlePlanetTap async 변환 + _showLoginPrompt 에러 핸들링

**Files:**
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart:204-266`

**변경:**

`_handlePlanetTap`을 `Future<void>`로 변환하고 `_showLoginPrompt`를 await:

```dart
  Future<void> _handlePlanetTap(
    BuildContext context,
    WidgetRef ref,
    ExplorationNodeEntity planet,
    int currentFuel,
    bool isGuest,
  ) async {
    if (planet.isUnlocked) {
      context.push('/explore/planet/${planet.id}');
      return;
    }

    // 게스트 모드: 지구 외 행성은 로그인 필요
    if (isGuest) {
      await _showLoginPrompt(context, ref);
      return;
    }
    // ... 나머지 동일
  }
```

`_showLoginPrompt`에 signOut 에러 핸들링 추가:

```dart
  Future<void> _showLoginPrompt(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: '로그인하시겠어요?',
      message: '게스트 모드의 데이터가\n모두 초기화돼요',
      confirmText: '로그인',
      cancelText: '취소',
    );
    if (confirmed == true) {
      try {
        await ref.read(authNotifierProvider.notifier).signOut();
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.error(context, '로그인 화면 전환에 실패했습니다.');
        }
      }
    }
  }
```

---

## Task 6: toEntity() byName 방어적 파싱

**Files:**
- Modify: `lib/features/fuel/data/models/fuel_transaction_model.dart:45-54`

**변경:**

```dart
extension FuelTransactionModelX on FuelTransactionModel {
  FuelTransactionEntity toEntity() => FuelTransactionEntity(
    id: id,
    type: FuelTransactionType.values
        .where((e) => e.name == type)
        .firstOrNull ?? FuelTransactionType.charge,
    amount: amount,
    reason: FuelTransactionReason.values
        .where((e) => e.name == reason)
        .firstOrNull ?? FuelTransactionReason.studySession,
    referenceId: referenceId,
    balanceAfter: balanceAfter,
    createdAt: createdAt,
  );
}
```

- `byName()` → `where().firstOrNull ??` 패턴으로 안전 파싱
- 잘못된 enum 문자열 시 기본값으로 폴백 (크래시 방지)

---

## Task 7: 문서 동기화 — guest-explore-login-prompt.md

**Files:**
- Modify: `docs/plans/2026-02-20-guest-explore-login-prompt.md:94-107`

**변경:**
- title: `'로그인이 필요해요'` → `'로그인하시겠어요?'`
- message: `'다른 행성을 탐험하려면\n로그인이 필요해요'` → `'게스트 모드의 데이터가\n모두 초기화돼요'`

---

## Task 8: 문서 동기화 — fuel-system-design.md

**Files:**
- Modify: `docs/plans/2026-02-20-fuel-system-design.md:59-68,93-101,169-221`

**변경 요약:**
1. FuelEntity에 `@Default(0) int pendingMinutes` 필드 추가
2. FuelRepository.chargeFuel 시그니처: `int pendingMinutes` 파라미터 추가, `Future<FuelEntity>` 반환
3. FuelRepository.consumeFuel: `Future<FuelEntity>` 반환
4. `canConsume` 메서드 제거
5. `clearAll()` 메서드 추가
6. Provider 체인: `@Riverpod(keepAlive: true)` 반영, UseCase 프로바이더 제거, async 메서드, pendingMinutes 누적 로직

---

## Task 9: 문서 동기화 — fuel-system-implementation.md

**Files:**
- Modify: `docs/plans/2026-02-20-fuel-system-implementation.md:430-454`

**변경 요약:**
1. chargeFuel/consumeFuel: `FuelEntity` → `Future<FuelEntity>` 반환
2. saveFuel/addTransaction 호출에 `await` 추가
3. FuelRepository 인터페이스에서 `canConsume` 제거
4. chargeFuel 시그니처에 `pendingMinutes` 파라미터 추가

---

## 검증

1. `flutter pub run build_runner build --delete-conflicting-outputs` — 정상 완료
2. `flutter analyze` — No issues found
3. 커밋
