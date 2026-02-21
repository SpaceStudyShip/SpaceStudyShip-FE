# Guest Explore Login Prompt Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Show all planets on explore map for guests, but prompt login when tapping non-Earth planets.

**Architecture:** Remove guest planet filtering from Provider (display all), add guest interaction guard in Screen (login dialog on non-Earth tap).

**Tech Stack:** Flutter Riverpod, AppDialog, GoRouter

---

### Task 1: Remove guest planet filter from ExplorationNotifier

**Files:**
- Modify: `lib/features/exploration/presentation/providers/exploration_provider.dart`

**Step 1: Remove guest filter in build()**

Lines 52-56: Delete the guest filter block.

Before:
```dart
final isGuest = ref.watch(isGuestProvider);
if (isGuest) {
  return allPlanets.where((p) => p.id == 'earth').toList();
}
```

After: (remove those 4 lines entirely)

**Step 2: Remove guest filter in _reload()**

Lines 85-88: Delete the guest filter block.

Before:
```dart
final isGuest = ref.read(isGuestProvider);
if (isGuest) {
  state = allPlanets.where((p) => p.id == 'earth').toList();
} else {
  state = allPlanets;
}
```

After:
```dart
state = allPlanets;
```

**Step 3: Remove unused import if isGuestProvider is no longer referenced**

Check if `isGuestProvider` import from auth_provider.dart is still needed (it may be used elsewhere in the file).

**Step 4: Run build_runner** (provider signature may change)

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

---

### Task 2: Add guest login dialog in explore_screen

**Files:**
- Modify: `lib/features/explore/presentation/screens/explore_screen.dart`

**Step 1: Add isGuest import and watch**

Add import (if not already present):
```dart
import '../../../auth/presentation/providers/auth_provider.dart';
```

In `build()`, add:
```dart
final isGuest = ref.watch(isGuestProvider);
```

Pass `isGuest` to `_buildSpaceMap` and `_handlePlanetTap`.

**Step 2: Add guest guard in _handlePlanetTap**

After the `planet.isUnlocked` check (line 213), add guest guard for non-Earth planets:

```dart
// 게스트 모드: 지구 외 행성은 로그인 필요
if (isGuest && planet.id != 'earth') {
  _showLoginPrompt(context, ref);
  return;
}
```

**Step 3: Add _showLoginPrompt method** (social screen pattern)

```dart
Future<void> _showLoginPrompt(BuildContext context, WidgetRef ref) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: '로그인하시겠어요?',
    message: '게스트 모드의 데이터가\n모두 초기화돼요',
    confirmText: '로그인',
    cancelText: '취소',
  );
  if (confirmed == true) {
    await ref.read(authNotifierProvider.notifier).signOut();
  }
}
```

**Step 4: Verify**

Run: `flutter analyze`
Expected: No issues found

---

### Task 3: Commit

```bash
git add -A
git commit -m "feat: 게스트 탐험 맵 전체 행성 표시 및 로그인 유도 다이얼로그 #41"
```
