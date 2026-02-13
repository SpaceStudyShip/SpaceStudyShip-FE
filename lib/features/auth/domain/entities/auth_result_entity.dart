import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result_entity.freezed.dart';

/// 로그인 결과 엔티티
///
/// 백엔드 로그인 API 응답을 Domain Layer에서 사용하는 형태로 변환합니다.
/// Presentation Layer는 이 엔티티만 참조합니다.
@freezed
class AuthResultEntity with _$AuthResultEntity {
  const factory AuthResultEntity({
    /// 사용자 ID
    required int userId,

    /// 닉네임 (서버에서 자동 생성)
    required String nickname,

    /// 신규 회원 여부
    ///
    /// true일 경우 닉네임 설정 페이지로 이동해야 합니다.
    required bool isNewUser,

    /// 게스트 모드 여부
    ///
    /// true일 경우 데이터가 서버에 저장되지 않으며,
    /// 소셜 탭 접근이 제한됩니다.
    @Default(false) bool isGuest,
  }) = _AuthResultEntity;
}
