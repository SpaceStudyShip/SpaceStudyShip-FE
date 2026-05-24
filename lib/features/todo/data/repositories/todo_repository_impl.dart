import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/todo_category_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local_todo_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/category_create_request_model.dart';
import '../models/category_update_request_model.dart';
import '../models/todo_category_model.dart';
import '../models/todo_create_request_model.dart';
import '../models/todo_model.dart';
import '../models/todo_update_request_model.dart';

/// 서버 source of truth + 로컬 캐시 폴백
///
/// 동기화 큐·재시도는 후속 사이클.
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remote;
  final LocalTodoDataSource cache;
  final Uuid _uuid;

  TodoRepositoryImpl({
    required this.remote,
    required this.cache,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  // === Todos ===

  @override
  Future<List<TodoEntity>> getTodoList({DateTime? date, String? categoryId}) async {
    try {
      final models = await remote.getTodos(
        date: date != null ? _dateFmt.format(date) : null,
        categoryId: categoryId,
      );
      await cache.saveTodos(models);
      return models.map((m) => m.toEntity()).toList();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        return cache.getTodos().map((m) => m.toEntity()).toList();
      }
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    List<String> categoryIds = const [],
    int? estimatedMinutes,
    List<DateTime>? scheduledDates,
  }) async {
    try {
      final request = TodoCreateRequestModel(
        id: _uuid.v4(),
        title: title,
        categoryIds: categoryIds.isEmpty ? null : categoryIds,
        estimatedMinutes: estimatedMinutes,
        scheduledDates: scheduledDates?.map(_dateFmt.format).toList(),
      );
      final created = await remote.createTodo(request);
      final updated = [...cache.getTodos(), created];
      await cache.saveTodos(updated);
      return created.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    try {
      final request = TodoUpdateRequestModel(
        title: todo.title,
        scheduledDates: todo.scheduledDates.map(_dateFmt.format).toList(),
        completedDates: todo.completedDates.map(_dateFmt.format).toList(),
        categoryIds: todo.categoryIds,
        estimatedMinutes: todo.estimatedMinutes,
        actualMinutes: todo.actualMinutes,
      );
      final updated = await remote.updateTodo(todo.id, request);
      final cached = cache.getTodos();
      final replaced = cached.map((m) => m.id == updated.id ? updated : m).toList();
      await cache.saveTodos(replaced);
      return updated.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await remote.deleteTodo(id);
      final cached = cache.getTodos();
      await cache.saveTodos(cached.where((m) => m.id != id).toList());
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  // === Categories ===

  @override
  Future<List<TodoCategoryEntity>> getCategories() async {
    try {
      final models = await remote.getCategories();
      await cache.saveCategories(models);
      return models.map((m) => m.toEntity()).toList();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        return cache.getCategories().map((m) => m.toEntity()).toList();
      }
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoCategoryEntity> createCategory({
    required String name,
    String? iconId,
  }) async {
    try {
      final request = CategoryCreateRequestModel(
        id: _uuid.v4(),
        name: name,
        iconId: iconId,
      );
      final created = await remote.createCategory(request);
      await cache.saveCategories([...cache.getCategories(), created]);
      return created.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<TodoCategoryEntity> updateCategory(TodoCategoryEntity category) async {
    try {
      final request = CategoryUpdateRequestModel(
        name: category.name,
        iconId: category.iconId,
        positionX: category.positionX,
        positionY: category.positionY,
      );
      final updated = await remote.updateCategory(category.id, request);
      final cached = cache.getCategories();
      await cache.saveCategories(
        cached.map((c) => c.id == updated.id ? updated : c).toList(),
      );
      return updated.toEntity();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await remote.deleteCategory(id);
      // 서버가 연관 Todo 의 categoryIds 자동 제거. 로컬 캐시도 동일 정리.
      final cachedTodos = cache.getTodos().map((t) {
        if (t.categoryIds.contains(id)) {
          return t.copyWith(
            categoryIds: t.categoryIds.where((cid) => cid != id).toList(),
          );
        }
        return t;
      }).toList();
      await cache.saveTodos(cachedTodos);
      await cache.saveCategories(
        cache.getCategories().where((c) => c.id != id).toList(),
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<void> clearAll() async {
    await cache.clearAll();
  }

  // === Helpers ===

  /// 네트워크 실패 판정 (spec D-11): timeout/connection/unknown 만 폴백 대상
  static bool _isNetworkFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }
}
