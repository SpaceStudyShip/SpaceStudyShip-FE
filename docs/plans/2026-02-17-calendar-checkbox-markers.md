# Calendar Checkbox Markers Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace small dot markers in SpaceCalendar with checkbox-style indicators below each date number

**Architecture:** Modify the `markerBuilder` in `space_calendar.dart` to render checkbox icons (14x14) instead of tiny dots (6x6). Increase `rowHeight` to accommodate the taller cell layout. The marker state logic stays the same: `eventLoader` + `isCompletedForDate()`.

**Tech Stack:** Flutter, table_calendar (CalendarBuilders), flutter_screenutil

---

### Task 1: Increase rowHeight to accommodate checkbox markers

**Files:**
- Modify: `lib/features/home/presentation/widgets/space_calendar.dart:73`

**Step 1: Update rowHeight values**

Change `rowHeight` from `48.h` / `42.h` to `56.h` / `48.h` to provide vertical space for checkbox below the date number.

```dart
// Before (line 73)
rowHeight: isCompact ? 42.h : 48.h,

// After
rowHeight: isCompact ? 48.h : 56.h,
```

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/home/presentation/widgets/space_calendar.dart
git commit -m "style: 캘린더 rowHeight 증가 (체크박스 마커 공간 확보)"
```

---

### Task 2: Replace dot markerBuilder with checkbox-style indicators

**Files:**
- Modify: `lib/features/home/presentation/widgets/space_calendar.dart:132-149`

**Step 1: Replace markerBuilder implementation**

Replace the current dot-based `markerBuilder` with checkbox-style icons:

```dart
// Replace lines 132-149 with:
// 체크박스 마커 — 완료 상태에 따라 체크박스 스타일 변경
markerBuilder: (context, day, events) {
  if (events.isEmpty) return const SizedBox.shrink();
  final allCompleted = events.every(
    (t) => t.isCompletedForDate(day),
  );
  return Positioned(
    bottom: 1.h,
    child: Icon(
      allCompleted
          ? Icons.check_box_rounded
          : Icons.check_box_outline_blank_rounded,
      size: 14.w,
      color: allCompleted
          ? AppColors.success
          : AppColors.textTertiary,
    ),
  );
},
```

**Design states:**
- **No todos** → no marker (SizedBox.shrink)
- **Has todos, not all complete** → `check_box_outline_blank_rounded` in `textTertiary` color (subtle empty checkbox)
- **All todos complete** → `check_box_rounded` in `success` color (green filled checkbox)

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Visual verification**

Run the app and navigate to the home screen calendar to confirm:
1. Dates with no todos show no marker
2. Dates with incomplete todos show an outlined empty checkbox
3. Dates with all todos completed show a green filled checkbox
4. Checkboxes are positioned neatly below the date number
5. Both compact (weekly strip) and expanded (monthly) views look correct

**Step 4: Commit**

```bash
git add lib/features/home/presentation/widgets/space_calendar.dart
git commit -m "feat: 캘린더 마커를 도트에서 체크박스 스타일로 변경"
```

---

### Summary of Changes

| What | Before | After |
|------|--------|-------|
| Marker icon (incomplete) | `Icons.circle` 6px blue dot | `Icons.check_box_outline_blank_rounded` 14px subtle checkbox |
| Marker icon (complete) | `Icons.check_circle` 6px green dot | `Icons.check_box_rounded` 14px green checkbox |
| Marker color (incomplete) | `AppColors.primary` (blue) | `AppColors.textTertiary` (subtle white 50%) |
| Marker color (complete) | `AppColors.success` (green) | `AppColors.success` (green, unchanged) |
| Row height (expanded) | 48.h | 56.h |
| Row height (compact) | 42.h | 48.h |
| Total file changes | 1 file | `space_calendar.dart` only |
