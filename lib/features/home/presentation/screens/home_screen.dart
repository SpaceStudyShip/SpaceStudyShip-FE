import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

/// 홈 스크린
///
/// 오늘의 할 일, 연료 상태, 퀵 액션 등을 표시합니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.spaceBackground,
        elevation: 0,
        title: Text(
          '우주공부선',
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Pretendard-Bold',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24.w,
            ),
            onPressed: () {
              // TODO: 알림 화면
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 연료 상태 카드
            _buildFuelCard(),
            SizedBox(height: 24.h),

            // 오늘의 할 일
            _buildSectionTitle('오늘의 할 일'),
            SizedBox(height: 12.h),
            _buildEmptyTodoCard(),
            SizedBox(height: 24.h),

            // 최근 활동
            _buildSectionTitle('최근 활동'),
            SizedBox(height: 12.h),
            _buildEmptyActivityCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.secondary.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⛽', style: TextStyle(fontSize: 24.sp)),
              SizedBox(width: 8.w),
              Text(
                '보유 연료',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Pretendard-SemiBold',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '0.0통',
            style: TextStyle(
              fontSize: 32.sp,
              fontFamily: 'Pretendard-Bold',
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '공부를 시작해서 연료를 모아보세요!',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Pretendard-Regular',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontFamily: 'Pretendard-Bold',
        color: Colors.white,
      ),
    );
  }

  Widget _buildEmptyTodoCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Column(
        children: [
          Text('📝', style: TextStyle(fontSize: 40.sp)),
          SizedBox(height: 12.h),
          Text(
            '오늘의 할 일이 없어요',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Pretendard-Medium',
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '할 일을 추가해보세요',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Pretendard-Regular',
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Column(
        children: [
          Text('🌟', style: TextStyle(fontSize: 40.sp)),
          SizedBox(height: 12.h),
          Text(
            '아직 활동 기록이 없어요',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Pretendard-Medium',
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '타이머로 공부를 시작해보세요',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Pretendard-Regular',
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
