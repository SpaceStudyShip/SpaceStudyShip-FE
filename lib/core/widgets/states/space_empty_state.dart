import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../animations/entrance_animations.dart';

/// 빈 상태 표시 위젯
///
/// 아이콘 원형 + 제목 + 부제목으로 구성된 빈 상태 플레이스홀더.
/// 소셜, 탐험, 홈 화면 등에서 공통 사용.
class SpaceEmptyState extends StatelessWidget {
  const SpaceEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.iconSize = 72,
    this.animated = true,
  });

  /// 표시할 아이콘
  final IconData icon;

  /// 제목 텍스트
  final String title;

  /// 부제목 텍스트
  final String subtitle;

  /// 아이콘 배경/테두리 색상 (기본: AppColors.textTertiary)
  final Color? color;

  /// 아이콘 원형 크기 (기본: 72)
  final double iconSize;

  /// FadeSlideIn 애니메이션 적용 여부 (기본: true)
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textTertiary;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: iconSize.w,
          height: iconSize.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveColor.withValues(alpha: 0.1),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: (iconSize * 0.44).sp, color: effectiveColor),
        ),
        SizedBox(height: AppSpacing.s16),
        Text(
          title,
          style: AppTextStyles.label_16.copyWith(color: Colors.white),
        ),
        SizedBox(height: AppSpacing.s8),
        Text(
          subtitle,
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    final widget = Center(child: content);
    if (animated) return FadeSlideIn(child: widget);
    return widget;
  }
}
