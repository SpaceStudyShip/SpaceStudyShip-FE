# TodoListScreen 편집 모드 + 일괄 삭제 구현

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** TodoListScreen에 편집 모드를 추가하여 카테고리와 미분류 할일을 체크박스로 선택 후 일괄 삭제

**Architecture:** TodoListScreen을 ConsumerStatefulWidget으로 변환하여 로컬 편집 상태(`_isEditMode`, `_selectedCategoryIds`, `_selectedTodoIds`)를 관리. AppBar에 편집/완료 토글 버튼을 배치하고, 편집 모드에서는 카테고리 카드와 할일 아이템에 체크박스 오버레이를 표시. 선택된 항목이 있으면 하단에 삭제 버튼을 FloatingActionButton으로 표시. Provider에 batch delete 메서드를 추가하여 한 번의 invalidateSelf로 처리.

**Tech Stack:** Flutter, Riverpod, SharedPreferences

---

### Task 1: Provider에 일괄 삭제 메서드 추가

**Files:**
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart`

**Step 1: TodoListNotifier에 deleteTodos 추가**

`deleteTodo` 아래에 일괄 삭제 메서드 추가:

```dart
Future<void> deleteTodos(List<String> ids) async {
  final previousState = state;
  state = AsyncData(
    state.valueOrNull?.where((t) => !ids.contains(t.id)).toList() ?? [],
  );
  try {
    final useCase = ref.read(deleteTodoUseCaseProvider);
    for (final id in ids) {
      await useCase.execute(id);
    }
  } catch (_) {
    state = previousState;
    rethrow;
  }
}
```

**Step 2: CategoryListNotifier에 deleteCategories 추가**

`deleteCategory` 아래에 일괄 삭제 메서드 추가:

```dart
Future<void> deleteCategories(List<String> ids) async {
  final useCase = ref.read(deleteCategoryUseCaseProvider);
  for (final id in ids) {
    await useCase.execute(id);
  }
  ref.invalidateSelf();
  ref.invalidate(todoListNotifierProvider);
}
```

**Step 3: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```bash
git add lib/features/todo/presentation/providers/todo_provider.dart
git commit -m "feat: TodoListNotifier/CategoryListNotifier 일괄 삭제 메서드 추가 #16"
```

---

### Task 2: CategoryFolderCard에 편집 모드 UI 추가

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_folder_card.dart`

**Step 1: isEditMode, isSelected 파라미터 추가 + UI 변경**

기존 `onDelete` prop 제거하고 `isEditMode`와 `isSelected` 추가:

```dart
class CategoryFolderCard extends StatefulWidget {
  const CategoryFolderCard({
    super.key,
    required this.name,
    this.emoji,
    required this.todoCount,
    required this.completedCount,
    required this.onTap,
    this.isEditMode = false,
    this.isSelected = false,
  });

  final String name;
  final String? emoji;
  final int todoCount;
  final int completedCount;
  final VoidCallback onTap;
  final bool isEditMode;
  final bool isSelected;
  // onDelete 제거
```

Stack children에서 기존 more_vert 버튼 제거. 대신 편집 모드일 때 좌상단에 체크 원 표시:

```dart
child: Stack(
  children: [
    // 편집 모드: 선택 체크 표시 (좌상단)
    if (widget.isEditMode)
      Positioned(
        top: 8.h,
        left: 8.w,
        child: AnimatedContainer(
          duration: TossDesignTokens.animationFast,
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.error
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.error
                  : AppColors.textTertiary,
              width: 2,
            ),
          ),
          child: widget.isSelected
              ? Icon(Icons.check, size: 14.w, color: Colors.white)
              : null,
        ),
      ),
    // 중앙 콘텐츠 (기존 유지)
    Center(child: Column(...)),
  ],
),
```

편집 모드일 때 카드 border를 선택 상태에 따라 변경:

```dart
decoration: BoxDecoration(
  color: AppColors.spaceSurface,
  borderRadius: AppRadius.card,
  border: Border.all(
    color: widget.isEditMode && widget.isSelected
        ? AppColors.error.withValues(alpha: 0.6)
        : AppColors.spaceDivider,
  ),
),
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/widgets/category_folder_card.dart
git commit -m "feat: CategoryFolderCard 편집 모드 선택 UI 추가 #16"
```

---

### Task 3: TodoListScreen을 ConsumerStatefulWidget으로 변환 + 편집 모드 구현

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`

**Step 1: ConsumerStatefulWidget 변환**

```dart
class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  bool _isEditMode = false;
  final Set<String> _selectedCategoryIds = {};
  final Set<String> _selectedTodoIds = {};

  int get _selectedCount => _selectedCategoryIds.length + _selectedTodoIds.length;

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedCategoryIds.clear();
        _selectedTodoIds.clear();
      }
    });
  }

  void _toggleCategorySelection(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  void _toggleTodoSelection(String id) {
    setState(() {
      if (_selectedTodoIds.contains(id)) {
        _selectedTodoIds.remove(id);
      } else {
        _selectedTodoIds.add(id);
      }
    });
  }
```

**Step 2: AppBar 편집 모드 UI**

AppBar를 조건부로 변경:

```dart
appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  title: _isEditMode
      ? Text(
          '$_selectedCount개 선택됨',
          style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
        )
      : null,
  iconTheme: const IconThemeData(color: Colors.white),
  actions: [
    if (_isEditMode)
      TextButton(
        onPressed: _toggleEditMode,
        child: Text(
          '취소',
          style: AppTextStyles.label_16.copyWith(color: AppColors.textSecondary),
        ),
      )
    else
      IconButton(
        onPressed: _toggleEditMode,
        icon: Icon(Icons.checklist_rounded, size: 24.w, color: Colors.white),
      ),
  ],
),
```

**Step 3: 카테고리 그리드에서 편집 모드 적용**

CategoryFolderCard에 `isEditMode`와 `isSelected` 전달. 편집 모드에서 탭하면 선택 토글, 일반 모드에서 탭하면 기존 화면 이동:

```dart
return CategoryFolderCard(
  name: cat.name,
  emoji: cat.emoji,
  todoCount: catTodos.length,
  completedCount: completedCount,
  isEditMode: _isEditMode,
  isSelected: _selectedCategoryIds.contains(cat.id),
  onTap: () {
    if (_isEditMode) {
      _toggleCategorySelection(cat.id);
    } else {
      context.push(
        RoutePaths.categoryTodoPath(cat.id),
        extra: {'name': cat.name, 'emoji': cat.emoji},
      );
    }
  },
);
```

**Step 4: 미분류 할일에서 편집 모드 적용**

편집 모드일 때 Dismissible 비활성화 + 체크박스 leading 추가:

```dart
if (uncategorized.isNotEmpty)
  ...uncategorized.map(
    (todo) => Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: _isEditMode
          ? GestureDetector(
              onTap: () => _toggleTodoSelection(todo.id),
              child: TodoItem(
                title: todo.title,
                subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
                    ? '${todo.actualMinutes}분 공부'
                    : null,
                isCompleted: todo.completed,
                onToggle: () => _toggleTodoSelection(todo.id),
                leading: _buildSelectionCheckbox(_selectedTodoIds.contains(todo.id)),
              ),
            )
          : Dismissible(
              // ... 기존 Dismissible 코드 유지
            ),
    ),
  ),
```

`_buildSelectionCheckbox` 헬퍼:

```dart
Widget _buildSelectionCheckbox(bool isSelected) {
  return AnimatedContainer(
    duration: TossDesignTokens.animationFast,
    width: 24.w,
    height: 24.w,
    decoration: BoxDecoration(
      color: isSelected ? AppColors.error : Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(
        color: isSelected ? AppColors.error : AppColors.textTertiary,
        width: 2,
      ),
    ),
    child: isSelected
        ? Icon(Icons.check, size: 14.w, color: Colors.white)
        : null,
  );
}
```

**Step 5: 하단 삭제 버튼 (FloatingActionButton)**

Scaffold에 `floatingActionButton` 추가:

```dart
floatingActionButton: _isEditMode && _selectedCount > 0
    ? FloatingActionButton.extended(
        onPressed: () => _confirmBatchDelete(context),
        backgroundColor: AppColors.error,
        icon: Icon(Icons.delete_outline, color: Colors.white, size: 20.w),
        label: Text(
          '$_selectedCount개 삭제',
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
      )
    : null,
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
```

**Step 6: 일괄 삭제 확인 다이얼로그 + 실행**

```dart
Future<void> _confirmBatchDelete(BuildContext context) async {
  final catCount = _selectedCategoryIds.length;
  final todoCount = _selectedTodoIds.length;

  final parts = <String>[];
  if (catCount > 0) parts.add('카테고리 ${catCount}개');
  if (todoCount > 0) parts.add('할일 ${todoCount}개');
  final description = parts.join(', ');

  final confirmed = await AppDialog.confirm(
    context: context,
    title: '일괄 삭제',
    message: '$description를 삭제하시겠습니까?\n카테고리의 할일은 미분류로 이동됩니다.',
    emotion: AppDialogEmotion.warning,
    confirmText: '삭제',
    cancelText: '취소',
    isDestructive: true,
  );

  if (confirmed == true && context.mounted) {
    if (_selectedCategoryIds.isNotEmpty) {
      await ref
          .read(categoryListNotifierProvider.notifier)
          .deleteCategories(_selectedCategoryIds.toList());
    }
    if (_selectedTodoIds.isNotEmpty) {
      await ref
          .read(todoListNotifierProvider.notifier)
          .deleteTodos(_selectedTodoIds.toList());
    }
    _toggleEditMode();
  }
}
```

**Step 7: 기존 _deleteCategory 메서드 및 관련 import 정리**

`_deleteCategory` 메서드 삭제 (더 이상 개별 삭제 UI 없음).

**Step 8: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 9: Commit**

```bash
git add lib/features/todo/presentation/screens/todo_list_screen.dart
git commit -m "feat: TodoListScreen 편집 모드 + 일괄 삭제 구현 #16"
```

---

### Task 4: 최종 검증

**Step 1: 전체 정적 분석**

Run: `flutter analyze`
Expected: No issues

**Step 2: 시각적 검증 (수동)**

확인 항목:
1. AppBar 우측 체크리스트 아이콘 탭 → 편집 모드 진입
2. 편집 모드에서 카테고리 카드 탭 → 체크 원 표시 + 빨간 테두리
3. 편집 모드에서 미분류 할일 탭 → 체크 원 표시
4. 선택 시 AppBar에 "N개 선택됨" 텍스트 갱신
5. 선택된 항목 있으면 하단에 "N개 삭제" FAB 표시
6. FAB 탭 → 확인 다이얼로그 → 삭제 → 편집 모드 해제
7. 취소 버튼 → 선택 초기화 + 편집 모드 해제
8. 일반 모드에서 기존 기능 정상 동작 (카테고리 탭 → 화면 이동, 스와이프 삭제/이동)
