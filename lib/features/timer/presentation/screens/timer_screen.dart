import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/buttons/app_button.dart';

/// 타이머 스크린
///
/// 공부 시간 측정 및 연료 획득 화면입니다.
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.spaceBackground,
        elevation: 0,
        title: Text(
          '타이머',
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Pretendard-Bold',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
              size: 24.w,
            ),
            onPressed: () {
              // TODO: 타이머 기록 화면
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 타이머 디스플레이
            Text(
              '00:00:00',
              style: TextStyle(
                fontSize: 64.sp,
                fontFamily: 'Pretendard-Bold',
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '집중 시간을 측정해보세요',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Pretendard-Regular',
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 48.h),

            // 시작 버튼
            AppButton(
              text: '시작하기',
              onPressed: () {
                // TODO: 타이머 시작
              },
            ),
            SizedBox(height: 48.h),

            // 오늘의 통계
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.spaceSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.spaceDivider,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('오늘', '0시간 0분'),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: AppColors.spaceDivider,
                  ),
                  _buildStatItem('이번 주', '0시간 0분'),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: AppColors.spaceDivider,
                  ),
                  _buildStatItem('연속', '0일'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'Pretendard-Regular',
            color: AppColors.textTertiary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Pretendard-SemiBold',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
