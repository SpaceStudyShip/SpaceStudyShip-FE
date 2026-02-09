# Background Color Consistency Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 바텀 네비게이션 바와 각 화면의 배경색을 우주 배경(SpaceBackground)과 시각적으로 통일

**Architecture:** MainShell의 바텀 네비게이션 바 글래스모피즘 투명도를 조정하고, 각 화면에서 SpaceBackground가 바텀 네비게이션 영역 뒤까지 올바르게 확장되도록 보장

**Tech Stack:** Flutter, AppColors, SpaceBackground widget

---

## 문제 분석

현재 구조:
- `MainShell` Scaffold: `extendBody: true` → 바디가 바텀 네비 뒤로 확장
- 바텀 네비: `BackdropFilter(blur: 20)` + `AppColors.spaceBackground.withValues(alpha: 0.85)` (85% 불투명)
- 각 화면: `backgroundColor: AppColors.spaceBackground` + `SpaceBackground()` 위젯 (별/네뷸라)

문제점:
1. 바텀 네비의 0.85 opacity 오버레이가 뒤의 SpaceBackground(별/네뷸라)를 과도하게 덮어서 시각적 단절 발생
2. `MainShell` Scaffold 자체에 `backgroundColor` 미지정 → 테마 기본값(`spaceBackground`) 사용 중이지만 명시적이지 않음
3. 바텀 네비 영역과 본문 영역 사이 색상 차이가 눈에 띔

---

### Task 1: MainShell 바텀 네비게이션 바 배경 투명도 조정

**Files:**
- Modify: `lib/routes/main_shell.dart:28`

**Step 1: 바텀 네비 배경 alpha 값을 0.85 → 0.75로 변경**

`main_shell.dart` 28번째 줄:
```dart
// Before:
color: AppColors.spaceBackground.withValues(alpha: 0.85),

// After:
color: AppColors.spaceBackground.withValues(alpha: 0.75),
```

이유: 0.85는 너무 불투명해서 뒤의 SpaceBackground가 거의 보이지 않아 단색 배경처럼 보임. 0.75로 낮추면 글래스모피즘 효과를 유지하면서도 SpaceBackground의 별/네뷸라가 살짝 비쳐 시각적 연속성 확보.

**Step 2: MainShell Scaffold에 backgroundColor 명시적 지정**

`main_shell.dart` Scaffold에 배경색 명시:
```dart
// Before:
return Scaffold(
  body: navigationShell,
  extendBody: true,

// After:
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  body: navigationShell,
  extendBody: true,
```

**Step 3: 시각적 확인**

Run: `flutter run`
확인: 바텀 네비게이션 바가 뒤의 SpaceBackground 별/네뷸라를 살짝 비추면서 본문과 자연스러운 색상 전환이 이루어지는지 확인.

**Step 4: Commit**

```bash
git add lib/routes/main_shell.dart
git commit -m "fix: 바텀 네비게이션 바 배경 투명도 조정으로 우주 배경과 시각적 통일"
```

---

### Task 2: profile_screen.dart 배경 구조 일관성 확인 및 수정

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`

**Step 1: profile_screen.dart 배경 구조 점검**

현재 `profile_screen.dart` 구조:
```dart
Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      SafeArea(child: SingleChildScrollView(...)),
    ],
  ),
)
```

이미 올바른 구조. `extendBodyBehindAppBar: true`로 AppBar 뒤로 배경 확장됨.
추가로 `extendBody: true`도 설정하여 바텀 네비 뒤로도 배경이 확장되도록 보장.

**Step 2: extendBody 추가**

```dart
// Before:
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,

// After:
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  extendBody: true,
```

참고: 이 화면은 MainShell 안의 자식 Scaffold. MainShell이 이미 `extendBody: true`이지만, 자식 Scaffold에도 명시하면 내부 레이아웃이 바텀 네비 영역을 고려한 사이즈로 확장됨.

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "fix: 프로필 화면 extendBody 추가로 바텀 네비 뒤 배경 확장"
```

---

### Task 3: 나머지 탭 화면들도 동일한 배경 구조 적용 확인

**Files:**
- Check/Modify: `lib/features/home/presentation/screens/home_screen.dart`
- Check/Modify: `lib/features/timer/presentation/screens/timer_screen.dart`
- Check/Modify: `lib/features/explore/presentation/screens/explore_screen.dart`
- Check/Modify: `lib/features/social/presentation/screens/social_screen.dart`

**Step 1: 각 화면의 배경 구조 확인**

모든 탭 화면이 동일한 패턴을 따르는지 확인:
- `backgroundColor: AppColors.spaceBackground` ✅
- `extendBodyBehindAppBar: true` ✅
- `SpaceBackground()` 위젯 사용 ✅

누락된 항목이 있으면 추가.

**Step 2: 통일성 수정 적용**

각 화면에서 누락된 속성 추가. 특히 `home_screen.dart`는 이미 `CustomScrollView` + `SliverAppBar` 구조라 별도 확인 필요.

**Step 3: Commit**

```bash
git add -A
git commit -m "fix: 모든 탭 화면 배경 구조 통일"
```

---

### Task 4: flutter analyze 검증

**Step 1: 분석 실행**

Run: `flutter analyze`
Expected: No issues found!

**Step 2: 앱 실행하여 시각적 검증**

Run: `flutter run`
확인 포인트:
- 모든 탭에서 바텀 네비 색상이 배경과 자연스럽게 연결되는지
- 글래스모피즘 효과가 적절히 유지되는지
- 탭 전환 시 배경색 깜빡임이 없는지
