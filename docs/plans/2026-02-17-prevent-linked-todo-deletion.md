# 타이머 연동 중인 할 일 삭제 방지 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 타이머에 연동된 할 일은 타이머가 동작 중(running/paused)일 때 삭제할 수 없도록 방지

**Architecture:** timerNotifierProvider의 linkedTodoId를 삭제 시점에 체크하여 차단. UI 레벨(confirmDismiss)과 Provider 레벨(deleteTodo/deleteTodos) 양쪽에서 이중 방어. 차단 시 AppSnackBar.warning으로 사용자에게 안내.

**Tech Stack:** Flutter, Riverpod, AppSnackBar, AppDialog

---

### Task 1: 스와이프 삭제 방지 (DismissibleTodoItem)

스와이프로 할 일을 삭제할 때, 타이머에 연동된 할 일이면 삭제를 차단하고 스낵바로 안내한다.

**Files:**
- Modify: `lib/features/todo/presentation/widgets/dismissible_todo_item.dart:44-85`

**Step 1: import 추가**

```dart
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../timer/presentation/providers/timer_provider.dart';
import '../../../timer/presentation/providers/timer_state.dart';
```

**Step 2: confirmDismiss의 삭제 방향(endToStart) 처리 최상단에 타이머 연동 체크 추가**

`confirmDismiss` 콜백에서 `direction == DismissDirection.endToStart` 블록 진입 직후(line 57 이후), 다중 날짜 체크 전에 아래 코드 삽입:

```dart
// 삭제 방향일 때: 타이머 연동 체크
if (direction == DismissDirection.endToStart) {
  final timerState = ref.read(timerNotifierProvider);
  if (timerState.status != TimerStatus.idle &&
      timerState.linkedTodoId == todo.id) {
    AppSnackBar.warning(context, '타이머에 연동된 할 일은 삭제할 수 없어요');
    return false;
  }
  // ... 기존 다중 날짜 / 단일 삭제 로직 유지
}
```

정확한 위치: 기존 `// 삭제 방향: 다중 날짜 할일이면 선택지 표시` 주석 바로 위에 삽입.

**Step 3: flutter analyze**

Run: `flutter analyze lib/features/todo/presentation/widgets/dismissible_todo_item.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/todo/presentation/widgets/dismissible_todo_item.dart
git commit -m "feat: 타이머 연동 중인 할 일 스와이프 삭제 방지"
```

---

### Task 2: 일괄 삭제 방지 (TodoListScreen)

편집 모드에서 일괄 삭제 시, 타이머에 연동된 할 일이 선택 목록에 포함되어 있으면 해당 항목을 제외하고 삭제하거나, 단독이면 삭제를 차단한다.

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart:362-399`

**Step 1: import 추가**

파일 상단에 아래 import 추가 (없는 것만):

```dart
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../timer/presentation/providers/timer_provider.dart';
import '../../../timer/presentation/providers/timer_state.dart';
```

**Step 2: _confirmBatchDelete에 연동 체크 로직 추가**

`_confirmBatchDelete` 메서드에서, 다이얼로그 표시 전에 연동된 할 일을 필터링:

```dart
Future<void> _confirmBatchDelete(BuildContext context) async {
  // 타이머 연동 중인 할 일 체크
  final timerState = ref.read(timerNotifierProvider);
  final linkedTodoId = timerState.status != TimerStatus.idle
      ? timerState.linkedTodoId
      : null;

  final filteredTodoIds = _selectedTodoIds
      .where((id) => id != linkedTodoId)
      .toList();

  if (filteredTodoIds.length < _selectedTodoIds.length) {
    if (mounted) {
      AppSnackBar.warning(context, '타이머에 연동된 할 일은 삭제에서 제외되었어요');
    }
  }

  // 삭제할 항목이 하나도 없으면 종료
  if (filteredTodoIds.isEmpty && _selectedCategoryIds.isEmpty) return;

  final catCount = _selectedCategoryIds.length;
  final todoCount = filteredTodoIds.length;

  final parts = <String>[];
  if (catCount > 0) parts.add('카테고리 $catCount개');
  if (todoCount > 0) parts.add('할일 $todoCount개');
  final description = parts.join(', ');

  final confirmed = await AppDialog.confirm(
    context: context,
    title: '일괄 삭제',
    message:
        '$description를 삭제하시겠습니까?\n카테고리의 할일은 미분류로 이동됩니다.\n\n삭제된 항목은 복구할 수 없습니다.',
    emotion: AppDialogEmotion.warning,
    confirmText: '삭제',
    cancelText: '취소',
    isDestructive: true,
  );

  if (confirmed == true && mounted) {
    if (filteredTodoIds.isNotEmpty) {
      await ref
          .read(todoListNotifierProvider.notifier)
          .deleteTodos(filteredTodoIds);
    }
    if (!mounted) return;
    if (_selectedCategoryIds.isNotEmpty) {
      await ref
          .read(categoryListNotifierProvider.notifier)
          .deleteCategories(_selectedCategoryIds.toList());
    }
    if (!mounted) return;
    _toggleEditMode();
  }
}
```

**Step 3: flutter analyze**

Run: `flutter analyze lib/features/todo/presentation/screens/todo_list_screen.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/todo/presentation/screens/todo_list_screen.dart
git commit -m "feat: 일괄 삭제 시 타이머 연동 할 일 제외 처리"
```

---

### Task 3: 전체 통합 검증

**Step 1: flutter analyze 전체**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 변경 파일 확인**

변경된 파일 2개:
- `lib/features/todo/presentation/widgets/dismissible_todo_item.dart`
- `lib/features/todo/presentation/screens/todo_list_screen.dart`
