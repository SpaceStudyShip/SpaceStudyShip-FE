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
      icon: Icons.checklist_rounded,
      color: AppColors.primary,
      title: '할 일을 정리하고',
      description: '오늘의 공부 계획을 세워보세요.\n작은 목표부터 하나씩 달성해 나가요.',
    ),
    _OnboardingData(
      icon: Icons.timer_rounded,
      color: AppColors.accentGold,
      title: '시간을 측정하고',
      description: '집중 시간을 기록하면 연료가 충전돼요.\n꾸준히 공부하면 더 멀리 탐험할 수 있어요.',
    ),
    _OnboardingData(
      icon: Icons.explore_rounded,
      color: AppColors.secondary,
      title: '우주를 탐험해요',
      description: '새로운 행성을 발견하고\n친구들과 함께 우주를 탐험해요!',
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
      context.go(RoutePaths.home);
    }
  }

  void _skip() {
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
                    text: _currentPage == _pages.length - 1 ? '시작하기' : '다음',
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
