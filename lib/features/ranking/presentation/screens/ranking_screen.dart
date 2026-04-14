import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/space/ranking_item.dart';
import '../providers/ranking_provider.dart';
import '../widgets/my_rank_card.dart';
import '../widgets/period_tabs.dart';

/// 학습 랭킹 화면 (Mock UI)
///
/// 일간/주간/월간 탭 + 내 순위 카드 + 랭킹 리스트.
/// 데이터는 모두 더미 — API 연결 시 ranking_provider만 교체.
class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(rankingPeriodProvider);
    final entries = ref.watch(rankingProvider);
    final myRank = ref.watch(myRankProvider);

    final me = entries.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => entries.first,
    );

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '학습 랭킹',
          style: AppTextStyles.heading_20.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.s8),
                PeriodTabs(
                  selected: period,
                  onChanged: (p) =>
                      ref.read(rankingPeriodProvider.notifier).state = p,
                ),
                SizedBox(height: AppSpacing.s16),
                MyRankCard(
                  rank: myRank,
                  totalCount: entries.length,
                  studyDuration: me.studyDuration,
                ),
                SizedBox(height: AppSpacing.s16),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      0,
                      AppSpacing.s20,
                      AppSpacing.s24,
                    ),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: AppSpacing.s8),
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      return RankingItem(
                        rank: i + 1,
                        userName: e.userName,
                        studyTime: e.studyDuration,
                        isCurrentUser: e.isCurrentUser,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
