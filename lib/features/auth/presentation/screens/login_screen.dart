import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../routes/route_paths.dart';

/// 로그인 스크린
///
/// Google 소셜 로그인을 제공합니다.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 및 타이틀
              Text(
                '🚀',
                style: TextStyle(fontSize: 64.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                '우주공부선에 오신 것을\n환영합니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontFamily: 'Pretendard-Bold',
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '함께 우주를 탐험하며 공부해요',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Pretendard-Regular',
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 3),

              // Google 로그인 버튼
              AppButton(
                text: 'Google로 시작하기',
                onPressed: () {
                  // TODO: Google 로그인 구현
                  context.go(RoutePaths.onboarding);
                },
                width: double.infinity,
                height: 56.h,
              ),

              SizedBox(height: 16.h),

              // 약관 안내
              Text(
                '로그인 시 서비스 이용약관 및 개인정보 처리방침에\n동의하는 것으로 간주됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: 'Pretendard-Regular',
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
