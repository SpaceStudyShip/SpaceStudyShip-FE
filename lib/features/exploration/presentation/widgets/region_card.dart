import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/exploration_node_entity.dart';
import 'region_flag_icon.dart';

/// 지역 카드 위젯
///
/// 행성 상세 화면에서 지역(Region) 노드를 표시합니다.
/// 해금/미해금/클리어 3가지 상태를 시각적으로 표현합니다.
class RegionCard extends StatefulWidget {
  const RegionCard({
    super.key,
    required this.node,
    required this.currentFuel,
    this.onTap,
  });

  /// 지역 노드 데이터
  final ExplorationNodeEntity node;

  /// 현재 보유 연료 (해금 가능 여부 판단용)
  final int currentFuel;

  /// 탭 콜백
  final VoidCallback? onTap;

  @override
  State<RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<RegionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isLocked = !widget.node.isUnlocked;
    final isCleared = widget.node.isCleared;

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
          margin: EdgeInsets.only(bottom: AppSpacing.s12),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: isCleared
                ? AppColors.success.withValues(alpha: 0.08)
                : isLocked
                ? AppColors.spaceBackground
                : AppColors.spaceSurface,
            borderRadius: AppRadius.large,
            border: Border.all(
              color: isCleared
                  ? AppColors.success.withValues(alpha: 0.4)
                  : isLocked
                  ? AppColors.spaceDivider.withValues(alpha: 0.5)
                  : AppColors.spaceDivider,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 지역 아이콘 (클리어 시 체크 오버레이)
              _buildRegionIconWithStatus(isLocked, isCleared),
              SizedBox(width: AppSpacing.s16),

              // 지역 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.node.name,
                      style: AppTextStyles.paragraph14Semibold.copyWith(
                        color: isLocked ? AppColors.textTertiary : Colors.white,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),
                    if (!isLocked && widget.node.description.isNotEmpty)
                      Text(
                        widget.node.description,
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // 잠금 아이콘
              if (isLocked) ...[
                SizedBox(width: AppSpacing.s8),
                Icon(
                  Icons.lock_rounded,
                  size: 18.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionIconWithStatus(bool isLocked, bool isCleared) {
    final double size = 40.w;
    final flag = RegionFlagIcon(
      icon: widget.node.icon,
      size: size,
      isLocked: isLocked,
    );

    if (!isCleared) return flag;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          flag,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.spaceBackground,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(1),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 16.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
