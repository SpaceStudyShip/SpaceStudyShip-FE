# Bottom Sheet Tap-to-Expand Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 바텀시트 탭 시 한번에 펼쳐지게 하고, 접힌/펼친 상태에 따라 UI를 다르게 표시

**Architecture:** `DraggableScrollableController.size`를 listen하여 접힌/펼친 상태 감지. 접힌 상태에서는 컴팩트 미리보기 (제목+개수+화살표), 탭 시 `animateTo(0.6)`으로 한번에 펼침. 중간 snap 제거.

**Tech Stack:** DraggableScrollableController, AnimatedSwitcher/AnimatedCrossFade

---

## 현재 상태

```
DraggableScrollableSheet:
  snapSizes: [0.22, 0.4, 0.6]  ← 중간 단계 있음
  builder:
    드래그 핸들
    "오늘의 할 일" 제목
    빈 할 일 카드
    "최근 활동" 제목
    빈 활동 카드
```

접힌/펼친 상태 구분 없이 동일한 UI.

## 목표 상태

```
DraggableScrollableSheet:
  snapSizes: [0.22, 0.6]  ← 중간 단계 제거 (한번에 올라감)
  builder:
    if (접힌 상태, size < 0.3):
      드래그 핸들
      탭 가능한 컴팩트 Row: "오늘의 할 일 · 0개  ▲"
      → 탭하면 animateTo(0.6)
    else (펼친 상태):
      드래그 핸들
      "오늘의 할 일" 제목
      할 일 카드
      "최근 활동" 제목
      활동 카드
```

---

### Task 1: 바텀시트 상태 감지 + UI 분기

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: _sheetController 리스너 추가**

State에 `_isSheetExpanded` 상태 추가 + 리스너:

```dart
// State에 추가
bool _isSheetExpanded = false;

// initState에서 리스너 등록
@override
void initState() {
  super.initState();
  _sheetController.addListener(_onSheetChanged);
}

void _onSheetChanged() {
  final expanded = _sheetController.size > 0.3;
  if (expanded != _isSheetExpanded) {
    setState(() => _isSheetExpanded = expanded);
  }
}
```

dispose에서 리스너 제거:
```dart
@override
void dispose() {
  _sheetController.removeListener(_onSheetChanged);
  _sheetController.dispose();
  super.dispose();
}
```

**Step 2: snapSizes에서 0.4 제거**

중간 단계 없이 한번에:

```dart
// Before:
snapSizes: const [0.22, 0.4, 0.6],

// After:
snapSizes: const [0.22, 0.6],
```

**Step 3: _buildBottomSheet() builder 내부 분기**

접힌 상태와 펼친 상태 UI를 분기:

```dart
builder: (context, scrollController) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.spaceSurface,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.r),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: _isSheetExpanded
        ? _buildExpandedSheet(scrollController)
        : _buildCollapsedSheet(scrollController),
  );
},
```

**Step 4: _buildCollapsedSheet() 작성 — 컴팩트 미리보기**

탭하면 한번에 펼쳐지는 컴팩트 UI:

```dart
Widget _buildCollapsedSheet(ScrollController scrollController) {
  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      // 드래그 핸들
      Center(
        child: Container(
          margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),

      // 탭 가능한 요약 Row
      GestureDetector(
        onTap: () {
          _sheetController.animateTo(
            0.6,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              Text(
                '오늘의 할 일',
                style: AppTextStyles.subHeading_18.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: AppSpacing.s8),
              Text(
                '· 0개',
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppColors.textTertiary,
                size: 24.w,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
```

**Step 5: _buildExpandedSheet() 작성 — 기존 풀 콘텐츠**

기존 ListView 내용을 메서드로 분리:

```dart
Widget _buildExpandedSheet(ScrollController scrollController) {
  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      // 드래그 핸들
      Center(
        child: Container(
          margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),

      Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
        child: _buildSectionTitle('오늘의 할 일'),
      ),
      Padding(
        padding: AppPadding.horizontal20,
        child: _buildEmptyTodoCard(),
      ),

      Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
        child: _buildSectionTitle('최근 활동'),
      ),
      Padding(
        padding: AppPadding.horizontal20,
        child: _buildEmptyActivityCard(),
      ),

      SizedBox(height: 40.h),
    ],
  );
}
```

**Step 6: 기존 _buildBottomSheet()의 인라인 ListView 제거**

기존 builder 내부의 ListView를 위의 분기 코드로 교체 (Step 3에서 이미 처리).

**Step 7: Verify**

Run: `flutter analyze`

---

### Task 2: 시각적 검증

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 확인 포인트**

앱 실행하여 확인:
- 접힌 상태: 드래그 핸들 + "오늘의 할 일 · 0개 ▲" 한 줄만 보임
- 탭하면 중간 없이 0.6까지 한번에 올라감 (400ms easeOutCubic)
- 펼친 상태: 기존 풀 콘텐츠 (할 일 카드 + 활동 카드)
- 배경 탭하면 0.22로 접힘 (기존 동작 유지)
- 드래그로 올려도 0.4 없이 0.22 ↔ 0.6 스냅

---

### Summary of Changes

| File | Change | Reason |
|------|--------|--------|
| `home_screen.dart` | `_isSheetExpanded` 상태 + 리스너 | 접힌/펼친 감지 |
| `home_screen.dart` | snapSizes `[0.22, 0.4, 0.6]` → `[0.22, 0.6]` | 중간 단계 제거 |
| `home_screen.dart` | `_buildCollapsedSheet()` 추가 | 접힌 상태 컴팩트 UI |
| `home_screen.dart` | `_buildExpandedSheet()` 추가 | 펼친 상태 풀 UI |
| `home_screen.dart` | builder 내부 분기 | 상태별 UI 전환 |

**Total: 1 file modified**
