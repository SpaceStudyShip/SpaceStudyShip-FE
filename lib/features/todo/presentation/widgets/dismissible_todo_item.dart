import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';
import 'category_move_bottom_sheet.dart';
import 'todo_add_bottom_sheet.dart';

/// 양방향 스와이프 Dismissible + TodoItem 통합 위젯
///
/// - 좌→우: 카테고리 이동 바텀시트
/// - 우→좌: 삭제 확인 (다중 날짜면 3가지 선택)
/// - 탭: 완료 토글 (onTap 미지정 시)
///
/// [contextDate] 캘린더에서 선택된 날짜. null이면 글로벌(isFullyCompleted) 사용.
class DismissibleTodoItem extends ConsumerWidget {
  const DismissibleTodoItem({
    super.key,
    required this.todo,
    this.contextDate,
    this.onTap,
  });

  final TodoEntity todo;
  final DateTime? contextDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = contextDate != null
        ? todo.isCompletedForDate(contextDate!)
        : todo.isFullyCompleted;

    return Dismissible(
      key: Key('${todo.id}_${contextDate?.toIso8601String() ?? "global"}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final newCategoryId = await showCategoryMoveBottomSheet(
            context: context,
            currentCategoryId: todo.categoryId,
          );
          if (newCategoryId != null && context.mounted) {
            ref
                .read(todoListNotifierProvider.notifier)
                .updateTodo(
                  todo.copyWith(
                    categoryId: newCategoryId == '' ? null : newCategoryId,
                  ),
                );
          }
          return false;
        }
        // 삭제 방향: 다중 날짜 할일이면 선택지 표시
        if (todo.scheduledDates.length > 1 && contextDate != null) {
          final action = await _showMultiDateDeleteSheet(context);
          if (action == null) return false;
          if (!context.mounted) return false;
          final notifier = ref.read(todoListNotifierProvider.notifier);
          switch (action) {
            case _DeleteAction.thisDateOnly:
              await notifier.removeDateFromTodo(todo, contextDate!);
              return false; // 직접 처리함
            case _DeleteAction.thisAndAfter:
              await notifier.removeDateAndAfterFromTodo(todo, contextDate!);
              return false;
            case _DeleteAction.all:
              return true; // onDismissed에서 삭제
          }
        }
        // 단일 날짜 또는 글로벌 뷰: 기존 삭제 확인
        if (!context.mounted) return false;
        final confirmed = await AppDialog.confirm(
          context: context,
          title: '할일 삭제',
          message: "'${todo.title}'을(를) 삭제하시겠습니까?\n삭제된 항목은 복구할 수 없습니다.",
          emotion: AppDialogEmotion.warning,
          confirmText: '삭제',
          cancelText: '취소',
          isDestructive: true,
        );
        return confirmed == true;
      },
      onDismissed: (_) {
        ref.read(todoListNotifierProvider.notifier).deleteTodo(todo.id);
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: AppPadding.horizontal20,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          borderRadius: AppRadius.large,
        ),
        child: Icon(
          Icons.drive_file_move_outline,
          color: AppColors.primary,
          size: 24.w,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: AppPadding.horizontal20,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: AppRadius.large,
        ),
        child: Icon(Icons.delete_outline, color: AppColors.error, size: 24.w),
      ),
      child: TodoItem(
        title: todo.title,
        subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
            ? '${todo.actualMinutes}분 공부'
            : null,
        isCompleted: isCompleted,
        onToggle: () {
          final date = contextDate ?? DateTime.now();
          ref
              .read(todoListNotifierProvider.notifier)
              .toggleTodoForDate(todo, date);
        },
        onTap: onTap ?? () => _openEditSheet(context, ref),
      ),
    );
  }

  void _openEditSheet(BuildContext context, WidgetRef ref) async {
    final result = await showTodoAddBottomSheet(
      context: context,
      initialTodo: todo,
    );
    if (result != null && context.mounted) {
      ref.read(todoListNotifierProvider.notifier).updateTodo(
            todo.copyWith(
              title: result['title'] as String,
              categoryId: result['categoryId'] as String?,
              scheduledDates:
                  (result['scheduledDates'] as List<DateTime>?) ?? [],
            ),
          );
    }
  }

  Future<_DeleteAction?> _showMultiDateDeleteSheet(BuildContext context) {
    return showModalBottomSheet<_DeleteAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MultiDateDeleteSheet(contextDate: contextDate!),
    );
  }
}

enum _DeleteAction { thisDateOnly, thisAndAfter, all }

class _MultiDateDeleteSheet extends StatelessWidget {
  const _MultiDateDeleteSheet({required this.contextDate});

  final DateTime contextDate;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('M/d (E)', 'ko_KR').format(contextDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Text(
              '반복 할일 삭제',
              style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
            ),
          ),
          _buildOption(
            context,
            icon: Icons.today,
            label: '$dateLabel만 삭제',
            action: _DeleteAction.thisDateOnly,
          ),
          _buildOption(
            context,
            icon: Icons.event,
            label: '$dateLabel 이후 모두 삭제',
            action: _DeleteAction.thisAndAfter,
          ),
          _buildOption(
            context,
            icon: Icons.delete_forever,
            label: '전체 삭제',
            action: _DeleteAction.all,
            isDestructive: true,
          ),
          SizedBox(height: AppSpacing.s8),
          // 취소 버튼
          Padding(
            padding: AppPadding.horizontal20,
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12.h),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required _DeleteAction action,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(action),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.textSecondary,
                size: 20.w,
              ),
              SizedBox(width: AppSpacing.s12),
              Text(
                label,
                style: AppTextStyles.label_16.copyWith(
                  color: isDestructive ? AppColors.error : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
