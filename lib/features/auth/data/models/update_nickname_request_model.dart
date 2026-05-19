import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_nickname_request_model.freezed.dart';
part 'update_nickname_request_model.g.dart';

/// 닉네임 변경 요청 DTO
///
/// `PATCH /api/auth/nickname` 요청 바디.
/// 닉네임 규칙: 2~10자, 한글/영문 대소문자/숫자 (`^[가-힣a-zA-Z0-9]+$`)
@freezed
class UpdateNicknameRequestModel with _$UpdateNicknameRequestModel {
  const factory UpdateNicknameRequestModel({required String nickname}) =
      _UpdateNicknameRequestModel;

  factory UpdateNicknameRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateNicknameRequestModelFromJson(json);
}
