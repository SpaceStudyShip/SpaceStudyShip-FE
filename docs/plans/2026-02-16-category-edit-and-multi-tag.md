# Category Edit & Multi-Tag System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 카테고리 수정 기능 추가 + 단일 카테고리(폴더)를 다중 카테고리(태그) 시스템으로 전환

**Architecture:** Clean Architecture 3-Layer 구조를 유지하며 Data → Domain → Presentation 순으로 bottom-up 구현. Phase 1(카테고리 수정)은 비파괴적 변경, Phase 2(다중 태그)는 전 레이어 마이그레이션.

**Tech Stack:** Flutter + Freezed + Riverpod Generator + SharedPreferences

**Branch:** `20260216_#21_카테고리_수정_기능_추가_및_태그_시스템_전환_단일_다중`

---

## Phase 1: 카테고리 수정 기능 (비파괴적)

### Task 1: Domain + Data — updateCategory 인프라 추가

**Files:**
- Modify: `lib/features/todo/domain/repositories/todo_repository.dart`
- Modify: `lib/features/todo/domain/entities/todo_category_entity.dart`
- Modify: `lib/features/todo/data/models/todo_category_model.dart`
- Modify: `lib/features/todo/data/repositories/local_todo_repository_impl.dart`

**Step 1: Repository 인터페이스에 updateCategory 메서드 추가**

`todo_repository.dart` — `deleteCategory` 아래에:

```dart
Future<TodoCategoryEntity> updateCategory(TodoCategoryEntity category);
```

**Step 2: TodoCategoryEntity에 updatedAt 필드 추가**

`todo_category_entity.dart`:

```dart
@freezed
class TodoCategoryEntity with _$TodoCategoryEntity {
  const factory TodoCategoryEntity({
    required String id,
    required String name,
    String? emoji,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TodoCategoryEntity;
}
```

**Step 3: TodoCategoryModel에 updatedAt 필드 + 변환 로직 추가**

`todo_category_model.dart` — 필드 추가:

```dart
@JsonKey(name: 'updated_at') DateTime? updatedAt,
```

변환 extension 양쪽에 `updatedAt: updatedAt` 추가.

**Step 4: LocalTodoRepositoryImpl에 updateCategory 구현**

`local_todo_repository_impl.dart` — Categories 섹션, `deleteCategory` 위에:

```dart
@override
Future<TodoCategoryEntity> updateCategory(TodoCategoryEntity category) async {
  final categories = _dataSource.getCategories();
  final index = categories.indexWhere((c) => c.id == category.id);
  if (index == -1) throw Exception('Category not found: ${category.id}');

  final updated = category.copyWith(updatedAt: DateTime.now()).toModel();
  categories[index] = updated;
  await _dataSource.saveCategories(categories);

  return updated.toEntity();
}
```

**Step 5: build_runner + 검증**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Run: `flutter analyze`
Expected: No issues found

**Step 6: Commit**

```
feat: 카테고리 수정 인프라 추가 (updateCategory + updatedAt 필드) #21
```

---

### Task 2: Domain + Presentation — UseCase + Provider 연결

**Files:**
- Create: `lib/features/todo/domain/usecases/update_category_usecase.dart`
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart`

**Step 1: UpdateCategoryUseCase 생성**

```dart
import '../entities/todo_category_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateCategoryUseCase {
  final TodoRepository _repository;

  UpdateCategoryUseCase(this._repository);

  Future<TodoCategoryEntity> execute(TodoCategoryEntity category) {
    return _repository.updateCategory(category);
  }
}
```

**Step 2: todo_provider.dart에 UseCase Provider 추가**

import 추가 + `deleteCategoryUseCase` Provider 아래에:

```dart
@riverpod
UpdateCategoryUseCase updateCategoryUseCase(Ref ref) {
  return UpdateCategoryUseCase(ref.watch(todoRepositoryProvider));
}
```

**Step 3: CategoryListNotifier에 updateCategory 메서드 추가**

`deleteCategory` 메서드 위에:

```dart
Future<void> updateCategory(TodoCategoryEntity category) async {
  final previousState = state;
  state = AsyncData(
    state.valueOrNull
            ?.map((c) => c.id == category.id ? category : c)
            .toList() ??
        [],
  );
  try {
    final useCase = ref.read(updateCategoryUseCaseProvider);
    await useCase.execute(category);
  } catch (_) {
    state = previousState;
    rethrow;
  }
}
```

**Step 4: build_runner + 검증**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Run: `flutter analyze`
Expected: No issues found

**Step 5: Commit**

```
feat: UpdateCategoryUseCase + CategoryListNotifier.updateCategory 추가 #21
```

---

### Task 3: UI — CategoryAddBottomSheet 추가/수정 겸용 확장

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_add_bottom_sheet.dart`

**Step 1: 생성자에 initialCategory 파라미터 추가**

```dart
class CategoryAddBottomSheet extends StatefulWidget {
  const CategoryAddBottomSheet({super.key, this.initialCategory});

  final ({String id, String name, String? emoji})? initialCategory;
  // ...
}
```

**Step 2: initState에서 초기값 + 모드 판별**

```dart
bool get _isEditMode => widget.initialCategory != null;

@override
void initState() {
  super.initState();
  if (widget.initialCategory != null) {
    _nameController.text = widget.initialCategory!.name;
    _selectedEmoji = widget.initialCategory!.emoji ?? '📁';
  }
  _nameController.addListener(() => setState(() {}));
}
```

**Step 3: 제목/버튼 텍스트 분기**

- 제목: `_isEditMode ? '카테고리 수정' : '카테고리 추가'`
- 버튼: `_isEditMode ? '수정하기' : '추가하기'`

**Step 4: _submit에서 id 포함 반환**

```dart
void _submit() {
  final name = _nameController.text.trim();
  if (name.isEmpty) return;
  Navigator.of(context).pop({
    if (_isEditMode) 'id': widget.initialCategory!.id,
    'name': name,
    'emoji': _selectedEmoji,
  });
}
```

**Step 5: 헬퍼 함수에 initialCategory 파라미터 추가**

```dart
Future<Map<String, dynamic>?> showCategoryAddBottomSheet({
  required BuildContext context,
  ({String id, String name, String? emoji})? initialCategory,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => CategoryAddBottomSheet(
      initialCategory: initialCategory,
    ),
  );
}
```

**Step 6: 검증**

Run: `flutter analyze`
Expected: No issues found

---

### Task 4: UI — CategoryFolderCard 롱프레스 + TodoListScreen 연동

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_folder_card.dart`
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`

**Step 1: CategoryFolderCard에 onLongPress 콜백 추가**

생성자 파라미터에 `final VoidCallback? onLongPress;` 추가.
GestureDetector에 `onLongPress: widget.onLongPress,` 추가.

**Step 2: TodoListScreen에 _editCategory 메서드 추가**

```dart
Future<void> _editCategory(
  BuildContext context,
  WidgetRef ref,
  TodoCategoryEntity cat,
) async {
  final result = await showCategoryAddBottomSheet(
    context: context,
    initialCategory: (id: cat.id, name: cat.name, emoji: cat.emoji),
  );
  if (result != null && mounted) {
    ref.read(categoryListNotifierProvider.notifier).updateCategory(
      cat.copyWith(
        name: result['name'] as String,
        emoji: result['emoji'] as String?,
      ),
    );
  }
}
```

**Step 3: Consumer 내부 CategoryFolderCard에 onLongPress 전달**

```dart
CategoryFolderCard(
  // ... 기존 props
  onLongPress: _isEditMode
      ? null
      : () => _editCategory(context, ref, cat),
)
```

**Step 4: 검증 + Commit**

Run: `flutter analyze`

```
feat: 카테고리 수정 UI (롱프레스 → 바텀시트 + 이름/이모지 편집) #21
```

---

## Phase 2: 다중 카테고리(태그) 시스템 전환

### Task 5: 파일 리네임 (폴더 → 태그 의미 반영)

**Renames:**
1. `category_folder_card.dart` → `category_card.dart`
   - Class: `CategoryFolderCard` → `CategoryCard`
   - State: `_CategoryFolderCardState` → `_CategoryCardState`
   - Import 수정: `todo_list_screen.dart`

2. `category_move_bottom_sheet.dart` → `category_select_bottom_sheet.dart`
   - Class: `CategoryMoveBottomSheet` → `CategorySelectBottomSheet`
   - Helper: `showCategoryMoveBottomSheet` → `showCategorySelectBottomSheet`
   - Import 수정: `dismissible_todo_item.dart`

**Step 1: git mv로 파일 이동**

```bash
git mv lib/features/todo/presentation/widgets/category_folder_card.dart \
       lib/features/todo/presentation/widgets/category_card.dart
git mv lib/features/todo/presentation/widgets/category_move_bottom_sheet.dart \
       lib/features/todo/presentation/widgets/category_select_bottom_sheet.dart
```

**Step 2: 파일 내 클래스/함수명 일괄 변경**

`category_card.dart`:
- `CategoryFolderCard` → `CategoryCard` (전체)
- `_CategoryFolderCardState` → `_CategoryCardState`

`category_select_bottom_sheet.dart`:
- `CategoryMoveBottomSheet` → `CategorySelectBottomSheet`
- `showCategoryMoveBottomSheet` → `showCategorySelectBottomSheet`
- 제목 텍스트: `'카테고리 이동'` → `'카테고리 선택'`

**Step 3: import 경로 수정**

`todo_list_screen.dart`:
- `import '../widgets/category_folder_card.dart'` → `import '../widgets/category_card.dart'`
- `CategoryFolderCard(` → `CategoryCard(`

`dismissible_todo_item.dart`:
- `import 'category_move_bottom_sheet.dart'` → `import 'category_select_bottom_sheet.dart'`
- `showCategoryMoveBottomSheet(` → `showCategorySelectBottomSheet(`

**Step 4: 검증 + Commit**

Run: `flutter analyze`

```
refactor: 파일 리네임 (CategoryFolderCard → CategoryCard, CategoryMove → CategorySelect) #21
```

---

### Task 6: Data Model — TodoModel의 categoryId → categoryIds 마이그레이션

**Files:**
- Modify: `lib/features/todo/data/models/todo_model.dart`

**Step 1: 필드 변경**

```dart
// 기존:  @JsonKey(name: 'category_id') String? categoryId,
// 변경:
@JsonKey(name: 'category_ids') @Default([]) List<String> categoryIds,
```

**Step 2: _migrateJson에 마이그레이션 로직 추가**

return 전에 추가:

```dart
// category_id (String?) → category_ids (List<String>)
if (!migrated.containsKey('category_ids') &&
    migrated.containsKey('category_id')) {
  final oldId = migrated['category_id'] as String?;
  migrated['category_ids'] = oldId != null ? [oldId] : <String>[];
  migrated.remove('category_id');
}
```

**Step 3: 변환 extension에서 `categoryId` → `categoryIds` 변경**

TodoModelX, TodoEntityToModelX 양쪽 모두 `categoryIds: categoryIds`.

---

### Task 7: Domain Entity — TodoEntity의 categoryId → categoryIds

**Files:**
- Modify: `lib/features/todo/domain/entities/todo_entity.dart`

**Step 1: 필드 변경**

```dart
// 기존:  String? categoryId,
// 변경:
@Default([]) List<String> categoryIds,
```

**Step 2: build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 성공. 이후 다수의 컴파일 에러 발생 (정상 — Task 8~12에서 수정)

---

### Task 8: Repository + UseCase — categoryIds 파라미터 전파

**Files:**
- Modify: `lib/features/todo/domain/repositories/todo_repository.dart`
- Modify: `lib/features/todo/data/repositories/local_todo_repository_impl.dart`
- Modify: `lib/features/todo/domain/usecases/create_todo_usecase.dart`

**Step 1: Repository 인터페이스 — createTodo 시그니처 변경**

```dart
Future<TodoEntity> createTodo({
  required String title,
  List<String> categoryIds = const [],
  int? estimatedMinutes,
  List<DateTime>? scheduledDates,
});
```

**Step 2: LocalTodoRepositoryImpl — 3곳 수정**

getTodoList:
```dart
final filtered = categoryId != null
    ? models.where((m) => m.categoryIds.contains(categoryId)).toList()
    : models;
```

createTodo:
```dart
Future<TodoEntity> createTodo({
  required String title,
  List<String> categoryIds = const [],
  // ... 나머지 동일
}) async {
  final model = TodoModel(
    // ... categoryIds: categoryIds,
  );
}
```

deleteCategory — categoryIds 리스트에서 제거:
```dart
final updatedTodos = todos.map((t) {
  if (t.categoryIds.contains(id)) {
    return t.copyWith(
      categoryIds: t.categoryIds.where((cid) => cid != id).toList(),
    );
  }
  return t;
}).toList();
```

**Step 3: CreateTodoUseCase — categoryIds 파라미터**

```dart
Future<TodoEntity> execute({
  required String title,
  List<String> categoryIds = const [],
  int? estimatedMinutes,
  List<DateTime>? scheduledDates,
}) {
  return _repository.createTodo(
    title: title,
    categoryIds: categoryIds,
    estimatedMinutes: estimatedMinutes,
    scheduledDates: scheduledDates,
  );
}
```

---

### Task 9: Provider — 전체 카테고리 관련 Provider 업데이트

**Files:**
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart`

**Step 1: TodoListNotifier.addTodo — categoryIds 파라미터**

```dart
Future<void> addTodo({
  required String title,
  List<String> categoryIds = const [],
  int? estimatedMinutes,
  List<DateTime>? scheduledDates,
}) async { ... }
```

**Step 2: todosForCategory — 미분류 = `categoryIds.isEmpty`**

```dart
@riverpod
List<TodoEntity> todosForCategory(Ref ref, String? categoryId) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  if (categoryId == null) {
    return todos.where((t) => t.categoryIds.isEmpty).toList();
  }
  return todos.where((t) => t.categoryIds.contains(categoryId)).toList();
}
```

**Step 3: categoryTodoStats — 동일 로직**

```dart
final catTodos = categoryId == null
    ? todos.where((t) => t.categoryIds.isEmpty)
    : todos.where((t) => t.categoryIds.contains(categoryId));
```

**Step 4: build_runner + Commit**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

```
feat: 다중 카테고리 데이터 레이어 마이그레이션 (categoryId → categoryIds) #21
```

---

### Task 10: UI — TodoAddBottomSheet 다중 카테고리 선택

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**Step 1: 상태 변수 변경**

`String? _selectedCategoryId` → `List<String> _selectedCategoryIds = []`

**Step 2: initState 초기값**

```dart
if (widget.initialTodo != null) {
  _selectedCategoryIds = List<String>.from(widget.initialTodo!.categoryIds);
} else if (widget.initialCategoryId != null) {
  _selectedCategoryIds = [widget.initialCategoryId!];
}
```

**Step 3: 카테고리 칩 — 다중 선택 토글**

미분류 칩: `_selectedCategoryIds.isEmpty` 체크, 탭 시 `_selectedCategoryIds.clear()`
카테고리 칩: `_selectedCategoryIds.contains(cat.id)` 체크, 탭 시 토글 (add/remove)

**Step 4: _submit 반환값**

```dart
'categoryIds': List<String>.from(_selectedCategoryIds),
```

---

### Task 11: UI — CategorySelectBottomSheet 다중 선택 전환

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_select_bottom_sheet.dart`

**Step 1: ConsumerWidget → ConsumerStatefulWidget 전환**

```dart
class CategorySelectBottomSheet extends ConsumerStatefulWidget {
  const CategorySelectBottomSheet({super.key, this.currentCategoryIds = const []});
  final List<String> currentCategoryIds;
  @override
  ConsumerState<CategorySelectBottomSheet> createState() => _CategorySelectBottomSheetState();
}

class _CategorySelectBottomSheetState extends ConsumerState<CategorySelectBottomSheet> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.currentCategoryIds);
  }
  // ...
}
```

**Step 2: 체크박스 토글 방식**

미분류: `_selectedIds.isEmpty` 체크, 탭 시 `_selectedIds.clear()`
카테고리: `_selectedIds.contains(cat.id)` 체크, 탭 시 토글

**Step 3: 하단 확인 버튼 추가**

```dart
Padding(
  padding: AppPadding.horizontal20,
  child: AppButton(
    text: '확인',
    onPressed: () => Navigator.of(context).pop(_selectedIds),
    width: double.infinity,
  ),
),
```

**Step 4: 헬퍼 함수 — 반환 타입 `List<String>?`**

```dart
Future<List<String>?> showCategorySelectBottomSheet({
  required BuildContext context,
  List<String> currentCategoryIds = const [],
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => CategorySelectBottomSheet(
      currentCategoryIds: currentCategoryIds,
    ),
  );
}
```

---

### Task 12: UI — 호출부 전체 업데이트

**Files:**
- Modify: `lib/features/todo/presentation/widgets/dismissible_todo_item.dart`
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`
- Modify: `lib/features/todo/presentation/screens/category_todo_screen.dart`
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: DismissibleTodoItem**

스와이프 카테고리 선택:
```dart
final newCategoryIds = await showCategorySelectBottomSheet(
  context: context,
  currentCategoryIds: todo.categoryIds,
);
if (newCategoryIds != null && context.mounted) {
  ref.read(todoListNotifierProvider.notifier).updateTodo(
    todo.copyWith(categoryIds: newCategoryIds),
  );
}
```

수정 `_openEditSheet`:
```dart
categoryIds: (result['categoryIds'] as List<String>?) ?? [],
```

**Step 2: TodoListScreen — addTodo 호출부**

```dart
categoryIds: (result['categoryIds'] as List<String>?) ?? [],
```

**Step 3: CategoryTodoScreen — addTodo 호출부**

```dart
categoryIds: (result['categoryIds'] as List<String>?) ?? [],
```

**Step 4: HomeScreen — addTodo 호출부**

`lib/features/home/presentation/screens/home_screen.dart:404` 수정:
```dart
categoryIds: (result['categoryIds'] as List<String>?) ?? [],
```

**Step 5: build_runner + 검증 + Commit**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Run: `flutter analyze`

```
feat: 다중 카테고리 UI 전환 (칩 다중선택 + CategorySelectBottomSheet) #21
```

---

### Task 13: 최종 검증 및 정리

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 수동 테스트 체크리스트**

- [ ] 카테고리 추가 → 정상 동작
- [ ] 카테고리 롱프레스 → 수정 바텀시트 (이름/이모지 편집)
- [ ] 카테고리 이름/이모지 수정 → 즉시 반영
- [ ] 할일 추가 시 카테고리 다중 선택 가능
- [ ] 할일 수정 시 기존 카테고리들 체크 유지
- [ ] 카테고리 화면에서 해당 카테고리 포함 할일 표시
- [ ] 다중 카테고리 할일이 여러 카테고리 화면에 각각 표시
- [ ] 카테고리 삭제 시 할일의 categoryIds에서 해당 ID 제거
- [ ] 미분류 섹션: categoryIds 비어있는 할일만 표시
- [ ] 기존 데이터(단일 categoryId) → categoryIds 마이그레이션 정상 작동
- [ ] 홈 화면 할일 추가 시 categoryIds 정상 전달

---

## 영향 범위 요약

| 레이어 | 파일 | 변경 내용 |
|--------|------|----------|
| **Domain Entity** | `todo_entity.dart` | `categoryId` → `categoryIds` |
| **Domain Entity** | `todo_category_entity.dart` | `updatedAt` 추가 |
| **Domain Repository** | `todo_repository.dart` | `updateCategory` 추가, `createTodo` 시그니처 |
| **Domain UseCase** | `update_category_usecase.dart` | 신규 생성 |
| **Domain UseCase** | `create_todo_usecase.dart` | `categoryIds` 파라미터 |
| **Data Model** | `todo_model.dart` | `categoryIds` + `_migrateJson` |
| **Data Model** | `todo_category_model.dart` | `updatedAt` 추가 |
| **Data Repository** | `local_todo_repository_impl.dart` | `updateCategory`, `.contains()` 필터 |
| **Presentation** | `todo_provider.dart` | `updateCategory`, 필터 Provider 수정 |
| **UI** | `category_add_bottom_sheet.dart` | 추가/수정 겸용 |
| **UI (rename)** | `category_folder_card.dart` → `category_card.dart` | `onLongPress` + 클래스명 변경 |
| **UI (rename)** | `category_move_bottom_sheet.dart` → `category_select_bottom_sheet.dart` | 다중 선택 + StatefulWidget 전환 |
| **UI** | `todo_add_bottom_sheet.dart` | 다중 카테고리 칩 |
| **UI** | `dismissible_todo_item.dart` | `categoryIds` + 새 import |
| **UI** | `todo_list_screen.dart` | 호출부 + 새 import |
| **UI** | `category_todo_screen.dart` | 호출부 수정 |
| **UI** | `home_screen.dart` | 호출부 수정 (line 404) |
