# 로그인 시마다 온보딩 표시 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** SharedPreferences 캐시 기반 온보딩 제어를 제거하고, 로그인할 때마다 온보딩을 표시한다. 앱 재시작 시에는 온보딩을 건너뛴다.

**Architecture:** `AuthResultEntity`에 인메모리 `needsOnboarding` 플래그 추가. 로그인 시 `true` 설정 → 라우터가 `/onboarding`으로 리다이렉트 → 온보딩 완료 시 `false`로 업데이트. 캐시(SharedPreferences) 의존성 완전 제거.

**Tech Stack:** Flutter, Riverpod, GoRouter, Freezed

---

## 현재 문제

1. 소셜 로그인 성공 → GoRouter redirect가 바로 `/home`으로 보냄 → 온보딩 안 뜸
2. 게스트만 `LoginScreen`에서 수동으로 `context.go(/onboarding)` 호출
3. `kHasSeenOnboardingKey` 캐시가 비동기(SharedPreferences)라 동기적 redirect에서 사용 불가
4. 캐시 삭제 타이밍 관리가 복잡하고 버그 유발

## 해결 방안

인메모리 플래그(`needsOnboarding`)로 온보딩 제어:
- **로그인 시**: `needsOnboarding: true` → 라우터가 `/onboarding`으로 리다이렉트
- **온보딩 완료**: `needsOnboarding: false` → 라우터가 `/home`으로 리다이렉트
- **앱 재시작**: `build()`에서 기존 유저 복원 → `needsOnboarding: false` (기본값)
- **SharedPreferences 캐시 로직 전부 제거**

---

### Task 1: AuthResultEntity에 needsOnboarding 필드 추가

**Files:**
- Modify: `lib/features/auth/domain/entities/auth_result_entity.dart`

**Step 1: 필드 추가**

```dart
/// 온보딩 표시 필요 여부 (인메모리 전용, 로그인 직후 true)
@Default(false) bool needsOnboarding,
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

---

### Task 2: AuthNotifier 로그인 메서드에서 needsOnboarding: true 설정

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

**Step 1: signInWithGoogle 결과에 needsOnboarding 추가**

```dart
// signInWithGoogle() 내부 (성공 시)
final result = await useCase.execute();
state = AsyncValue.data(result.copyWith(needsOnboarding: true));
```

**Step 2: signInWithApple 결과에 needsOnboarding 추가**

```dart
// signInWithApple() 내부 (성공 시)
final result = await useCase.execute();
state = AsyncValue.data(result.copyWith(needsOnboarding: true));
```

**Step 3: signInAsGuest 결과에 needsOnboarding 추가**

```dart
state = const AsyncValue.data(
  AuthResultEntity(
    userId: -1,
    nickname: '게스트',
    isNewUser: false,
    isGuest: true,
    needsOnboarding: true,
  ),
);
```

**Step 4: kHasSeenOnboardingKey 관련 코드 전부 제거**

삭제 대상:
- `const kHasSeenOnboardingKey` 상수 선언
- `signOut()` 게스트 분기: `prefs.remove(kHasSeenOnboardingKey)` 및 debugPrint 수정
- `signOut()` 일반 분기: `prefs.remove(kHasSeenOnboardingKey)` 및 debugPrint 제거
- `build()`에서 kHasSeenOnboardingKey 참조 있으면 제거

**Step 5: onboardingCompleted() 메서드 추가**

```dart
/// 온보딩 완료 후 상태 갱신
void onboardingCompleted() {
  final current = state.value;
  if (current != null) {
    state = AsyncValue.data(current.copyWith(needsOnboarding: false));
  }
}
```

---

### Task 3: app_router.dart redirect에서 온보딩 리다이렉트 추가

**Files:**
- Modify: `lib/routes/app_router.dart`

**Step 1: redirect 로직 수정**

```dart
// 기존:
// 로그인됨 + 인증 화면에 있으면 → 홈으로
if (isAuthRoute && location != RoutePaths.onboarding) {
  return RoutePaths.home;
}

// 변경:
// 로그인됨 + 온보딩 필요 → 온보딩으로
if (user.needsOnboarding) {
  return (location == RoutePaths.onboarding) ? null : RoutePaths.onboarding;
}

// 로그인됨 + 인증 화면에 있으면 → 홈으로
if (isAuthRoute) {
  return RoutePaths.home;
}
```

---

### Task 4: OnboardingScreen에서 캐시 제거, AuthNotifier 호출로 변경

**Files:**
- Modify: `lib/features/auth/presentation/screens/onboarding_screen.dart`

**Step 1: SharedPreferences 제거, ConsumerStatefulWidget으로 변경**

```dart
// 기존
class OnboardingScreen extends StatefulWidget {

// 변경
class OnboardingScreen extends ConsumerStatefulWidget {
```

**Step 2: _completeOnboarding() 수정**

```dart
// 기존
Future<void> _completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kHasSeenOnboardingKey, true);
  if (mounted) context.go(RoutePaths.home);
}

// 변경
void _completeOnboarding() {
  ref.read(authNotifierProvider.notifier).onboardingCompleted();
  // GoRouter redirect가 자동으로 /home으로 이동
}
```

**Step 3: 불필요한 import 제거**

- `shared_preferences` import 제거
- `auth_provider.dart` import 추가 (authNotifierProvider 사용)

---

### Task 5: LoginScreen에서 게스트 온보딩 수동 네비게이션 제거

**Files:**
- Modify: `lib/features/auth/presentation/screens/login_screen.dart`

**Step 1: _handleGuestSignIn() 간소화**

```dart
// 기존
Future<void> _handleGuestSignIn() async {
  AppSnackBar.warning(context, '게스트 모드에서는 정보가 저장되지 않습니다');
  await ref.read(authNotifierProvider.notifier).signInAsGuest();
  if (!mounted) return;
  final prefs = await SharedPreferences.getInstance();
  if (!mounted) return;
  final hasSeenOnboarding = prefs.getBool(kHasSeenOnboardingKey) ?? false;
  if (!hasSeenOnboarding) {
    context.go(RoutePaths.onboarding);
  } else {
    context.go(RoutePaths.home);
  }
}

// 변경
Future<void> _handleGuestSignIn() async {
  AppSnackBar.warning(context, '게스트 모드에서는 정보가 저장되지 않습니다');
  await ref.read(authNotifierProvider.notifier).signInAsGuest();
  // GoRouter redirect가 자동으로 /onboarding → /home 처리
}
```

**Step 2: 불필요한 import 제거**

- `shared_preferences` import 제거
- `go_router` import 제거 (사용처 없으면)
- `route_paths` import 제거 (사용처 없으면)

---

### Task 6: flutter analyze 및 최종 검증

Run: `flutter analyze`
Expected: No issues found

---

## 변경 파일 요약

| # | 파일 | 변경 내용 |
|---|------|----------|
| 1 | `auth_result_entity.dart` | `needsOnboarding` 필드 추가 |
| 2 | `auth_result_entity.freezed.dart` | 자동생성 |
| 3 | `auth_provider.dart` | 로그인 시 `needsOnboarding: true`, `onboardingCompleted()` 추가, 캐시 로직 제거 |
| 4 | `auth_provider.g.dart` | 자동생성 |
| 5 | `app_router.dart` | redirect에서 `needsOnboarding` 체크 추가 |
| 6 | `onboarding_screen.dart` | ConsumerStatefulWidget, 캐시 제거, `onboardingCompleted()` 호출 |
| 7 | `login_screen.dart` | 게스트 수동 네비게이션 제거, SharedPreferences 제거 |

총 5개 파일 수정 + 2개 자동생성. 신규 파일 없음.
