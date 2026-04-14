import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/ranking_entry.dart';

/// 일간 / 주간 / 월간 필터 탭
class PeriodTabs extends StatelessWidget {
  const PeriodTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final RankingPeriod selected;
  final ValueChanged<RankingPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          _Tab(
            label: '일간',
            active: selected == RankingPeriod.daily,
            onTap: () => onChanged(RankingPeriod.daily),
          ),
          SizedBox(width: AppSpacing.s8),
          _Tab(
            label: '주간',
            active: selected == RankingPeriod.weekly,
            onTap: () => onChanged(RankingPeriod.weekly),
          ),
          SizedBox(width: AppSpacing.s8),
          _Tab(
            label: '월간',
            active: selected == RankingPeriod.monthly,
            onTap: () => onChanged(RankingPeriod.monthly),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

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
