# 홈 바텀시트 접힌 상태 재설계 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 홈 화면 바텀시트의 접힌 상태를 컴팩트 카드(진행률 바 + 완료 카운트)로 재설계하여 플로팅 네비게이션과의 시각적 충돌을 해결한다.

**Architecture:** `_buildCollapsedSheet()` 메서드만 재작성하고, 펼친 상태는 유지. 날짜별 할일 완료 통계를 위한 provider를 추가한다. DraggableScrollableSheet의 사이즈 파라미터를 컴팩트 카드 높이에 맞게 조정한다.

**Tech Stack:** Flutter · Riverpod · flutter_screenutil · 디자인 시스템 상수 (AppColors, AppSpacing, AppPadding, AppRadius, AppTextStyles, TossDesignTokens)

---

## File Structure

| 파일 | 변경 | 역할 |
|------|------|------|
| `lib/features/todo/presentation/providers/todo_provider.dart` | 수정 | `todoCompletionStatsForDate` provider 추가 |
| `lib/features/home/presentation/screens/home_screen.dart` | 수정 | `_buildCollapsedSheet()` 재작성 + 시트 사이즈 조정 |

---

## Task 1: 날짜별 할일 완료 통계 Provider 추가

**Files:**
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart:352` (파일 끝에 추가)

- [ ] **Step 1: provider 추가**

`todo_provider.dart` 파일 끝(`todosByDateMap` provider 아래)에 다음 provider를 추가한다:

```dart
// === 날짜별 할일 완료 통계 (홈 컴팩트 카드용) ===

@riverpod
({int total, int completed}) todoCompletionStatsForDate(Ref ref, DateTime date) {
  final todos = ref.watch(todosForDateProvider(date));
  final normalizedDate = TodoEntity.normalizeDate(date);
  return (
    total: todos.length,
    completed: todos.where((t) => t.isCompletedForDate(normalizedDate)).length,
  );
}
```

- [ ] **Step 2: 코드 생성 실행**

```bash
cd /Users/luca/workspace/Flutter_Project/space_study_ship
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `todo_provider.g.dart`에 `todoCompletionStatsForDateProvider` 생성됨.

- [ ] **Step 3: 정적 분석 확인**

```bash
flutter analyze
```

Expected: 에러 없음.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/todo/presentation/providers/todo_provider.dart lib/features/todo/presentation/providers/todo_provider.g.dart
git commit -m "feat : 날짜별 할일 완료 통계 provider 추가 #54"
```

---

## Task 2: 바텀시트 접힌 상태 컴팩트 카드로 재설계

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

### Step 1: 바텀시트 사이즈 파라미터 조정

`_buildBottomSheet()` 메서드(line 224~251)에서 사이즈 값을 변경한다:

- [ ] **Step 1-1: DraggableScrollableSheet 사이즈 변경**

```dart
// 변경 전:
initialChildSize: 0.30,
minChildSize: 0.30,
maxChildSize: 0.85,
snap: true,
snapSizes: const [0.30, 0.85],

// 변경 후:
initialChildSize: 0.18,
minChildSize: 0.18,
maxChildSize: 0.85,
snap: true,
snapSizes: const [0.18, 0.85],
```

- [ ] **Step 1-2: `_onSheetChanged()` 임계값 조정 (line 72~83)**

```dart
// 변경 전:
final expanded = _sheetController.size > 0.4;

// 변경 후:
final expanded = _sheetController.size > 0.3;
```

- [ ] **Step 1-3: 홈 탭 재탭 시 접힘 위치 조정 (line 104~112)**

```dart
// 변경 전:
_sheetController.animateTo(
  0.30,
  ...
);

// 변경 후:
_sheetController.animateTo(
  0.18,
  ...
);
```

- [ ] **Step 1-4: GestureDetector onTap 접힘 위치 조정 (line 154~161)**

```dart
// 변경 전:
_sheetController.animateTo(
  0.30,
  ...
);

// 변경 후:
_sheetController.animateTo(
  0.18,
  ...
);
```

- [ ] **Step 1-5: 우주선 탭 시 접힘 위치 조정 (line 190~194)**

```dart
// 변경 전:
_sheetController.animateTo(
  0.25,
  ...
);

// 변경 후:
_sheetController.animateTo(
  0.18,
  ...
);
```

### Step 2: `_buildCollapsedSheet()` 메서드 재작성

- [ ] **Step 2-1: `_buildCollapsedSheet()` 전체 교체 (line 253~340)**

기존 메서드를 아래로 완전히 교체한다:

```dart
/// 접힌 상태: 컴팩트 카드 (진행률 바 + 완료 카운트)
Widget _buildCollapsedSheet(ScrollController scrollController) {
  final todayKey = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final stats = ref.watch(todoCompletionStatsForDateProvider(todayKey));
  final hasAnyTodo = stats.total > 0;
  final progress = hasAnyTodo ? stats.completed / stats.total : 0.0;

  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    physics: const ClampingScrollPhysics(),
    children: [
      const DragHandle(),

      // 컴팩트 카드 본체
      GestureDetector(
        onTap: () {
          _sheetController.animateTo(
            0.85,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            children: [
              // 타이틀 행: "오늘의 할 일" + 완료 카운트
              Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                  SizedBox(width: AppSpacing.s8),
                  Text(
                    '오늘의 할 일',
                    style: AppTextStyles.label_16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (hasAnyTodo)
                    Text(
                      '${stats.completed}/${stats.total} 완료',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    )
                  else
                    Text(
                      '할 일을 추가해보세요',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),

              // 진행률 바 (할일이 있을 때만)
              if (hasAnyTodo) ...[
                SizedBox(height: AppSpacing.s12),
                ClipRRect(
                  borderRadius: AppRadius.small,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.h,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.s4),
            ],
          ),
        ),
      ),
    ],
  );
}
```

- [ ] **Step 2-2: import 추가 확인**

`home_screen.dart` 상단에 `todoCompletionStatsForDateProvider`가 이미 `todo_provider.dart`에서 import되어 있으므로 추가 import 불필요. 확인만 한다.

### Step 3: 정적 분석 및 커밋

- [ ] **Step 3-1: 정적 분석**

```bash
flutter analyze
```

Expected: 에러 없음.

- [ ] **Step 3-2: 커밋**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat : 홈 바텀시트 접힌 상태를 컴팩트 카드로 재설계 #54"
```

---

## Task 3: 시각 확인 및 미세 조정

- [ ] **Step 1: 시뮬레이터에서 확인**

확인 항목:
1. 접힌 상태에서 플로팅 네비와 겹치지 않는지
2. 컴팩트 카드가 네비 위에 적절한 간격으로 위치하는지
3. 할일 0개 → "할 일을 추가해보세요" 표시
4. 할일 3개 중 1개 완료 → "1/3 완료" + 진행률 바 33%
5. 카드 탭 → 0.85로 펼침 동작
6. 드래그로 펼침/접힘 동작
7. 펼친 상태에서 캘린더 + 할일 목록 정상 동작
8. 홈 탭 재탭 → 0.18로 접힘

- [ ] **Step 2: minChildSize 미세 조정**

시뮬레이터 확인 후 `0.18`이 적절하지 않으면 `0.15~0.22` 범위에서 조정. 컴팩트 카드 + DragHandle이 완전히 보이면서 플로팅 네비와 겹치지 않는 값을 찾는다.

- [ ] **Step 3: 조정 사항 커밋 (변경이 있을 경우)**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "fix : 홈 바텀시트 컴팩트 카드 사이즈 미세 조정 #54"
```
