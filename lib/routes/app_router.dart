import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_paths.dart';
import 'main_shell.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/spacing_and_radius.dart';
import '../core/constants/text_styles.dart';
import '../core/widgets/backgrounds/space_background.dart';
import '../features/auth/domain/entities/auth_result_entity.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
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

/// 스플래시 최소 표시 시간 (2초)
final splashDelayProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
});

/// GoRouter의 refreshListenable로 사용되는 ChangeNotifier
///
/// authNotifierProvider 및 splashDelayProvider 상태 변경 시 GoRouter redirect를 재평가합니다.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthResultEntity?>>(
      authNotifierProvider,
      (prev, next) => notifyListeners(),
    );
    _ref.listen<AsyncValue<void>>(
      splashDelayProvider,
      (prev, next) => notifyListeners(),
    );
  }

  final Ref _ref;
}

/// 앱 라우터 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;

      final isAuthRoute =
          location == RoutePaths.splash ||
          location == RoutePaths.login ||
          location == RoutePaths.onboarding;

      final splashDone = ref.read(splashDelayProvider).hasValue;

      // 인증 로딩 중이거나 스플래시 최소 시간 미경과 → 스플래시 유지
      if (authState.isLoading ||
          (location == RoutePaths.splash && !splashDone)) {
        return null;
      }

      final user = authState.valueOrNull;

      // 미로그인 → 로그인 화면으로
      if (user == null) {
        return (location == RoutePaths.login) ? null : RoutePaths.login;
      }

      // 로그인됨 + 인증 화면에 있으면
      if (isAuthRoute) {
        if (location == RoutePaths.login) return RoutePaths.onboarding;
        if (location == RoutePaths.onboarding) return null;
        return RoutePaths.home; // splash 등
      }

      return null;
    },
    routes: [
      // ═══════════════════════════════════════════════════
      // 인증 플로우 (ShellRoute 외부)
      // ═══════════════════════════════════════════════════
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ═══════════════════════════════════════════════════
      // 메인 탭 (ShellRoute - 바텀 네비게이션)
      // ═══════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: MainShell(navigationShell: navigationShell),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
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
      backgroundColor: AppColors.spaceBackground,
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
                SizedBox(height: AppSpacing.s16),
                Text(
                  '페이지를 찾을 수 없습니다',
                  style: AppTextStyles.label_16.copyWith(color: Colors.white),
                ),
                SizedBox(height: AppSpacing.s8),
                Text(
                  state.uri.toString(),
                  style: AppTextStyles.tag_12.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: AppSpacing.s24),
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
      backgroundColor: AppColors.spaceBackground,
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
                SizedBox(height: AppSpacing.s16),
                Text(
                  title,
                  style: AppTextStyles.subHeading_18.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.s8),
                Text(
                  '개발 중...',
                  style: AppTextStyles.paragraph_14.copyWith(
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
