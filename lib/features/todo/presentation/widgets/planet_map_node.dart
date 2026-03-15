import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';

/// 줌 티어 — 캔버스 확대 수준에 따라 노드 정보 표시 범위 결정
enum ZoomTier { far, normal, close }

/// 카테고리 맵 캔버스 위의 행성 노드
///
/// [zoomTier]에 따라 표시 정보가 달라짐:
/// - far: 아이콘만
/// - normal: 아이콘 + 이름
/// - close: 아이콘 + 이름 + 진행률
class PlanetMapNode extends StatefulWidget {
  const PlanetMapNode({
    super.key,
    required this.categoryId,
    required this.name,
    this.iconId,
    required this.todoCount,
    required this.completedCount,
    required this.zoomTier,
    required this.onTap,
    required this.onLongPress,
    this.isDragging = false,
  });

  final String categoryId;
  final String name;
  final String? iconId;
  final int todoCount;
  final int completedCount;
  final ZoomTier zoomTier;
  final VoidCallback onTap;
  final void Function(LongPressStartDetails) onLongPress;
  final bool isDragging;

  @override
  State<PlanetMapNode> createState() => _PlanetMapNodeState();
}

class _PlanetMapNodeState extends State<PlanetMapNode> {
  bool _isPressed = false;

  /// 할일 수에 따른 행성 크기: 48.w ~ 80.w
  double get _planetSize {
    final base = 48.w;
    final scaled = base + (widget.todoCount * 4.w);
    return scaled.clamp(base, 80.w);
  }

  @override
  Widget build(BuildContext context) {
    final showName = widget.zoomTier != ZoomTier.far;
    final showProgress = widget.zoomTier == ZoomTier.close;

    return Semantics(
      label: '${widget.name} 카테고리, 할일 ${widget.todoCount}개',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPressStart: widget.onLongPress,
        child: AnimatedScale(
          scale: widget.isDragging
              ? 1.1
              : _isPressed
              ? TossDesignTokens.cardTapScale
              : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 중 그림자
              if (widget.isDragging)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CategoryIcons.buildIcon(
                    widget.iconId,
                    size: _planetSize,
                  ),
                )
              else
                CategoryIcons.buildIcon(widget.iconId, size: _planetSize),

              // 이름 (normal/close 줌 티어)
              AnimatedOpacity(
                opacity: showName ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    widget.name,
                    style: AppTextStyles.tag_12.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // 진행률 (close 줌 티어만)
              AnimatedOpacity(
                opacity: showProgress ? 1.0 : 0.0,
                duration: TossDesignTokens.animationFast,
                child: Text(
                  '${widget.completedCount}/${widget.todoCount} 완료',
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
