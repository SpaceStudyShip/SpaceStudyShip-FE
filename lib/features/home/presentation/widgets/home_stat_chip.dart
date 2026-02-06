import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 홈 화면 상태 칩 위젯
///
/// 연료, 경험치 등 상태 정보를 컴팩트하게 표시합니다.
///
/// **사용 예시**:
/// ```dart
/// HomeStatChip(
///   icon: '⛽',
///   value: '85',
///   label: '연료',
///   valueColor: AppColors.fuelFull,
/// )
/// ```
class HomeStatChip extends StatelessWidget {
  const HomeStatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
    this.onTap,
  });

  /// 아이콘 (이모지)
  final String icon;

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.spaceSurface,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: AppColors.spaceDivider,
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
                Text(icon, style: TextStyle(fontSize: 16.w)),
                SizedBox(width: 4.w),
                Text(
                  value,
                  style: AppTextStyles.label_16.copyWith(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
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
