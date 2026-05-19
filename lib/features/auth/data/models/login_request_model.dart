import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_model.freezed.dart';
part 'login_request_model.g.dart';

/// 소셜 로그인 요청 DTO
///
/// `POST /api/auth/login` 요청 바디. `docs/api-docs.json` 의
/// `LoginRequest` 스키마와 1:1 정렬.
///
/// **필수 필드 (5개)**:
/// - [socialType]: `KAKAO` | `GOOGLE` | `APPLE`
/// - [idToken]: Firebase ID Token
/// - [fcmToken]: FCM 디바이스 토큰 (minLength: 0 — 발급 실패 시 빈 문자열 fallback)
/// - [deviceType]: `IOS` | `ANDROID`
/// - [deviceId]: UUID v4 (`^[0-9a-fA-F-]{36}$`)
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String socialType,
    required String idToken,
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
}
