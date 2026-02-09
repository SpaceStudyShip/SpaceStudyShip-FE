import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '프로필',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
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
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: SingleChildScrollView(
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
          ),
        ],
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
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: 40.sp,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // 이름
        Text(
          '우주 탐험가',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
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
            style: AppTextStyles.tag_12.copyWith(color: AppColors.primary),
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
        border: Border.all(color: AppColors.spaceDivider, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SpaceStatItem(label: '총 공부', value: '0시간', valueFirst: true),
          Container(width: 1, height: 40.h, color: AppColors.spaceDivider),
          SpaceStatItem(label: '연속', value: '0일', valueFirst: true),
          Container(width: 1, height: 40.h, color: AppColors.spaceDivider),
          SpaceStatItem(label: '배지', value: '0개', valueFirst: true),
        ],
      ),
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
            bottom: BorderSide(color: AppColors.spaceDivider, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.w, color: AppColors.textSecondary),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.label16Medium.copyWith(color: Colors.white),
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
