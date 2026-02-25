import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/space/badge_card.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../domain/entities/badge_entity.dart' as badge_domain;
import '../providers/badge_provider.dart';

/// 배지 컬렉션 스크린
///
/// 카테고리별로 그룹핑된 배지 목록을 4열 그리드로 표시합니다.
/// 탭하면 배지 상세 다이얼로그가 표시됩니다.
class BadgeCollectionScreen extends ConsumerWidget {
  const BadgeCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgeNotifierProvider);
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '배지 컬렉션',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: badges.isEmpty
                ? const Center(
                    child: SpaceEmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: '배지가 없어요',
                      subtitle: '공부를 시작하면 배지를 얻을 수 있어요',
                    ),
                  )
                : SingleChildScrollView(
                    padding: AppPadding.all20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 수집 현황
                        Text(
                          '$unlockedCount / ${badges.length} 획득',
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.s20),

                        // 카테고리별 배지 그룹
                        ..._buildCategoryGroups(context, badges),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryGroups(
    BuildContext context,
    List<badge_domain.BadgeEntity> badges,
  ) {
    const categories = [
      (badge_domain.BadgeCategory.studyTime, '공부 시간'),
      (badge_domain.BadgeCategory.streak, '연속 기록'),
      (badge_domain.BadgeCategory.session, '세션'),
      (badge_domain.BadgeCategory.exploration, '탐험'),
      (badge_domain.BadgeCategory.fuel, '연료'),
      (badge_domain.BadgeCategory.hidden, '히든'),
    ];

    final widgets = <Widget>[];

    for (final (category, label) in categories) {
      final group = badges.where((b) => b.category == category).toList();
      if (group.isEmpty) continue;

      // 섹션 헤더
      widgets.add(
        Text(
          label,
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
      );
      widgets.add(SizedBox(height: AppSpacing.s12));

      // 4열 그리드
      widgets.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppSpacing.s8,
            mainAxisSpacing: AppSpacing.s8,
            childAspectRatio: 0.75,
          ),
          itemCount: group.length,
          itemBuilder: (context, index) {
            final badge = group[index];
            return BadgeCard(
              icon: badge.icon,
              name: badge.name,
              isUnlocked: badge.isUnlocked,
              rarity: _mapRarity(badge.rarity),
              description: badge.description,
              onTap: () => _showBadgeDetail(context, badge),
            );
          },
        ),
      );
      widgets.add(SizedBox(height: AppSpacing.s24));
    }

    return widgets;
  }

  /// domain BadgeRarity -> widget BadgeRarity 변환
  BadgeRarity _mapRarity(badge_domain.BadgeRarity rarity) {
    switch (rarity) {
      case badge_domain.BadgeRarity.normal:
        return BadgeRarity.normal;
      case badge_domain.BadgeRarity.rare:
        return BadgeRarity.rare;
      case badge_domain.BadgeRarity.epic:
        return BadgeRarity.epic;
      case badge_domain.BadgeRarity.legendary:
        return BadgeRarity.legendary;
      case badge_domain.BadgeRarity.hidden:
        return BadgeRarity.hidden;
    }
  }

  void _showBadgeDetail(
    BuildContext context,
    badge_domain.BadgeEntity badge,
  ) {
    AppDialog.show(
      context: context,
      title: badge.isUnlocked ? badge.name : '???',
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.isUnlocked ? badge.icon : '🔒',
            style: TextStyle(fontSize: 48.sp),
          ),
          SizedBox(height: AppSpacing.s12),
          Text(
            badge.isUnlocked ? badge.description : '아직 해금되지 않은 배지예요',
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
