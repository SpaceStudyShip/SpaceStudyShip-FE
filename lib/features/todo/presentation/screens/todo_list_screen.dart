import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/route_paths.dart';
import '../../domain/entities/todo_category_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_add_bottom_sheet.dart';
import '../widgets/category_folder_card.dart';
import '../widgets/category_move_bottom_sheet.dart';
import '../widgets/todo_add_bottom_sheet.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '오늘의 할 일',
          style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showTodoAddBottomSheet(context: context);
              if (result != null && context.mounted) {
                ref.read(todoListNotifierProvider.notifier).addTodo(
                  title: result['title'] as String,
                  categoryId: result['categoryId'] as String?,
                );
              }
            },
            icon: Icon(Icons.add_rounded, size: 24.w),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          _buildBody(context, ref, todosAsync, categoriesAsync),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<TodoEntity>> todosAsync,
    AsyncValue<List<TodoCategoryEntity>> categoriesAsync,
  ) {
    // 둘 중 하나라도 로딩이면 로딩 표시
    if (todosAsync.isLoading || categoriesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 에러 처리
    final todosError = todosAsync.error;
    final categoriesError = categoriesAsync.error;
    if (todosError != null) {
      return Center(
        child: Text(
          '오류: $todosError',
          style: AppTextStyles.label_16.copyWith(color: AppColors.error),
        ),
      );
    }
    if (categoriesError != null) {
      return Center(
        child: Text(
          '오류: $categoriesError',
          style: AppTextStyles.label_16.copyWith(color: AppColors.error),
        ),
      );
    }

    final todos = todosAsync.valueOrNull ?? [];
    final categories = categoriesAsync.valueOrNull ?? [];
    final uncategorized = todos.where((t) => t.categoryId == null).toList();
    final hasContent = categories.isNotEmpty || uncategorized.isNotEmpty;

    if (!hasContent) {
      return const Center(
        child: SpaceEmptyState(
          icon: Icons.edit_note_rounded,
          title: '할 일이 없어요',
          subtitle: '오른쪽 상단 + 버튼으로 추가해보세요',
        ),
      );
    }

    return ListView(
      padding: AppPadding.screenPadding,
      children: [
        // ── 카테고리 폴더 섹션 ──
        if (categories.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '카테고리',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              GestureDetector(
                onTap: () => _addCategory(context, ref),
                child: Text(
                  '+ 추가',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8),
          ...categories.map((cat) {
            final catTodos =
                todos.where((t) => t.categoryId == cat.id).toList();
            final completedCount =
                catTodos.where((t) => t.completed).length;

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CategoryFolderCard(
                name: cat.name,
                emoji: cat.emoji,
                todoCount: catTodos.length,
                completedCount: completedCount,
                onTap: () {
                  context.push(
                    RoutePaths.categoryTodoPath(cat.id),
                    extra: {'name': cat.name, 'emoji': cat.emoji},
                  );
                },
                onDelete: () =>
                    _deleteCategory(context, ref, cat.id, cat.name),
              ),
            );
          }),
          SizedBox(height: AppSpacing.s16),
        ],

        // 카테고리가 없을 때 추가 유도
        if (categories.isEmpty) ...[
          _AddCategoryButton(
            onTap: () => _addCategory(context, ref),
          ),
          SizedBox(height: AppSpacing.s16),
        ],

        // ── 미분류 할일 섹션 ──
        if (uncategorized.isNotEmpty) ...[
          Text(
            '미분류',
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSpacing.s8),
          ...uncategorized.map((todo) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Dismissible(
                  key: Key(todo.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
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
                  onDismissed: (_) {
                    ref
                        .read(todoListNotifierProvider.notifier)
                        .deleteTodo(todo.id);
                  },
                  child: GestureDetector(
                    onLongPress: () async {
                      final newCategoryId =
                          await showCategoryMoveBottomSheet(
                        context: context,
                        currentCategoryId: todo.categoryId,
                      );
                      if (newCategoryId != null && context.mounted) {
                        ref
                            .read(todoListNotifierProvider.notifier)
                            .updateTodo(
                              todo.copyWith(
                                categoryId:
                                    newCategoryId == '' ? null : newCategoryId,
                              ),
                            );
                      }
                    },
                    child: TodoItem(
                      title: todo.title,
                      subtitle: todo.actualMinutes != null &&
                              todo.actualMinutes! > 0
                          ? '${todo.actualMinutes}분 공부'
                          : null,
                      isCompleted: todo.completed,
                      onToggle: () {
                        ref
                            .read(todoListNotifierProvider.notifier)
                            .toggleTodo(todo);
                      },
                    ),
                  ),
                ),
              )),
        ],
      ],
    );
  }

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final result = await showCategoryAddBottomSheet(context: context);
    if (result != null && context.mounted) {
      ref.read(categoryListNotifierProvider.notifier).addCategory(
        name: result['name'] as String,
        emoji: result['emoji'] as String?,
      );
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: '카테고리 삭제',
      message: "'$name' 카테고리를 삭제하시겠습니까?\n할일은 미분류로 이동됩니다.",
      emotion: AppDialogEmotion.warning,
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      ref.read(categoryListNotifierProvider.notifier).deleteCategory(id);
    }
  }
}

class _AddCategoryButton extends StatelessWidget {
  const _AddCategoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.cardPadding,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.spaceDivider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.create_new_folder_outlined,
                size: 20.w, color: AppColors.textTertiary),
            SizedBox(width: AppSpacing.s8),
            Text(
              '카테고리 만들기',
              style: AppTextStyles.label_16.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
