# 2차 리뷰 이슈 수정 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 2차 `/review-flutter` 리뷰에서 발견된 Critical 2건, Major 3건 이슈를 수정하여 코드 안정성을 높인다.

**Architecture:** 기존 Clean Architecture 구조 내에서 방어 코딩(에러 처리)과 DRY 리팩토링을 진행. 새 파일 생성 없이 기존 파일만 수정.

**Tech Stack:** Flutter 3.9+ · Riverpod 2.6 · SharedPreferences

---

### Task 1: checkAndUnlock 루프 내 개별 배지 에러 처리 (Critical)

**문제:** `badge_provider.dart`의 `checkAndUnlock()` — 배지 목록 순회 중 개별 배지에서 예외 발생 시 전체 루프가 중단되어 나머지 배지 체크가 실행되지 않음.

**Files:**
- Modify: `lib/features/badge/presentation/providers/badge_provider.dart:71-87`

**Step 1: for 루프 내부에 try/catch 추가**

현재 코드:
```dart
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
  );

  if (shouldUnlock) {
    await repository.unlockBadge(badge.id);
    newlyUnlocked.add(badge);
  }
}
```

변경 후:
```dart
for (final badge in locked) {
  try {
    final shouldUnlock = _checkCondition(
      badge: badge,
      totalMinutes: totalMinutes,
      streak: streak,
      sessionCount: sessionCount,
      totalCharged: fuelState.totalCharged,
      unlockedPlanets: unlockedPlanets,
      unlockedRegions: unlockedRegions,
      currentHour: currentHour,
    );

    if (shouldUnlock) {
      await repository.unlockBadge(badge.id);
      newlyUnlocked.add(badge);
    }
  } catch (e) {
    debugPrint('배지 해금 체크 실패 (${badge.id}): $e');
  }
}
```

**Step 2: import 추가 확인**

`package:flutter/foundation.dart` import 필요 (debugPrint용). 없으면 추가.

**Step 3: 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/badge/presentation/providers/badge_provider.dart
git commit -m "fix: checkAndUnlock 루프 내 개별 배지 에러 처리 추가"
```

---

### Task 2: _clearGuestData 부분 실패 에러 처리 (Critical)

**문제:** `auth_provider.dart`의 `_clearGuestData()` — 순차 호출 중 하나 실패 시 나머지 미실행. 예: badgeRepo.clearAll() 실패하면 그 뒤의 invalidate도 실행되지 않음.

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:335-353`

**Step 1: 각 clear 호출을 개별 try/catch로 감싸기**

현재 코드:
```dart
Future<void> _clearGuestData() async {
  final todoRepo = ref.read(todoRepositoryProvider);
  await todoRepo.clearAll();
  final timerRepo = ref.read(timerSessionRepositoryProvider);
  await timerRepo.clearAll();
  final fuelRepo = ref.read(fuelRepositoryProvider);
  await fuelRepo.clearAll();
  final explorationRepo = ref.read(explorationRepositoryProvider);
  await explorationRepo.clearAll();
  final badgeRepo = ref.read(badgeRepositoryProvider);
  await badgeRepo.clearAll();

  ref.invalidate(timerSessionListNotifierProvider);
  ref.invalidate(todoListNotifierProvider);
  ref.invalidate(categoryListNotifierProvider);
  ref.invalidate(fuelNotifierProvider);
  ref.invalidate(explorationNotifierProvider);
  ref.invalidate(badgeNotifierProvider);
}
```

변경 후:
```dart
Future<void> _clearGuestData() async {
  // 각 저장소 독립 삭제 — 하나 실패해도 나머지 계속 진행
  final clearTasks = <Future<void> Function()>[
    () => ref.read(todoRepositoryProvider).clearAll(),
    () => ref.read(timerSessionRepositoryProvider).clearAll(),
    () => ref.read(fuelRepositoryProvider).clearAll(),
    () => ref.read(explorationRepositoryProvider).clearAll(),
    () => ref.read(badgeRepositoryProvider).clearAll(),
  ];

  for (final task in clearTasks) {
    try {
      await task();
    } catch (e) {
      debugPrint('게스트 데이터 삭제 실패: $e');
    }
  }

  // 메모리 캐시 무효화 (예외 발생 불가)
  ref.invalidate(timerSessionListNotifierProvider);
  ref.invalidate(todoListNotifierProvider);
  ref.invalidate(categoryListNotifierProvider);
  ref.invalidate(fuelNotifierProvider);
  ref.invalidate(explorationNotifierProvider);
  ref.invalidate(badgeNotifierProvider);
}
```

**Step 2: 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "fix: _clearGuestData 부분 실패 시 나머지 작업 계속 진행"
```

---

### Task 3: debugLogDiagnostics를 kDebugMode로 제한 (Major)

**문제:** `app_router.dart:59` — `debugLogDiagnostics: true`가 릴리즈 빌드에서도 라우터 로그를 출력함.

**Files:**
- Modify: `lib/routes/app_router.dart:59`

**Step 1: kDebugMode import 추가 및 값 변경**

```dart
// import 추가 (이미 있으면 생략)
import 'package:flutter/foundation.dart';
```

변경:
```dart
// Before
debugLogDiagnostics: true,

// After
debugLogDiagnostics: kDebugMode,
```

**Step 2: 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/routes/app_router.dart
git commit -m "fix: debugLogDiagnostics를 kDebugMode로 제한"
```

---

### Task 4: Hidden 배지 시간 범위 매칭 (Major)

**문제:** `badge_provider.dart:124` — `currentHour == badge.requiredValue`는 세션 종료 시각이 정확히 해당 시각이어야만 해금됨. 새벽 3시 배지는 3:00~3:59에만 해금 가능하므로 현재 로직은 맞지만, 세션 종료가 4:00:00 정각이면 놓침. 시작 시각도 함께 체크하여 안정성을 높인다.

**Files:**
- Modify: `lib/features/badge/presentation/providers/badge_provider.dart:44-94` (checkAndUnlock 메서드)
- Modify: `lib/features/badge/presentation/providers/badge_provider.dart:96-126` (_checkCondition 메서드)

**Step 1: checkAndUnlock에 세션 시작 시각 파라미터 전달**

`checkAndUnlock` 메서드에 옵셔널 `sessionStartTime` 파라미터를 추가하여 세션 시작 시각도 체크:

```dart
Future<List<BadgeEntity>> checkAndUnlock({DateTime? sessionStartTime}) async {
  // ... 기존 통계 수집 코드 ...

  // 히든 배지: 현재 시간 + 세션 시작 시간 체크
  final now = DateTime.now();
  final currentHour = now.hour;
  final sessionStartHour = sessionStartTime?.hour;

  // ... for 루프 ...
  final shouldUnlock = _checkCondition(
    badge: badge,
    totalMinutes: totalMinutes,
    streak: streak,
    sessionCount: sessionCount,
    totalCharged: fuelState.totalCharged,
    unlockedPlanets: unlockedPlanets,
    unlockedRegions: unlockedRegions,
    currentHour: currentHour,
    sessionStartHour: sessionStartHour,
  );
  // ...
}
```

**Step 2: _checkCondition의 hidden 분기에 시작 시각 체크 추가**

```dart
bool _checkCondition({
  required BadgeEntity badge,
  required int totalMinutes,
  required int streak,
  required int sessionCount,
  required int totalCharged,
  required int unlockedPlanets,
  required int unlockedRegions,
  required int currentHour,
  int? sessionStartHour,
}) {
  switch (badge.category) {
    // ... 기존 case들 동일 ...
    case BadgeCategory.hidden:
      // 세션 종료 시각 또는 시작 시각이 해당 시간대에 포함되면 해금
      return currentHour == badge.requiredValue ||
          sessionStartHour == badge.requiredValue;
  }
}
```

**Step 3: timer_screen.dart에서 세션 시작 시각 전달**

`timer_screen.dart`에서 `checkAndUnlock()` 호출 부분을 찾아 `sessionStartTime`을 전달:
- `timer_provider.dart`의 세션 결과에 시작 시각이 포함되어 있는지 확인
- 있으면 전달, 없으면 현재 로직 유지 (기존 호출 위치 확인 필요)

**Step 4: 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/badge/presentation/providers/badge_provider.dart
git commit -m "fix: hidden 배지 시간 범위 매칭 — 세션 시작/종료 시각 모두 체크"
```

---

### Task 5: auth signIn 메서드 DRY 리팩토링 (Major)

**문제:** `auth_provider.dart`의 `signInWithGoogle()`과 `signInWithApple()`의 에러 처리 패턴이 거의 동일 (provider 이름과 UseCase만 다름).

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:213-277`

**Step 1: 공통 _signInWithSocial 메서드 추출**

```dart
/// 소셜 로그인 공통 처리
Future<void> _signInWithSocial({
  required SocialLoginProvider provider,
  required Future<AuthResultEntity> Function() execute,
  required String providerName,
}) async {
  ref.read(activeLoginNotifierProvider.notifier).set(provider);
  state = const AsyncValue.loading();

  try {
    final result = await execute();
    state = AsyncValue.data(result);
  } on FirebaseAuthException catch (e) {
    state = AsyncValue.error(
      FirebaseAuthErrorHandler.createAuthException(e, provider: providerName),
      StackTrace.current,
    );
    rethrow;
  } catch (e, stack) {
    if (e is AppException) {
      state = AsyncValue.error(e, stack);
    } else {
      state = AsyncValue.error(
        AuthException(message: '알 수 없는 오류가 발생했습니다.', originalException: e),
        stack,
      );
    }
    rethrow;
  } finally {
    ref.read(activeLoginNotifierProvider.notifier).clear();
  }
}
```

**Step 2: signInWithGoogle / signInWithApple 단순화**

```dart
Future<void> signInWithGoogle() async {
  await _signInWithSocial(
    provider: SocialLoginProvider.google,
    execute: () => ref.read(signInWithGoogleUseCaseProvider).execute(),
    providerName: 'Google',
  );
}

Future<void> signInWithApple() async {
  await _signInWithSocial(
    provider: SocialLoginProvider.apple,
    execute: () => ref.read(signInWithAppleUseCaseProvider).execute(),
    providerName: 'Apple',
  );
}
```

**Step 3: 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "refactor: signInWithGoogle/Apple 공통 패턴을 _signInWithSocial로 추출"
```

---

## 요약

| Task | 심각도 | 파일 | 내용 |
|------|--------|------|------|
| 1 | Critical | badge_provider.dart | checkAndUnlock 루프 내 try/catch |
| 2 | Critical | auth_provider.dart | _clearGuestData 부분 실패 처리 |
| 3 | Major | app_router.dart | debugLogDiagnostics: kDebugMode |
| 4 | Major | badge_provider.dart | hidden 배지 시간 범위 매칭 |
| 5 | Major | auth_provider.dart | signIn DRY 리팩토링 |

**전체 수정 후 최종 검증:**
```bash
flutter analyze
flutter pub run build_runner build --delete-conflicting-outputs  # Task 1, 4에서 provider 시그니처 변경 시
```
