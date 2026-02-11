import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_paths.dart';
import 'main_shell.dart';
import '../core/widgets/backgrounds/space_background.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/timer/presentation/screens/timer_screen.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/exploration/presentation/screens/exploration_detail_screen.dart';
import '../features/social/presentation/screens/social_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/about_screen.dart';
import '../features/profile/presentation/screens/spaceship_collection_screen.dart';

/// 앱 라우터 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      // ═══════════════════════════════════════════════════
      // 인증 플로우 (ShellRoute 외부)
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ═══════════════════════════════════════════════════
      // 메인 탭 (ShellRoute - 바텀 네비게이션)
      // ═══════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // 홈 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  // Todo 목록
                  GoRoute(
                    path: 'todo',
                    name: 'todoList',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '오늘의 할 일'),
                  ),
                  // Todo 상세
                  GoRoute(
                    path: 'todo/:id',
                    name: 'todoDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PlaceholderScreen(title: 'Todo: $id');
                    },
                  ),
                ],
              ),
            ],
          ),

          // 타이머 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.timer,
                name: 'timer',
                builder: (context, state) => const TimerScreen(),
                routes: [
                  GoRoute(
                    path: 'focus',
                    name: 'timerFocus',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '집중 모드'),
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'timerHistory',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '타이머 기록'),
                  ),
                ],
              ),
            ],
          ),

          // 탐험 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.explore,
                name: 'explore',
                builder: (context, state) => const ExploreScreen(),
                routes: [
                  // 행성 상세 (지역 목록)
                  GoRoute(
                    path: 'planet/:id',
                    name: 'planetDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ExplorationDetailScreen(planetId: id);
                    },
                  ),
                  GoRoute(
                    path: 'location/:id',
                    name: 'locationDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PlaceholderScreen(title: '장소: $id');
                    },
                  ),
                  GoRoute(
                    path: 'mission/:id',
                    name: 'missionDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PlaceholderScreen(title: '미션: $id');
                    },
                  ),
                ],
              ),
            ],
          ),

          // 소셜 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.social,
                name: 'social',
                builder: (context, state) => const SocialScreen(),
                routes: [
                  GoRoute(
                    path: 'friends',
                    name: 'friends',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '친구 목록'),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'friendDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PlaceholderScreen(title: '친구: $id');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'groups',
                    name: 'groups',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '그룹 목록'),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'groupDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PlaceholderScreen(title: '그룹: $id');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'ranking',
                    name: 'ranking',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '랭킹'),
                  ),
                ],
              ),
            ],
          ),

          // 프로필 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '설정'),
                  ),
                  GoRoute(
                    path: 'badges',
                    name: 'badges',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '배지 컬렉션'),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'badgeDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PlaceholderScreen(title: '배지: $id');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'spaceships',
                    name: 'spaceships',
                    builder: (context, state) =>
                        const SpaceshipCollectionScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'spaceshipDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PlaceholderScreen(title: '우주선: $id');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'statistics',
                    name: 'statistics',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: '통계'),
                  ),
                  GoRoute(
                    path: 'about',
                    name: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_off_rounded,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '페이지를 찾을 수 없습니다',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  state.uri.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(RoutePaths.home),
                  child: const Text('홈으로 돌아가기'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
});

/// 임시 플레이스홀더 스크린
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_rounded,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '개발 중...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
