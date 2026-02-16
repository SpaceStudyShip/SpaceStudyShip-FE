import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    final previousState = state;
    // 낙관적 업데이트: Loading 없이 즉시 리스트에서 제거
    state = AsyncData(
      state.valueOrNull?.where((t) => t.id != id).toList() ?? [],
    );
    try {
      final useCase = ref.read(deleteTodoUseCaseProvider);
      await useCase.execute(id);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

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
    ref.invalidate(todoListNotifierProvider);
  }

  Future<void> deleteCategories(List<String> ids) async {
    final useCase = ref.read(deleteCategoryUseCaseProvider);
    for (final id in ids) {
      await useCase.execute(id);
    }
    ref.invalidateSelf();
    ref.invalidate(todoListNotifierProvider);
  }
}
