import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_category_entity.freezed.dart';

@freezed
class TodoCategoryEntity with _$TodoCategoryEntity {
  const factory TodoCategoryEntity({
    required String id,
    required String name,
    String? iconId,
    double? positionX,
    double? positionY,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TodoCategoryEntity;
}
