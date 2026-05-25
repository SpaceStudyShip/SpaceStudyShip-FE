// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_create_request_model.freezed.dart';
part 'category_create_request_model.g.dart';

/// POST /api/todo-categories 요청 본문
@Freezed(toJson: true, fromJson: false)
class CategoryCreateRequestModel with _$CategoryCreateRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory CategoryCreateRequestModel({
    String? id,
    required String name,
    String? iconId,
    double? positionX,
    double? positionY,
  }) = _CategoryCreateRequestModel;
}
