import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
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
      emoji: '📋',
      title: '할 일을 정리하고',
      description: '오늘의 공부 계획을 세워보세요.\n작은 목표부터 하나씩 달성해 나가요.',
    ),
    _OnboardingData(
      emoji: '⏱️',
      title: '시간을 측정하고',
      description: '집중 시간을 기록하면 연료가 충전돼요.\n꾸준히 공부하면 더 멀리 탐험할 수 있어요.',
    ),
    _OnboardingData(
      emoji: '🌌',
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
      body: SafeArea(
        child: Column(
          children: [
            // 스킵 버튼
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  '건너뛰기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Pretendard-Medium',
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
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(page.emoji, style: TextStyle(fontSize: 80.sp)),
                        SizedBox(height: 32.h),
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontFamily: 'Pretendard-Bold',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Pretendard-Regular',
                            color: AppColors.textSecondary,
                            height: 1.6,
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
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // 다음/시작 버튼
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AppButton(
                text: _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                onPressed: _nextPage,
                width: double.infinity,
                height: 56.h,
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;
}
