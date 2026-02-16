import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_entity.freezed.dart';

@freezed
class TodoEntity with _$TodoEntity {
  const TodoEntity._();

  const factory TodoEntity({
    required String id,
    required String title,
    @Default([]) List<DateTime> scheduledDates,
    @Default([]) List<DateTime> completedDates,
    String? categoryId,
    int? estimatedMinutes,
    int? actualMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoEntity;

  static DateTime normalizeDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  bool isCompletedForDate(DateTime date) {
    final normalized = normalizeDate(date);
    return completedDates
        .any((d) => normalizeDate(d) == normalized);
  }

  bool get isFullyCompleted {
    if (scheduledDates.isEmpty) return completedDates.isNotEmpty;
    return scheduledDates.every((d) => isCompletedForDate(d));
  }
}
