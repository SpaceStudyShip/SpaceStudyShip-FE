/// 앱 라우트 경로 상수
///
/// Feature-First 구조에 맞춰 경로를 그룹화합니다.
abstract class RoutePaths {
  // ═══════════════════════════════════════════════════
  // 인증 플로우
  // ═══════════════════════════════════════════════════
  static const splash = '/';
  static const login = '/login';
  static const onboarding = '/onboarding';

  // ═══════════════════════════════════════════════════
  // 메인 탭 (ShellRoute - 바텀 네비게이션)
  // ═══════════════════════════════════════════════════
  static const home = '/home';
  static const timer = '/timer';
  static const explore = '/explore';
  static const social = '/social';
  static const profile = '/profile';

  // ═══════════════════════════════════════════════════
  // Home 하위 화면
  // ═══════════════════════════════════════════════════
  static const todoList = '/home/todo';
  static const todoDetail = '/home/todo/:id';
  static String todoDetailPath(String id) => '/home/todo/$id';

  // 카테고리별 할일 목록
  static const categoryTodo = '/home/todo/category/:categoryId';
  static String categoryTodoPath(String categoryId) =>
      '/home/todo/category/$categoryId';

  // ═══════════════════════════════════════════════════
  // Timer 하위 화면
  // ═══════════════════════════════════════════════════
  static const timerFocus = '/timer/focus';
  static const timerHistory = '/timer/history';

  // ═══════════════════════════════════════════════════
  // Explore 하위 화면
  // ═══════════════════════════════════════════════════
  static const planetDetail = '/explore/planet/:id';
  static String planetDetailPath(String id) => '/explore/planet/$id';

  static const locationDetail = '/explore/location/:id';
  static String locationDetailPath(String id) => '/explore/location/$id';

  static const missionDetail = '/explore/mission/:id';
  static String missionDetailPath(String id) => '/explore/mission/$id';

  // ═══════════════════════════════════════════════════
  // Social 하위 화면
  // ═══════════════════════════════════════════════════
  static const friends = '/social/friends';
  static const groups = '/social/groups';
  static const ranking = '/social/ranking';

  static const friendDetail = '/social/friends/:id';
  static String friendDetailPath(String id) => '/social/friends/$id';

  static const groupDetail = '/social/groups/:id';
  static String groupDetailPath(String id) => '/social/groups/$id';

  // ═══════════════════════════════════════════════════
  // Profile 하위 화면
  // ═══════════════════════════════════════════════════
  static const settings = '/profile/settings';
  static const badges = '/profile/badges';
  static const spaceships = '/profile/spaceships';
  static const statistics = '/profile/statistics';
  static const about = '/profile/about';

  static const badgeDetail = '/profile/badges/:id';
  static String badgeDetailPath(String id) => '/profile/badges/$id';

  static const spaceshipDetail = '/profile/spaceships/:id';
  static String spaceshipDetailPath(String id) => '/profile/spaceships/$id';
}
