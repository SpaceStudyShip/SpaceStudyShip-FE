import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/login_prompt_helper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/states/space_empty_state.dart';

/// 소셜 스크린
///
/// 친구, 그룹, 랭킹 등 소셜 기능을 제공합니다.
/// 게스트 모드에서는 로그인 유도 화면을 표시합니다.
class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);

    if (isGuest) {
      return _buildGuestView(context, ref);
    }

    return _buildAuthenticatedView();
  }

  Widget _buildGuestView(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: AppSpacing.s20,
        title: Text(
          '소셜',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpaceEmptyState(
                icon: Icons.people_rounded,
                color: AppColors.primary,
                title: '친구와 함께 공부하려면',
                subtitle: '로그인이 필요해요',
              ),
              SizedBox(height: AppSpacing.s24),
              AppButton(
                text: '로그인하기',
                onPressed: () => showLoginPrompt(
                  context: context,
                  ref: ref,
                  message: '소셜 기능을 이용하려면 로그인이 필요해요.',
                ),
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          titleSpacing: AppSpacing.s20,
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
        body: TabBarView(
          children: [_buildFriendsTab(), _buildGroupsTab(), _buildRankingTab()],
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
