import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/states/space_empty_state.dart';

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text(
            '소셜',
            style: AppTextStyles.heading_20.copyWith(color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: AppTextStyles.paragraph14Semibold,
            unselectedLabelStyle: AppTextStyles.paragraph_14_100,
            tabs: const [
              Tab(text: '친구'),
              Tab(text: '그룹'),
              Tab(text: '랭킹'),
            ],
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: SpaceBackground()),
            TabBarView(
              children: [_buildFriendsTab(), _buildGroupsTab(), _buildRankingTab()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return SpaceEmptyState(
      icon: Icons.people_rounded,
      color: AppColors.primary,
      title: '아직 친구가 없어요',
      subtitle: '친구를 추가해서 함께 공부해요',
    );
  }

  Widget _buildGroupsTab() {
    return SpaceEmptyState(
      icon: Icons.groups_rounded,
      color: AppColors.secondary,
      title: '참여 중인 그룹이 없어요',
      subtitle: '그룹에 참여해서 함께 목표를 달성해요',
    );
  }

  Widget _buildRankingTab() {
    return SpaceEmptyState(
      icon: Icons.emoji_events_rounded,
      color: AppColors.accentGold,
      title: '랭킹 준비 중',
      subtitle: '공부 시간을 기록하면 랭킹에 참여할 수 있어요',
    );
  }
}
