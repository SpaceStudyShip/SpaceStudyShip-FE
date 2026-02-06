import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

/// 소셜 스크린
///
/// 친구, 그룹, 랭킹 등 소셜 기능을 제공합니다.
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.spaceBackground,
        appBar: AppBar(
          backgroundColor: AppColors.spaceBackground,
          elevation: 0,
          title: Text(
            '소셜',
            style: TextStyle(
              fontSize: 20.sp,
              fontFamily: 'Pretendard-Bold',
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Pretendard-SemiBold',
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Pretendard-Regular',
            ),
            tabs: const [
              Tab(text: '친구'),
              Tab(text: '그룹'),
              Tab(text: '랭킹'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFriendsTab(),
            _buildGroupsTab(),
            _buildRankingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '👥',
            style: TextStyle(fontSize: 64.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '아직 친구가 없어요',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Pretendard-Medium',
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '친구를 추가해서 함께 공부해요',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Pretendard-Regular',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🏠',
            style: TextStyle(fontSize: 64.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '참여 중인 그룹이 없어요',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Pretendard-Medium',
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '그룹에 참여해서 함께 목표를 달성해요',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Pretendard-Regular',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🏆',
            style: TextStyle(fontSize: 64.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '랭킹 준비 중',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Pretendard-Medium',
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '공부 시간을 기록하면 랭킹에 참여할 수 있어요',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Pretendard-Regular',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
