# 게스트 모드 Todo 기능 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 게스트 모드에서 SharedPreferences 기반 로컬 할일(Todo) CRUD + 카테고리(폴더) 기능을 구현하고, HomeScreen의 하드코딩된 할일을 실제 데이터로 교체한다.
ㅇ
**Architecture:** Clean Architecture 3-Layer (Domain → Data → Presentation). TodoRepository 인터페이스에 LocalTodoRepositoryImpl(SharedPreferences)을 주입. isGuest 플래그로 향후 Remote 구현체와 분기 가능하도록 설계.

**Tech Stack:** Flutter, Riverpod 2.6.1 (@riverpod), Freezed 2.5.7, SharedPreferences 2.3.4, UUID 4.5.2

---

## Phase 1: 도메인 레이어 (순수 Dart, 외부 의존성 없음)

### Task 1: TodoEntity 생성

**Files:**

- Create: `lib/features/todo/domain/entities/todo_entity.dart`

**Step 1: Entity 파일 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_entity.freezed.dart';

@freezed
class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,
    required String title,
    @Default(false) bool completed,
    String? categoryId,
    int? estimatedMinutes,
    int? actualMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoEntity;
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/domain/entities/todo_entity.dart
git commit -m "feat: TodoEntity 도메인 엔티티 추가"
```

---

### Task 2: TodoCategoryEntity 생성

**Files:**

- Create: `lib/features/todo/domain/entities/todo_category_entity.dart`

**Step 1: Entity 파일 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_category_entity.freezed.dart';

@freezed
class TodoCategoryEntity with _$TodoCategoryEntity {
  const factory TodoCategoryEntity({
    required String id,
    required String name,
    String? emoji,
    required DateTime createdAt,
  }) = _TodoCategoryEntity;
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/domain/entities/todo_category_entity.dart
git commit -m "feat: TodoCategoryEntity 도메인 엔티티 추가"
```

---

### Task 3: TodoRepository 인터페이스 생성

**Files:**

- Create: `lib/features/todo/domain/repositories/todo_repository.dart`

**Step 1: 인터페이스 파일 생성**

```dart
import '../entities/todo_entity.dart';
import '../entities/todo_category_entity.dart';

abstract class TodoRepository {
  // 할일
  Future<List<TodoEntity>> getTodoList({String? categoryId});
  Future<TodoEntity> createTodo({
    required String title,
    String? categoryId,
    int? estimatedMinutes,
  });
  Future<TodoEntity> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(String id);

  // 카테고리
  Future<List<TodoCategoryEntity>> getCategories();
  Future<TodoCategoryEntity> createCategory({
    required String name,
    String? emoji,
  });
  Future<void> deleteCategory(String id);

  // 전체 삭제 (로그아웃 시)
  Future<void> clearAll();
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/domain/repositories/todo_repository.dart
git commit -m "feat: TodoRepository 인터페이스 추가"
```

---

### Task 4: Todo UseCases 생성

**Files:**

- Create: `lib/features/todo/domain/usecases/get_todo_list_usecase.dart`
- Create: `lib/features/todo/domain/usecases/create_todo_usecase.dart`
- Create: `lib/features/todo/domain/usecases/update_todo_usecase.dart`
- Create: `lib/features/todo/domain/usecases/delete_todo_usecase.dart`

**Step 1: GetTodoListUseCase**

```dart
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodoListUseCase {
  final TodoRepository _repository;

  GetTodoListUseCase(this._repository);

  Future<List<TodoEntity>> execute({String? categoryId}) {
    return _repository.getTodoList(categoryId: categoryId);
  }
}
```

**Step 2: CreateTodoUseCase**

```dart
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class CreateTodoUseCase {
  final TodoRepository _repository;

  CreateTodoUseCase(this._repository);

  Future<TodoEntity> execute({
    required String title,
    String? categoryId,
    int? estimatedMinutes,
  }) {
    return _repository.createTodo(
      title: title,
      categoryId: categoryId,
      estimatedMinutes: estimatedMinutes,
    );
  }
}
```

**Step 3: UpdateTodoUseCase**

```dart
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoUseCase {
  final TodoRepository _repository;

  UpdateTodoUseCase(this._repository);

  Future<TodoEntity> execute(TodoEntity todo) {
    return _repository.updateTodo(todo);
  }
}
```

**Step 4: DeleteTodoUseCase**

```dart
import '../repositories/todo_repository.dart';

class DeleteTodoUseCase {
  final TodoRepository _repository;

  DeleteTodoUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteTodo(id);
  }
}
```

**Step 5: Commit**

```bash
git add lib/features/todo/domain/usecases/
git commit -m "feat: Todo CRUD UseCase 추가"
```

---

### Task 5: Category UseCases 생성

**Files:**

- Create: `lib/features/todo/domain/usecases/get_categories_usecase.dart`
- Create: `lib/features/todo/domain/usecases/create_category_usecase.dart`
- Create: `lib/features/todo/domain/usecases/delete_category_usecase.dart`

**Step 1: GetCategoriesUseCase**

```dart
import '../entities/todo_category_entity.dart';
import '../repositories/todo_repository.dart';

class GetCategoriesUseCase {
  final TodoRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<List<TodoCategoryEntity>> execute() {
    return _repository.getCategories();
  }
}
```

**Step 2: CreateCategoryUseCase**

```dart
import '../entities/todo_category_entity.dart';
import '../repositories/todo_repository.dart';

class CreateCategoryUseCase {
  final TodoRepository _repository;

  CreateCategoryUseCase(this._repository);

  Future<TodoCategoryEntity> execute({
    required String name,
    String? emoji,
  }) {
    return _repository.createCategory(name: name, emoji: emoji);
  }
}
```

**Step 3: DeleteCategoryUseCase**

```dart
import '../repositories/todo_repository.dart';

class DeleteCategoryUseCase {
  final TodoRepository _repository;

  DeleteCategoryUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteCategory(id);
  }
}
```

**Step 4: Commit**

```bash
git add lib/features/todo/domain/usecases/
git commit -m "feat: Category CRUD UseCase 추가"
```

---

## Phase 2: 데이터 레이어 (SharedPreferences + JSON 직렬화)

### Task 6: TodoModel 생성 (DTO + 변환 확장)

**Files:**

- Create: `lib/features/todo/data/models/todo_model.dart`

**Step 1: Model 파일 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo_entity.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    @Default(false) bool completed,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'estimated_minutes') int? estimatedMinutes,
    @JsonKey(name: 'actual_minutes') int? actualMinutes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
}

extension TodoModelX on TodoModel {
  TodoEntity toEntity() => TodoEntity(
        id: id,
        title: title,
        completed: completed,
        categoryId: categoryId,
        estimatedMinutes: estimatedMinutes,
        actualMinutes: actualMinutes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension TodoEntityToModelX on TodoEntity {
  TodoModel toModel() => TodoModel(
        id: id,
        title: title,
        completed: completed,
        categoryId: categoryId,
        estimatedMinutes: estimatedMinutes,
        actualMinutes: actualMinutes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/data/models/todo_model.dart
git commit -m "feat: TodoModel DTO 및 변환 확장 추가"
```

---

### Task 7: TodoCategoryModel 생성 (DTO + 변환 확장)

**Files:**

- Create: `lib/features/todo/data/models/todo_category_model.dart`

**Step 1: Model 파일 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo_category_entity.dart';

part 'todo_category_model.freezed.dart';
part 'todo_category_model.g.dart';

@freezed
class TodoCategoryModel with _$TodoCategoryModel {
  const factory TodoCategoryModel({
    required String id,
    required String name,
    String? emoji,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TodoCategoryModel;

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TodoCategoryModelFromJson(json);
}

extension TodoCategoryModelX on TodoCategoryModel {
  TodoCategoryEntity toEntity() => TodoCategoryEntity(
        id: id,
        name: name,
        emoji: emoji,
        createdAt: createdAt,
      );
}

extension TodoCategoryEntityToModelX on TodoCategoryEntity {
  TodoCategoryModel toModel() => TodoCategoryModel(
        id: id,
        name: name,
        emoji: emoji,
        createdAt: createdAt,
      );
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/data/models/todo_category_model.dart
git commit -m "feat: TodoCategoryModel DTO 및 변환 확장 추가"
```

---

### Task 8: 코드 생성 (build_runner)

**Step 1: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `.freezed.dart` 및 `.g.dart` 파일이 생성됨

- `todo_entity.freezed.dart`
- `todo_category_entity.freezed.dart`
- `todo_model.freezed.dart`, `todo_model.g.dart`
- `todo_category_model.freezed.dart`, `todo_category_model.g.dart`

**Step 2: Commit 생성 파일**

```bash
git add lib/features/todo/
git commit -m "chore: Todo 도메인/데이터 모델 코드 생성"
```

---

### Task 9: LocalTodoDataSource 생성

**Files:**

- Create: `lib/features/todo/data/datasources/local_todo_datasource.dart`

**Step 1: DataSource 구현**

SharedPreferences에서 JSON 문자열로 Todo와 Category를 읽고 쓰는 클래스.

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_model.dart';
import '../models/todo_category_model.dart';

class LocalTodoDataSource {
  static const _todosKey = 'guest_todos';
  static const _categoriesKey = 'guest_todo_categories';

  final SharedPreferences _prefs;

  LocalTodoDataSource(this._prefs);

  // === Todos ===

  List<TodoModel> getTodos() {
    final jsonString = _prefs.getString(_todosKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTodos(List<TodoModel> todos) async {
    final jsonString = json.encode(todos.map((e) => e.toJson()).toList());
    await _prefs.setString(_todosKey, jsonString);
  }

  // === Categories ===

  List<TodoCategoryModel> getCategories() {
    final jsonString = _prefs.getString(_categoriesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => TodoCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<TodoCategoryModel> categories) async {
    final jsonString =
        json.encode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_categoriesKey, jsonString);
  }

  // === Clear ===

  Future<void> clearAll() async {
    await _prefs.remove(_todosKey);
    await _prefs.remove(_categoriesKey);
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/data/datasources/local_todo_datasource.dart
git commit -m "feat: LocalTodoDataSource SharedPreferences 구현"
```

---

### Task 10: LocalTodoRepositoryImpl 생성

**Files:**

- Create: `lib/features/todo/data/repositories/local_todo_repository_impl.dart`

**Step 1: Repository 구현**

```dart
import 'package:uuid/uuid.dart';

import '../../domain/entities/todo_category_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local_todo_datasource.dart';
import '../models/todo_category_model.dart';
import '../models/todo_model.dart';

class LocalTodoRepositoryImpl implements TodoRepository {
  final LocalTodoDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  LocalTodoRepositoryImpl(this._dataSource);

  // === 할일 ===

  @override
  Future<List<TodoEntity>> getTodoList({String? categoryId}) async {
    final models = _dataSource.getTodos();
    final filtered = categoryId != null
        ? models.where((m) => m.categoryId == categoryId).toList()
        : models;
    return filtered.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    String? categoryId,
    int? estimatedMinutes,
  }) async {
    final now = DateTime.now();
    final model = TodoModel(
      id: _uuid.v4(),
      title: title,
      categoryId: categoryId,
      estimatedMinutes: estimatedMinutes,
      createdAt: now,
      updatedAt: now,
    );

    final todos = _dataSource.getTodos();
    todos.add(model);
    await _dataSource.saveTodos(todos);

    return model.toEntity();
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    final todos = _dataSource.getTodos();
    final index = todos.indexWhere((m) => m.id == todo.id);
    if (index == -1) throw Exception('Todo not found: ${todo.id}');

    final updated = todo.copyWith(updatedAt: DateTime.now()).toModel();
    todos[index] = updated;
    await _dataSource.saveTodos(todos);

    return updated.toEntity();
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = _dataSource.getTodos();
    todos.removeWhere((m) => m.id == id);
    await _dataSource.saveTodos(todos);
  }

  // === 카테고리 ===

  @override
  Future<List<TodoCategoryEntity>> getCategories() async {
    return _dataSource.getCategories().map((m) => m.toEntity()).toList();
  }

  @override
  Future<TodoCategoryEntity> createCategory({
    required String name,
    String? emoji,
  }) async {
    final model = TodoCategoryModel(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      createdAt: DateTime.now(),
    );

    final categories = _dataSource.getCategories();
    categories.add(model);
    await _dataSource.saveCategories(categories);

    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(String id) async {
    // 1. 소속 할일의 categoryId를 null로 변경 (미분류로 이동)
    final todos = _dataSource.getTodos();
    final updatedTodos = todos.map((t) {
      if (t.categoryId == id) {
        return t.copyWith(categoryId: null);
      }
      return t;
    }).toList();
    await _dataSource.saveTodos(updatedTodos);

    // 2. 카테고리 삭제
    final categories = _dataSource.getCategories();
    categories.removeWhere((c) => c.id == id);
    await _dataSource.saveCategories(categories);
  }

  // === 전체 삭제 ===

  @override
  Future<void> clearAll() async {
    await _dataSource.clearAll();
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/data/repositories/local_todo_repository_impl.dart
git commit -m "feat: LocalTodoRepositoryImpl 구현"
```

---

## Phase 3: 프레젠테이션 레이어 - Providers

### Task 11: Todo Providers 생성

**Files:**

- Create: `lib/features/todo/presentation/providers/todo_provider.dart`

**Step 1: Provider 파일 생성**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local_todo_datasource.dart';
import '../../data/repositories/local_todo_repository_impl.dart';
import '../../domain/entities/todo_category_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/create_todo_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_todo_list_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';

part 'todo_provider.g.dart';

// === DataSource & Repository ===

@riverpod
LocalTodoDataSource localTodoDataSource(Ref ref) {
  throw UnimplementedError('SharedPreferences override 필요');
}

@riverpod
TodoRepository todoRepository(Ref ref) {
  final dataSource = ref.watch(localTodoDataSourceProvider);
  return LocalTodoRepositoryImpl(dataSource);
}

// === UseCases ===

@riverpod
GetTodoListUseCase getTodoListUseCase(Ref ref) {
  return GetTodoListUseCase(ref.watch(todoRepositoryProvider));
}

@riverpod
CreateTodoUseCase createTodoUseCase(Ref ref) {
  return CreateTodoUseCase(ref.watch(todoRepositoryProvider));
}

@riverpod
UpdateTodoUseCase updateTodoUseCase(Ref ref) {
  return UpdateTodoUseCase(ref.watch(todoRepositoryProvider));
}

@riverpod
DeleteTodoUseCase deleteTodoUseCase(Ref ref) {
  return DeleteTodoUseCase(ref.watch(todoRepositoryProvider));
}

@riverpod
GetCategoriesUseCase getCategoriesUseCase(Ref ref) {
  return GetCategoriesUseCase(ref.watch(todoRepositoryProvider));
}

@riverpod
CreateCategoryUseCase createCategoryUseCase(Ref ref) {
  return CreateCategoryUseCase(ref.watch(todoRepositoryProvider));
}

@riverpod
DeleteCategoryUseCase deleteCategoryUseCase(Ref ref) {
  return DeleteCategoryUseCase(ref.watch(todoRepositoryProvider));
}

// === Todo 상태 관리 ===

@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  FutureOr<List<TodoEntity>> build() async {
    final useCase = ref.read(getTodoListUseCaseProvider);
    return useCase.execute();
  }

  Future<void> addTodo({
    required String title,
    String? categoryId,
    int? estimatedMinutes,
  }) async {
    final useCase = ref.read(createTodoUseCaseProvider);
    await useCase.execute(
      title: title,
      categoryId: categoryId,
      estimatedMinutes: estimatedMinutes,
    );
    ref.invalidateSelf();
  }

  Future<void> toggleTodo(TodoEntity todo) async {
    final useCase = ref.read(updateTodoUseCaseProvider);
    await useCase.execute(todo.copyWith(completed: !todo.completed));
    ref.invalidateSelf();
  }

  Future<void> updateTodo(TodoEntity todo) async {
    final useCase = ref.read(updateTodoUseCaseProvider);
    await useCase.execute(todo);
    ref.invalidateSelf();
  }

  Future<void> deleteTodo(String id) async {
    final useCase = ref.read(deleteTodoUseCaseProvider);
    await useCase.execute(id);
    ref.invalidateSelf();
  }
}

// === 카테고리 상태 관리 ===

@riverpod
class CategoryListNotifier extends _$CategoryListNotifier {
  @override
  FutureOr<List<TodoCategoryEntity>> build() async {
    final useCase = ref.read(getCategoriesUseCaseProvider);
    return useCase.execute();
  }

  Future<void> addCategory({required String name, String? emoji}) async {
    final useCase = ref.read(createCategoryUseCaseProvider);
    await useCase.execute(name: name, emoji: emoji);
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(String id) async {
    final useCase = ref.read(deleteCategoryUseCaseProvider);
    await useCase.execute(id);
    ref.invalidateSelf();
    // 카테고리 삭제 시 할일 목록도 갱신
    ref.invalidate(todoListNotifierProvider);
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/presentation/providers/todo_provider.dart
git commit -m "feat: Todo Riverpod Provider 추가"
```

---

### Task 12: 코드 생성 + SharedPreferences Override 설정

**Step 1: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `todo_provider.g.dart` 생성

**Step 2: main.dart에서 SharedPreferences override 확인**

`main.dart` (또는 앱 진입점)에서 `ProviderScope`의 `overrides`에 `localTodoDataSourceProvider`를 override해야 합니다.

현재 `main.dart`를 확인하여 SharedPreferences 초기화 위치를 파악하고, override를 추가합니다.

```dart
// main.dart의 ProviderScope overrides에 추가:
final prefs = await SharedPreferences.getInstance();

ProviderScope(
  overrides: [
    localTodoDataSourceProvider.overrideWithValue(
      LocalTodoDataSource(prefs),
    ),
  ],
  child: const App(),
)
```

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/providers/
git add lib/main.dart
git commit -m "feat: Todo Provider 코드 생성 및 SharedPreferences override 설정"
```

---

## Phase 4: 프레젠테이션 레이어 - UI

### Task 13: TodoAddBottomSheet 위젯 생성

**Files:**

- Create: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**Step 1: 바텀시트 위젯 구현**

할일 추가 바텀시트. 제목 입력 (필수) + 예상 시간 입력 (선택).
기존 `SpaceshipSelector` 바텀시트 패턴을 따릅니다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';

class TodoAddBottomSheet extends StatefulWidget {
  const TodoAddBottomSheet({super.key});

  @override
  State<TodoAddBottomSheet> createState() => _TodoAddBottomSheetState();
}

class _TodoAddBottomSheetState extends State<TodoAddBottomSheet> {
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final minutes = int.tryParse(_minutesController.text.trim());

    Navigator.of(context).pop({
      'title': title,
      'estimatedMinutes': minutes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // 제목
            Padding(
              padding: AppPadding.screenPadding,
              child: Text(
                '할 일 추가',
                style:
                    AppTextStyles.subHeading_18.copyWith(color: Colors.white),
              ),
            ),

            // 입력 필드
            Padding(
              padding: AppPadding.horizontal20,
              child: AppTextField(
                controller: _titleController,
                hintText: '할 일을 입력하세요',
                onSubmitted: (_) => _submit(),
                autofocus: true,
              ),
            ),
            SizedBox(height: AppSpacing.s12),

            Padding(
              padding: AppPadding.horizontal20,
              child: AppTextField(
                controller: _minutesController,
                hintText: '예상 시간 (분, 선택)',
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _submit(),
              ),
            ),
            SizedBox(height: AppSpacing.s20),

            // 추가 버튼
            Padding(
              padding: AppPadding.horizontal20,
              child: AppButton(
                text: '추가하기',
                onPressed: _titleController.text.trim().isEmpty
                    ? null
                    : _submit,
                width: double.infinity,
              ),
            ),

            SizedBox(
                height: MediaQuery.of(context).padding.bottom + 20.h),
          ],
        ),
      ),
    );
  }
}

/// 할일 추가 바텀시트를 표시하는 헬퍼 함수
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => const TodoAddBottomSheet(),
  );
}
```

> **주의**: `AppButton`의 `onPressed`가 null이면 disabled 상태. `_titleController`에 리스너를 달아서 빈 값일 때 disabled 처리해야 할 수 있음 → `initState`에서 `_titleController.addListener(() => setState(() {}))` 추가 필요.

**Step 2: Commit**

```bash
git add lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart
git commit -m "feat: TodoAddBottomSheet 바텀시트 위젯 추가"
```

---

### Task 14: HomeScreen 통합 - 하드코딩 → Provider 교체

**Files:**

- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**핵심 변경사항:**

1. `StatefulWidget` → `ConsumerStatefulWidget`로 변경 (Riverpod 연동)
2. 하드코딩된 `_todos` 리스트 제거
3. `todoListNotifierProvider`로 데이터 바인딩
4. 할일 추가 바텀시트 연동
5. 스와이프 삭제 (`Dismissible`) 추가
6. 완료 토글을 Provider 메서드로 교체

**Step 1: import 추가 및 클래스 변경**

파일 상단에 추가:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../todo/presentation/providers/todo_provider.dart';
import '../../../todo/presentation/widgets/todo_add_bottom_sheet.dart';
```

`StatefulWidget` → `ConsumerStatefulWidget`:

```dart
class HomeScreen extends ConsumerStatefulWidget {
  // ...
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ...
}
```

**Step 2: `_todos` 하드코딩 제거**

`_todos` 필드(lines 42-48)를 삭제. 대신 build 내에서 Provider 데이터 사용:

```dart
final todosAsync = ref.watch(todoListNotifierProvider);
```

**Step 3: 접힌 상태 업데이트**

`_buildCollapsedSheet`의 미완료 개수를 Provider에서 계산:

```dart
final todosAsync = ref.watch(todoListNotifierProvider);
final pendingCount = todosAsync.valueOrNull
    ?.where((t) => !t.completed)
    .length ?? 0;
```

**Step 4: 펼친 상태 업데이트**

`_buildExpandedSheet`에서 TodoItem을 Provider 데이터로 교체:

```dart
final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
final previewTodos = todos.take(3).toList();
```

TodoItem 사용:

```dart
Dismissible(
  key: Key(todo.id),
  direction: DismissDirection.endToStart,
  background: Container(
    alignment: Alignment.centerRight,
    padding: AppPadding.horizontal20,
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.2),
      borderRadius: AppRadius.large,
    ),
    child: Icon(Icons.delete_outline, color: AppColors.error, size: 24.w),
  ),
  onDismissed: (_) {
    ref.read(todoListNotifierProvider.notifier).deleteTodo(todo.id);
  },
  child: TodoItem(
    title: todo.title,
    subtitle: todo.estimatedMinutes != null
        ? '${todo.estimatedMinutes}분'
        : null,
    isCompleted: todo.completed,
    onToggle: () {
      ref.read(todoListNotifierProvider.notifier).toggleTodo(todo);
    },
  ),
)
```

**Step 5: 할일 추가 버튼**

섹션 타이틀 옆에 추가 버튼:

```dart
Row(
  children: [
    Text('오늘의 할 일', style: AppTextStyles.subHeading_18.copyWith(color: Colors.white)),
    const Spacer(),
    GestureDetector(
      onTap: () async {
        final result = await showTodoAddBottomSheet(context: context);
        if (result != null) {
          ref.read(todoListNotifierProvider.notifier).addTodo(
            title: result['title'] as String,
            estimatedMinutes: result['estimatedMinutes'] as int?,
          );
        }
      },
      child: Icon(Icons.add_rounded, color: AppColors.primary, size: 24.w),
    ),
  ],
)
```

**Step 6: Commit**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat: HomeScreen 할일 데이터를 Provider로 교체"
```

---

### Task 15: 로그아웃 시 Todo 데이터 삭제 연동

**Files:**

- Modify: `lib/features/auth/presentation/providers/auth_provider.dart` (lines 293-301)

**Step 1: signOut 메서드에 Todo clearAll 추가**

게스트 모드 signOut 블록에 Todo 데이터 삭제 추가:

```dart
// 기존 코드 (lines 296-301):
if (currentUser?.isGuest == true) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(kIsGuestKey);
  debugPrint('🧹 게스트 캐시 삭제 완료 ($kIsGuestKey)');
  state = const AsyncValue.data(null);
  return;
}

// 변경 후:
if (currentUser?.isGuest == true) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(kIsGuestKey);

  // 게스트 할일 데이터 삭제
  final todoRepo = ref.read(todoRepositoryProvider);
  await todoRepo.clearAll();
  debugPrint('🧹 게스트 캐시 삭제 완료 ($kIsGuestKey, todos, categories)');

  state = const AsyncValue.data(null);
  return;
}
```

import 추가:

```dart
import '../../../todo/presentation/providers/todo_provider.dart';
```

**Step 2: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "feat: 게스트 로그아웃 시 Todo 데이터 삭제 연동"
```

---

### Task 16: flutter analyze 검증

**Step 1: 정적 분석 실행**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 2: 빌드 확인**

```bash
flutter build apk --debug 2>&1 | tail -5
```

Expected: 빌드 성공

---

## Phase 5: TodoListScreen + 카테고리 관리 (선택적 확장)

### Task 17: CategoryFolderCard 위젯 생성

**Files:**

- Create: `lib/features/todo/presentation/widgets/category_folder_card.dart`

**Step 1: 카테고리 폴더 카드 위젯**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';

class CategoryFolderCard extends StatefulWidget {
  const CategoryFolderCard({
    super.key,
    required this.name,
    this.emoji,
    required this.todoCount,
    required this.completedCount,
    required this.onTap,
    this.onDelete,
  });

  final String name;
  final String? emoji;
  final int todoCount;
  final int completedCount;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  State<CategoryFolderCard> createState() => _CategoryFolderCardState();
}

class _CategoryFolderCardState extends State<CategoryFolderCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Container(
          padding: AppPadding.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.spaceDivider),
          ),
          child: Row(
            children: [
              // 이모지/아이콘
              Text(
                widget.emoji ?? '📁',
                style: TextStyle(fontSize: 24.sp),
              ),
              SizedBox(width: AppSpacing.s12),

              // 이름 + 진행 상황
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppTextStyles.label_16
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Text(
                      '${widget.completedCount}/${widget.todoCount} 완료',
                      style: AppTextStyles.tag_12
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),

              // 삭제
              if (widget.onDelete != null)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Padding(
                    padding: AppPadding.all8,
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 20.w,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

              Icon(
                Icons.chevron_right_rounded,
                size: 20.w,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/todo/presentation/widgets/category_folder_card.dart
git commit -m "feat: CategoryFolderCard 위젯 추가"
```

---

### Task 18: TodoListScreen 생성

**Files:**

- Create: `lib/features/todo/presentation/screens/todo_list_screen.dart`
- Modify: `lib/routes/app_router.dart` (lines 159-163 — PlaceholderScreen 교체)

**Step 1: TodoListScreen 구현**

카테고리별 폴더 + 미분류 할일 표시. ConsumerWidget 사용.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_folder_card.dart';
import '../widgets/todo_add_bottom_sheet.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '오늘의 할 일',
          style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showTodoAddBottomSheet(context: context);
              if (result != null) {
                ref.read(todoListNotifierProvider.notifier).addTodo(
                      title: result['title'] as String,
                      estimatedMinutes: result['estimatedMinutes'] as int?,
                    );
              }
            },
            icon: Icon(Icons.add_rounded, size: 24.w),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          todosAsync.when(
            data: (todos) {
              if (todos.isEmpty) {
                return Center(
                  child: SpaceEmptyState(
                    icon: Icons.edit_note_rounded,
                    title: '할 일이 없어요',
                    subtitle: '오른쪽 상단 + 버튼으로 추가해보세요',
                  ),
                );
              }

              return ListView.builder(
                padding: AppPadding.screenPadding,
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Dismissible(
                      key: Key(todo.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
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
                      onDismissed: (_) {
                        ref
                            .read(todoListNotifierProvider.notifier)
                            .deleteTodo(todo.id);
                      },
                      child: TodoItem(
                        title: todo.title,
                        subtitle: todo.estimatedMinutes != null
                            ? '${todo.estimatedMinutes}분'
                            : null,
                        isCompleted: todo.completed,
                        onToggle: () {
                          ref
                              .read(todoListNotifierProvider.notifier)
                              .toggleTodo(todo);
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Text(
                '오류: $error',
                style: AppTextStyles.label_16
                    .copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: app_router.dart에서 PlaceholderScreen → TodoListScreen 교체**

`lib/routes/app_router.dart` lines 159-163:

```dart
// 변경 전:
builder: (context, state) =>
    const PlaceholderScreen(title: '오늘의 할 일'),

// 변경 후:
builder: (context, state) => const TodoListScreen(),
```

import 추가:

```dart
import '../features/todo/presentation/screens/todo_list_screen.dart';
```

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/screens/todo_list_screen.dart
git add lib/routes/app_router.dart
git commit -m "feat: TodoListScreen 추가 및 라우터 연결"
```

---

### Task 19: 최종 검증

**Step 1: flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 2: build_runner 최종 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: 앱 실행 테스트**

```bash
flutter run
```

수동 테스트 체크리스트:

- [ ] 게스트 로그인 → 홈 화면 진입
- [ ] 오늘의 할 일 섹션에 빈 상태 표시
- [ ] - 버튼 → 바텀시트 → 할일 추가 → 리스트에 표시
- [ ] 할일 체크박스 토글 → 완료/미완료 전환
- [ ] 할일 스와이프 → 삭제
- [ ] 더보기 → TodoListScreen 이동
- [ ] TodoListScreen에서 할일 추가/토글/삭제
- [ ] 앱 종료 → 재시작 → 할일 데이터 유지 확인
- [ ] 로그아웃 → 재로그인 → 할일 데이터 초기화 확인

**Step 4: 최종 Commit**

```bash
git add -A
git commit -m "chore: 게스트 Todo 기능 최종 검증 완료"
```

---

## 파일 생성 요약

| Phase        | 파일                                                                  | 작업   |
| ------------ | --------------------------------------------------------------------- | ------ |
| Domain       | `lib/features/todo/domain/entities/todo_entity.dart`                  | Create |
| Domain       | `lib/features/todo/domain/entities/todo_category_entity.dart`         | Create |
| Domain       | `lib/features/todo/domain/repositories/todo_repository.dart`          | Create |
| Domain       | `lib/features/todo/domain/usecases/get_todo_list_usecase.dart`        | Create |
| Domain       | `lib/features/todo/domain/usecases/create_todo_usecase.dart`          | Create |
| Domain       | `lib/features/todo/domain/usecases/update_todo_usecase.dart`          | Create |
| Domain       | `lib/features/todo/domain/usecases/delete_todo_usecase.dart`          | Create |
| Domain       | `lib/features/todo/domain/usecases/get_categories_usecase.dart`       | Create |
| Domain       | `lib/features/todo/domain/usecases/create_category_usecase.dart`      | Create |
| Domain       | `lib/features/todo/domain/usecases/delete_category_usecase.dart`      | Create |
| Data         | `lib/features/todo/data/models/todo_model.dart`                       | Create |
| Data         | `lib/features/todo/data/models/todo_category_model.dart`              | Create |
| Data         | `lib/features/todo/data/datasources/local_todo_datasource.dart`       | Create |
| Data         | `lib/features/todo/data/repositories/local_todo_repository_impl.dart` | Create |
| Presentation | `lib/features/todo/presentation/providers/todo_provider.dart`         | Create |
| Presentation | `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`   | Create |
| Presentation | `lib/features/todo/presentation/widgets/category_folder_card.dart`    | Create |
| Presentation | `lib/features/todo/presentation/screens/todo_list_screen.dart`        | Create |
| Integration  | `lib/features/home/presentation/screens/home_screen.dart`             | Modify |
| Integration  | `lib/features/auth/presentation/providers/auth_provider.dart`         | Modify |
| Integration  | `lib/routes/app_router.dart`                                          | Modify |
| Integration  | `lib/main.dart`                                                       | Modify |
