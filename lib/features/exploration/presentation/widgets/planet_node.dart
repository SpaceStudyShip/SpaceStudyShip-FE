import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/planet_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../providers/exploration_provider.dart';

/// 맵 위 행성 노드 위젯
///
/// 우주 맵에서 행성을 원형 아이콘으로 표시합니다.
/// 해금/잠금/클리어 3가지 상태를 시각적으로 구분합니다.
/// 진행도를 내부에서 직접 watch하여 해당 행성만 리빌드됩니다.
class PlanetNode extends ConsumerStatefulWidget {
  const PlanetNode({
    super.key,
    required this.node,
    this.isCurrentLocation = false,
    required this.onTap,
  });

  final ExplorationNodeEntity node;
  final bool isCurrentLocation;
  final VoidCallback onTap;

  @override
  ConsumerState<PlanetNode> createState() => _PlanetNodeState();
}

class _PlanetNodeState extends ConsumerState<PlanetNode>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.node.isUnlocked && !widget.node.isCleared) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !widget.node.isUnlocked;
    final isCleared = widget.node.isCleared;
    final progress = ref.watch(explorationProgressProvider(widget.node.id));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: SizedBox(
          width: 100.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 우주선 표시
              if (widget.isCurrentLocation) ...[
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(height: 2.h),
              ],

              // 행성 원형 아이콘
              _buildPlanetCircle(isLocked, isCleared),

              SizedBox(height: AppSpacing.s4),

              // 행성 이름
              Text(
                widget.node.name,
                style: AppTextStyles.label16Medium.copyWith(
                  color: isLocked ? AppColors.textTertiary : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.s4),

              // 진행도 or 필요 연료
              if (isLocked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${widget.node.requiredFuel}통',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                )
              else if (!isCleared)
                Text(
                  '${progress.clearedChildren}/${progress.totalChildren}',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                )
              else if (isCleared)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 12.sp,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '클리어',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanetCircle(bool isLocked, bool isCleared) {
    final iconSize = 80.w;
    final planetColor = PlanetIcons.colorOf(widget.node.icon);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = widget.node.isUnlocked && !isCleared
            ? 0.15 + _glowController.value * 0.2
            : 0.0;

        return Container(
          width: iconSize,
          height: iconSize,
          decoration: glowOpacity > 0
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: planetColor.withValues(alpha: glowOpacity),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                )
              : null,
          child: isLocked
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.spaceDivider.withValues(alpha: 0.4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 22.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                )
              : PlanetIcons.buildIcon(widget.node.icon, size: iconSize),
        );
      },
    );
  }
}
