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
    this.onDelete,
  });

  final String name;
  final String? emoji;
  final int todoCount;
  final int completedCount;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

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
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.spaceDivider),
          ),
          child: Stack(
            children: [
              // 더보기 버튼 (우상단)
              if (widget.onDelete != null)
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Padding(
                      padding: AppPadding.all8,
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16.w,
                        color: AppColors.textTertiary,
                      ),
                    ),
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
