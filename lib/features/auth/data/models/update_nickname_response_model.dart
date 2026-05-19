import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_nickname_response_model.freezed.dart';
part 'update_nickname_response_model.g.dart';

/// 닉네임 변경 응답 DTO
///
/// `PATCH /api/auth/nickname` 응답 (200). 변경된 닉네임을 반환.
@freezed
class UpdateNicknameResponseModel with _$UpdateNicknameResponseModel {
  const factory UpdateNicknameResponseModel({required String nickname}) =
      _UpdateNicknameResponseModel;

  factory UpdateNicknameResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateNicknameResponseModelFromJson(json);
}
