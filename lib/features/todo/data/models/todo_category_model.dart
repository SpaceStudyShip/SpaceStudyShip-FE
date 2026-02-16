// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo_category_entity.dart';

part 'todo_category_model.freezed.dart';
part 'todo_category_model.g.dart';

@freezed
class TodoCategoryModel with _$TodoCategoryModel {
  const factory TodoCategoryModel({
    required String id,
    required String name,
    String? emoji,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _TodoCategoryModel;

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TodoCategoryModelFromJson(json);
}

extension TodoCategoryModelX on TodoCategoryModel {
  TodoCategoryEntity toEntity() => TodoCategoryEntity(
    id: id,
    name: name,
    emoji: emoji,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension TodoCategoryEntityToModelX on TodoCategoryEntity {
  TodoCategoryModel toModel() => TodoCategoryModel(
    id: id,
    name: name,
    emoji: emoji,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
