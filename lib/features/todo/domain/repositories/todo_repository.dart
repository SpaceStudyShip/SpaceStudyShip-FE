import '../entities/todo_category_entity.dart';
import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodoList({String? categoryId});
  Future<TodoEntity> createTodo({
    required String title,
    String? categoryId,
    int? estimatedMinutes,
  });
  Future<TodoEntity> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(String id);

  Future<List<TodoCategoryEntity>> getCategories();
  Future<TodoCategoryEntity> createCategory({
    required String name,
    String? emoji,
  });
  Future<void> deleteCategory(String id);

  Future<void> clearAll();
}
