import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/login_prompt_helper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../widgets/social_seat_view.dart';

/// 소셜 스크린
///
/// 인증된 사용자에게 우주 뷰(SocialSpaceView)를 표시합니다.
/// 게스트 모드에서는 로그인 유도 화면을 표시합니다.
class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);

    if (isGuest) {
      return _buildGuestView(context, ref);
    }

    return const SocialSeatView();
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
}
