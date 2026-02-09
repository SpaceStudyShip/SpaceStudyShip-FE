import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/space_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../domain/entities/exploration_node_entity.dart';
import '../../domain/entities/exploration_progress_entity.dart';

/// 맵 위 행성 노드 위젯
///
/// 우주 맵에서 행성을 원형 아이콘으로 표시합니다.
/// 해금/잠금/클리어 3가지 상태를 시각적으로 구분합니다.
class PlanetNode extends StatefulWidget {
  const PlanetNode({
    super.key,
    required this.node,
    this.progress,
    this.isCurrentLocation = false,
    required this.onTap,
  });

  final ExplorationNodeEntity node;
  final ExplorationProgressEntity? progress;
  final bool isCurrentLocation;
  final VoidCallback onTap;

  @override
  State<PlanetNode> createState() => _PlanetNodeState();
}

class _PlanetNodeState extends State<PlanetNode>
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
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 우주선 표시
              if (widget.isCurrentLocation) ...[
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 16.sp,
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
                style: AppTextStyles.tag_12.copyWith(
                  color: isLocked ? AppColors.textTertiary : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              // 진행도 or 필요 연료
              if (isLocked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 10.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${widget.node.requiredFuel.toStringAsFixed(1)}통',
                      style: AppTextStyles.tag_10.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                )
              else if (widget.progress != null && !isCleared)
                Text(
                  '${widget.progress!.clearedChildren}/${widget.progress!.totalChildren}',
                  style: AppTextStyles.tag_10.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                )
              else if (isCleared)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 10.sp,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '클리어',
                      style: AppTextStyles.tag_10.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
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
    final circleSize = 56.w;
    final planetGradient = SpaceIcons.gradientOf(widget.node.icon);
    final planetColor = SpaceIcons.colorOf(widget.node.icon);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = widget.node.isUnlocked && !isCleared
            ? 0.15 + _glowController.value * 0.2
            : 0.0;

        return Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isLocked
                ? null
                : RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.9,
                    colors: [
                      planetGradient[0].withValues(
                        alpha: isCleared ? 0.15 : 0.3,
                      ),
                      planetGradient[1].withValues(
                        alpha: isCleared ? 0.08 : 0.15,
                      ),
                    ],
                  ),
            color: isLocked
                ? AppColors.spaceDivider.withValues(alpha: 0.4)
                : null,
            border: Border.all(
              color: isCleared
                  ? AppColors.success.withValues(alpha: 0.6)
                  : isLocked
                  ? AppColors.spaceDivider.withValues(alpha: 0.5)
                  : planetColor.withValues(alpha: 0.5),
              width: isCleared ? 2.0 : 1.5,
            ),
            boxShadow: glowOpacity > 0
                ? [
                    BoxShadow(
                      color: planetColor.withValues(alpha: glowOpacity),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLocked
                ? Icon(
                    Icons.lock_rounded,
                    size: 22.sp,
                    color: AppColors.textTertiary,
                  )
                : ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: planetGradient,
                    ).createShader(bounds),
                    child: Icon(
                      SpaceIcons.resolve(widget.node.icon),
                      size: 26.sp,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
