import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
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
            onPressed: (slidableContext) =>
                _moveCategory(slidableContext, context, ref),
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
              onPressed: (slidableContext) =>
                  _removeFromDate(slidableContext, context, ref),
              backgroundColor: Colors.transparent,
              child: _buildActionContent(
                icon: Icons.event_busy_rounded,
                label: '제거',
                color: AppColors.accentGoldLight,
              ),
            ),
          CustomSlidableAction(
            onPressed: (slidableContext) =>
                _deleteTodo(slidableContext, context, ref),
            backgroundColor: Colors.transparent,
            child: _buildActionContent(
              icon: Icons.delete_outline,
              label: '삭제',
              color: AppColors.error,
            ),
          ),
        ],
      ),

      child: Builder(
        builder: (slidableChildContext) => TodoItem(
          title: todo.title,
          subtitle: todo.studyTimeLabel,
          isCompleted: isCompleted,
          onToggle: () {
            if (contextDate == null) return;
            ref
                .read(todoListNotifierProvider.notifier)
                .toggleTodoForDate(todo, contextDate!);
          },
          onTap:
              onTap ??
              () {
                final slidable = Slidable.of(slidableChildContext);
                if (slidable != null &&
                    (slidable.animation.value > 0 ||
                        slidable.animation.isAnimating)) {
                  slidable.close();
                  return;
                }
                _openEditSheet(context, ref);
              },
        ),
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
        SizedBox(height: AppSpacing.s4),
        Text(label, style: AppTextStyles.tag_12.copyWith(color: color)),
      ],
    );
  }

  /// 카테고리 이동
  Future<void> _moveCategory(
    BuildContext slidableContext,
    BuildContext context,
    WidgetRef ref,
  ) async {
    Slidable.of(slidableContext)?.close();
    if (!context.mounted) return;
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
  Future<void> _removeFromDate(
    BuildContext slidableContext,
    BuildContext context,
    WidgetRef ref,
  ) async {
    Slidable.of(slidableContext)?.close();
    if (contextDate == null) return;
    if (_isLinkedToTimer(ref)) {
      AppSnackBar.warning(context, '타이머에 연동된 할 일은 제거할 수 없어요');
      return;
    }
    // 마지막 날짜인 경우 확인 다이얼로그
    if (todo.scheduledDates.length == 1) {
      final confirmed = await AppDialog.confirm(
        context: context,
        title: '할일 제거',
        message: "'${todo.title}'의 마지막 배정 날짜입니다.\n제거하면 할일이 삭제됩니다.",
        emotion: AppDialogEmotion.warning,
        confirmText: '제거',
        cancelText: '취소',
        isDestructive: true,
      );
      if (confirmed != true || !context.mounted) return;
    }
    await ref
        .read(todoListNotifierProvider.notifier)
        .removeDateFromTodo(todo, contextDate!);
  }

  /// 할일 완전 삭제
  Future<void> _deleteTodo(
    BuildContext slidableContext,
    BuildContext context,
    WidgetRef ref,
  ) async {
    Slidable.of(slidableContext)?.close();
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
      await ref.read(todoListNotifierProvider.notifier).deleteTodo(todo.id);
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
