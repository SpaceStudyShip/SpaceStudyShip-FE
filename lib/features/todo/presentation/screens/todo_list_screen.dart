import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../../routes/route_paths.dart';
import '../../domain/entities/todo_category_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_add_bottom_sheet.dart';
import '../widgets/category_folder_card.dart';
import '../widgets/category_move_bottom_sheet.dart';
import '../widgets/todo_add_bottom_sheet.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  bool _isEditMode = false;
  final Set<String> _selectedCategoryIds = {};
  final Set<String> _selectedTodoIds = {};

  int get _selectedCount =>
      _selectedCategoryIds.length + _selectedTodoIds.length;

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedCategoryIds.clear();
        _selectedTodoIds.clear();
      }
    });
  }

  void _toggleCategorySelection(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  void _toggleTodoSelection(String id) {
    setState(() {
      if (_selectedTodoIds.contains(id)) {
        _selectedTodoIds.remove(id);
      } else {
        _selectedTodoIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoListNotifierProvider);
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _isEditMode
            ? Text(
                '$_selectedCount개 선택됨',
                style: AppTextStyles.subHeading_18.copyWith(
                  color: Colors.white,
                ),
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: _toggleEditMode,
              child: Text(
                '취소',
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            IconButton(
              onPressed: _toggleEditMode,
              icon: Icon(
                Icons.delete_outline,
                size: 24.w,
                color: AppColors.error,
              ),
            ),
        ],
      ),
      floatingActionButton: _isEditMode && _selectedCount > 0
          ? Padding(
              padding: EdgeInsets.only(
                bottom: kBottomNavigationBarHeight + 50.h,
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _confirmBatchDelete(context),
                backgroundColor: AppColors.error,
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 20.w,
                ),
                label: Text(
                  '$_selectedCount개 삭제',
                  style: AppTextStyles.label_16.copyWith(color: Colors.white),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          _buildBody(todosAsync, categoriesAsync),
        ],
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<TodoEntity>> todosAsync,
    AsyncValue<List<TodoCategoryEntity>> categoriesAsync,
  ) {
    if (todosAsync.isLoading || categoriesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 36.h,
        left: 20.w,
        right: 20.w,
        bottom: 16.h,
      ),
      children: [
        // ── 카테고리 섹션 헤더 ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '카테고리',
              style: AppTextStyles.heading_20.copyWith(color: Colors.white),
            ),
            if (!_isEditMode)
              GestureDetector(
                onTap: () => _addCategory(context),
                child: Text(
                  '+ 추가',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.s20),

        // ── 카테고리 2열 그리드 ──
        if (categories.isNotEmpty)
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: AppSpacing.s12,
              mainAxisSpacing: AppSpacing.s12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catTodos = todos
                  .where((t) => t.categoryId == cat.id)
                  .toList();
              final completedCount = catTodos.where((t) => t.completed).length;

              return CategoryFolderCard(
                name: cat.name,
                emoji: cat.emoji,
                todoCount: catTodos.length,
                completedCount: completedCount,
                isEditMode: _isEditMode,
                isSelected: _selectedCategoryIds.contains(cat.id),
                onTap: () {
                  if (_isEditMode) {
                    _toggleCategorySelection(cat.id);
                  } else {
                    context.push(
                      RoutePaths.categoryTodoPath(cat.id),
                      extra: {'name': cat.name, 'emoji': cat.emoji},
                    );
                  }
                },
              );
            },
          ),
        SizedBox(height: AppSpacing.s56),

        // ── 미분류 할일 섹션 ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '미분류',
              style: AppTextStyles.heading_20.copyWith(color: Colors.white),
            ),
            if (!_isEditMode)
              GestureDetector(
                onTap: () async {
                  final result = await showTodoAddBottomSheet(context: context);
                  if (result != null && mounted) {
                    ref
                        .read(todoListNotifierProvider.notifier)
                        .addTodo(
                          title: result['title'] as String,
                          categoryId: result['categoryId'] as String?,
                        );
                  }
                },
                child: Text(
                  '+ 추가',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.s20),
        if (uncategorized.isNotEmpty)
          ...uncategorized.map(
            (todo) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _isEditMode
                  ? TodoItem(
                      title: todo.title,
                      subtitle:
                          todo.actualMinutes != null && todo.actualMinutes! > 0
                          ? '${todo.actualMinutes}분 공부'
                          : null,
                      isCompleted: todo.completed,
                      onToggle: () => _toggleTodoSelection(todo.id),
                      onTap: () => _toggleTodoSelection(todo.id),
                      leading: _buildSelectionCheckbox(
                        _selectedTodoIds.contains(todo.id),
                      ),
                    )
                  : Dismissible(
                      key: Key(todo.id),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          final newCategoryId =
                              await showCategoryMoveBottomSheet(
                                context: context,
                                currentCategoryId: todo.categoryId,
                              );
                          if (newCategoryId != null && mounted) {
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
                          return false;
                        }
                        // 삭제 확인
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
                        ref
                            .read(todoListNotifierProvider.notifier)
                            .deleteTodo(todo.id);
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
                        subtitle:
                            todo.actualMinutes != null &&
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
          ),
      ],
    );
  }

  Widget _buildSelectionCheckbox(bool isSelected) {
    return AnimatedContainer(
      duration: TossDesignTokens.animationFast,
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.error : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.error : AppColors.textTertiary,
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, size: 14.w, color: Colors.white)
          : null,
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    final result = await showCategoryAddBottomSheet(context: context);
    if (result != null && mounted) {
      ref
          .read(categoryListNotifierProvider.notifier)
          .addCategory(
            name: result['name'] as String,
            emoji: result['emoji'] as String?,
          );
    }
  }

  Future<void> _confirmBatchDelete(BuildContext context) async {
    final catCount = _selectedCategoryIds.length;
    final todoCount = _selectedTodoIds.length;

    final parts = <String>[];
    if (catCount > 0) parts.add('카테고리 $catCount개');
    if (todoCount > 0) parts.add('할일 $todoCount개');
    final description = parts.join(', ');

    final confirmed = await AppDialog.confirm(
      context: context,
      title: '일괄 삭제',
      message:
          '$description를 삭제하시겠습니까?\n카테고리의 할일은 미분류로 이동됩니다.\n\n삭제된 항목은 복구할 수 없습니다.',
      emotion: AppDialogEmotion.warning,
      confirmText: '삭제',
      cancelText: '취소',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      // 할일 먼저 삭제 (낙관적 업데이트, invalidate 없음)
      // 카테고리 나중 삭제 (invalidate로 최종 정합성 보장)
      if (_selectedTodoIds.isNotEmpty) {
        await ref
            .read(todoListNotifierProvider.notifier)
            .deleteTodos(_selectedTodoIds.toList());
      }
      if (_selectedCategoryIds.isNotEmpty) {
        await ref
            .read(categoryListNotifierProvider.notifier)
            .deleteCategories(_selectedCategoryIds.toList());
      }
      _toggleEditMode();
    }
  }
}
