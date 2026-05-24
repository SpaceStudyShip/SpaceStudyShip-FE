// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_create_request_model.freezed.dart';
part 'todo_create_request_model.g.dart';

/// POST /api/todos 요청 본문
@Freezed(toJson: true, fromJson: false)
class TodoCreateRequestModel with _$TodoCreateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory TodoCreateRequestModel({
    String? id,
    required String title,
    List<String>? categoryIds,
    int? estimatedMinutes,
    List<String>? scheduledDates, // YYYY-MM-DD
  }) = _TodoCreateRequestModel;
}
