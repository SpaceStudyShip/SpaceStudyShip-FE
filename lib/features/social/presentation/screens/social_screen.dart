import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/login_prompt_helper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/constellation_map.dart';
import '../widgets/groups_tab_content.dart';
import '../widgets/ranking_tab_content.dart';

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
      body: SafeArea(
        child: Center(
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
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
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
              Expanded(
                child: TabBarView(
                  children: const [
                    ConstellationMap(),
                    GroupsTabContent(),
                    RankingTabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
