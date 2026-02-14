// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo_entity.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    @Default(false) bool completed,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'estimated_minutes') int? estimatedMinutes,
    @JsonKey(name: 'actual_minutes') int? actualMinutes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
}

extension TodoModelX on TodoModel {
  TodoEntity toEntity() => TodoEntity(
        id: id,
        title: title,
        completed: completed,
        categoryId: categoryId,
        estimatedMinutes: estimatedMinutes,
        actualMinutes: actualMinutes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension TodoEntityToModelX on TodoEntity {
  TodoModel toModel() => TodoModel(
        id: id,
        title: title,
        completed: completed,
        categoryId: categoryId,
        estimatedMinutes: estimatedMinutes,
        actualMinutes: actualMinutes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
