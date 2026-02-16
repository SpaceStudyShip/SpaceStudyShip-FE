# Todo 수정 기능 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 기존 할일의 제목, 카테고리, 예정일을 수정할 수 있는 편집 기능 추가

**Architecture:** TodoItem의 체크박스/본문 탭 영역을 분리하여 본문 탭 시 편집 시트를 열고, 기존 TodoAddBottomSheet를 생성/수정 겸용으로 확장. DismissibleTodoItem 내부에서 편집 플로우를 처리하므로 3개 화면(HomeScreen, TodoListScreen, CategoryTodoScreen)은 변경 불필요.

**Tech Stack:** Flutter, Riverpod, Freezed (TodoEntity), table_calendar

---

## 분석 요약

### 이미 구현된 백엔드 인프라 (변경 불필요)

| 레이어 | 컴포넌트 | 상태 |
|--------|----------|------|
| Domain | `TodoEntity.copyWith()` (Freezed) | ✅ |
| Domain | `TodoRepository.updateTodo(TodoEntity)` | ✅ |
| Data | `LocalTodoRepositoryImpl.updateTodo()` | ✅ |
| Data | `UpdateTodoUseCase` | ✅ |
| Provider | `TodoListNotifier.updateTodo()` (낙관적 업데이트 + 롤백) | ✅ |

### UI 변경 필요 (3개 파일)

| 파일 | 변경 내용 |
|------|-----------|
| `todo_item.dart` | 체크박스/본문 탭 영역 분리 |
| `todo_add_bottom_sheet.dart` | 수정 모드 지원 (initialTodo 파라미터) |
| `dismissible_todo_item.dart` | 탭 시 편집 시트 열기 + updateTodo 호출 |

---

### Task 1: TodoItem 체크박스/본문 탭 영역 분리

**Files:**
- Modify: `lib/core/widgets/space/todo_item.dart:57-121`

**현재 동작:** 전체 아이템이 하나의 GestureDetector → `(onTap ?? onToggle)` 호출
**변경 후:**
- `onTap`이 제공되면: 체크박스 탭 → `onToggle`, 본문 탭 → `onTap`
- `onTap`이 null이면: 전체 탭 → `onToggle` (기존 동작 유지)

**Step 1: build() 메서드에서 GestureDetector 구조 변경**

체크박스에 별도 GestureDetector를 추가하고, 외부 GestureDetector는 onTap만 호출하도록 변경:

```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTapDown: (_) => setState(() => _isPressed = true),
    onTapUp: (_) {
      setState(() => _isPressed = false);
      // onTap이 있으면 onTap 호출, 없으면 onToggle 호출
      (widget.onTap ?? widget.onToggle).call();
    },
    onTapCancel: () => setState(() => _isPressed = false),
    child: AnimatedScale(
      scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
      duration: TossDesignTokens.animationFast,
      curve: TossDesignTokens.springCurve,
      child: Container(
        padding: AppPadding.listItemPadding,
        decoration: BoxDecoration(
          color: AppColors.spaceSurface,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: widget.isCompleted
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.spaceDivider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 체크박스: onTap 존재 시 별도 탭 영역
            if (widget.onTap != null)
              GestureDetector(
                onTap: widget.onToggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(right: AppSpacing.s12),
                  child: widget.leading ?? _buildCheckbox(),
                ),
              )
            else ...[
              widget.leading ?? _buildCheckbox(),
              SizedBox(width: AppSpacing.s12),
            ],

            // 제목 및 부제목
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.label_16.copyWith(
                      color: widget.isCompleted
                          ? AppColors.textTertiary
                          : Colors.white,
                      decoration: widget.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textTertiary,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: AppSpacing.s4),
                    Text(
                      widget.subtitle!,
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

**핵심:** `widget.onTap != null`일 때만 체크박스를 별도 `GestureDetector`로 감싸서 `onToggle`을 독립 호출. `onTap`이 null이면 기존과 동일하게 전체 탭 → `onToggle`.

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

---

### Task 2: TodoAddBottomSheet에 수정 모드 추가

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**Step 1: 생성자에 initialTodo 파라미터 추가**

```dart
class TodoAddBottomSheet extends ConsumerStatefulWidget {
  const TodoAddBottomSheet({
    super.key,
    this.initialCategoryId,
    this.initialScheduledDates,
    this.initialTodo,
  });

  final String? initialCategoryId;
  final List<DateTime>? initialScheduledDates;
  /// 수정 모드: 기존 할일 전달 시 편집 모드로 동작
  final TodoEntity? initialTodo;

  @override
  ConsumerState<TodoAddBottomSheet> createState() => _TodoAddBottomSheetState();
}
```

import 추가: `import '../../domain/entities/todo_entity.dart';`

**Step 2: initState에서 initialTodo 값으로 필드 초기화**

```dart
@override
void initState() {
  super.initState();
  final todo = widget.initialTodo;
  if (todo != null) {
    // 수정 모드: 기존 값으로 초기화
    _titleController.text = todo.title;
    _selectedCategoryId = todo.categoryId;
    _selectedScheduledDates = todo.scheduledDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toList();
    if (_selectedScheduledDates.isNotEmpty) {
      _calendarFocusedDay = _selectedScheduledDates.first;
    }
  } else {
    // 생성 모드: 기존 로직
    _selectedCategoryId = widget.initialCategoryId;
    if (widget.initialScheduledDates != null &&
        widget.initialScheduledDates!.isNotEmpty) {
      _selectedScheduledDates = widget.initialScheduledDates!
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList();
    } else {
      final now = DateTime.now();
      _selectedScheduledDates = [DateTime(now.year, now.month, now.day)];
    }
  }
}
```

**Step 3: 헤더와 버튼 텍스트를 모드에 따라 변경**

`_isEditMode` getter 추가:

```dart
bool get _isEditMode => widget.initialTodo != null;
```

제목 텍스트 변경 (Line ~124):

```dart
'할 일 추가' → _isEditMode ? '할 일 수정' : '할 일 추가'
```

버튼 텍스트 변경 (Line ~288):

```dart
'추가하기' → _isEditMode ? '수정하기' : '추가하기'
```

**Step 4: _submit에서 id 포함하여 반환**

```dart
void _submit() {
  final title = _titleController.text.trim();
  if (title.isEmpty) return;
  Navigator.of(context).pop({
    'title': title,
    'categoryId': _selectedCategoryId,
    'scheduledDates': _selectedScheduledDates,
    if (widget.initialTodo != null) 'id': widget.initialTodo!.id,
  });
}
```

**Step 5: showTodoAddBottomSheet 헬퍼 함수에 initialTodo 파라미터 추가**

```dart
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
  String? initialCategoryId,
  List<DateTime>? initialScheduledDates,
  TodoEntity? initialTodo,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => TodoAddBottomSheet(
      initialCategoryId: initialCategoryId,
      initialScheduledDates: initialScheduledDates,
      initialTodo: initialTodo,
    ),
  );
}
```

**Step 6: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

---

### Task 3: DismissibleTodoItem에서 탭 시 편집 시트 열기

**Files:**
- Modify: `lib/features/todo/presentation/widgets/dismissible_todo_item.dart`

**Step 1: import 추가**

```dart
import 'todo_add_bottom_sheet.dart';
```

**Step 2: TodoItem의 onTap에 편집 로직 연결**

`build()` 메서드 내 `TodoItem` 생성 부분 (Line ~115-128) 변경:

```dart
child: TodoItem(
  title: todo.title,
  subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
      ? '${todo.actualMinutes}분 공부'
      : null,
  isCompleted: isCompleted,
  onToggle: () {
    final date = contextDate ?? DateTime.now();
    ref
        .read(todoListNotifierProvider.notifier)
        .toggleTodoForDate(todo, date);
  },
  onTap: onTap ?? () => _openEditSheet(context, ref),
),
```

**Step 3: _openEditSheet 메서드 추가**

DismissibleTodoItem 클래스에 편집 시트를 여는 메서드 추가:

```dart
void _openEditSheet(BuildContext context, WidgetRef ref) async {
  final result = await showTodoAddBottomSheet(
    context: context,
    initialTodo: todo,
  );
  if (result != null && context.mounted) {
    ref.read(todoListNotifierProvider.notifier).updateTodo(
      todo.copyWith(
        title: result['title'] as String,
        categoryId: result['categoryId'] as String?,
        scheduledDates:
            (result['scheduledDates'] as List<DateTime>?) ?? [],
      ),
    );
  }
}
```

**Step 4: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

---

### Task 4: 최종 검증 및 커밋

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 커밋**

```text
feat: 할일 수정 기능 추가 (제목, 카테고리, 날짜 편집)
```

---

## 동작 요약

| 동작 | 기존 | 변경 후 |
|------|------|---------|
| 할일 탭 | 완료 토글 | 수정 시트 열림 |
| 체크박스 탭 | (구분 없음) | 완료 토글 |
| 스와이프 좌→우 | 카테고리 이동 | 변경 없음 |
| 스와이프 우→좌 | 삭제 | 변경 없음 |

**화면별 영향:**
- HomeScreen: 변경 없음 (DismissibleTodoItem 내부 처리)
- TodoListScreen: 변경 없음
- CategoryTodoScreen: 변경 없음
