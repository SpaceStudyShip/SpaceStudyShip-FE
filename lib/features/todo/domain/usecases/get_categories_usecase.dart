import '../entities/todo_category_entity.dart';
import '../repositories/todo_repository.dart';

class GetCategoriesUseCase {
  final TodoRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<List<TodoCategoryEntity>> execute() {
    return _repository.getCategories();
  }
}
