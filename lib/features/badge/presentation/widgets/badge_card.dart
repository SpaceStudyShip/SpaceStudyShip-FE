import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/badge_entity.dart';

/// 뱃지 카드 위젯 - 컬렉션용
///
/// **사용 예시**:
/// ```dart
/// BadgeCard(
///   icon: '🚀',
///   name: '스타 파일럿',
///   isUnlocked: true,
///   rarity: BadgeRarity.rare,
///   onTap: () => showDetail(),
/// )
/// ```
class BadgeCard extends StatefulWidget {
  const BadgeCard({
    super.key,
    required this.icon,
    required this.name,
    this.isUnlocked = false,
    this.rarity = BadgeRarity.normal,
    this.onTap,
  });

  /// 뱃지 아이콘 (이모지)
  final String icon;

  /// 뱃지 이름
  final String name;

  /// 해금 여부
  final bool isUnlocked;

  /// 희귀도
  final BadgeRarity rarity;

  /// 탭 콜백
  final VoidCallback? onTap;

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard> {
  bool _isPressed = false;

  Color get _borderColor {
    if (!widget.isUnlocked) return AppColors.spaceDivider;

    switch (widget.rarity) {
      case BadgeRarity.normal:
        return AppColors.textTertiary;
      case BadgeRarity.rare:
        return AppColors.primary;
      case BadgeRarity.epic:
        return AppColors.secondary;
      case BadgeRarity.legendary:
        return AppColors.accentGold;
      case BadgeRarity.hidden:
        return AppColors.accentPink;
    }
  }

  double get _borderWidth {
    switch (widget.rarity) {
      case BadgeRarity.normal:
        return 1.0;
      case BadgeRarity.rare:
      case BadgeRarity.epic:
        return 2.0;
      case BadgeRarity.legendary:
      case BadgeRarity.hidden:
        return 2.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Container(
          width: 80.w,
          padding: AppPadding.all12,
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.large,
            border: Border.all(color: _borderColor, width: _borderWidth),
            boxShadow:
                widget.isUnlocked && widget.rarity == BadgeRarity.legendary
                ? [
                    BoxShadow(
                      color: AppColors.accentGold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 (이모지 직접 렌더링)
              Semantics(
                label: widget.isUnlocked ? '${widget.name} 배지 아이콘' : '잠긴 배지',
                child: ExcludeSemantics(
                  child: Text(
                    widget.isUnlocked ? widget.icon : '🔒',
                    style: TextStyle(fontSize: 28.sp),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s8),

              // 이름
              Text(
                widget.isUnlocked ? widget.name : '???',
                style: AppTextStyles.tag_12.copyWith(
                  color: widget.isUnlocked
                      ? Colors.white
                      : AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
