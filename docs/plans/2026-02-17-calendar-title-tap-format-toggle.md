# 캘린더 타이틀 탭 포맷 토글 (칩 제거, 년월 탭 → 월간/주간)

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** "월간/주간" 별도 버튼/칩을 완전 제거하고, "2026년 2월" 타이틀 텍스트 자체를 탭하면 월간↔주간이 전환되도록 한다. 두 곳 모두 적용: SpaceCalendar(홈), TodoAddBottomSheet(할일 추가).

**Architecture:** 두 캘린더 모두 TableCalendar 기본 헤더를 숨기고(`headerVisible: false`) 커스텀 헤더를 직접 구성한다. 타이틀 텍스트 옆에 작은 `▾` 아이콘만 배치하여 탭 가능 어포던스를 최소한으로 제공한다. 별도 칩/배지 없음.

**Tech Stack:** Flutter, table_calendar ^3.2.0, flutter_screenutil

---

## UX 디자인

```
[<]     2026년 2월 ▾     [>]      ← 타이틀 영역 탭하면 전환
```

- "2026년 2월" 텍스트 + 작은 ▾ 아이콘 (AppColors.textTertiary, 10~12px)
- 칩, 배지, 별도 버튼 없음
- 탭하면 월간 ↔ 주간 즉시 전환 (캘린더 행 수 변화가 피드백)
- ▾ 아이콘이 유일한 시각적 힌트 (미니멀)

---

### Task 1: SpaceCalendar 커스텀 헤더 (홈 화면)

**Files:**
- Modify: `lib/features/home/presentation/widgets/space_calendar.dart`

**Step 1: SpaceCalendar를 StatelessWidget → 커스텀 헤더 포함으로 수정**

`build()` 메서드를 수정하여:
1. `headerVisible: false` (compact이 아닐 때도)
2. compact이 아닐 때 커스텀 헤더 Row를 TableCalendar 위에 배치
3. 타이틀 탭 시 `onFormatChanged` 콜백 호출

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // 커스텀 헤더 (compact 아닐 때만)
      if (!isCompact)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  final prev = DateTime(focusedDay.year, focusedDay.month - 1);
                  onPageChanged?.call(prev);
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_left, color: AppColors.primary, size: 20.w),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final next = calendarFormat == CalendarFormat.month
                        ? CalendarFormat.week
                        : CalendarFormat.month;
                    onFormatChanged?.call(next);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('yyyy년 M월', 'ko_KR').format(focusedDay),
                        style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16.w,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final next = DateTime(focusedDay.year, focusedDay.month + 1);
                  onPageChanged?.call(next);
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right, color: AppColors.primary, size: 20.w),
                ),
              ),
            ],
          ),
        ),
      // TableCalendar 본체
      TableCalendar<TodoEntity>(
        // ... headerVisible: false (항상)
        // ... 나머지 동일
      ),
    ],
  );
}
```

주의: SpaceCalendar의 커스텀 헤더 화살표는 기존 스타일(원형 배경 + primary 색상)을 유지한다.

**Step 2: analyze 확인**

Run: `flutter analyze lib/features/home/presentation/widgets/space_calendar.dart`

**Step 3: Commit**

```bash
git add lib/features/home/presentation/widgets/space_calendar.dart
git commit -m "feat: SpaceCalendar 헤더 리디자인 — 타이틀 탭으로 월간/주간 전환"
```

---

### Task 2: TodoAddBottomSheet 캘린더 칩 제거

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**Step 1: 기존 커스텀 헤더에서 칩 Container 제거, 타이틀+▾만 남기기**

현재 코드 (방금 수정한 것)에서 `formatLabel`/칩 Container/unfold_more 아이콘을 모두 제거하고, 타이틀 텍스트 + 작은 `keyboard_arrow_down` 아이콘만 남긴다.

가운데 Expanded 영역의 GestureDetector child를:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      DateFormat('yyyy년 M월', 'ko_KR').format(_calendarFocusedDay),
      style: AppTextStyles.label_16.copyWith(color: Colors.white),
    ),
    SizedBox(width: 4.w),
    Icon(
      Icons.keyboard_arrow_down,
      size: 16.w,
      color: AppColors.textTertiary,
    ),
  ],
)
```

로 교체한다. `formatLabel` 변수도 제거.

**Step 2: analyze 확인**

Run: `flutter analyze lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart
git commit -m "refactor: 할일 캘린더 헤더 칩 제거, 타이틀 탭 토글로 통일"
```

---

## 두 캘린더 비교 (변경 후)

| 항목 | SpaceCalendar (홈) | TodoAddBottomSheet |
|------|--------------------|--------------------|
| 헤더 | 커스텀 Row | 커스텀 Row |
| 타이틀 | subHeading_18 + ▾ | label_16 + ▾ |
| 화살표 | 원형 배경 (기존 스타일 유지) | 아이콘만 (간소) |
| 포맷 토글 | 타이틀 탭 → onFormatChanged | 타이틀 탭 → setState |
| 별도 칩/버튼 | 없음 | 없음 |
