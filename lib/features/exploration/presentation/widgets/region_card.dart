import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/space_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/exploration_node_entity.dart';

/// 지역 카드 위젯
///
/// 행성 상세 화면에서 지역(Region) 노드를 표시합니다.
/// 해금/미해금/클리어 3가지 상태를 시각적으로 표현합니다.
class RegionCard extends StatefulWidget {
  const RegionCard({
    super.key,
    required this.node,
    required this.currentFuel,
    this.onUnlock,
    this.onTap,
  });

  /// 지역 노드 데이터
  final ExplorationNodeEntity node;

  /// 현재 보유 연료 (해금 가능 여부 판단용)
  final double currentFuel;

  /// 해금 버튼 콜백 (null이면 해금 불가)
  final VoidCallback? onUnlock;

  /// 탭 콜백 (클리어된 지역 재방문 등)
  final VoidCallback? onTap;

  @override
  State<RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<RegionCard> {
  bool _isPressed = false;

  bool get _canUnlock =>
      !widget.node.isUnlocked && widget.currentFuel >= widget.node.requiredFuel;

  @override
  Widget build(BuildContext context) {
    final isLocked = !widget.node.isUnlocked;
    final isCleared = widget.node.isCleared;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (isLocked && _canUnlock) {
          widget.onUnlock?.call();
        } else if (!isLocked) {
          widget.onTap?.call();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
              // 지역 아이콘
              _buildRegionIcon(isLocked, isCleared),
              SizedBox(width: AppSpacing.s12),

              // 지역 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.node.name,
                            style: AppTextStyles.paragraph14Semibold.copyWith(
                              color: isLocked
                                  ? AppColors.textTertiary
                                  : Colors.white,
                            ),
                          ),
                        ),
                        if (isCleared)
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 18.w,
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    if (isLocked)
                      _buildLockedInfo()
                    else if (widget.node.description.isNotEmpty)
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

              // 해금 버튼 또는 상태 표시
              if (isLocked) ...[
                SizedBox(width: AppSpacing.s8),
                _buildUnlockButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionIcon(bool isLocked, bool isCleared) {
    final iconColor = isCleared
        ? AppColors.success
        : isLocked
        ? AppColors.textTertiary
        : SpaceIcons.colorOf(widget.node.icon);

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCleared
            ? AppColors.success.withValues(alpha: 0.15)
            : isLocked
            ? AppColors.spaceDivider.withValues(alpha: 0.2)
            : iconColor.withValues(alpha: 0.1),
      ),
      child: Center(
        child: isLocked
            ? Icon(
                Icons.lock_rounded,
                size: 18.sp,
                color: AppColors.textTertiary,
              )
            : SpaceIcons.buildIcon(widget.node.icon, size: 18.sp),
      ),
    );
  }

  Widget _buildLockedInfo() {
    final fuelColor = _canUnlock
        ? AppColors.accentGold
        : AppColors.textTertiary;
    return Row(
      children: [
        Icon(Icons.local_gas_station_rounded, size: 12.sp, color: fuelColor),
        SizedBox(width: 2.w),
        Text(
          '${widget.node.requiredFuel.toStringAsFixed(1)}통',
          style: AppTextStyles.tag_12.copyWith(
            color: fuelColor,
            fontWeight: _canUnlock ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (!_canUnlock) ...[
          SizedBox(width: AppSpacing.s4),
          Text(
            '(부족)',
            style: AppTextStyles.tag_10.copyWith(
              color: AppColors.error.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUnlockButton() {
    return AnimatedContainer(
      duration: TossDesignTokens.animationFast,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _canUnlock
            ? AppColors.primary
            : AppColors.spaceDivider.withValues(alpha: 0.3),
        borderRadius: AppRadius.medium,
      ),
      child: Text(
        '해금',
        style: AppTextStyles.tag_12.copyWith(
          color: _canUnlock ? Colors.white : AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
