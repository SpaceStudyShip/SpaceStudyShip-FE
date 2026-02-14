import '../repositories/todo_repository.dart';

class DeleteTodoUseCase {
  final TodoRepository _repository;

  DeleteTodoUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteTodo(id);
  }
}
