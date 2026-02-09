import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 홈 화면 상태 칩 위젯
///
/// 연료, 경험치 등 상태 정보를 컴팩트하게 표시합니다.
///
/// **사용 예시**:
/// ```dart
/// HomeStatChip(
///   iconData: Icons.local_gas_station_rounded,
///   value: '85',
///   label: '연료',
///   valueColor: AppColors.fuelFull,
/// )
/// ```
class HomeStatChip extends StatelessWidget {
  const HomeStatChip({
    super.key,
    required this.iconData,
    required this.value,
    required this.label,
    this.valueColor,
    this.onTap,
  });

  /// 아이콘
  final IconData iconData;

  /// 값 (예: 85, 1,234)
  final String value;

  /// 라벨 (예: 연료, 경험치)
  final String label;

  /// 값 색상 (기본: Colors.white)
  final Color? valueColor;

  /// 탭 콜백
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.listItemPadding,
        decoration: BoxDecoration(
          gradient: AppGradients.statChip,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: AppColors.spaceDivider.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 + 값
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, size: 16.w, color: color),
                SizedBox(width: 4.w),
                Text(
                  value,
                  style: AppTextStyles.label_16.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s4),
            // 라벨
            Text(
              label,
              style: AppTextStyles.tag_12.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
