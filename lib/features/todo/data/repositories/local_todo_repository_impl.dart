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

  // === Todos ===

  @override
  Future<List<TodoEntity>> getTodoList({String? categoryId}) async {
    final models = _dataSource.getTodos();
    final filtered = categoryId != null
        ? models.where((m) => m.categoryIds.contains(categoryId)).toList()
        : models;
    return filtered.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    List<String> categoryIds = const [],
    int? estimatedMinutes,
    List<DateTime>? scheduledDates,
  }) async {
    final now = DateTime.now();
    final model = TodoModel(
      id: _uuid.v4(),
      title: title,
      categoryIds: categoryIds,
      estimatedMinutes: estimatedMinutes,
      scheduledDates: scheduledDates ?? [],
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

  // === Categories ===

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
  Future<TodoCategoryEntity> updateCategory(TodoCategoryEntity category) async {
    final categories = _dataSource.getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index == -1) throw Exception('Category not found: ${category.id}');

    final updated = category.copyWith(updatedAt: DateTime.now()).toModel();
    categories[index] = updated;
    await _dataSource.saveCategories(categories);

    return updated.toEntity();
  }

  @override
  Future<void> deleteCategory(String id) async {
    // 1. 소속 할일의 categoryIds에서 해당 ID 제거
    final todos = _dataSource.getTodos();
    final updatedTodos = todos.map((t) {
      if (t.categoryIds.contains(id)) {
        return t.copyWith(
          categoryIds: t.categoryIds.where((cid) => cid != id).toList(),
        );
      }
      return t;
    }).toList();
    await _dataSource.saveTodos(updatedTodos);

    // 2. 카테고리 삭제
    final categories = _dataSource.getCategories();
    categories.removeWhere((c) => c.id == id);
    await _dataSource.saveCategories(categories);
  }

  // === Clear ===

  @override
  Future<void> clearAll() async {
    await _dataSource.clearAll();
  }
}
