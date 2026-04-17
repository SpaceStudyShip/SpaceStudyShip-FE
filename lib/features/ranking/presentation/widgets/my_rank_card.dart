import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 내 순위 요약 카드
class MyRankCard extends StatelessWidget {
  const MyRankCard({
    super.key,
    required this.rank,
    required this.totalCount,
    required this.studyDuration,
  });

  final int? rank;
  final int totalCount;
  final Duration studyDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            alignment: Alignment.center,
            child: Text(
              rank == null ? '-' : '$rank',
              style: AppTextStyles.heading_20.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내 순위',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: AppSpacing.s4),
                Text(
                  rank == null ? '랭킹에 들지 못했어요' : '$totalCount명 중 $rank위',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _format(studyDuration),
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                '내 공부 시간',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return m > 0 ? '$h시간 $m분' : '$h시간';
    return '$m분';
  }
}
