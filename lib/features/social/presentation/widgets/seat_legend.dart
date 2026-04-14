import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 좌석 상태 범례 한 줄
///
/// 선장(파랑) / 공부 중(초록) / 충전 중(회색) 색상 + 라벨 표시
class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          _LegendItem(color: AppColors.primary, label: '선장'),
          SizedBox(width: AppSpacing.s12),
          _LegendItem(color: AppColors.success, label: '공부 중'),
          SizedBox(width: AppSpacing.s12),
          _LegendItem(color: AppColors.spaceDivider, label: '충전 중'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 1.2),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: AppSpacing.s4),
        Text(
          label,
          style: AppTextStyles.tag_10.copyWith(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
