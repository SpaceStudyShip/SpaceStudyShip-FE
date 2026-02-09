import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../routes/route_paths.dart';

/// 스플래시 스크린
///
/// 앱 시작 시 로고를 표시하고 인증 상태를 확인합니다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // TODO: 실제 인증 상태 확인 로직 추가
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // TODO: 인증 상태 확인 후 분기 (API 연동 시 로그인 상태면 홈으로)
    context.go(RoutePaths.login);
  }

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
            SizedBox(height: 24.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: Text(
                '우주공부선',
                style: AppTextStyles.semibold28.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 8.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Space Study Ship',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 48.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
