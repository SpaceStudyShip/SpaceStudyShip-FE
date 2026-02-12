# SnackBar 에러 표시: ref.listen → try/catch 패턴 전환

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 로그인 취소/실패 시 매번 SnackBar가 표시되도록 `ref.listen` 패턴을 cops_and_robbers 프로젝트의 `ConsumerStatefulWidget` + try/catch 패턴으로 전환

**Architecture:** AuthNotifier의 signIn 메서드에 `rethrow` 추가 → LoginScreen을 `ConsumerStatefulWidget`으로 변환 → `_handleGoogleSignIn()` / `_handleAppleSignIn()`에서 `await signIn()` + try/catch로 에러를 잡아 `AppSnackBar.error()` 직접 호출. `ActiveLoginNotifier` Riverpod provider는 그대로 유지하여 버튼별 로딩 상태 관리.

**Tech Stack:** Flutter, Riverpod 2.x (@riverpod), build_runner

---

## 현재 문제

`ref.listen`을 `ConsumerWidget.build()` 안에서 사용하면 Riverpod의 listener lifecycle 문제로 **최초 에러만 SnackBar가 표시**되고, 이후 동일한 에러(로그인 취소 등)에는 콜백이 발화되지 않음.

### 해결 방향 (cops_and_robbers 참고)

| 항목 | 현재 (broken) | 변경 후 |
|------|--------------|---------|
| Widget 타입 | `ConsumerWidget` | `ConsumerStatefulWidget` |
| 에러 감지 | `ref.listen` (콜백) | try/catch (직접) |
| AuthNotifier | 에러 state 설정만 | 에러 state 설정 + `rethrow` |
| SnackBar 호출 | ref.listen 콜백 내부 | catch 블록에서 직접 호출 |
| 로딩 상태 | `ActiveLoginNotifier` provider | 유지 (변경 없음) |

---

## Task 1: AuthNotifier signIn 메서드에 rethrow 추가

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

**Step 1: signInWithGoogle()에 rethrow 추가**

현재 코드 (lines 195-208):
```dart
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
```

변경 후:
```dart
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Google'),
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
```

핵심: 각 catch 블록 끝에 `rethrow` 추가. state에 에러를 설정한 뒤 호출측(LoginScreen)에도 예외를 전파하여 try/catch로 잡을 수 있게 함.

**Step 2: signInWithApple()에도 동일하게 rethrow 추가**

현재 코드 (lines 226-239) → 동일 패턴으로 각 catch 블록 끝에 `rethrow` 추가.

**Step 3: flutter analyze 검증**

Run: `flutter analyze`
Expected: No issues found

---

## Task 2: LoginScreen을 ConsumerStatefulWidget + try/catch로 전환

**Files:**
- Modify: `lib/features/auth/presentation/screens/login_screen.dart`

**Step 1: ConsumerWidget → ConsumerStatefulWidget 전환**

현재:
```dart
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
```

변경:
```dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
```

**Step 2: ref.listen 블록 전체 삭제**

삭제할 코드 (lines 34-43):
```dart
    // 에러 발생 시 SnackBar 표시
    ref.listen<AsyncValue<AuthResultEntity?>>(authNotifierProvider, (_, next) {
      if (next.hasError && next.error != null) {
        final error = next.error;
        final message = (error is AuthException)
            ? error.message
            : '로그인에 실패했어요. 다시 시도해 주세요.';
        AppSnackBar.error(context, message);
      }
    });
```

**Step 3: _handleGoogleSignIn() 메서드 추가**

```dart
  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      // 성공 시 GoRouter redirect가 자동 처리
    } catch (_) {
      if (!mounted) return;
      _showLoginError();
    }
  }
```

**Step 4: _handleAppleSignIn() 메서드 추가**

```dart
  Future<void> _handleAppleSignIn() async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();
    } catch (_) {
      if (!mounted) return;
      _showLoginError();
    }
  }
```

**Step 5: _showLoginError() 메서드 추가**

```dart
  void _showLoginError() {
    final authState = ref.read(authNotifierProvider);
    final error = authState.error;
    final message = (error is AuthException)
        ? error.message
        : '로그인에 실패했어요. 다시 시도해 주세요.';
    AppSnackBar.error(context, message);
  }
```

핵심: `ref.read(authNotifierProvider)`로 현재 state의 error를 읽어 메시지 추출. AuthNotifier가 catch에서 state 설정 → rethrow 순서이므로 이 시점에 error가 state에 이미 저장되어 있음.

**Step 6: Google 버튼 onPressed 변경**

현재:
```dart
                    child: GoogleLoginButton(
                      isLoading: isGoogleLoading,
                      onPressed: isLoading
                          ? null
                          : () {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .signInWithGoogle();
                            },
                    ),
```

변경:
```dart
                    child: GoogleLoginButton(
                      isLoading: isGoogleLoading,
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                    ),
```

**Step 7: Apple 버튼 onPressed 변경**

현재:
```dart
                      child: AppleLoginButton(
                        isLoading: isAppleLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .signInWithApple();
                              },
                      ),
```

변경:
```dart
                      child: AppleLoginButton(
                        isLoading: isAppleLoading,
                        onPressed: isLoading ? null : _handleAppleSignIn,
                      ),
```

**Step 8: import 정리**

`AuthResultEntity` import 삭제 (ref.listen 제거로 더 이상 타입 파라미터에 사용되지 않음):
```dart
// 삭제: import '../../domain/entities/auth_result_entity.dart';
```

**Step 9: flutter analyze 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 10: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart lib/features/auth/presentation/screens/login_screen.dart
git commit -m "fix: SnackBar 에러 표시를 ref.listen에서 try/catch 패턴으로 전환"
```

---

## 최종 코드 형태

### auth_provider.dart (signInWithGoogle 변경 부분만)
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

### login_screen.dart (전체)
```dart
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/buttons/social_login_button.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    } catch (_) {
      if (!mounted) return;
      _showLoginError();
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();
    } catch (_) {
      if (!mounted) return;
      _showLoginError();
    }
  }

  void _showLoginError() {
    final authState = ref.read(authNotifierProvider);
    final error = authState.error;
    final message = (error is AuthException)
        ? error.message
        : '로그인에 실패했어요. 다시 시도해 주세요.';
    AppSnackBar.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final activeLogin = ref.watch(activeLoginNotifierProvider);
    final isLoading = authState.isLoading;
    final isGoogleLoading = isLoading && activeLogin == SocialLoginProvider.google;
    final isAppleLoading = isLoading && activeLogin == SocialLoginProvider.apple;

    return Scaffold(
      // ... (UI 코드 동일, onPressed만 변경)
    );
  }
}
```

---

## 검증 체크리스트

- [ ] `flutter analyze` — 정적 분석 통과
- [ ] Google 로그인 취소 → SnackBar 에러 표시
- [ ] Google 로그인 취소 (2번째) → SnackBar 에러 다시 표시
- [ ] Apple 로그인 취소 → SnackBar 에러 표시
- [ ] Google 클릭 → Google만 스피너, Apple은 비활성화 (기존 동작 유지)
- [ ] 로그인 성공 → GoRouter redirect로 홈 이동 (변경 없음)
