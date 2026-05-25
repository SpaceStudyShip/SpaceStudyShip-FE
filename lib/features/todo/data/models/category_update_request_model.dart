// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_update_request_model.freezed.dart';
part 'category_update_request_model.g.dart';

/// PATCH /api/todo-categories/{categoryId} 요청 본문
///
/// 전송하지 않은 필드는 기존 값 유지.
@Freezed(toJson: true, fromJson: false)
class CategoryUpdateRequestModel with _$CategoryUpdateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory CategoryUpdateRequestModel({
    String? name,
    String? iconId,
    double? positionX,
    double? positionY,
  }) = _CategoryUpdateRequestModel;
}
