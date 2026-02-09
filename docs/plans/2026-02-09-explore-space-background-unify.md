# Explore Screen Space Background Color Unification Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the explore screen's AppBar and bottom area seamlessly blend with the star field background, eliminating visible color boundaries.

**Architecture:** The star field (`SpaceMapBackground`) currently renders only in the body area, creating hard edges at the AppBar (top) and bottom nav (bottom). We fix this by: (1) making the AppBar transparent + `extendBodyBehindAppBar: true` so stars show behind it, (2) extending the map height to include bottom nav area so stars show behind the glassmorphism bottom bar too. The bottom nav already uses `extendBody: true` with semi-transparent backdrop, so it will naturally overlay the extended star field.

**Tech Stack:** Flutter Scaffold, AppBar transparency, ScreenUtil

---

### Task 1: Make AppBar transparent and extend body behind it

**Files:**
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart:49-82`

**Step 1: Add `extendBodyBehindAppBar: true` and make AppBar transparent**

In the `build()` method, update the Scaffold and AppBar:

```dart
// Before
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  appBar: AppBar(
    backgroundColor: AppColors.spaceBackground,
    elevation: 0,

// After
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
```

**Step 2: Extend map height to account for AppBar + bottom nav**

Update `mapHeight` calculation and `_mapTopPadding` to include the system status bar + AppBar height, and add bottom padding for the bottom nav:

```dart
// In build(), after getting planets:
final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
final bottomInset = MediaQuery.of(context).padding.bottom + 72.h; // bottom nav height

// Update mapHeight
final mapHeight = topInset +
    _mapTopPadding +
    (planets.length - 1) * _planetSpacing +
    _mapBottomPadding +
    bottomInset;
```

**Step 3: Offset planet positions to account for top inset**

In `_calculatePlanetPositions`, the y calculation should add `topInset`:

```dart
// Pass topInset to _calculatePlanetPositions
// and update y calculation:
final y = topInset + _mapTopPadding + i * _planetSpacing;
```

**Step 4: Run static analysis**

Run: `flutter analyze`
Expected: No issues found

**Step 5: Visual verification**

Run: `flutter run` on emulator/device
Expected:
- Stars visible behind the AppBar (title and fuel gauge float over stars)
- Stars visible behind the bottom navigation bar (glassmorphism overlays stars)
- No visible color boundary between AppBar and map body
- No visible color boundary between map body and bottom nav
- Planet positions unchanged (not hidden behind AppBar or bottom nav)

**Step 6: Commit**

```bash
git add lib/features/explore/presentation/screens/explore_screen.dart
git commit -m "fix: unify explore screen background - stars extend behind AppBar and bottom nav"
```

---

### Summary of Changes

| Location | Change | Reason |
|----------|--------|--------|
| Scaffold | `extendBodyBehindAppBar: true` | Body renders behind AppBar |
| AppBar | `backgroundColor: Colors.transparent`, `scrolledUnderElevation: 0` | AppBar becomes see-through |
| mapHeight | Add `topInset + bottomInset` | Stars cover full screen including behind AppBar/bottom nav |
| Planet y positions | Add `topInset` offset | Planets don't hide behind transparent AppBar |

**Total: 1 file, ~10 lines changed**
