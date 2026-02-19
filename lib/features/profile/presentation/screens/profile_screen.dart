import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../auth/domain/entities/auth_result_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../routes/route_paths.dart';

/// 프로필 스크린 추후 개선 가능
///
/// 사용자 정보, 컬렉션, 통계, 설정 등을 제공합니다.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.all20,
          child: Column(
            children: [
              // 프로필 정보
              _buildProfileHeader(ref.watch(authNotifierProvider).valueOrNull),
              SizedBox(height: AppSpacing.s24),

              // 통계 요약
              _buildStatsCard(),
              SizedBox(height: AppSpacing.s24),

              // 메뉴 리스트
              _buildMenuList(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthResultEntity? user) {
    final isGuest = user?.isGuest ?? false;
    final nickname = isGuest ? '게스트' : (user?.nickname ?? '우주 탐험가');

    return Column(
      children: [
        // 아바타
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isGuest
                  ? [AppColors.textTertiary, AppColors.spaceDivider]
                  : [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(Icons.person_rounded, size: 40.sp, color: Colors.white),
          ),
        ),
        SizedBox(height: AppSpacing.s16),

        // 이름
        Text(
          nickname,
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.s4),

        // 레벨/칭호
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: (isGuest ? AppColors.textTertiary : AppColors.primary)
                .withValues(alpha: 0.2),
            borderRadius: AppRadius.large,
          ),
          child: Text(
            isGuest ? '체험 모드' : 'Lv.1 신입 탐험가',
            style: AppTextStyles.tag_12.copyWith(
              color: isGuest ? AppColors.textSecondary : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: AppPadding.all20,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.large,
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

  Widget _buildMenuList(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);

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
        _buildMenuItem(
          icon: Icons.info_outline_rounded,
          title: '앱 정보',
          onTap: () => context.push(RoutePaths.about),
        ),
        SizedBox(height: AppSpacing.s16),
        _buildMenuItem(
          icon: Icons.logout_rounded,
          title: '로그아웃',
          iconColor: AppColors.error,
          textColor: AppColors.error,
          showChevron: false,
          onTap: () async {
            final confirmed = await AppDialog.confirm(
              context: context,
              title: '로그아웃하시겠어요?',
              message: isGuest ? '게스트 모드의 데이터가\n모두 초기화돼요' : null,
              isDestructive: isGuest,
              confirmText: '로그아웃',
              cancelText: '취소',
            );
            if (confirmed == true) {
              await ref.read(authNotifierProvider.notifier).signOut();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.large,
      child: Container(
        padding: AppPadding.all16,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.spaceDivider, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.w, color: iconColor ?? AppColors.textSecondary),
            SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.label16Medium.copyWith(
                  color: textColor ?? Colors.white,
                ),
              ),
            ),
            if (showChevron)
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
