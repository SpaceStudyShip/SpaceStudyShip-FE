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
    String? iconId,
    double? positionX,
    double? positionY,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TodoCategoryModel;

  factory TodoCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TodoCategoryModelFromJson(_migrateJson(json));

  /// 구버전 SharedPreferences 캐시 (snake_case) → 현재 camelCase 키 변환.
  /// 이미 camelCase 가 존재하면 그쪽 우선.
  static Map<String, dynamic> _migrateJson(Map<String, dynamic> json) {
    final migrated = Map<String, dynamic>.from(json);
    const renames = {
      'icon_id': 'iconId',
      'position_x': 'positionX',
      'position_y': 'positionY',
      'created_at': 'createdAt',
      'updated_at': 'updatedAt',
    };
    for (final entry in renames.entries) {
      if (migrated.containsKey(entry.key) &&
          !migrated.containsKey(entry.value)) {
        migrated[entry.value] = migrated[entry.key];
        migrated.remove(entry.key);
      }
    }
    return migrated;
  }
}

extension TodoCategoryModelX on TodoCategoryModel {
  TodoCategoryEntity toEntity() => TodoCategoryEntity(
    id: id,
    name: name,
    iconId: iconId,
    positionX: positionX,
    positionY: positionY,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension TodoCategoryEntityToModelX on TodoCategoryEntity {
  TodoCategoryModel toModel() => TodoCategoryModel(
    id: id,
    name: name,
    iconId: iconId,
    positionX: positionX,
    positionY: positionY,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
