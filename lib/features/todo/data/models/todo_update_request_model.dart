// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_update_request_model.freezed.dart';
part 'todo_update_request_model.g.dart';

/// PATCH /api/todos/{todoId} 요청 본문
///
/// 전송하지 않은 필드는 기존 값 유지, 빈 배열은 명시적 모두 제거.
@Freezed(toJson: true, fromJson: false)
class TodoUpdateRequestModel with _$TodoUpdateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory TodoUpdateRequestModel({
    String? title,
    List<String>? scheduledDates,
    List<String>? completedDates,
    List<String>? categoryIds,
    int? estimatedMinutes,
    int? actualMinutes,
  }) = _TodoUpdateRequestModel;
}
