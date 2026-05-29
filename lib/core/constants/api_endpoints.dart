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

  /// 닉네임 변경
  static const nickname = '/api/auth/nickname';

  // ============================================
  // Todo
  // ============================================

  /// 할 일 목록 / 생성
  static const todos = '/api/todos';

  /// 할 일 단건 (수정/삭제)
  static String todoById(String id) => '/api/todos/$id';

  // ============================================
  // Todo Category
  // ============================================

  /// 카테고리 목록 / 생성
  static const todoCategories = '/api/todo-categories';

  /// 카테고리 단건 (수정/삭제)
  static String todoCategoryById(String id) => '/api/todo-categories/$id';

  // ============================================
  // Fuel
  // ============================================

  /// 연료 잔량 조회
  static const fuel = '/api/fuel';

  /// 연료 거래 내역 조회 (페이지네이션)
  static const fuelTransactions = '/api/fuel/transactions';

  // ============================================
  // Timer
  // ============================================

  /// 타이머 세션 저장(POST) / 페이지네이션 조회(GET)
  static const timerSessions = '/api/timer-sessions';

  /// 오늘 공부 통계 (KST)
  static const timerSessionsTodayStats = '/api/timer-sessions/today-stats';

  // ============================================
  // Exploration
  // ============================================

  /// 전체 행성 목록
  static const explorationPlanets = '/api/explorations/planets';

  /// 특정 행성 하위 지역 목록
  static String explorationRegions(String planetId) =>
      '/api/explorations/planets/$planetId/regions';

  /// 지역 해금 (연료 소비)
  static String explorationUnlockRegion(String regionId) =>
      '/api/explorations/regions/$regionId/unlock';

  /// 행성 해금 (연료 소비)
  static String explorationUnlockPlanet(String planetId) =>
      '/api/explorations/planets/$planetId/unlock';
}
