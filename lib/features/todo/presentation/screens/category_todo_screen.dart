import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_move_bottom_sheet.dart';
import '../widgets/todo_add_bottom_sheet.dart';

class CategoryTodoScreen extends ConsumerWidget {
  const CategoryTodoScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.categoryEmoji,
  });

  final String categoryId;
  final String categoryName;
  final String? categoryEmoji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Hero(
          tag: 'category_$categoryId',
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (categoryEmoji != null)
                  Text(categoryEmoji!, style: TextStyle(fontSize: 20.sp)),
                if (categoryEmoji != null) SizedBox(width: AppSpacing.s8),
                Text(
                  categoryName,
                  style: AppTextStyles.subHeading_18.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showTodoAddBottomSheet(
                context: context,
                initialCategoryId: categoryId,
              );
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
          todosAsync.when(
            data: (todos) {
              final categoryTodos =
                  todos.where((t) => t.categoryId == categoryId).toList();

              if (categoryTodos.isEmpty) {
                return const Center(
                  child: SpaceEmptyState(
                    icon: Icons.folder_open_rounded,
                    title: '할 일이 없어요',
                    subtitle: '오른쪽 상단 + 버튼으로 추가해보세요',
                  ),
                );
              }

              return ListView.builder(
                padding: AppPadding.screenPadding,
                itemCount: categoryTodos.length,
                itemBuilder: (context, index) {
                  final todo = categoryTodos[index];
                  return Padding(
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
                                    categoryId: newCategoryId == ''
                                        ? null
                                        : newCategoryId,
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
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                '오류: $error',
                style:
                    AppTextStyles.label_16.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
