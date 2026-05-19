import '../../../../core/errors/app_exception.dart';
import '../entities/auth_result_entity.dart';

/// Auth Repository 인터페이스
///
/// Domain Layer에서 정의하며, Data Layer에서 구현합니다.
/// Presentation Layer는 이 인터페이스에만 의존합니다.
///
/// **의존성 흐름**: Presentation → Domain ← Data
abstract class AuthRepository {
  /// 소셜 로그인 (Google)
  ///
  /// 1. Firebase Google 로그인
  /// 2. Firebase ID Token 획득
  /// 3. 백엔드 `/api/auth/login` 호출
  /// 4. JWT 토큰 저장
  ///
  /// Returns: [AuthResultEntity] (memberId, nickname, isNewMember)
  Future<AuthResultEntity> signInWithGoogle();

  /// 소셜 로그인 (Apple)
  ///
  /// 1. Firebase Apple 로그인
  /// 2. Firebase ID Token 획득
  /// 3. 백엔드 `/api/auth/login` 호출
  /// 4. JWT 토큰 저장
  ///
  /// Returns: [AuthResultEntity] (memberId, nickname, isNewMember)
  Future<AuthResultEntity> signInWithApple();

  /// 로그아웃
  ///
  /// 1. 백엔드 `/api/auth/logout` 호출
  /// 2. Firebase 로그아웃
  /// 3. JWT 토큰 삭제
  Future<void> signOut();

  /// 닉네임 변경
  ///
  /// `PATCH /api/auth/nickname` 호출 후 새 닉네임 문자열 반환.
  ///
  /// Throws:
  /// - [InvalidInputValueException] (400): 클라이언트 사전 검증 실패 또는 서버 형식 오류
  /// - [UnauthenticatedRequestException] (401)
  /// - [DuplicatedNicknameException] (409)
  Future<String> updateNickname(String nickname);

  /// 닉네임 중복 확인
  ///
  /// `GET /api/auth/check-nickname` 호출. true = 사용 가능, false = 이미 사용 중.
  ///
  /// Throws:
  /// - [InvalidInputValueException] (400)
  /// - [UnauthenticatedRequestException] (401)
  Future<bool> checkNickname(String nickname);

  /// 회원 탈퇴
  ///
  /// `DELETE /api/auth/withdraw` 호출 후 Firebase signOut + 로컬 토큰 삭제.
  /// 204 응답 / Firebase 측 사용자 부재 / 외부 시스템 일시 오류 모두 정상 완료로 처리 (멱등).
  ///
  /// Throws:
  /// - [UnauthenticatedRequestException] (401)
  Future<void> withdraw();
}
