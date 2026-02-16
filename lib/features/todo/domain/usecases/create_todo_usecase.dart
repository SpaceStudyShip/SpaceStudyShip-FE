import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class CreateTodoUseCase {
  final TodoRepository _repository;

  CreateTodoUseCase(this._repository);

  Future<TodoEntity> execute({
    required String title,
    String? categoryId,
    int? estimatedMinutes,
    List<DateTime>? scheduledDates,
  }) {
    return _repository.createTodo(
      title: title,
      categoryId: categoryId,
      estimatedMinutes: estimatedMinutes,
      scheduledDates: scheduledDates,
    );
  }
}
