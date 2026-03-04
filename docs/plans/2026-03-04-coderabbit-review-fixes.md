# CodeRabbit 리뷰 개선 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** PR #47 CodeRabbit 리뷰에서 지적된 디자인 시스템 미준수 및 UX 이슈 수정

**Architecture:** 디자인 토큰(AppColors, AppSpacing, AppTextStyles) 하드코딩 → 상수 치환 + Provider keepAlive 설정

**Tech Stack:** Flutter · Riverpod (build_runner) · AppColors/AppSpacing/AppTextStyles 상수 체계

---

## 수정 범위 요약

| 심각도 | 파일 | 이슈 |
|--------|------|------|
| 🟠 Major | `timer_animation_provider.dart` | AutoDispose → keepAlive (화면 재진입 시 깜빡임) |
| 🟡 Minor | `timer_screen.dart:55,63` | `Colors.white` → `AppColors.textPrimary` |
| 🟡 Minor | `timer_animation_selector.dart:78,92` | 하드코딩 여백 → `AppSpacing` |
| 🟡 Minor | `timer_animation_selector.dart:149-153` | 직접 `TextStyle` → `AppTextStyles.tag10Semibold` |
| 🟡 Minor | `timer_animation_selector.dart:168` | `Colors.black54` → `AppColors.barrier` |

---

### Task 1: TimerAnimationNotifier keepAlive 설정 (Major)

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_animation_provider.dart:8`
- Regenerate: `lib/features/timer/presentation/providers/timer_animation_provider.g.dart`

**배경:** 현재 `@riverpod`(AutoDispose)로 생성되어 화면 이탈 후 재진입 시 `build()`가 재실행됨. 이때 `defaultAsset`을 먼저 반환하고 `_loadSaved()`가 비동기로 저장값을 로드하므로, 기본 애니메이션이 잠깐 보였다가 저장된 애니메이션으로 전환되는 깜빡임 발생.

**Step 1: @riverpod → @Riverpod(keepAlive: true) 변경**

```dart
// Before
@riverpod
class TimerAnimationNotifier extends _$TimerAnimationNotifier {

// After
@Riverpod(keepAlive: true)
class TimerAnimationNotifier extends _$TimerAnimationNotifier {
```

**Step 2: build_runner 재생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `timer_animation_provider.g.dart`가 `NotifierProvider` (AutoDispose 아님)로 재생성

**Step 3: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_animation_provider.dart lib/features/timer/presentation/providers/timer_animation_provider.g.dart
git commit -m "fix: TimerAnimationNotifier keepAlive 설정으로 화면 재진입 깜빡임 방지"
```

---

### Task 2: AppColors.barrier 상수 추가

**Files:**
- Modify: `lib/core/constants/app_colors.dart`

**배경:** `Colors.black54`가 barrier 색상으로 프로젝트 전반에 5곳 이상 하드코딩되어 있음. 우선 상수를 추가하고, 이 PR 범위 내 파일만 치환.

**Step 1: AppColors에 barrier 상수 추가**

`app_colors.dart`의 Background 섹션 끝 (`spaceDivider` 아래)에 추가:

```dart
  /// Barrier - 모달/바텀시트 딤 배경 (54% 불투명 블랙)
  static const Color barrier = Color(0x8A000000);
```

**Step 2: Commit**

```bash
git add lib/core/constants/app_colors.dart
git commit -m "feat: AppColors.barrier 상수 추가"
```

---

### Task 3: timer_screen.dart 하드코딩 색상 치환

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:55,63`

**Step 1: Colors.white → AppColors.textPrimary**

```dart
// Line 55 — Before
style: AppTextStyles.heading_20.copyWith(color: Colors.white),
// After
style: AppTextStyles.heading_20.copyWith(color: AppColors.textPrimary),

// Line 63 — Before
color: isRunning ? AppColors.primary : Colors.white,
// After
color: isRunning ? AppColors.primary : AppColors.textPrimary,
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "style: timer_screen Colors.white → AppColors.textPrimary 치환"
```

---

### Task 4: timer_animation_selector.dart 디자인 토큰 치환

**Files:**
- Modify: `lib/features/timer/presentation/widgets/timer_animation_selector.dart:78,92,149-153,168`

**Step 1: 하드코딩 여백 → AppSpacing**

```dart
// Line 78 — Before
SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
// After
SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.s20),

// Line 92 — Before
margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
// After  (s6 없으므로 s8 사용)
margin: EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
```

**Step 2: TextStyle 직접 정의 → AppTextStyles**

```dart
// Lines 149-153 — Before
style: TextStyle(
  color: Colors.white,
  fontSize: 10.sp,
  fontWeight: FontWeight.w600,
),
// After
style: AppTextStyles.tag10Semibold.copyWith(color: AppColors.textPrimary),
```

**Step 3: barrier 색상 → AppColors.barrier**

```dart
// Line 168 — Before
barrierColor: Colors.black54,
// After
barrierColor: AppColors.barrier,
```

**Step 4: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/timer/presentation/widgets/timer_animation_selector.dart
git commit -m "style: timer_animation_selector 디자인 토큰 하드코딩 치환"
```

---

## 제외 항목 (의도적/문서)

| 항목 | 사유 |
|------|------|
| docs/ 마크다운 lint (코드 블록 언어, 헤딩 레벨) | 계획 문서 — 코드 품질에 영향 없음 |
| docs/ 에셋 경로 불일치 | 이미 구현에서는 올바른 에셋 사용 중, 계획 문서만 잔존 |
| Flutter 버전 3.9 표기 | 13주 워크플로우 문서의 프로젝트 초기 기준 표기 |
| `Colors.transparent` (backgroundColor) | 바텀시트 투명 배경은 Flutter 표준 패턴 |
| `timer_screen.dart`의 기타 `Colors.white` (line 71, 281) | 이번 리뷰 범위 외 — 별도 `/review-design-system`으로 처리 |
