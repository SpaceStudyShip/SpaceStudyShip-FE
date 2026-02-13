import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../routes/route_paths.dart';

/// 온보딩 스크린
///
/// 신규 사용자에게 앱 사용법을 안내합니다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.rocket_launch_rounded,
      color: AppColors.primary,
      title: '당신의 우주선이 준비됐어요',
      description: '공부를 연료 삼아, 우주를 항해해볼까요?',
    ),
    _OnboardingData(
      icon: Icons.local_gas_station_rounded,
      color: AppColors.accentGold,
      title: '할 일을 끝내면 연료가 채워져요',
      description: '매일 조금씩, 더 멀리 갈 수 있어요',
    ),
    _OnboardingData(
      icon: Icons.explore_rounded,
      color: AppColors.secondary,
      title: '어떤 행성을 발견하게 될까요?',
      description: '지금 바로 첫 항해를 시작하세요',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: Column(
              children: [
                // 스킵 버튼
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      '건너뛰기',
                      style: AppTextStyles.paragraph_14_100.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),

                // 페이지 뷰
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: AppPadding.all20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 그라데이션 원형 아이콘
                            FadeSlideIn(
                              child: GradientCircleIcon(
                                icon: page.icon,
                                color: page.color,
                                size: 96,
                                iconSize: 42,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s32),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 100),
                              child: Text(
                                page.title,
                                style: AppTextStyles.heading_24.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.s16),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                page.description,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.paragraph_14.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 인디케이터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 24.w : 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.spaceDivider,
                        borderRadius: AppRadius.small,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.s32),

                // 다음/시작 버튼
                Padding(
                  padding: AppPadding.horizontal20,
                  child: AppButton(
                    text: _currentPage == _pages.length - 1 ? '탐험 시작하기' : '다음',
                    onPressed: _nextPage,
                    width: double.infinity,
                    height: 56.h,
                  ),
                ),

                SizedBox(height: AppSpacing.s32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
}
