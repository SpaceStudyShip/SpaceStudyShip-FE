import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class CreateTodoUseCase {
  final TodoRepository _repository;

  CreateTodoUseCase(this._repository);

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
}
