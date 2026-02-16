import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodoListUseCase {
  final TodoRepository _repository;

  GetTodoListUseCase(this._repository);

  Future<List<TodoEntity>> execute({String? categoryId}) {
    return _repository.getTodoList(categoryId: categoryId);
  }
}
