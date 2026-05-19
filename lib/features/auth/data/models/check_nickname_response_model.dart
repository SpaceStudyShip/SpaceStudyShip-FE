import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_nickname_response_model.freezed.dart';
part 'check_nickname_response_model.g.dart';

/// 닉네임 중복 확인 응답 DTO
///
/// `GET /api/auth/check-nickname` 응답 (200).
/// `available: true` 면 사용 가능, `false` 면 이미 사용 중.
@freezed
class CheckNicknameResponseModel with _$CheckNicknameResponseModel {
  const factory CheckNicknameResponseModel({
    required bool available,
  }) = _CheckNicknameResponseModel;

  factory CheckNicknameResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CheckNicknameResponseModelFromJson(json);
}
