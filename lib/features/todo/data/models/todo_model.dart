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
    @JsonKey(name: 'scheduled_dates')
    @Default([])
    List<DateTime> scheduledDates,
    @JsonKey(name: 'completed_dates')
    @Default([])
    List<DateTime> completedDates,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'estimated_minutes') int? estimatedMinutes,
    @JsonKey(name: 'actual_minutes') int? actualMinutes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(_migrateJson(json));

  /// 기존 단일 날짜/bool 완료 형식 → 다중 날짜 형식 마이그레이션
  static Map<String, dynamic> _migrateJson(Map<String, dynamic> json) {
    final migrated = Map<String, dynamic>.from(json);

    // scheduled_date → scheduled_dates
    if (!migrated.containsKey('scheduled_dates') &&
        migrated.containsKey('scheduled_date')) {
      final oldDate = migrated['scheduled_date'];
      migrated['scheduled_dates'] = oldDate != null ? [oldDate] : [];
      migrated.remove('scheduled_date');
    }

    // completed (bool) → completed_dates (List)
    if (!migrated.containsKey('completed_dates') &&
        migrated.containsKey('completed')) {
      final wasCompleted = migrated['completed'] as bool? ?? false;
      if (wasCompleted) {
        final scheduledDates = migrated['scheduled_dates'] as List<dynamic>?;
        if (scheduledDates != null && scheduledDates.isNotEmpty) {
          migrated['completed_dates'] = List<dynamic>.from(scheduledDates);
        } else {
          migrated['completed_dates'] = [
            migrated['updated_at'] ?? DateTime.now().toIso8601String(),
          ];
        }
      } else {
        migrated['completed_dates'] = [];
      }
      migrated.remove('completed');
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
    scheduledDates: scheduledDates,
    completedDates: completedDates,
    categoryId: categoryId,
    estimatedMinutes: estimatedMinutes,
    actualMinutes: actualMinutes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
