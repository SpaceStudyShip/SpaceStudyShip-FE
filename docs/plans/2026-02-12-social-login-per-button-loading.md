# 소셜 로그인 버튼 개별 로딩/비활성화 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 소셜 로그인 버튼 클릭 시 해당 버튼만 스피너, 나머지 버튼은 비활성화(회색) 처리

**Architecture:** `@riverpod` Notifier(`ActiveLoginNotifier`)를 별도 생성하여 현재 진행 중인 소셜 로그인 프로바이더를 추적. `AuthNotifier`가 로그인 시작/종료 시 이 provider를 업데이트. `LoginScreen`에서 두 provider를 `ref.watch`하여 버튼별 로딩/비활성화 상태를 분기.

**Tech Stack:** Flutter, Riverpod 2.x (@riverpod), build_runner

---

## 현재 상태 분석

### 문제점
`LoginScreen`에서 `isLoading = authState.isLoading`을 두 버튼에 동일하게 전달:
```dart
GoogleLoginButton(isLoading: isLoading, ...)  // 둘 다 스피너
AppleLoginButton(isLoading: isLoading, ...)   // 둘 다 스피너
```

### 기대 동작
| 상태 | Google 버튼 | Apple 버튼 |
|------|------------|-----------|
| 대기 | 활성화 | 활성화 |
| Google 클릭 | 스피너 (isLoading=true) | 비활성화 (onPressed=null) |
| Apple 클릭 | 비활성화 (onPressed=null) | 스피너 (isLoading=true) |

### 이미 완성된 것
- `AppButton`: `onPressed == null` → `AppColors.spaceSurface` 배경 + `AppColors.textDisabled` 텍스트 (비활성화 UI 이미 구현됨)
- `GoogleLoginButton` / `AppleLoginButton`: `isLoading` + `onPressed` 파라미터 이미 지원
- `AuthNotifier.signInWithGoogle()` / `signInWithApple()`: `state = AsyncValue.loading()` 이미 호출

### Reference (cops_and_robbers)
- `ConsumerStatefulWidget` + `setState`로 `_isGoogleLoading` / `_isAppleLoading` 로컬 상태 관리
- `AuthNotifier`에서 `rethrow` → LoginPage에서 try/catch로 에러 핸들링
- 현재 프로젝트는 `ConsumerWidget` + `ref.listen` 패턴 → 별도 Riverpod provider로 구현

---

## Task 1: ActiveLoginNotifier provider 생성

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

**Step 1: SocialLoginProvider enum 추가**

Presentation Layer Providers 섹션 상단, `authState` provider 위에 추가:

```dart
/// 현재 로그인 진행 중인 소셜 프로바이더
enum SocialLoginProvider { google, apple }
```

**Step 2: ActiveLoginNotifier 추가**

`authState` provider 바로 아래, `AuthNotifier` 위에 추가:

```dart
/// 현재 진행 중인 소셜 로그인 프로바이더를 추적하는 Notifier
///
/// Google/Apple 로그인 시작 시 해당 프로바이더로 설정,
/// 로그인 완료/실패 시 null로 초기화.
/// LoginScreen에서 버튼별 로딩/비활성화 상태를 결정하는 데 사용.
@riverpod
class ActiveLoginNotifier extends _$ActiveLoginNotifier {
  @override
  SocialLoginProvider? build() => null;

  void set(SocialLoginProvider provider) => state = provider;
  void clear() => state = null;
}
```

**Step 3: AuthNotifier.signInWithGoogle()에서 activeLogin 설정**

```dart
Future<void> signInWithGoogle() async {
  ref.read(activeLoginNotifierProvider.notifier).set(SocialLoginProvider.google);
  state = const AsyncValue.loading();

  try {
    final useCase = ref.read(signInWithGoogleUseCaseProvider);
    final result = await useCase.execute();
    state = AsyncValue.data(result);
  } on FirebaseAuthException catch (e) {
    state = AsyncValue.error(
      FirebaseAuthErrorHandler.createAuthException(e, provider: 'Google'),
      StackTrace.current,
    );
  } catch (e, stack) {
    if (e is AppException) {
      state = AsyncValue.error(e, stack);
    } else {
      state = AsyncValue.error(
        AuthException(message: '알 수 없는 오류가 발생했습니다.', originalException: e),
        stack,
      );
    }
  } finally {
    ref.read(activeLoginNotifierProvider.notifier).clear();
  }
}
```

핵심: `finally` 블록에서 `clear()` — 성공/실패 모두 초기화

**Step 4: AuthNotifier.signInWithApple()에서 activeLogin 설정**

동일 패턴:
```dart
Future<void> signInWithApple() async {
  ref.read(activeLoginNotifierProvider.notifier).set(SocialLoginProvider.apple);
  state = const AsyncValue.loading();
  // ... try/catch 동일 ...
  } finally {
    ref.read(activeLoginNotifierProvider.notifier).clear();
  }
}
```

**Step 5: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `auth_provider.g.dart` 재생성 (ActiveLoginNotifier 포함)

**Step 6: flutter analyze로 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 7: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart lib/features/auth/presentation/providers/auth_provider.g.dart
git commit -m "feat: ActiveLoginNotifier provider 추가 (버튼별 로딩 상태 추적)"
```

---

## Task 2: LoginScreen 버튼별 로딩/비활성화 분기

**Files:**
- Modify: `lib/features/auth/presentation/screens/login_screen.dart`

**Step 1: 기존 공유 isLoading을 버튼별 상태로 분리**

현재 코드 (lines 28-29):
```dart
final authState = ref.watch(authNotifierProvider);
final isLoading = authState.isLoading;
```

변경 후:
```dart
final authState = ref.watch(authNotifierProvider);
final activeLogin = ref.watch(activeLoginNotifierProvider);
final isLoading = authState.isLoading;
final isGoogleLoading = isLoading && activeLogin == SocialLoginProvider.google;
final isAppleLoading = isLoading && activeLogin == SocialLoginProvider.apple;
```

**Step 2: Google 버튼에 개별 상태 적용**

현재 코드 (lines 95-96):
```dart
GoogleLoginButton(
  isLoading: isLoading,
  onPressed: isLoading
```

변경 후:
```dart
GoogleLoginButton(
  isLoading: isGoogleLoading,
  onPressed: isLoading
```

핵심: `isLoading: isGoogleLoading` (Google일 때만 스피너), `onPressed: isLoading ? null` (어느 쪽이든 로딩 중이면 클릭 차단)

**Step 3: Apple 버튼에 개별 상태 적용**

현재 코드 (lines 112-113):
```dart
AppleLoginButton(
  isLoading: isLoading,
  onPressed: isLoading
```

변경 후:
```dart
AppleLoginButton(
  isLoading: isAppleLoading,
  onPressed: isLoading
```

**Step 4: flutter analyze로 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/auth/presentation/screens/login_screen.dart
git commit -m "feat: 소셜 로그인 버튼 개별 로딩/비활성화 처리"
```

---

## 검증 체크리스트

- [ ] `build_runner` 성공 — `auth_provider.g.dart`에 `ActiveLoginNotifier` 생성됨
- [ ] `flutter analyze` — 정적 분석 통과
- [ ] Google 버튼 클릭 → Google만 스피너, Apple은 비활성화(회색)
- [ ] Apple 버튼 클릭 → Apple만 스피너, Google은 비활성화(회색)
- [ ] 대기 상태 → 두 버튼 모두 활성화
- [ ] 로그인 취소/실패 → 두 버튼 모두 활성화로 복원 (finally에서 clear)
- [ ] SnackBar 에러 표시 여전히 정상 작동
