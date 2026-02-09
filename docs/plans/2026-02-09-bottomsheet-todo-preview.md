# Bottom Sheet Todo Preview Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 홈 바텀시트를 할 일 미리보기 전용으로 개선 — 최대 3개 표시 + "더보기" 버튼으로 TodoScreen 이동. "최근 활동" 섹션 제거.

**Architecture:** 홈 화면에 임시 할 일 데이터 추가, 바텀시트 펼친 상태에서 TodoItem 위젯으로 최대 3개 표시, "더보기" 버튼으로 TodoScreen placeholder 연결. 접힌 상태에서 실제 개수 반영.

**Tech Stack:** Flutter, 기존 TodoItem 위젯, GoRouter

---

## 현재 상태

```
바텀시트 펼친 상태:
  드래그 핸들
  "오늘의 할 일" 제목
  빈 할 일 카드 (SpaceEmptyState)
  "최근 활동" 제목
  빈 활동 카드 (SpaceEmptyState)
```

## 목표 상태

```
바텀시트 접힌 상태:
  드래그 핸들
  "오늘의 할 일 · 3개  ▲"  ← 실제 개수 반영

바텀시트 펼친 상태:
  드래그 핸들
  "오늘의 할 일" 제목
  TodoItem x 최대 3개 (체크 토글 가능)
  "더보기" 버튼 → TodoScreen 이동
  (할 일 없으면 SpaceEmptyState 유지)
```

---

### Task 1: 임시 할 일 데이터 + 바텀시트 UI 교체

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: 임시 할 일 데이터 추가**

State에 임시 할 일 리스트 추가 (나중에 Riverpod Provider로 교체):

```dart
// import 추가
import '../../../../core/widgets/space/todo_item.dart';

// State에 추가
final List<Map<String, dynamic>> _todos = [
  {'title': '알고리즘 2문제 풀기', 'subtitle': '30분', 'completed': false},
  {'title': '영어 단어 50개 외우기', 'subtitle': '20분', 'completed': true},
  {'title': '수학 과제 제출', 'subtitle': '1시간', 'completed': false},
  {'title': '물리 노트 정리', 'subtitle': '40분', 'completed': false},
];
```

**Step 2: 접힌 상태 개수 반영**

`_buildCollapsedSheet()`의 "· 0개"를 실제 미완료 개수로:

```dart
// Before:
Text(
  '· 0개',
  style: AppTextStyles.label_16.copyWith(
    color: AppColors.textTertiary,
  ),
),

// After:
Text(
  '· ${_todos.where((t) => !t['completed']).length}개',
  style: AppTextStyles.label_16.copyWith(
    color: AppColors.textTertiary,
  ),
),
```

**Step 3: _buildExpandedSheet() 교체**

기존 "최근 활동" 섹션 제거, TodoItem 미리보기 + "더보기" 버튼으로 교체:

```dart
Widget _buildExpandedSheet(ScrollController scrollController) {
  final previewTodos = _todos.take(3).toList();

  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      _buildDragHandle(),

      Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
        child: _buildSectionTitle('오늘의 할 일'),
      ),

      // 할 일 미리보기 (최대 3개) 또는 빈 상태
      if (previewTodos.isEmpty)
        Padding(
          padding: AppPadding.horizontal20,
          child: _buildEmptyTodoCard(),
        )
      else ...[
        ...previewTodos.asMap().entries.map((entry) {
          final index = _todos.indexOf(entry.value);
          final todo = entry.value;
          return Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
            child: TodoItem(
              title: todo['title'] as String,
              subtitle: todo['subtitle'] as String?,
              isCompleted: todo['completed'] as bool,
              onToggle: () {
                setState(() {
                  _todos[index]['completed'] = !(_todos[index]['completed'] as bool);
                });
              },
            ),
          );
        }),

        // "더보기" 버튼 (할 일이 3개 이상일 때)
        if (_todos.length > 3)
          Padding(
            padding: AppPadding.horizontal20,
            child: TextButton(
              onPressed: () {
                // TODO: GoRouter로 TodoScreen 이동
                // context.push(RoutePaths.todoList);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '더보기',
                    style: AppTextStyles.label_16.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.w,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],

      SizedBox(height: 40.h),
    ],
  );
}
```

**Step 4: _buildEmptyActivityCard() 삭제**

"최근 활동" 관련 코드 제거:
- `_buildEmptyActivityCard()` 메서드 삭제

**Step 5: Verify**

Run: `flutter analyze`

---

### Task 2: 시각적 검증

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 확인 포인트**

앱 실행하여 확인:
- 접힌 상태: "오늘의 할 일 · 2개 ▲" (미완료 개수 반영)
- 펼친 상태: TodoItem 3개 표시 (체크박스 토글 가능)
- 체크 시 접힌 상태 개수 즉시 반영
- "더보기" 버튼 표시 (4개 중 3개만 미리보기이므로)
- "최근 활동" 섹션 없음

---

### Summary of Changes

| File | Change | Reason |
|------|--------|--------|
| `home_screen.dart` | 임시 `_todos` 데이터 추가 | 미리보기용 샘플 데이터 |
| `home_screen.dart` | 접힌 상태 개수 동적 반영 | 실시간 미완료 개수 표시 |
| `home_screen.dart` | 펼친 상태 TodoItem 미리보기 | 최대 3개 + 더보기 버튼 |
| `home_screen.dart` | `_buildEmptyActivityCard()` 삭제 | 최근 활동 섹션 제거 |
| `home_screen.dart` | TodoItem import 추가 | 기존 공용 위젯 활용 |

**Total: 1 file modified**
**TodoScreen 전용 화면은 별도 계획으로 분리 (feature/todo 전체 구현 필요)**
