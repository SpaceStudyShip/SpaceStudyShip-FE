import '../repositories/todo_repository.dart';

class DeleteCategoryUseCase {
  final TodoRepository _repository;

  DeleteCategoryUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteCategory(id);
  }
}
