import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../todo/domain/entities/todo_category_entity.dart';
import '../../../todo/domain/entities/todo_entity.dart';
import '../../../todo/presentation/providers/todo_provider.dart';

class TodoSelectBottomSheet extends ConsumerWidget {
  const TodoSelectBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.3, 0.5, 0.8],
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.modal,
          ),
          child: todosAsync.when(
            data: (todos) {
              final incomplete = todos
                  .where((t) => !t.isFullyCompleted)
                  .toList();

              final categoriesAsync = ref.watch(categoryListNotifierProvider);
              final categories = categoriesAsync.valueOrNull ?? [];

              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  // 드래그 핸들
                  const SliverToBoxAdapter(child: DragHandle()),

                  // 제목
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppPadding.bottomSheetTitlePadding,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '할 일 연동',
                          style: AppTextStyles.subHeading_18.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 연동 없이 시작 버튼
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppPadding.horizontal20,
                      child: AppButton(
                        text: '연동 없이 시작',
                        onPressed: () => Navigator.of(context).pop(true),
                        width: double.infinity,
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.textSecondary,
                        borderColor: AppColors.spaceDivider,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),

                  // 미완료 할일 목록
                  if (incomplete.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: AppPadding.all20,
                        child: SpaceEmptyState(
                          icon: Icons.check_circle_outline,
                          title: '미완료 할 일이 없어요',
                          subtitle: '할 일을 추가한 뒤 연동해보세요',
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
                          final todo = incomplete[index];
                          return _TodoSelectTile(
                            todo: todo,
                            categories: categories,
                            onTap: () => Navigator.of(context).pop(todo),
                          );
                        }, childCount: incomplete.length),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _TodoSelectTile extends StatelessWidget {
  const _TodoSelectTile({
    required this.todo,
    required this.categories,
    required this.onTap,
  });

  final TodoEntity todo;
  final List<TodoCategoryEntity> categories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final infoItems = _buildInfoItems();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.large,
          child: Container(
            padding: AppPadding.listItemPadding,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.spaceDivider.withValues(alpha: 0.3),
              ),
              borderRadius: AppRadius.large,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.radio_button_unchecked,
                  color: AppColors.textTertiary,
                  size: 20.w,
                ),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: AppTextStyles.label_16.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (infoItems.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.s4),
                        Text(
                          infoItems.join('  ·  '),
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _buildInfoItems() {
    final items = <String>[];

    // 카테고리 이름 (첫 번째 카테고리만)
    if (todo.categoryIds.isNotEmpty) {
      final cat = categories
          .where((c) => c.id == todo.categoryIds.first)
          .firstOrNull;
      if (cat != null) {
        final prefix = cat.emoji != null ? '${cat.emoji} ' : '';
        items.add('$prefix${cat.name}');
      }
    }

    // 예상 시간
    if (todo.estimatedMinutes != null && todo.estimatedMinutes! > 0) {
      items.add('예상 ${todo.estimatedMinutes}분');
    }

    // 누적 실제 시간
    if (todo.actualMinutes != null && todo.actualMinutes! > 0) {
      items.add('${todo.actualMinutes}분');
    }

    return items;
  }
}

/// 할일 선택 바텀시트 표시 헬퍼
/// 반환: null(dismiss) / true(연동없이시작) / TodoEntity(할일선택)
Future<Object?> showTodoSelectBottomSheet({required BuildContext context}) {
  return showModalBottomSheet<Object>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => const TodoSelectBottomSheet(),
  );
}
