# Component Extraction & Code Quality Refactor Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extract 5 duplicated UI patterns into reusable widgets and fix inline TextStyle violations to improve code consistency and maintainability.

**Architecture:** Create new reusable widgets in `core/widgets/` following existing Atomic Design structure. Each extraction replaces inline duplicated code with a single-source widget. All new widgets are optional-parameter-based for backward compatibility.

**Tech Stack:** Flutter StatelessWidget, ScreenUtil, AppTextStyles, AppColors

---

### Task 1: Create `GradientCircleIcon` widget

**Files:**
- Create: `lib/core/widgets/atoms/gradient_circle_icon.dart`

**Step 1: Create the widget**

The same gradient circle + glow + ShaderMask icon pattern appears in 4 places (splash, login, onboarding, spaceship_header). Extract into a reusable atom:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 그라데이션 원형 아이콘
///
/// RadialGradient 배경 + border + glow shadow + ShaderMask 아이콘.
/// 스플래시, 로그인, 온보딩, 우주선 헤더에서 공통 사용.
class GradientCircleIcon extends StatelessWidget {
  const GradientCircleIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 80,
    this.iconSize,
    this.gradientColors,
  });

  /// 아이콘
  final IconData icon;

  /// 기본 색상 (그라데이션/테두리/그림자에 사용)
  final Color color;

  /// 원형 컨테이너 크기 (기본 80)
  final double size;

  /// 아이콘 크기 (기본: size * 0.45)
  final double? iconSize;

  /// ShaderMask용 그라데이션 색상 (기본: [color, color.withValues(alpha: 0.7)])
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? (size * 0.45).sp;
    final effectiveGradient = gradientColors ?? [color, color.withValues(alpha: 0.7)];

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: effectiveGradient,
          ).createShader(bounds),
          child: Icon(
            icon,
            size: effectiveIconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Run static analysis**

Run: `flutter analyze lib/core/widgets/atoms/gradient_circle_icon.dart`
Expected: No issues found

---

### Task 2: Replace GradientCircleIcon usages in 4 files

**Files:**
- Modify: `lib/features/auth/presentation/screens/splash_screen.dart:51-88`
- Modify: `lib/features/auth/presentation/screens/login_screen.dart:34-71`
- Modify: `lib/features/auth/presentation/screens/onboarding_screen.dart:109-149`
- Modify: `lib/features/home/presentation/widgets/spaceship_header.dart:177-221`

**Step 1: Update splash_screen.dart**

Replace the 38-line Container with:
```dart
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';

// Replace Container(width: 96.w, ...) with:
GradientCircleIcon(
  icon: Icons.rocket_launch_rounded,
  color: AppColors.primary,
  size: 96,
  iconSize: 44,
  gradientColors: [AppColors.primaryLight, AppColors.primary],
),
```

**Step 2: Update login_screen.dart**

Replace the 38-line Container with:
```dart
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';

// Replace Container(width: 80.w, ...) with:
GradientCircleIcon(
  icon: Icons.rocket_launch_rounded,
  color: AppColors.primary,
  size: 80,
  iconSize: 36,
  gradientColors: [AppColors.primaryLight, AppColors.primary],
),
```

**Step 3: Update onboarding_screen.dart**

Replace the 41-line Container with:
```dart
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';

// Replace Container(width: 96.w, ...) with:
GradientCircleIcon(
  icon: page.icon,
  color: page.color,
  size: 96,
  iconSize: 42,
),
```

**Step 4: Update spaceship_header.dart**

Replace the `_buildSpaceshipIcon()` method body with:
```dart
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';

Widget _buildSpaceshipIcon() {
  final gradient = SpaceIcons.gradientOf(widget.spaceshipIcon);
  final baseColor = SpaceIcons.colorOf(widget.spaceshipIcon);

  return GradientCircleIcon(
    icon: SpaceIcons.resolve(widget.spaceshipIcon),
    color: baseColor,
    size: 80,
    iconSize: 40,
    gradientColors: gradient,
  );
}
```

**Step 5: Run static analysis**

Run: `flutter analyze`
Expected: No issues found

---

### Task 3: Fix inline TextStyles in profile_screen.dart

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`

Replace 6 raw `TextStyle()` instances with `AppTextStyles` constants. Also add missing `text_styles.dart` import.

**Step 1: Add import and fix AppBar title (line ~24)**

```dart
import '../../../../core/constants/text_styles.dart';

// Before:
style: TextStyle(fontSize: 20.sp, fontFamily: 'Pretendard-Bold', color: Colors.white)
// After:
style: AppTextStyles.heading_20.copyWith(color: Colors.white)
```

**Step 2: Fix profile name (line ~98)**

```dart
// Before:
style: TextStyle(fontSize: 20.sp, fontFamily: 'Pretendard-Bold', color: Colors.white)
// After:
style: AppTextStyles.heading_20.copyWith(color: Colors.white)
```

**Step 3: Fix level badge (line ~115)**

```dart
// Before:
style: TextStyle(fontSize: 12.sp, fontFamily: 'Pretendard-Medium', color: AppColors.primary)
// After:
style: AppTextStyles.tag_12.copyWith(color: AppColors.primary)
```

**Step 4: Fix stat value (line ~152)**

```dart
// Before:
style: TextStyle(fontSize: 18.sp, fontFamily: 'Pretendard-Bold', color: Colors.white)
// After:
style: AppTextStyles.subHeading_18.copyWith(color: Colors.white)
```

**Step 5: Fix stat label (line ~161)**

```dart
// Before:
style: TextStyle(fontSize: 12.sp, fontFamily: 'Pretendard-Regular', color: AppColors.textTertiary)
// After:
style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary)
```

**Step 6: Fix menu item title (line ~215)**

```dart
// Before:
style: TextStyle(fontSize: 16.sp, fontFamily: 'Pretendard-Medium', color: Colors.white)
// After:
style: AppTextStyles.label16Medium.copyWith(color: Colors.white)
```

**Step 7: Run static analysis**

Run: `flutter analyze lib/features/profile/`
Expected: No issues found

---

### Task 4: Create `SpaceEmptyState` widget

**Files:**
- Create: `lib/core/widgets/states/space_empty_state.dart`

**Step 1: Create the widget**

The empty state pattern appears in social (3 tabs), explore (1), home (2 cards). Extract:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../animations/entrance_animations.dart';

/// 빈 상태 표시 위젯
///
/// 아이콘 원형 + 제목 + 부제목으로 구성된 빈 상태 플레이스홀더.
/// 소셜, 탐험, 홈 화면 등에서 공통 사용.
class SpaceEmptyState extends StatelessWidget {
  const SpaceEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.iconSize = 72,
    this.animated = true,
  });

  /// 표시할 아이콘
  final IconData icon;

  /// 제목 텍스트
  final String title;

  /// 부제목 텍스트
  final String subtitle;

  /// 아이콘 배경/테두리 색상 (기본: AppColors.textTertiary)
  final Color? color;

  /// 아이콘 원형 크기 (기본: 72)
  final double iconSize;

  /// FadeSlideIn 애니메이션 적용 여부 (기본: true)
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textTertiary;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: iconSize.w,
          height: iconSize.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveColor.withValues(alpha: 0.1),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: (iconSize * 0.44).sp,
            color: effectiveColor,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    final widget = Center(child: content);
    if (animated) return FadeSlideIn(child: widget);
    return widget;
  }
}
```

**Step 2: Run static analysis**

Run: `flutter analyze lib/core/widgets/states/space_empty_state.dart`
Expected: No issues found

---

### Task 5: Replace SpaceEmptyState usages in 3 files

**Files:**
- Modify: `lib/features/social/presentation/screens/social_screen.dart`
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart`
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: Update social_screen.dart**

Remove `_buildEmptyTab()` method. Replace 3 tab methods:
```dart
import '../../../../core/widgets/states/space_empty_state.dart';

// Remove _buildEmptyTab method entirely

Widget _buildFriendsTab() {
  return SpaceEmptyState(
    icon: Icons.people_rounded,
    color: AppColors.primary,
    title: '아직 친구가 없어요',
    subtitle: '친구를 추가해서 함께 공부해요',
  );
}

Widget _buildGroupsTab() {
  return SpaceEmptyState(
    icon: Icons.groups_rounded,
    color: AppColors.secondary,
    title: '참여 중인 그룹이 없어요',
    subtitle: '그룹에 참여해서 함께 목표를 달성해요',
  );
}

Widget _buildRankingTab() {
  return SpaceEmptyState(
    icon: Icons.emoji_events_rounded,
    color: AppColors.accentGold,
    title: '랭킹 준비 중',
    subtitle: '공부 시간을 기록하면 랭킹에 참여할 수 있어요',
  );
}
```

Also remove the now-unused `entrance_animations.dart` import if `FadeSlideIn` is no longer used directly.

**Step 2: Update explore_screen.dart**

Replace `_buildEmptyState()` method:
```dart
import '../../../../core/widgets/states/space_empty_state.dart';

Widget _buildEmptyState() {
  return SpaceEmptyState(
    icon: Icons.explore_rounded,
    color: AppColors.secondary,
    title: '탐험할 행성이 없습니다',
    subtitle: '곧 새로운 행성이 추가됩니다!',
    iconSize: 80,
  );
}
```

Note: explore_screen still uses `FadeSlideIn` and `ScaleIn` for planet nodes, so keep that import.

**Step 3: Update home_screen.dart**

Replace `_buildEmptyTodoCard()` and `_buildEmptyActivityCard()`:
```dart
import '../../../../core/widgets/states/space_empty_state.dart';

Widget _buildEmptyTodoCard() {
  return AppCard(
    style: AppCardStyle.outlined,
    padding: EdgeInsets.all(24.w),
    child: SpaceEmptyState(
      icon: Icons.edit_note_rounded,
      title: '오늘의 할 일이 없어요',
      subtitle: '할 일을 추가해보세요',
      iconSize: 40,
      animated: false,
    ),
  );
}

Widget _buildEmptyActivityCard() {
  return AppCard(
    style: AppCardStyle.outlined,
    padding: EdgeInsets.all(24.w),
    child: SpaceEmptyState(
      icon: Icons.auto_awesome_rounded,
      title: '아직 활동 기록이 없어요',
      subtitle: '타이머로 공부를 시작해보세요',
      iconSize: 40,
      animated: false,
    ),
  );
}
```

Note: Home screen cards use `AppCard` wrapper + `animated: false` (parent `FadeSlideIn` already handles animation).

**Step 4: Run static analysis**

Run: `flutter analyze`
Expected: No issues found

---

### Task 6: Create `SpaceStatItem` widget

**Files:**
- Create: `lib/core/widgets/atoms/space_stat_item.dart`

**Step 1: Create the widget**

Timer와 Profile 화면의 `_buildStatItem()` 통합:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 통계 아이템 위젯
///
/// 아이콘 + 라벨 + 값으로 구성된 통계 표시 위젯.
/// 타이머, 프로필 화면에서 공통 사용.
class SpaceStatItem extends StatelessWidget {
  const SpaceStatItem({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.valueFirst = false,
  });

  /// 상단 아이콘 (optional)
  final IconData? icon;

  /// 라벨 텍스트
  final String label;

  /// 값 텍스트
  final String value;

  /// true면 값이 라벨 위에 표시 (프로필 스타일)
  final bool valueFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null && !valueFirst) ...[
          Icon(icon, size: 16.w, color: AppColors.textTertiary),
          SizedBox(height: 4.h),
        ],
        if (valueFirst) ...[
          Text(
            value,
            style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
          ),
        ] else ...[
          Text(
            label,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.paragraph_14.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
```

**Step 2: Run static analysis**

Run: `flutter analyze lib/core/widgets/atoms/space_stat_item.dart`
Expected: No issues found

---

### Task 7: Replace SpaceStatItem usages + final verification

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart`
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`

**Step 1: Update timer_screen.dart**

Remove `_buildStatItem()` method, replace usages:
```dart
import '../../../../core/widgets/atoms/space_stat_item.dart';

// Replace _buildStatItem(icon: Icons.today_rounded, label: '오늘', value: '0시간 0분')
// with:
SpaceStatItem(icon: Icons.today_rounded, label: '오늘', value: '0시간 0분'),
SpaceStatItem(icon: Icons.date_range_rounded, label: '이번 주', value: '0시간 0분'),
SpaceStatItem(icon: Icons.local_fire_department_rounded, label: '연속', value: '0일'),
```

Remove `_buildStatItem` method definition.

**Step 2: Update profile_screen.dart**

Remove `_buildStatItem()` method, replace usages:
```dart
import '../../../../core/widgets/atoms/space_stat_item.dart';

// Replace _buildStatItem('총 공부', '0시간') with:
SpaceStatItem(label: '총 공부', value: '0시간', valueFirst: true),
SpaceStatItem(label: '연속', value: '0일', valueFirst: true),
SpaceStatItem(label: '배지', value: '0개', valueFirst: true),
```

Remove `_buildStatItem` method definition.

**Step 3: Full analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/widgets/atoms/gradient_circle_icon.dart \
  lib/core/widgets/states/space_empty_state.dart \
  lib/core/widgets/atoms/space_stat_item.dart \
  lib/features/auth/presentation/screens/splash_screen.dart \
  lib/features/auth/presentation/screens/login_screen.dart \
  lib/features/auth/presentation/screens/onboarding_screen.dart \
  lib/features/home/presentation/widgets/spaceship_header.dart \
  lib/features/home/presentation/screens/home_screen.dart \
  lib/features/profile/presentation/screens/profile_screen.dart \
  lib/features/social/presentation/screens/social_screen.dart \
  lib/features/explore/presentation/screens/explore_screen.dart \
  lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "refactor: extract reusable widgets from duplicated UI patterns

- GradientCircleIcon: gradient circle + glow + ShaderMask (4 usages)
- SpaceEmptyState: icon + title + subtitle empty placeholder (6 usages)
- SpaceStatItem: icon + label + value stat display (6 usages)
- Fix 6 inline TextStyle() → AppTextStyles in profile_screen"
```

---

### Summary of Changes

| New Widget | Location | Replaces | Usages |
|-----------|----------|----------|--------|
| `GradientCircleIcon` | `core/widgets/atoms/` | 30-line gradient circle Container | 4 |
| `SpaceEmptyState` | `core/widgets/states/` | Empty state Column pattern | 6 |
| `SpaceStatItem` | `core/widgets/atoms/` | `_buildStatItem()` methods | 6 |

| Fix | Files | Count |
|-----|-------|-------|
| TextStyle → AppTextStyles | profile_screen.dart | 6 |

**Total: 3 new files, 9 modified files**
**Estimated code reduction: ~200 lines of duplicated UI code**
