import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../routes/route_paths.dart';
import '../models/seat_slot.dart';
import '../providers/friends_provider.dart';
import 'add_friend_sheet.dart';
import 'boarding_pass_bar.dart';
import 'seat_grid.dart';
import 'seat_legend.dart';

/// 소셜 좌석 배치 뷰
///
/// 구성: 헤더 → 범례 → 탭 → SeatGrid → BoardingPassBar
class SocialSeatView extends ConsumerWidget {
  const SocialSeatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(seatAssignmentProvider);
    final boardedCount = ref.watch(boardedCountProvider);
    final filter = ref.watch(seatFilterProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            boardedCount: boardedCount,
            onAddTap: () => AddFriendSheet.show(context),
            onRankingTap: () => context.push(RoutePaths.ranking),
          ),
          SizedBox(height: AppSpacing.s8),
          const SeatLegend(),
          SizedBox(height: AppSpacing.s12),
          _FilterTabs(
            selected: filter,
            onChanged: (f) => ref.read(seatFilterProvider.notifier).state = f,
          ),
          SizedBox(height: AppSpacing.s12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: SeatGrid(
              slots: slots,
              muteOthers: (slot) => _shouldMute(slot, filter),
              onSeatTap: (slot) => _onSeatTap(context, slot),
            ),
          ),
          const Spacer(),
          BoardingPassBar(
            shipName: '우주선 1호',
            boardedCount: boardedCount,
            totalSeats: 12,
            onAddFriend: () => AddFriendSheet.show(context),
          ),
          SizedBox(
            height:
                MediaQuery.of(context).padding.bottom +
                FloatingNavMetrics.totalHeight +
                AppSpacing.s12,
          ),
        ],
      ),
    );
  }

  bool _shouldMute(SeatSlot slot, SeatFilter filter) {
    if (filter == SeatFilter.all) return false;
    if (slot.status == SeatStatus.empty) return false;
    if (filter == SeatFilter.studying) {
      return slot.status != SeatStatus.me && slot.status != SeatStatus.studying;
    }
    return slot.status != SeatStatus.docked;
  }

  void _onSeatTap(BuildContext context, SeatSlot slot) {
    if (slot.status == SeatStatus.empty) {
      AddFriendSheet.show(context);
      return;
    }
    if (slot.friend == null || slot.status == SeatStatus.me) return;
    context.push(RoutePaths.friendDetail, extra: slot.friend);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.boardedCount,
    required this.onAddTap,
    required this.onRankingTap,
  });

  final int boardedCount;
  final VoidCallback onAddTap;
  final VoidCallback onRankingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '소셜',
                  style: AppTextStyles.heading_24.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.s4),
                Text(
                  '우주선 1호 · $boardedCount명 탑승 중',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRankingTap,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.spaceSurface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.spaceDivider),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.emoji_events_outlined,
                size: 18.w,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s8),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.spaceSurface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.spaceDivider),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 18.w,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onChanged});

  final SeatFilter selected;
  final ValueChanged<SeatFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          _Tab(
            label: '공부 중',
            active: selected == SeatFilter.studying,
            onTap: () => onChanged(SeatFilter.studying),
          ),
          SizedBox(width: AppSpacing.s8),
          _Tab(
            label: '충전 중',
            active: selected == SeatFilter.docked,
            onTap: () => onChanged(SeatFilter.docked),
          ),
          SizedBox(width: AppSpacing.s8),
          _Tab(
            label: '전체',
            active: selected == SeatFilter.all,
            onTap: () => onChanged(SeatFilter.all),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: active ? AppColors.primary : AppColors.spaceDivider,
          ),
        ),
        child: Text(
          label,
          style: active
              ? AppTextStyles.paragraph14Semibold.copyWith(color: Colors.white)
              : AppTextStyles.paragraph_14_100.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
      ),
    );
  }
}
