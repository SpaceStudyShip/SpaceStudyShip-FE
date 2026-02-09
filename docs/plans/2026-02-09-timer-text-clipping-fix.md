# Timer Text Clipping Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the timer "00:00:00" text being clipped inside the timer ring by increasing the ring size and adding overflow protection.

**Architecture:** The timer ring is a `CustomPaint` + `Stack` layout inside a fixed `SizedBox(220.w)`. The `48.sp` font with `letterSpacing: 4` produces text wider than the 220.w container on most devices. We increase the ring to 260.w and wrap the text in a `FittedBox` as overflow safety.

**Tech Stack:** Flutter, ScreenUtil (.w/.sp), CustomPainter

---

### Task 1: Increase timer ring container size and add FittedBox overflow protection

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:43-83`

**Step 1: Update SizedBox and CustomPaint dimensions**

Change lines 43-57 — increase all `220.w` references to `260.w`:

```dart
// Before (line 43-46)
child: SizedBox(
  width: 220.w,
  height: 220.w,

// After
child: SizedBox(
  width: 260.w,
  height: 260.w,
```

```dart
// Before (line 51)
size: Size(220.w, 220.w),

// After
size: Size(260.w, 260.w),
```

**Step 2: Wrap time text Column in FittedBox for overflow safety**

Change lines 59-79 — wrap the Column in a `Padding` + `FittedBox`:

```dart
// Before (line 59-79)
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      '00:00:00',
      style: AppTextStyles.heading_20.copyWith(
        fontSize: 48.sp,
        color: Colors.white,
        letterSpacing: 4,
        fontWeight: FontWeight.w700,
      ),
    ),
    SizedBox(height: 4.h),
    Text(
      '집중 시간을 측정해보세요',
      style: AppTextStyles.tag_12.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  ],
),

// After
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16.w),
  child: FittedBox(
    fit: BoxFit.scaleDown,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '00:00:00',
          style: AppTextStyles.heading_20.copyWith(
            fontSize: 48.sp,
            color: Colors.white,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '집중 시간을 측정해보세요',
          style: AppTextStyles.tag_12.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  ),
),
```

**Step 3: Run static analysis**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Visual verification**

Run: `flutter run` on emulator/device
Expected:
- "00:00:00" fully visible inside the ring, not clipped on any edge
- Ring circle larger but still well-proportioned on screen
- Stats card and start button still visible below without scrolling on iPhone 12 (390x844)

**Step 5: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "fix: timer text clipping - increase ring size to 260.w and add FittedBox"
```

---

### Summary of Changes

| File | Change | Reason |
|------|--------|--------|
| `timer_screen.dart:43-46` | `220.w` → `260.w` (SizedBox) | Ring container too small for 48.sp text |
| `timer_screen.dart:51` | `220.w` → `260.w` (CustomPaint) | Match ring painter to new container size |
| `timer_screen.dart:59-79` | Wrap Column in `Padding` + `FittedBox` | Overflow safety on small screens |

**Total: 1 file, ~6 lines changed**
