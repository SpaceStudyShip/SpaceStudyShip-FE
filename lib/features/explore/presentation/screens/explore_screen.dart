import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

/// 탐험 스크린
///
/// 우주 탐험 맵과 잠금 해제 가능한 장소들을 표시합니다.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.spaceBackground,
        elevation: 0,
        title: Text(
          '우주 탐험',
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Pretendard-Bold',
            color: Colors.white,
          ),
        ),
        actions: [
          // 연료 표시
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.spaceSurface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⛽',
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(width: 4.w),
                Text(
                  '0.0통',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Pretendard-SemiBold',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 우주 탐험 맵 플레이스홀더
            Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.spaceBackground,
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🌍',
                      style: TextStyle(fontSize: 64.sp),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '지구',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: 'Pretendard-Bold',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '현재 위치',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Pretendard-Regular',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // 안내 메시지
            Text(
              '연료를 모아 새로운 행성을 탐험해보세요!',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Pretendard-Regular',
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // 탐험 가능한 장소 힌트
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.spaceSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.spaceDivider,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '🔒',
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '달',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Pretendard-SemiBold',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '필요 연료: 5.0통',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Pretendard-Regular',
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
