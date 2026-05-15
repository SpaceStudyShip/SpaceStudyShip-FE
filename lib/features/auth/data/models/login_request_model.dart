import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_model.freezed.dart';
part 'login_request_model.g.dart';

/// 소셜 로그인 요청 DTO
///
/// `POST /api/auth/login` 요청 바디
///
/// **필수 필드** (백엔드 OpenAPI 스펙 기준):
/// - [socialType]: 소셜 플랫폼 (`KAKAO`, `GOOGLE`, `APPLE`)
/// - [idToken]: Firebase ID Token
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    /// 소셜 플랫폼 (`KAKAO`, `GOOGLE`, `APPLE`)
    required String socialType,

    /// Firebase ID Token
    required String idToken,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
}
