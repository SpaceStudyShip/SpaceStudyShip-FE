import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';

/// 스플래시 스크린
///
/// 앱 시작 시 로고를 표시합니다.
/// GoRouter redirect가 인증 상태를 확인하고 자동으로 네비게이션합니다.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 - 그라데이션 원형 아이콘
                FadeSlideIn(
                  child: GradientCircleIcon(
                    icon: Icons.rocket_launch_rounded,
                    color: AppColors.primary,
                    size: 96,
                    iconSize: 44,
                    gradientColors: [AppColors.primaryLight, AppColors.primary],
                  ),
                ),
                SizedBox(height: AppSpacing.s24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    '우주공부선',
                    style: AppTextStyles.semibold28.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.s8),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Space Study Ship',
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.s48),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
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
