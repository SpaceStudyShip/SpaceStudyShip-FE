import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 스트릭 뱃지 위젯 - 우주 테마
///
/// **사용 예시**:
/// ```dart
/// StreakBadge(
///   days: 5,
///   isActive: true,
/// )
/// ```
class StreakBadge extends StatelessWidget {
  const StreakBadge({
    super.key,
    required this.days,
    this.isActive = true,
    this.showLabel = true,
    this.size = StreakBadgeSize.medium,
  });

  /// 연속 일수
  final int days;

  /// 활성화 상태 (오늘 공부 여부)
  final bool isActive;

  /// 라벨 표시 여부
  final bool showLabel;

  /// 크기
  final StreakBadgeSize size;

  Color get _color => isActive ? AppColors.accentGold : AppColors.textTertiary;

  TextStyle get _textStyle {
    switch (size) {
      case StreakBadgeSize.small:
        return AppTextStyles.tag_12;
      case StreakBadgeSize.medium:
        return AppTextStyles.paragraph_14;
      case StreakBadgeSize.large:
        return AppTextStyles.label_16;
    }
  }

  double get _iconSize {
    switch (size) {
      case StreakBadgeSize.small:
        return 14.w;
      case StreakBadgeSize.medium:
        return 18.w;
      case StreakBadgeSize.large:
        return 22.w;
    }
  }

  /// 스트릭 레벨에 따른 불꽃 개수
  int get _fireCount {
    if (days >= 100) return 3;
    if (days >= 30) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _fireCount,
            (i) => Icon(
              Icons.local_fire_department_rounded,
              size: _iconSize,
              color: _color,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        if (showLabel)
          Text(
            '연속 $days일째',
            style: _textStyle.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Text(
            '$days일',
            style: _textStyle.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

enum StreakBadgeSize { small, medium, large }
