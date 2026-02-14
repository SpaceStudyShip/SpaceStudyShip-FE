import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoUseCase {
  final TodoRepository _repository;

  UpdateTodoUseCase(this._repository);

  Future<TodoEntity> execute(TodoEntity todo) {
    return _repository.updateTodo(todo);
  }
}
