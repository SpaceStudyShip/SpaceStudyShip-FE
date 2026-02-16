import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';
import 'category_move_bottom_sheet.dart';

/// 양방향 스와이프 Dismissible + TodoItem 통합 위젯
///
/// - 좌→우: 카테고리 이동 바텀시트
/// - 우→좌: 삭제 확인 다이얼로그
/// - 탭: 완료 토글 (onTap 미지정 시)
class DismissibleTodoItem extends ConsumerWidget {
  const DismissibleTodoItem({
    super.key,
    required this.todo,
    this.onTap,
  });

  final TodoEntity todo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final newCategoryId = await showCategoryMoveBottomSheet(
            context: context,
            currentCategoryId: todo.categoryId,
          );
          if (newCategoryId != null && context.mounted) {
            ref.read(todoListNotifierProvider.notifier).updateTodo(
              todo.copyWith(
                categoryId: newCategoryId == '' ? null : newCategoryId,
              ),
            );
          }
          return false;
        }
        final confirmed = await AppDialog.confirm(
          context: context,
          title: '할일 삭제',
          message:
              "'${todo.title}'을(를) 삭제하시겠습니까?\n삭제된 항목은 복구할 수 없습니다.",
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
        child: Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 24.w,
        ),
      ),
      child: TodoItem(
        title: todo.title,
        subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
            ? '${todo.actualMinutes}분 공부'
            : null,
        isCompleted: todo.completed,
        onToggle: () {
          ref.read(todoListNotifierProvider.notifier).toggleTodo(todo);
        },
        onTap: onTap,
      ),
    );
  }
}
