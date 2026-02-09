# Unified Space Background Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extract the star field background from ExploreScreen into a reusable `SpaceBackground` widget and apply it consistently across all screens for a cohesive space theme.

**Architecture:** Create a lightweight `SpaceBackground` widget in `core/widgets/backgrounds/` that renders twinkling stars + nebula overlays. It fills its parent via `Positioned.fill`, uses fewer stars than the explore map (30 vs 50), and pauses animations when the tab is inactive via `TickerMode`. Each screen adds it as the bottom layer of a `Stack`. AppBar screens get transparent backgrounds so stars show through.

**Tech Stack:** Flutter CustomPainter, AnimationController, TickerMode, RepaintBoundary

---

### Task 1: Create reusable `SpaceBackground` widget

**Files:**
- Create: `lib/core/widgets/backgrounds/space_background.dart`

**Step 1: Create the SpaceBackground widget**

Extract the star + nebula painting logic from `SpaceMapBackground` into a simpler, screen-filling version:

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 우주 별 배경 위젯 (화면 전체용)
///
/// 랜덤 배치된 별들이 반짝이는 우주 배경을 표현합니다.
/// ExploreScreen의 SpaceMapBackground와 동일한 비주얼이지만
/// 일반 화면 크기에 최적화되어 별 수가 적습니다 (30개).
/// RepaintBoundary + TickerMode 기반 성능 보호.
class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  static const _starTintColors = [
    Color(0xFF64B5F6), // blue
    Color(0xFFBA68C8), // purple
    Color(0xFFFFD740), // gold
    Color(0xFFF06292), // pink
    Color(0xFF4DD0E1), // cyan
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final random = Random(42);
    _stars = List.generate(30, (i) {
      final hasTint = i % 5 == 0;
      final tintColor = hasTint
          ? _starTintColors[random.nextInt(_starTintColors.length)]
          : null;
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.0 + 0.5,
        twinkle: i < 5,
        twinkleOffset: random.nextDouble(),
        tintColor: tintColor,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context)) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _NebulaPainter(),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _StarPainter(
                      stars: _stars,
                      twinkleValue: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _Star, _NebulaPainter, _StarPainter — same logic as space_map_background.dart
// but painters use size from CustomPaint (no explicit height needed)
```

Key differences from `SpaceMapBackground`:
- No `height` parameter — uses `SizedBox.expand` to fill parent
- 30 stars instead of 50, 5 twinkling instead of 8
- Painters use `size` from `CustomPaint` directly (no `widget.height`)

**Step 2: Run static analysis**

Run: `flutter analyze lib/core/widgets/backgrounds/space_background.dart`
Expected: No issues found

---

### Task 2: Apply SpaceBackground to auth screens (Splash, Login, Onboarding)

**Files:**
- Modify: `lib/features/auth/presentation/screens/splash_screen.dart`
- Modify: `lib/features/auth/presentation/screens/login_screen.dart`
- Modify: `lib/features/auth/presentation/screens/onboarding_screen.dart`

These screens have no AppBar, so just wrap the `body` in a `Stack`:

**Step 1: Update SplashScreen**

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

// Change body from Center(...) to:
body: Stack(
  children: [
    const Positioned.fill(child: SpaceBackground()),
    Center(
      child: Column(/* existing content */),
    ),
  ],
),
```

**Step 2: Update LoginScreen**

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

// Change body from SafeArea(...) to:
body: Stack(
  children: [
    const Positioned.fill(child: SpaceBackground()),
    SafeArea(
      child: Padding(/* existing content */),
    ),
  ],
),
```

**Step 3: Update OnboardingScreen**

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

// Change body from SafeArea(...) to:
body: Stack(
  children: [
    const Positioned.fill(child: SpaceBackground()),
    SafeArea(
      child: Column(/* existing content */),
    ),
  ],
),
```

**Step 4: Run static analysis**

Run: `flutter analyze`
Expected: No issues found

---

### Task 3: Apply SpaceBackground to main tab screens (Home, Timer, Social, Profile)

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart`
- Modify: `lib/features/social/presentation/screens/social_screen.dart`
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart`

These screens have AppBars, so additionally need:
- `extendBodyBehindAppBar: true` on Scaffold
- `backgroundColor: Colors.transparent` + `scrolledUnderElevation: 0` on AppBar

**Step 1: Update HomeScreen**

HomeScreen uses `CustomScrollView` with `SliverAppBar`. The SliverAppBar already has `pinned: true`.

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

// Scaffold changes:
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      CustomScrollView(
        slivers: [
          SliverAppBar(
            // ...existing...
            backgroundColor: Colors.transparent,
            // ...rest unchanged...
          ),
          // ...existing slivers...
        ],
      ),
    ],
  ),
);
```

Note: SliverAppBar `backgroundColor` becomes transparent. The `pinned: true` AppBar when collapsed will show stars behind it.

**Step 2: Update TimerScreen**

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    // ...existing title & actions...
  ),
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      Center(
        child: Column(/* existing content */),
      ),
    ],
  ),
);
```

**Step 3: Update SocialScreen**

SocialScreen has `DefaultTabController` wrapping `Scaffold` with `AppBar` that has a `TabBar` bottom. The TabBar indicator needs to remain visible.

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

return DefaultTabController(
  length: 3,
  child: Scaffold(
    backgroundColor: AppColors.spaceBackground,
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      // ...existing title...
      bottom: TabBar(
        // ...existing...
      ),
    ),
    body: Stack(
      children: [
        const Positioned.fill(child: SpaceBackground()),
        TabBarView(
          children: [_buildFriendsTab(), _buildGroupsTab(), _buildRankingTab()],
        ),
      ],
    ),
  ),
);
```

**Step 4: Update ProfileScreen**

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    // ...existing title & actions...
  ),
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(/* existing content */),
        ),
      ),
    ],
  ),
);
```

Note: ProfileScreen's `SingleChildScrollView` needs `SafeArea` wrapping since `extendBodyBehindAppBar` makes body go behind AppBar.

**Step 5: Run static analysis**

Run: `flutter analyze`
Expected: No issues found

---

### Task 4: Apply SpaceBackground to ExplorationDetailScreen

**Files:**
- Modify: `lib/features/exploration/presentation/screens/exploration_detail_screen.dart`

This screen uses `CustomScrollView` with `SliverAppBar`. Similar to HomeScreen.

**Step 1: Update ExplorationDetailScreen**

```dart
// Add import
import '../../../../core/widgets/backgrounds/space_background.dart';

return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      CustomScrollView(
        slivers: [
          SliverAppBar(
            // ...existing...
            backgroundColor: Colors.transparent,
            // ...rest unchanged...
          ),
          // ...existing slivers...
        ],
      ),
    ],
  ),
);
```

**Step 2: Run static analysis**

Run: `flutter analyze`
Expected: No issues found

---

### Task 5: Final verification and commit

**Step 1: Full analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: Commit**

```bash
git add lib/core/widgets/backgrounds/space_background.dart \
  lib/features/auth/presentation/screens/splash_screen.dart \
  lib/features/auth/presentation/screens/login_screen.dart \
  lib/features/auth/presentation/screens/onboarding_screen.dart \
  lib/features/home/presentation/screens/home_screen.dart \
  lib/features/timer/presentation/screens/timer_screen.dart \
  lib/features/social/presentation/screens/social_screen.dart \
  lib/features/profile/presentation/screens/profile_screen.dart \
  lib/features/exploration/presentation/screens/exploration_detail_screen.dart
git commit -m "feat: add unified star field background across all screens

Extract twinkling star + nebula background into reusable SpaceBackground
widget and apply to all screens for cohesive space theme experience.
Stars visible behind transparent AppBars and bottom navigation."
```

---

### Summary of Changes

| File | Change | Notes |
|------|--------|-------|
| `core/widgets/backgrounds/space_background.dart` | **NEW** | 30 stars, 5 twinkling, nebula, TickerMode |
| `auth/.../splash_screen.dart` | Stack + SpaceBackground | No AppBar |
| `auth/.../login_screen.dart` | Stack + SpaceBackground | No AppBar |
| `auth/.../onboarding_screen.dart` | Stack + SpaceBackground | No AppBar |
| `home/.../home_screen.dart` | Stack + transparent SliverAppBar | `extendBodyBehindAppBar` |
| `timer/.../timer_screen.dart` | Stack + transparent AppBar | `extendBodyBehindAppBar` |
| `social/.../social_screen.dart` | Stack + transparent AppBar + TabBar | `extendBodyBehindAppBar` |
| `profile/.../profile_screen.dart` | Stack + transparent AppBar + SafeArea | `extendBodyBehindAppBar` |
| `exploration/.../exploration_detail_screen.dart` | Stack + transparent SliverAppBar | Already has gradient header |

**ExploreScreen**: Unchanged (already has `SpaceMapBackground` with 50 stars for scrollable map)

**Performance safeguards:**
- `RepaintBoundary` isolates star repainting from parent widget tree
- `TickerMode.of(context)` pauses animation on inactive tabs
- Only 5/30 stars twinkle (reduced from 8/50 in explore map)
- `shouldRepaint` only triggers on twinkle value change

**Total: 1 new file, 8 modified files**
