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
    @Default([]) List<DateTime> scheduledDates,
    @Default([]) List<DateTime> completedDates,
    @Default([]) List<String> categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(_migrateJson(json));

  /// 구버전 캐시 마이그레이션:
  /// - snake_case 키 → camelCase 키 (서버 응답은 camelCase 이므로 SharedPreferences 캐시 호환용)
  /// - 단일 scheduledDate → 배열 scheduledDates
  /// - bool completed → List completedDates
  /// - 단일 categoryId → 배열 categoryIds
  static Map<String, dynamic> _migrateJson(Map<String, dynamic> json) {
    final migrated = Map<String, dynamic>.from(json);

    // 0) snake_case → camelCase 키 변환 (구버전 SharedPreferences 캐시 호환)
    const renames = {
      'scheduled_dates': 'scheduledDates',
      'completed_dates': 'completedDates',
      'category_ids': 'categoryIds',
      'estimated_minutes': 'estimatedMinutes',
      'actual_minutes': 'actualMinutes',
      'created_at': 'createdAt',
      'updated_at': 'updatedAt',
      'scheduled_date': 'scheduledDate', // 더 옛 형식 (단일)
      'category_id': 'categoryId',
    };
    for (final entry in renames.entries) {
      if (migrated.containsKey(entry.key) &&
          !migrated.containsKey(entry.value)) {
        migrated[entry.value] = migrated[entry.key];
        migrated.remove(entry.key);
      }
    }

    // 1) scheduledDate (단일) → scheduledDates (배열)
    if (!migrated.containsKey('scheduledDates') &&
        migrated.containsKey('scheduledDate')) {
      final oldDate = migrated['scheduledDate'];
      migrated['scheduledDates'] = oldDate != null ? [oldDate] : [];
      migrated.remove('scheduledDate');
    }

    // 2) completed (bool) → completedDates (배열)
    if (!migrated.containsKey('completedDates') &&
        migrated.containsKey('completed')) {
      final wasCompleted = migrated['completed'] as bool? ?? false;
      if (wasCompleted) {
        final scheduledDates = migrated['scheduledDates'] as List<dynamic>?;
        if (scheduledDates != null && scheduledDates.isNotEmpty) {
          migrated['completedDates'] = List<dynamic>.from(scheduledDates);
        } else {
          migrated['completedDates'] = [
            migrated['updatedAt'] ?? DateTime.now().toIso8601String(),
          ];
        }
      } else {
        migrated['completedDates'] = [];
      }
      migrated.remove('completed');
    }

    // 3) categoryId (단일) → categoryIds (배열)
    if (!migrated.containsKey('categoryIds') &&
        migrated.containsKey('categoryId')) {
      final oldId = migrated['categoryId'] as String?;
      migrated['categoryIds'] = oldId != null ? [oldId] : <String>[];
      migrated.remove('categoryId');
    }

    return migrated;
  }
}

extension TodoModelX on TodoModel {
  TodoEntity toEntity() => TodoEntity(
    id: id,
    title: title,
    scheduledDates: scheduledDates,
    completedDates: completedDates,
    categoryIds: categoryIds,
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
    scheduledDates: scheduledDates,
    completedDates: completedDates,
    categoryIds: categoryIds,
    estimatedMinutes: estimatedMinutes,
    actualMinutes: actualMinutes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
