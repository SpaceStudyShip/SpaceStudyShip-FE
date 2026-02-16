# Hardcoded Color/Spacing Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace remaining hardcoded Color hex values with AppColors constants across the codebase.

**Architecture:** Direct constant substitution - replace `Color(0xFF...)` hex literals with their AppColors equivalents. No structural changes needed.

**Tech Stack:** Flutter, AppColors constants from `lib/core/constants/app_colors.dart`

---

## Analysis Summary

### Spacing (AppSpacing / AppPadding / AppRadius)
Previous cleanup (2026-02-09) already covered 21 files with ~85 replacements.
Remaining hardcoded values have **NO matching constants** and are acceptable:
- `SizedBox` with 2.h, 10.h, 58.h, 80.h, 100.h (no AppSpacing equivalents)
- `EdgeInsets.only(...)` patterns (no AppPadding for single-side padding)
- `EdgeInsets.symmetric` with non-standard combos like (h20,v12), (h12,v4), (h8,v2)
- `BorderRadius.circular(2.r)` (smallest AppRadius is small=4)

**No spacing changes needed.**

### Colors (AppColors) - Changes Required

3 files, ~12 replacements total.

---

### Task 1: Replace hardcoded colors in `space_background.dart`

**Files:**
- Modify: `lib/core/widgets/backgrounds/space_background.dart:26-30`

**Step 1: Replace 4 hardcoded Color hex values**

Current code (lines 26-30):
```dart
Color(0xFF64B5F6), // blue
Color(0xFFBA68C8), // purple
Color(0xFFFFD740), // gold
Color(0xFFF06292), // pink
Color(0xFF4DD0E1), // cyan  ← NO AppColors match, keep as-is
```

Replace with:
```dart
AppColors.primaryLight, // blue
AppColors.secondaryLight, // purple
AppColors.accentGoldLight, // gold
AppColors.accentPinkLight, // pink
const Color(0xFF4DD0E1), // cyan - no AppColors match
```

**Step 2: Verify import exists**

File already imports `app_colors.dart` - no change needed.

**Step 3: Run `flutter analyze`**

Run: `flutter analyze lib/core/widgets/backgrounds/space_background.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/widgets/backgrounds/space_background.dart
git commit -m "refactor: space_background 하드코딩 색상 → AppColors 상수 적용"
```

---

### Task 2: Replace hardcoded colors in `space_map_background.dart`

**Files:**
- Modify: `lib/features/exploration/presentation/widgets/space_map_background.dart:29-33`

**Step 1: Add AppColors import if missing**

Check if `import '../../../../core/constants/app_colors.dart';` exists.
If not, add it.

**Step 2: Replace 4 hardcoded Color hex values**

Current code (lines 29-33):
```dart
Color(0xFF64B5F6), // blue
Color(0xFFBA68C8), // purple
Color(0xFFFFD740), // gold
Color(0xFFF06292), // pink
Color(0xFF4DD0E1), // cyan  ← NO AppColors match, keep as-is
```

Replace with:
```dart
AppColors.primaryLight, // blue
AppColors.secondaryLight, // purple
AppColors.accentGoldLight, // gold
AppColors.accentPinkLight, // pink
const Color(0xFF4DD0E1), // cyan - no AppColors match
```

**Step 3: Run `flutter analyze`**

Run: `flutter analyze lib/features/exploration/presentation/widgets/space_map_background.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/exploration/presentation/widgets/space_map_background.dart
git commit -m "refactor: space_map_background 하드코딩 색상 → AppColors 상수 적용"
```

---

### Task 3: Replace `Colors.white.withValues(alpha: 0.5)` in `app_router.dart`

**Files:**
- Modify: `lib/routes/app_router.dart:389,400,443,456`

**Step 1: Replace 4 occurrences**

Replace all `Colors.white.withValues(alpha: 0.5)` with `AppColors.textTertiary`:

Lines 389, 400, 443, 456:
```dart
// Before
color: Colors.white.withValues(alpha: 0.5),

// After
color: AppColors.textTertiary,
```

**Step 2: Verify import exists**

File already imports `app_colors.dart` - no change needed.

**Step 3: Run `flutter analyze`**

Run: `flutter analyze lib/routes/app_router.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/routes/app_router.dart
git commit -m "refactor: app_router Colors.white.withValues → AppColors.textTertiary 적용"
```

---

### Task 4: Final verification

**Step 1: Run full analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: Verify no remaining direct Color hex matches**

Run grep to confirm no more AppColors-matching hex values remain outside constants:
```bash
grep -rn "Color(0xFF64B5F6)\|Color(0xFFBA68C8)\|Color(0xFFFFD740)\|Color(0xFFF06292)" lib/ --include="*.dart" | grep -v "core/constants/" | grep -v ".freezed.dart" | grep -v ".g.dart"
```
Expected: No results

---

## Not Changed (Intentionally)

| Value | File | Reason |
|-------|------|--------|
| `Color(0xFF4DD0E1)` cyan | space_background, space_map_background | No AppColors match |
| `Color(0xFFCD7F32)` bronze | ranking_item.dart | Unique decorative color |
| `Color(0xFF000000)` black | social_login_button.dart | Platform-specific (Google/Apple) |
| `space_icons.dart` hex colors | space_icons.dart | Emoji-specific color mappings (constants file) |
| `app_gradients.dart` hex colors | app_gradients.dart | Gradient-specific values (constants file) |
| `Colors.white` direct usage | Various files | Equivalent to `AppColors.textPrimary` per CLAUDE.md convention |
| All `SizedBox(height: N.h)` | Various | No matching AppSpacing constants |
| All `EdgeInsets.only(...)` | Various | No matching AppPadding presets |
| All `BorderRadius.circular(2.r)` | Various | No matching AppRadius constant |
