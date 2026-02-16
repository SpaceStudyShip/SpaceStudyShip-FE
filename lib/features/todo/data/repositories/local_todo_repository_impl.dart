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
        ? models.where((m) => m.categoryId == categoryId).toList()
        : models;
    return filtered.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    String? categoryId,
    int? estimatedMinutes,
    List<DateTime>? scheduledDates,
  }) async {
    final now = DateTime.now();
    final model = TodoModel(
      id: _uuid.v4(),
      title: title,
      categoryId: categoryId,
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

  // === Clear ===

  @override
  Future<void> clearAll() async {
    await _dataSource.clearAll();
  }
}
