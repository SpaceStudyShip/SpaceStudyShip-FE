# Spaceship Icon Upgrade Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 홈 화면 탐사선 아이콘 크기를 키우고, 나중에 Rive 애니메이션으로 교체할 수 있는 구조로 분리

**Architecture:** `SpaceshipAvatar` 위젯을 만들어 현재 `GradientCircleIcon` 직접 호출을 대체. 나중에 내부만 Rive로 바꾸면 호출부는 변경 없음

**Tech Stack:** Flutter, GradientCircleIcon (현재), Rive (미래)

---

## 현재 상태

- `spaceship_header.dart:183-189` → `GradientCircleIcon(size: 80, iconSize: 40)` 직접 호출
- 80.w = 약 75~80px 실제 크기 → 헤더 320.h 대비 작음
- 정적 아이콘, 애니메이션 없음

## 목표

- 탐사선 크기: 80 → 120 (헤더 대비 적절한 비율)
- glow 이펙트 강화 (존재감)
- `SpaceshipAvatar` 위젯으로 분리 → Rive 교체 시 이 위젯 내부만 수정

---

### Task 1: SpaceshipAvatar 위젯 생성

**Files:**
- Create: `lib/core/widgets/space/spaceship_avatar.dart`

**Step 1: SpaceshipAvatar 위젯 작성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/space_icons.dart';
import '../atoms/gradient_circle_icon.dart';

/// 우주선 아바타 위젯
///
/// 현재: GradientCircleIcon 기반 정적 아이콘 + pulse glow
/// 미래: Rive 애니메이션으로 교체 예정 (이 위젯 내부만 수정)
class SpaceshipAvatar extends StatefulWidget {
  const SpaceshipAvatar({
    super.key,
    required this.icon,
    this.size = 120,
    this.showGlow = true,
  });

  /// 우주선 이모지/아이콘 키
  final String icon;

  /// 전체 크기 (기본 120)
  final double size;

  /// glow 애니메이션 표시 여부
  final bool showGlow;

  @override
  State<SpaceshipAvatar> createState() => _SpaceshipAvatarState();
}

class _SpaceshipAvatarState extends State<SpaceshipAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = SpaceIcons.colorOf(widget.icon);
    final gradient = SpaceIcons.gradientOf(widget.icon);

    // TODO: 나중에 Rive 에셋으로 교체
    // return RiveAnimation(
    //   'assets/animations/spaceship.riv',
    //   artboard: widget.icon,
    //   fit: BoxFit.contain,
    // );

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = 0.15 + _glowController.value * 0.15;
        final glowSpread = 4.0 + _glowController.value * 8.0;
        final glowBlur = 24.0 + _glowController.value * 16.0;

        return Container(
          width: widget.size.w,
          height: widget.size.w,
          decoration: widget.showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withValues(alpha: glowOpacity),
                      blurRadius: glowBlur,
                      spreadRadius: glowSpread,
                    ),
                  ],
                )
              : null,
          child: GradientCircleIcon(
            icon: SpaceIcons.resolve(widget.icon),
            color: baseColor,
            size: widget.size,
            iconSize: widget.size * 0.42,
            gradientColors: gradient,
          ),
        );
      },
    );
  }
}
```

**Step 2: Verify**

Run: `flutter analyze`

**Step 3: Commit**

```bash
git add lib/core/widgets/space/spaceship_avatar.dart
git commit -m "feat: SpaceshipAvatar 위젯 생성 (Rive 교체 대비 구조)"
```

---

### Task 2: SpaceshipHeader에서 SpaceshipAvatar 사용

**Files:**
- Modify: `lib/features/home/presentation/widgets/spaceship_header.dart`

**Step 1: import 추가 및 _buildSpaceshipIcon 교체**

`spaceship_header.dart`에서:

```dart
// Before (import):
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';

// After (import):
import '../../../../core/widgets/space/spaceship_avatar.dart';
```

```dart
// Before:
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

// After:
Widget _buildSpaceshipIcon() {
  return SpaceshipAvatar(
    icon: widget.spaceshipIcon,
    size: 120,
  );
}
```

**Step 2: Verify**

Run: `flutter analyze`

**Step 3: Commit**

```bash
git add lib/features/home/presentation/widgets/spaceship_header.dart
git commit -m "feat: 홈 탐사선 아이콘 크기 확대 (80→120) + SpaceshipAvatar 적용"
```

---

### Task 3: 시각적 검증

**Step 1: 앱 실행**

Run: `flutter run`

확인 포인트:
- 탐사선 아이콘이 이전보다 눈에 띄게 큰지
- pulse glow 애니메이션이 자연스러운지
- 헤더 내 다른 요소(이름, 연료/경험치 칩)와 겹치지 않는지
- 120이 너무 크면 100~110으로 조정

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: No issues found!
