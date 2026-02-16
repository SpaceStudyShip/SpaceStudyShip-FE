import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';

class CategoryFolderCard extends StatefulWidget {
  const CategoryFolderCard({
    super.key,
    required this.name,
    this.emoji,
    required this.todoCount,
    required this.completedCount,
    required this.onTap,
    this.onLongPress,
    this.isEditMode = false,
    this.isSelected = false,
  });

  final String name;
  final String? emoji;
  final int todoCount;
  final int completedCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isEditMode;
  final bool isSelected;

  @override
  State<CategoryFolderCard> createState() => _CategoryFolderCardState();
}

class _CategoryFolderCardState extends State<CategoryFolderCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: widget.isEditMode && widget.isSelected
                  ? AppColors.error.withValues(alpha: 0.6)
                  : AppColors.spaceDivider,
            ),
          ),
          child: Stack(
            children: [
              // 편집 모드: 선택 체크 표시 (좌상단)
              if (widget.isEditMode)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: AnimatedContainer(
                    duration: TossDesignTokens.animationFast,
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppColors.error
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isSelected
                            ? AppColors.error
                            : AppColors.textTertiary,
                        width: 2,
                      ),
                    ),
                    child: widget.isSelected
                        ? Icon(Icons.check, size: 14.w, color: Colors.white)
                        : null,
                  ),
                ),
              // 중앙 콘텐츠
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.emoji ?? '📁',
                      style: TextStyle(fontSize: 32.sp),
                    ),
                    SizedBox(height: AppSpacing.s8),
                    Text(
                      widget.name,
                      style: AppTextStyles.label_16.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Text(
                      '${widget.completedCount}/${widget.todoCount} 완료',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
