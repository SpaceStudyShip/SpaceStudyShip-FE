import '../entities/todo_category_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateCategoryUseCase {
  final TodoRepository _repository;

  UpdateCategoryUseCase(this._repository);

  Future<TodoCategoryEntity> execute(TodoCategoryEntity category) {
    return _repository.updateCategory(category);
  }
}
