import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/route_paths.dart';

/// 프로필 스크린
///
/// 사용자 정보, 컬렉션, 통계, 설정 등을 제공합니다.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.spaceBackground,
        elevation: 0,
        title: Text(
          '프로필',
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Pretendard-Bold',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 24.w,
            ),
            onPressed: () {
              context.push(RoutePaths.settings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 프로필 정보
            _buildProfileHeader(),
            SizedBox(height: 24.h),

            // 통계 요약
            _buildStatsCard(),
            SizedBox(height: 24.h),

            // 메뉴 리스트
            _buildMenuList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // 아바타
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '👨‍🚀',
              style: TextStyle(fontSize: 40.sp),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // 이름
        Text(
          '우주 탐험가',
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Pretendard-Bold',
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),

        // 레벨/칭호
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            'Lv.1 신입 탐험가',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Pretendard-Medium',
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
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
          _buildStatItem('총 공부', '0시간'),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.spaceDivider,
          ),
          _buildStatItem('연속', '0일'),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.spaceDivider,
          ),
          _buildStatItem('배지', '0개'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Pretendard-Bold',
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'Pretendard-Regular',
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.bar_chart_outlined,
          title: '통계',
          onTap: () => context.push(RoutePaths.statistics),
        ),
        _buildMenuItem(
          icon: Icons.emoji_events_outlined,
          title: '배지 컬렉션',
          onTap: () => context.push(RoutePaths.badges),
        ),
        _buildMenuItem(
          icon: Icons.rocket_launch_outlined,
          title: '우주선 컬렉션',
          onTap: () => context.push(RoutePaths.spaceships),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.spaceDivider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.w,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Pretendard-Medium',
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24.w,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
