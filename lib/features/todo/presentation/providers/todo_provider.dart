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
  throw StateError(
    'LocalTodoDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
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
    List<DateTime>? scheduledDates,
  }) async {
    final useCase = ref.read(createTodoUseCaseProvider);
    await useCase.execute(
      title: title,
      categoryId: categoryId,
      estimatedMinutes: estimatedMinutes,
      scheduledDates: scheduledDates,
    );
    ref.invalidateSelf();
  }

  /// 특정 날짜의 완료 상태 토글
  Future<void> toggleTodoForDate(TodoEntity todo, DateTime date) async {
    final normalized = TodoEntity.normalizeDate(date);
    final isCompleted = todo.isCompletedForDate(date);
    final updatedCompletedDates = isCompleted
        ? todo.completedDates
              .where((d) => TodoEntity.normalizeDate(d) != normalized)
              .toList()
        : [...todo.completedDates, normalized];
    final toggled = todo.copyWith(completedDates: updatedCompletedDates);

    final previousState = state;
    state = AsyncData(
      state.valueOrNull?.map((t) => t.id == todo.id ? toggled : t).toList() ??
          [],
    );
    try {
      final useCase = ref.read(updateTodoUseCaseProvider);
      await useCase.execute(toggled);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateTodo(TodoEntity todo) async {
    final previousState = state;
    state = AsyncData(
      state.valueOrNull?.map((t) => t.id == todo.id ? todo : t).toList() ?? [],
    );
    try {
      final useCase = ref.read(updateTodoUseCaseProvider);
      await useCase.execute(todo);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  /// 특정 날짜만 제거 (scheduledDates + completedDates 에서 해당 날짜 제거)
  /// 날짜가 0개가 되면 할일 자체를 삭제한다.
  Future<void> removeDateFromTodo(TodoEntity todo, DateTime date) async {
    final normalized = TodoEntity.normalizeDate(date);
    final newScheduled = todo.scheduledDates
        .where((d) => TodoEntity.normalizeDate(d) != normalized)
        .toList();
    final newCompleted = todo.completedDates
        .where((d) => TodoEntity.normalizeDate(d) != normalized)
        .toList();

    if (newScheduled.isEmpty) {
      await deleteTodo(todo.id);
    } else {
      final updated = todo.copyWith(
        scheduledDates: newScheduled,
        completedDates: newCompleted,
      );
      await updateTodo(updated);
    }
  }

  /// 해당 날짜 이후 모두 제거 (해당 날짜 포함)
  /// 날짜가 0개가 되면 할일 자체를 삭제한다.
  Future<void> removeDateAndAfterFromTodo(
    TodoEntity todo,
    DateTime date,
  ) async {
    final normalized = TodoEntity.normalizeDate(date);
    final newScheduled = todo.scheduledDates
        .where((d) => TodoEntity.normalizeDate(d).isBefore(normalized))
        .toList();
    final newCompleted = todo.completedDates
        .where((d) => TodoEntity.normalizeDate(d).isBefore(normalized))
        .toList();

    if (newScheduled.isEmpty) {
      await deleteTodo(todo.id);
    } else {
      final updated = todo.copyWith(
        scheduledDates: newScheduled,
        completedDates: newCompleted,
      );
      await updateTodo(updated);
    }
  }

  Future<void> deleteTodo(String id) async {
    final previousState = state;
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
    final previousState = state;
    state = AsyncData(
      state.valueOrNull?.where((c) => c.id != id).toList() ?? [],
    );
    try {
      final useCase = ref.read(deleteCategoryUseCaseProvider);
      await useCase.execute(id);
      ref.invalidate(todoListNotifierProvider);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteCategories(List<String> ids) async {
    final previousState = state;
    state = AsyncData(
      state.valueOrNull?.where((c) => !ids.contains(c.id)).toList() ?? [],
    );
    try {
      final useCase = ref.read(deleteCategoryUseCaseProvider);
      for (final id in ids) {
        await useCase.execute(id);
      }
      ref.invalidate(todoListNotifierProvider);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

// === 날짜별 할일 필터 ===

@riverpod
List<TodoEntity> todosForDate(Ref ref, DateTime date) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  final normalizedDate = DateTime(date.year, date.month, date.day);
  return todos.where((t) {
    return t.scheduledDates.any((d) {
      final scheduled = DateTime(d.year, d.month, d.day);
      return scheduled == normalizedDate;
    });
  }).toList();
}

// === 미지정 할일 필터 ===

@riverpod
List<TodoEntity> unscheduledTodos(Ref ref) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  return todos.where((t) => t.scheduledDates.isEmpty).toList();
}

// === 날짜별 할일 맵 (캘린더 마커용) ===

@riverpod
Map<DateTime, List<TodoEntity>> todosByDateMap(Ref ref) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  final map = <DateTime, List<TodoEntity>>{};
  for (final todo in todos) {
    for (final date in todo.scheduledDates) {
      final key = DateTime(date.year, date.month, date.day);
      map.putIfAbsent(key, () => []).add(todo);
    }
  }
  return map;
}

// === 카테고리별 할일 필터 ===

@riverpod
List<TodoEntity> todosForCategory(Ref ref, String? categoryId) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  return todos.where((t) => t.categoryId == categoryId).toList();
}

// === 카테고리별 할일 통계 (Record: 구조적 동등성으로 불필요한 리빌드 방지) ===

@riverpod
({int todoCount, int completedCount}) categoryTodoStats(
  Ref ref,
  String? categoryId,
) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  final catTodos = todos.where((t) => t.categoryId == categoryId);
  return (
    todoCount: catTodos.length,
    completedCount: catTodos.where((t) => t.isFullyCompleted).length,
  );
}
