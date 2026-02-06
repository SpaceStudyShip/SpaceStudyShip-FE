import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
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

    // 임시: 바로 홈으로 이동
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Text('🚀', style: TextStyle(fontSize: 80.sp)),
            SizedBox(height: 24.h),
            Text(
              '우주공부선',
              style: TextStyle(
                fontSize: 28.sp,
                fontFamily: 'Pretendard-Bold',
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Space Study Ship',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Pretendard-Regular',
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
