import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/space_icons.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';

/// 우주선 희귀도
enum SpaceshipRarity {
  /// 일반 (정적)
  normal,

  /// 희귀 (정적, 국가 테마)
  rare,

  /// 에픽 (Rive 애니메이션)
  epic,

  /// 레전더리 (Rive 애니메이션)
  legendary,
}

/// 우주선 카드 위젯 - 컬렉션용
///
/// **사용 예시**:
/// ```dart
/// SpaceshipCard(
///   icon: '🚀',
///   name: '화성 탐사선',
///   isUnlocked: true,
///   isAnimated: true,
///   rarity: SpaceshipRarity.epic,
///   onTap: () => selectSpaceship(),
/// )
/// ```
class SpaceshipCard extends StatefulWidget {
  const SpaceshipCard({
    super.key,
    required this.icon,
    required this.name,
    this.isUnlocked = false,
    this.isAnimated = false,
    this.isSelected = false,
    this.rarity = SpaceshipRarity.normal,
    this.onTap,
  });

  /// 우주선 아이콘 (이모지)
  final String icon;

  /// 우주선 이름
  final String name;

  /// 해금 여부
  final bool isUnlocked;

  /// 애니메이션 여부 (Rive)
  final bool isAnimated;

  /// 현재 선택된 우주선 여부
  final bool isSelected;

  /// 희귀도
  final SpaceshipRarity rarity;

  /// 탭 콜백
  final VoidCallback? onTap;

  @override
  State<SpaceshipCard> createState() => _SpaceshipCardState();
}

class _SpaceshipCardState extends State<SpaceshipCard> {
  bool _isPressed = false;

  Color get _borderColor {
    if (widget.isSelected) return AppColors.primary;
    if (!widget.isUnlocked) return AppColors.spaceDivider;

    switch (widget.rarity) {
      case SpaceshipRarity.normal:
        return AppColors.textTertiary;
      case SpaceshipRarity.rare:
        return AppColors.primary;
      case SpaceshipRarity.epic:
        return AppColors.secondary;
      case SpaceshipRarity.legendary:
        return AppColors.accentGold;
    }
  }

  Color get _rarityBadgeColor {
    switch (widget.rarity) {
      case SpaceshipRarity.normal:
        return AppColors.textTertiary;
      case SpaceshipRarity.rare:
        return AppColors.primary;
      case SpaceshipRarity.epic:
        return AppColors.secondary;
      case SpaceshipRarity.legendary:
        return AppColors.accentGold;
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.large,
            border: Border.all(
              color: _borderColor,
              width: widget.isSelected ? 2.5 : 1.5,
            ),
            boxShadow:
                widget.isUnlocked && widget.rarity == SpaceshipRarity.legendary
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
              // 우주선 아이콘 + 애니메이션 마크
              Stack(
                alignment: Alignment.center,
                children: [
                  widget.isUnlocked
                      ? SpaceIcons.buildIcon(
                          widget.icon,
                          size: 32.w,
                        )
                      : Icon(
                          SpaceIcons.resolve(widget.icon),
                          size: 32.w,
                          color: AppColors.textTertiary,
                        ),
                  if (!widget.isUnlocked)
                    Icon(Icons.lock_rounded, size: 20.w, color: AppColors.textTertiary),
                  // 애니메이션 마크
                  if (widget.isAnimated && widget.isUnlocked)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 12.w,
                        color: AppColors.accentGold,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),

              // 이름 + 희귀도 배지
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isUnlocked &&
                      widget.rarity != SpaceshipRarity.normal)
                    Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.only(right: 4.w),
                      decoration: BoxDecoration(
                        color: _rarityBadgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Flexible(
                    child: Text(
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
                  ),
                ],
              ),

              // 선택 체크 표시
              if (widget.isSelected) ...[
                SizedBox(height: 4.h),
                Icon(Icons.check_circle, size: 16.w, color: AppColors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
