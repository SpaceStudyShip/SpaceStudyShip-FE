import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';

/// Todo 아이템 위젯 - 우주 테마
///
/// **사용 예시**:
/// ```dart
/// TodoItem(
///   title: '알고리즘 2문제 풀기',
///   isCompleted: false,
///   onToggle: () => toggleTodo(),
///   onTap: () => showDetail(),
///   onDelete: () => deleteTodo(),
/// )
/// ```
class TodoItem extends StatefulWidget {
  const TodoItem({
    super.key,
    required this.title,
    this.isCompleted = false,
    required this.onToggle,
    this.onTap,
    this.onDelete,
    this.subtitle,
    this.leading,
  });

  /// Todo 제목
  final String title;

  /// 완료 상태
  final bool isCompleted;

  /// 완료 토글 콜백
  final VoidCallback onToggle;

  /// 탭 콜백 (상세 보기)
  final VoidCallback? onTap;

  /// 삭제 콜백
  final VoidCallback? onDelete;

  /// 부제목 (예: 예상 시간)
  final String? subtitle;

  /// 왼쪽 위젯 (체크박스 대신)
  final Widget? leading;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool _isPressed = false;

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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.large,
            border: Border.all(
              color: widget.isCompleted
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.spaceDivider,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 체크박스 또는 커스텀 리딩
              widget.leading ?? _buildCheckbox(),
              SizedBox(width: 12.w),

              // 제목 및 부제목
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.label_16.copyWith(
                        color: widget.isCompleted
                            ? AppColors.textTertiary
                            : Colors.white,
                        decoration: widget.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textTertiary,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        widget.subtitle!,
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 삭제 버튼
              if (widget.onDelete != null)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.close,
                      size: 18.w,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.smoothCurve,
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: widget.isCompleted ? AppColors.success : Colors.transparent,
          borderRadius: AppRadius.small,
          border: Border.all(
            color: widget.isCompleted
                ? AppColors.success
                : AppColors.textTertiary,
            width: 2,
          ),
        ),
        child: widget.isCompleted
            ? Icon(Icons.check, size: 16.w, color: Colors.white)
            : null,
      ),
    );
  }
}
