import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../timer/presentation/providers/timer_provider.dart';
import '../../../timer/presentation/providers/timer_state.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';
import 'category_select_bottom_sheet.dart';
import 'todo_add_bottom_sheet.dart';

/// Slidable + TodoItem 통합 위젯
///
/// - 좌→우 (startActionPane): 카테고리 이동
/// - 우→좌 (endActionPane): 날짜에서 제거 + 삭제
/// - 탭: 할일 수정 바텀시트 (onTap 미지정 시)
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

    return Slidable(
      key: Key('${todo.id}_${contextDate?.toIso8601String() ?? "global"}'),
      groupTag: 'todos',

      // ── 좌→우: 카테고리 이동 ──
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _moveCategory(context, ref),
            backgroundColor: Colors.transparent,
            child: _buildActionContent(
              icon: Icons.drive_file_move_outline,
              label: '이동',
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),

      // ── 우→좌: 날짜에서 제거 + 삭제 ──
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: contextDate != null ? 0.5 : 0.25,
        children: [
          if (contextDate != null)
            CustomSlidableAction(
              onPressed: (_) => _removeFromDate(context, ref),
              backgroundColor: Colors.transparent,
              child: _buildActionContent(
                icon: Icons.event_busy_rounded,
                label: '제거',
                color: AppColors.accentGoldLight,
              ),
            ),
          CustomSlidableAction(
            onPressed: (_) => _deleteTodo(context, ref),
            backgroundColor: Colors.transparent,
            child: _buildActionContent(
              icon: Icons.delete_outline,
              label: '삭제',
              color: AppColors.error,
            ),
          ),
        ],
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

  Widget _buildActionContent({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22.w),
        SizedBox(height: 4.h),
        Text(label, style: AppTextStyles.tag_12.copyWith(color: color)),
      ],
    );
  }

  /// 카테고리 이동
  Future<void> _moveCategory(BuildContext context, WidgetRef ref) async {
    Slidable.of(context)?.close();
    final newCategoryIds = await showCategorySelectBottomSheet(
      context: context,
      currentCategoryIds: todo.categoryIds,
    );
    if (newCategoryIds != null && context.mounted) {
      ref
          .read(todoListNotifierProvider.notifier)
          .updateTodo(todo.copyWith(categoryIds: newCategoryIds));
    }
  }

  /// 선택된 날짜에서 제거 (bank로 복귀)
  Future<void> _removeFromDate(BuildContext context, WidgetRef ref) async {
    Slidable.of(context)?.close();
    if (contextDate == null) return;
    // 타이머 연동 체크
    if (_isLinkedToTimer(ref)) {
      AppSnackBar.warning(context, '타이머에 연동된 할 일은 제거할 수 없어요');
      return;
    }
    await ref
        .read(todoListNotifierProvider.notifier)
        .removeDateFromTodo(todo, contextDate!);
  }

  /// 할일 완전 삭제
  Future<void> _deleteTodo(BuildContext context, WidgetRef ref) async {
    Slidable.of(context)?.close();
    // 타이머 연동 체크
    if (_isLinkedToTimer(ref)) {
      AppSnackBar.warning(context, '타이머에 연동된 할 일은 삭제할 수 없어요');
      return;
    }
    final confirmed = await AppDialog.confirm(
      context: context,
      title: '할일 삭제',
      message: "'${todo.title}'을(를) 삭제하시겠습니까?\n삭제된 항목은 복구할 수 없습니다.",
      emotion: AppDialogEmotion.warning,
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      ref.read(todoListNotifierProvider.notifier).deleteTodo(todo.id);
    }
  }

  /// 할일 수정 바텀시트
  Future<void> _openEditSheet(BuildContext context, WidgetRef ref) async {
    final result = await showTodoAddBottomSheet(
      context: context,
      initialTodo: todo,
    );
    if (result != null && context.mounted) {
      ref
          .read(todoListNotifierProvider.notifier)
          .updateTodo(
            todo.copyWith(
              title: result['title'] as String,
              categoryIds: (result['categoryIds'] as List<String>?) ?? [],
              scheduledDates:
                  (result['scheduledDates'] as List<DateTime>?) ?? [],
            ),
          );
    }
  }

  /// 타이머에 연동된 할일인지 확인
  bool _isLinkedToTimer(WidgetRef ref) {
    final timerState = ref.read(timerNotifierProvider);
    return timerState.status != TimerStatus.idle &&
        timerState.linkedTodoId == todo.id;
  }
}
