# Social Login Button 프로젝트 적응 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** cops_and_robbers에서 가져온 `social_login_button.dart`를 현재 프로젝트(Space Study Ship) 색상 체계에 맞게 수정하고, `login_screen.dart`에 Google + Apple 소셜 로그인 버튼을 연결한다.

**Architecture:** 기존 `AppButton` 래퍼 패턴을 유지하면서 AppColors 참조만 현재 프로젝트에 맞게 교체. login_screen에서는 Platform.isIOS 체크로 Apple 버튼을 iOS에서만 노출.

**Tech Stack:** Flutter, flutter_svg, sign_in_with_apple, google_sign_in, Riverpod

---

## 현재 상태 분석

### 문제점
1. `social_login_button.dart`에서 `AppColors.white`, `AppColors.black` 참조 → **현재 프로젝트에 해당 상수 없음**
2. `login_screen.dart`에서 Google 버튼을 raw `AppButton`으로 사용 중 → `GoogleLoginButton` 위젯 미활용
3. Apple 로그인 버튼 없음 (auth 인프라는 이미 완성됨)

### 이미 완성된 것
- `assets/icons/icon_google.svg` ✅
- `assets/icons/icon_apple.svg` ✅
- `AuthNotifier.signInWithGoogle()` ✅
- `AuthNotifier.signInWithApple()` ✅
- `FirebaseAuthDataSource.signInWithApple()` ✅
- `AppButton` icon/iconPosition 지원 ✅

---

## Task 1: `social_login_button.dart` 색상 참조 수정

**Files:**
- Modify: `lib/core/widgets/buttons/social_login_button.dart`

**Step 1: GoogleLoginButton 색상 수정**

`AppColors.white` → `Colors.white` (Flutter 내장)

```dart
// 변경 전
backgroundColor: AppColors.white,

// 변경 후
backgroundColor: Colors.white,
```

**Step 2: AppleLoginButton 색상 수정**

`AppColors.black` → `const Color(0xFF000000)`
`AppColors.white` → `Colors.white`

```dart
// 변경 전
backgroundColor: AppColors.black,
foregroundColor: AppColors.white,

// 변경 후
backgroundColor: const Color(0xFF000000),
foregroundColor: Colors.white,
```

**Step 3: flutter analyze로 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/widgets/buttons/social_login_button.dart
git commit -m "fix: social_login_button 색상 참조를 현재 프로젝트에 맞게 수정"
```

---

## Task 2: `login_screen.dart`에 Google + Apple 버튼 통합

**Files:**
- Modify: `lib/features/auth/presentation/screens/login_screen.dart`

**Step 1: import 추가**

```dart
import 'dart:io' show Platform;
import '../../../../core/widgets/buttons/social_login_button.dart';
```

**Step 2: 기존 Google AppButton → GoogleLoginButton으로 교체**

현재 코드 (lines 85-100):
```dart
FadeSlideIn(
  delay: const Duration(milliseconds: 300),
  child: AppButton(
    text: 'Google로 시작하기',
    isLoading: isLoading,
    onPressed: isLoading
        ? null
        : () {
            ref.read(authNotifierProvider.notifier).signInWithGoogle();
          },
    width: double.infinity,
    height: 56.h,
  ),
),
```

변경 후:
```dart
// Google 로그인 버튼
FadeSlideIn(
  delay: const Duration(milliseconds: 300),
  child: SizedBox(
    width: double.infinity,
    child: GoogleLoginButton(
      isLoading: isLoading,
      onPressed: isLoading
          ? null
          : () {
              ref.read(authNotifierProvider.notifier).signInWithGoogle();
            },
    ),
  ),
),

SizedBox(height: AppSpacing.s12),

// Apple 로그인 버튼 (iOS만)
if (Platform.isIOS)
  FadeSlideIn(
    delay: const Duration(milliseconds: 400),
    child: SizedBox(
      width: double.infinity,
      child: AppleLoginButton(
        isLoading: isLoading,
        onPressed: isLoading
            ? null
            : () {
                ref.read(authNotifierProvider.notifier).signInWithApple();
              },
      ),
    ),
  ),
```

**Step 3: 약관 FadeSlideIn delay 조정**

Apple 버튼 추가로 delay 순서 조정:
```dart
// 변경 전: delay 400ms
FadeSlideIn(
  delay: const Duration(milliseconds: 400),
  child: Text('로그인 시 서비스 이용약관...',

// 변경 후: delay 500ms
FadeSlideIn(
  delay: const Duration(milliseconds: 500),
  child: Text('로그인 시 서비스 이용약관...',
```

**Step 4: 미사용 import 제거**

`app_button.dart` import를 제거 (GoogleLoginButton/AppleLoginButton이 내부에서 사용하므로):
```dart
// 제거
import '../../../../core/widgets/buttons/app_button.dart';
```

**Step 5: flutter analyze로 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/auth/presentation/screens/login_screen.dart
git commit -m "feat: 로그인 화면에 Google/Apple 소셜 로그인 버튼 통합"
```

---

## Task 3: GoogleLoginButton/AppleLoginButton width 지원 추가

**Files:**
- Modify: `lib/core/widgets/buttons/social_login_button.dart`

현재 `GoogleLoginButton`과 `AppleLoginButton`은 `width` 파라미터를 지원하지 않아 SizedBox로 감싸야 함.
부모에서 `SizedBox(width: double.infinity)` 대신 버튼 자체에 width를 전달하면 더 깔끔.

**Step 1: width, height 파라미터 추가**

```dart
class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Google로 시작하기',
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/icons/icon_google.svg',
        width: 20.w,
        height: 20.h,
      ),
      iconPosition: IconPosition.leading,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF000000),
      showBorder: true,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }
}
```

AppleLoginButton도 동일하게 width, height 파라미터 추가.

**Step 2: 아이콘 크기를 직접 ScreenUtil 값으로 변경**

`AppSpacing.horizontal20` / `AppSpacing.vertical20`는 간격용 → 아이콘 크기에는 `20.w` / `20.h` 직접 사용이 더 적절:

```dart
// 변경 전
width: AppSpacing.horizontal20,
height: AppSpacing.vertical20,

// 변경 후
width: 20.w,
height: 20.h,
```

**Step 3: login_screen.dart에서 SizedBox 래퍼 제거**

```dart
// 변경 전
SizedBox(
  width: double.infinity,
  child: GoogleLoginButton(...),
),

// 변경 후
GoogleLoginButton(
  ...,
  width: double.infinity,
),
```

AppleLoginButton도 동일.

**Step 4: flutter analyze로 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/core/widgets/buttons/social_login_button.dart lib/features/auth/presentation/screens/login_screen.dart
git commit -m "refactor: 소셜 로그인 버튼에 width/height 파라미터 추가"
```

---

## 검증 체크리스트

- [ ] `flutter analyze` — 정적 분석 통과
- [ ] Google 로그인 버튼이 흰색 배경 + 검정 텍스트 + Google 아이콘으로 표시
- [ ] Apple 로그인 버튼이 검정 배경 + 흰색 텍스트 + Apple 아이콘으로 표시
- [ ] Apple 버튼은 iOS에서만 노출 (`Platform.isIOS`)
- [ ] 두 버튼 모두 `isLoading` 상태에서 로딩 인디케이터 표시
- [ ] 버튼 클릭 시 각각 `signInWithGoogle()`, `signInWithApple()` 호출
