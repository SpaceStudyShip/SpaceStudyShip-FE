import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_entity.freezed.dart';

@freezed
class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,
    required String title,
    @Default(false) bool completed,
    String? categoryId,
    int? estimatedMinutes,
    int? actualMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoEntity;
}
