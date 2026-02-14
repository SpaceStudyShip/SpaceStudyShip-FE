import '../entities/todo_category_entity.dart';
import '../repositories/todo_repository.dart';

class CreateCategoryUseCase {
  final TodoRepository _repository;

  CreateCategoryUseCase(this._repository);

  Future<TodoCategoryEntity> execute({required String name, String? emoji}) {
    return _repository.createCategory(name: name, emoji: emoji);
  }
}
