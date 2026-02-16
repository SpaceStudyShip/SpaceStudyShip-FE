import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../providers/todo_provider.dart';
import '../widgets/dismissible_todo_item.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (categoryEmoji != null)
              Text(categoryEmoji!, style: TextStyle(fontSize: 20.sp)),
            if (categoryEmoji != null) SizedBox(width: AppSpacing.s8),
            Text(
              categoryName,
              style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
            ),
          ],
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
                ref
                    .read(todoListNotifierProvider.notifier)
                    .addTodo(
                      title: result['title'] as String,
                      categoryId: result['categoryId'] as String?,
                      scheduledDates:
                          result['scheduledDates'] as List<DateTime>?,
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
              final categoryTodos = todos
                  .where((t) => t.categoryId == categoryId)
                  .toList();

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
                padding: EdgeInsets.only(
                  top:
                      MediaQuery.of(context).padding.top +
                      kToolbarHeight +
                      16.h,
                  left: 20.w,
                  right: 20.w,
                  bottom: 16.h,
                ),
                itemCount: categoryTodos.length,
                itemBuilder: (context, index) {
                  final todo = categoryTodos[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: DismissibleTodoItem(todo: todo),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                '오류: $error',
                style: AppTextStyles.label_16.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
