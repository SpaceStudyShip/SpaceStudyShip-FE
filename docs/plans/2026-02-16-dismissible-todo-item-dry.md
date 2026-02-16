# DismissibleTodoItem DRY 추출 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 3곳에 중복된 Dismissible+TodoItem 패턴을 `DismissibleTodoItem` 위젯으로 추출하고, HomeScreen에 카테고리 이동 스와이프를 추가한다.

**Architecture:** 공통 Dismissible 패턴을 `features/todo/presentation/widgets/dismissible_todo_item.dart`로 추출. ConsumerWidget으로 구현하여 내부에서 todo provider 접근. 3개 화면에서 중복 코드를 제거하고 단일 위젯으로 교체.

**Tech Stack:** Flutter, Riverpod (ConsumerWidget), 기존 위젯 재사용 (TodoItem, AppDialog, CategoryMoveBottomSheet)

---

## 현재 중복 현황

| 파일 | 스와이프 방향 | 기능 |
|---|---|---|
| `home_screen.dart:469-516` | endToStart만 | 삭제만 |
| `todo_list_screen.dart:294-374` | horizontal | 카테고리 이동 + 삭제 |
| `category_todo_screen.dart:108-189` | horizontal | 카테고리 이동 + 삭제 |

→ 3곳 모두 `DismissibleTodoItem`으로 통합. HomeScreen도 양방향 스와이프 지원.

---

### Task 1: DismissibleTodoItem 위젯 생성

**Files:**
- Create: `lib/features/todo/presentation/widgets/dismissible_todo_item.dart`

**Step 1: 위젯 파일 작성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';
import 'category_move_bottom_sheet.dart';

/// 양방향 스와이프 Dismissible + TodoItem 통합 위젯
///
/// - 좌→우: 카테고리 이동 바텀시트
/// - 우→좌: 삭제 확인 다이얼로그
/// - 탭: 완료 토글 (onTap 미지정 시)
class DismissibleTodoItem extends ConsumerWidget {
  const DismissibleTodoItem({
    super.key,
    required this.todo,
    this.onTap,
  });

  final TodoEntity todo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final newCategoryId = await showCategoryMoveBottomSheet(
            context: context,
            currentCategoryId: todo.categoryId,
          );
          if (newCategoryId != null && context.mounted) {
            ref.read(todoListNotifierProvider.notifier).updateTodo(
              todo.copyWith(
                categoryId: newCategoryId == '' ? null : newCategoryId,
              ),
            );
          }
          return false;
        }
        final confirmed = await AppDialog.confirm(
          context: context,
          title: '할일 삭제',
          message:
              "'${todo.title}'을(를) 삭제하시겠습니까?\n삭제된 항목은 복구할 수 없습니다.",
          emotion: AppDialogEmotion.warning,
          confirmText: '삭제',
          cancelText: '취소',
          isDestructive: true,
        );
        return confirmed == true;
      },
      onDismissed: (_) {
        ref.read(todoListNotifierProvider.notifier).deleteTodo(todo.id);
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: AppPadding.horizontal20,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          borderRadius: AppRadius.large,
        ),
        child: Icon(
          Icons.drive_file_move_outline,
          color: AppColors.primary,
          size: 24.w,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: AppPadding.horizontal20,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: AppRadius.large,
        ),
        child: Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 24.w,
        ),
      ),
      child: TodoItem(
        title: todo.title,
        subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
            ? '${todo.actualMinutes}분 공부'
            : null,
        isCompleted: todo.completed,
        onToggle: () {
          ref.read(todoListNotifierProvider.notifier).toggleTodo(todo);
        },
        onTap: onTap,
      ),
    );
  }
}
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/todo/presentation/widgets/dismissible_todo_item.dart
git commit -m "feat: DismissibleTodoItem 공통 위젯 추출 #17"
```

---

### Task 2: HomeScreen에 DismissibleTodoItem 적용

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: import 추가 + 불필요 import 제거**

추가:
```dart
import '../../../todo/presentation/widgets/dismissible_todo_item.dart';
```

제거 (DismissibleTodoItem이 내부 처리):
```dart
import '../../../../core/widgets/dialogs/app_dialog.dart'; // 더 이상 직접 사용 안 함
```

추가 필요:
```dart
import '../../../todo/presentation/widgets/category_move_bottom_sheet.dart';
```
→ 실제로는 DismissibleTodoItem 내부에서 처리하므로 이 import도 불필요.

**Step 2: `_buildTodoRow` 메서드 교체**

기존 (40줄+):
```dart
Widget _buildTodoRow(TodoEntity todo) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
    child: Dismissible(
      // ... 40줄의 Dismissible 코드
    ),
  );
}
```

교체:
```dart
Widget _buildTodoRow(TodoEntity todo) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
    child: DismissibleTodoItem(todo: todo),
  );
}
```

**Step 3: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues found (unused import 경고 시 제거)

**Step 4: 커밋**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "refactor: HomeScreen _buildTodoRow를 DismissibleTodoItem으로 교체 #17"
```

---

### Task 3: TodoListScreen에 DismissibleTodoItem 적용

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`

**Step 1: import 추가 + 불필요 import 제거**

추가:
```dart
import '../widgets/dismissible_todo_item.dart';
```

제거 가능 여부 확인:
- `category_move_bottom_sheet.dart` → 미분류 섹션의 Dismissible에서만 사용 → DismissibleTodoItem이 대체하므로 제거
- `app_dialog.dart` → `_confirmBatchDelete`에서 여전히 사용 → 유지

**Step 2: 미분류 섹션 Dismissible 교체**

기존 (lines 294-374, 약 80줄):
```dart
: Dismissible(
    key: Key(todo.id),
    direction: DismissDirection.horizontal,
    // ... 80줄의 중복 코드
  ),
```

교체:
```dart
: DismissibleTodoItem(todo: todo),
```

**Step 3: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 커밋**

```bash
git add lib/features/todo/presentation/screens/todo_list_screen.dart
git commit -m "refactor: TodoListScreen 미분류 섹션을 DismissibleTodoItem으로 교체 #17"
```

---

### Task 4: CategoryTodoScreen에 DismissibleTodoItem 적용

**Files:**
- Modify: `lib/features/todo/presentation/screens/category_todo_screen.dart`

**Step 1: import 추가 + 불필요 import 제거**

추가:
```dart
import '../widgets/dismissible_todo_item.dart';
```

제거:
- `category_move_bottom_sheet.dart` → DismissibleTodoItem이 대체
- `app_dialog.dart` → DismissibleTodoItem이 대체
- `todo_item.dart` → DismissibleTodoItem이 대체

**Step 2: Dismissible 블록 교체**

기존 (lines 106-189, 약 83줄):
```dart
return Padding(
  padding: EdgeInsets.only(bottom: 8.h),
  child: Dismissible(
    // ... 83줄의 중복 코드
  ),
);
```

교체:
```dart
return Padding(
  padding: EdgeInsets.only(bottom: 8.h),
  child: DismissibleTodoItem(todo: todo),
);
```

**Step 3: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 커밋**

```bash
git add lib/features/todo/presentation/screens/category_todo_screen.dart
git commit -m "refactor: CategoryTodoScreen을 DismissibleTodoItem으로 교체 #17"
```

---

## 변경 요약

| 항목 | Before | After |
|---|---|---|
| 중복 코드 | ~200줄 (3곳 x ~70줄) | ~100줄 (위젯 1곳) |
| HomeScreen 스와이프 | 삭제만 (단방향) | 카테고리 이동 + 삭제 (양방향) |
| 유지보수 | 3곳 동시 수정 필요 | 1곳만 수정 |
