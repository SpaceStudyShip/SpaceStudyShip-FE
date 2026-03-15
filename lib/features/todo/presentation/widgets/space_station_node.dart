import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import 'planet_map_node.dart';

/// 캔버스 중앙의 우주 정거장 (미분류 할일 허브)
class SpaceStationNode extends StatefulWidget {
  const SpaceStationNode({
    super.key,
    required this.uncategorizedCount,
    required this.zoomTier,
    required this.onTap,
  });

  final int uncategorizedCount;
  final ZoomTier zoomTier;
  final VoidCallback onTap;

  @override
  State<SpaceStationNode> createState() => _SpaceStationNodeState();
}

class _SpaceStationNodeState extends State<SpaceStationNode> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final showLabel = widget.zoomTier != ZoomTier.far;
    final showCount = widget.zoomTier == ZoomTier.close;

    return Semantics(
      label: '미분류 할일 ${widget.uncategorizedCount}개',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.spaceSurface,
                  border: Border.all(color: AppColors.spaceDivider, width: 2),
                ),
                child: Icon(
                  Icons.space_dashboard_rounded,
                  size: 32.w,
                  color: AppColors.textSecondary,
                ),
              ),

              // 라벨
              AnimatedOpacity(
                opacity: showLabel ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    '미분류',
                    style: AppTextStyles.tag_12.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // 개수
              AnimatedOpacity(
                opacity: showCount ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Text(
                  '${widget.uncategorizedCount}개',
                  style: AppTextStyles.tag_10.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
