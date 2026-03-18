import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/space/ranking_item.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../providers/ranking_provider.dart';

class RankingTabContent extends ConsumerStatefulWidget {
  const RankingTabContent({super.key});

  @override
  ConsumerState<RankingTabContent> createState() => _RankingTabContentState();
}

class _RankingTabContentState extends ConsumerState<RankingTabContent>
    with SingleTickerProviderStateMixin {
  // 명시적 controller로 상위 DefaultTabController와 격리
  late final TabController _subTabController;
  RankingPeriod _selectedPeriod = RankingPeriod.weekly;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _subTabController.addListener(() {
      if (!_subTabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  RankingType get _currentType =>
      _subTabController.index == 0 ? RankingType.all : RankingType.friends;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(
      rankingListProvider(_currentType, _selectedPeriod),
    );
    final myEntry = entries.where((e) => e.isMe).firstOrNull;
    final listEntries = entries.where((e) => !e.isMe).toList();

    return Column(
      children: [
        // 서브 탭: 전체 / 친구
        Padding(
          padding: AppPadding.horizontal20,
          child: TabBar(
            controller: _subTabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: AppTextStyles.paragraph14Semibold,
            unselectedLabelStyle: AppTextStyles.paragraph_14_100,
            tabs: const [Tab(text: '전체'), Tab(text: '친구')],
          ),
        ),

        SizedBox(height: AppSpacing.s12),

        // 기간 필터
        Padding(
          padding: AppPadding.horizontal20,
          child: Row(
            children: RankingPeriod.values.map((period) {
              final isSelected = period == _selectedPeriod;
              final label = switch (period) {
                RankingPeriod.today => '오늘',
                RankingPeriod.weekly => '주간',
                RankingPeriod.monthly => '월간',
              };
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.s8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedPeriod = period),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.spaceSurface,
                  labelStyle: AppTextStyles.tag_12.copyWith(
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.medium,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 0,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: AppSpacing.s12),

        // 랭킹 리스트
        Expanded(
          child: listEntries.isEmpty
              ? SpaceEmptyState(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.accentGold,
                  title: '랭킹 준비 중',
                  subtitle: '공부 시간을 기록하면 랭킹에 참여할 수 있어요',
                )
              : ListView.separated(
                  padding: AppPadding.horizontal20,
                  itemCount: listEntries.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: AppSpacing.s8),
                  itemBuilder: (context, index) {
                    final entry = listEntries[index];
                    return RankingItem(
                      rank: entry.rank,
                      userName: entry.name,
                      studyTime:
                          Duration(minutes: entry.studyTimeMinutes),
                      isCurrentUser: false,
                    );
                  },
                ),
        ),

        // 내 순위 하단 고정
        if (myEntry != null) ...[
          Divider(color: AppColors.spaceDivider, height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s8,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            child: RankingItem(
              rank: myEntry.rank,
              userName: myEntry.name,
              studyTime: Duration(minutes: myEntry.studyTimeMinutes),
              isCurrentUser: true,
            ),
          ),
        ],
      ],
    );
  }
}
