/// API 엔드포인트 상수
///
/// 백엔드 Spring Boot API의 모든 엔드포인트를 중앙에서 관리합니다.
/// Retrofit DataSource와 AuthInterceptor에서 참조합니다.
///
/// **사용처**:
/// - `AuthInterceptor`: 공개 API 판별 (토큰 주입 제외)
/// - `AuthRemoteDataSource`: Retrofit 엔드포인트 경로
abstract class ApiEndpoints {
  // ============================================
  // Auth
  // ============================================

  /// 소셜 로그인 (Google/Apple)
  static const login = '/api/auth/login';

  /// 로그아웃
  static const logout = '/api/auth/logout';

  /// JWT 토큰 재발급
  static const reissue = '/api/auth/reissue';

  /// 회원 탈퇴
  static const withdraw = '/api/auth/withdraw';

  /// 닉네임 중복 확인
  static const checkNickname = '/api/auth/check-nickname';
}
