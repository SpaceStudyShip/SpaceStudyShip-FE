import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 통계 아이템 위젯
///
/// 아이콘 + 라벨 + 값으로 구성된 통계 표시 위젯.
/// 타이머, 프로필 화면에서 공통 사용.
class SpaceStatItem extends StatelessWidget {
  const SpaceStatItem({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.valueFirst = false,
  });

  /// 상단 아이콘 (optional)
  final IconData? icon;

  /// 라벨 텍스트
  final String label;

  /// 값 텍스트
  final String value;

  /// true면 값이 라벨 위에 표시 (프로필 스타일)
  final bool valueFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null && !valueFirst) ...[
          Icon(icon, size: 16.w, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.s4),
        ],
        if (valueFirst) ...[
          Text(
            value,
            style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
          ),
          SizedBox(height: AppSpacing.s4),
          Text(
            label,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
          ),
        ] else ...[
          Text(
            label,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
          ),
          SizedBox(height: AppSpacing.s4),
          Text(
            value,
            style: AppTextStyles.paragraph_14.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
