import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../providers/todo_provider.dart';
import 'dismissible_todo_item.dart';
import 'todo_add_bottom_sheet.dart';

/// 카테고리 할일 바텀시트
///
/// 캔버스에서 행성/정거장 탭 시 표시.
/// [categoryId]가 null이면 미분류 할일 표시.
class CategoryTodoBottomSheet extends ConsumerWidget {
  const CategoryTodoBottomSheet({
    super.key,
    this.categoryId,
    this.categoryName = '미분류',
    this.categoryIconId,
    required this.bottomPadding,
  });

  final String? categoryId;
  final String categoryName;
  final String? categoryIconId;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosForCategoryProvider(categoryId));
    final stats = ref.watch(categoryTodoStatsProvider(categoryId));

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.55, 0.75, 0.9],
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.modal,
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              const SliverToBoxAdapter(child: DragHandle()),

              // 헤더: 아이콘 + 이름 + 진행률
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppPadding.horizontal20,
                  child: Row(
                    children: [
                      if (categoryId != null)
                        CategoryIcons.buildIcon(categoryIconId, size: 24.w)
                      else
                        Icon(
                          Icons.space_dashboard_rounded,
                          size: 24.w,
                          color: AppColors.textSecondary,
                        ),
                      SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: AppTextStyles.subHeading_18.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${stats.completedCount}/${stats.todoCount} 완료',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),

              // 할 일 추가 버튼
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppPadding.horizontal20,
                  child: AppButton(
                    text: '+ 할 일 추가',
                    onPressed: () async {
                      final result = await showTodoAddBottomSheet(
                        context: context,
                        initialCategoryIds: categoryId != null
                            ? [categoryId!]
                            : null,
                      );
                      if (result != null && context.mounted) {
                        ref
                            .read(todoListNotifierProvider.notifier)
                            .addTodo(
                              title: result['title'] as String,
                              categoryIds:
                                  (result['categoryIds'] as List<String>?) ??
                                  [],
                              scheduledDates:
                                  result['scheduledDates'] as List<DateTime>?,
                            );
                      }
                    },
                    width: double.infinity,
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.textSecondary,
                    borderColor: AppColors.spaceDivider,
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),

              // 할일 목록
              if (todos.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppSpacing.s40),
                    child: const SpaceEmptyState(
                      icon: Icons.folder_open_rounded,
                      title: '할 일이 없어요',
                      subtitle: '위 버튼으로 추가해보세요',
                      iconSize: 32,
                      animated: false,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: AppPadding.horizontal20,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final todo = todos[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.s8),
                        child: DismissibleTodoItem(todo: todo),
                      );
                    }, childCount: todos.length),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
            ],
          ),
        );
      },
    );
  }
}
