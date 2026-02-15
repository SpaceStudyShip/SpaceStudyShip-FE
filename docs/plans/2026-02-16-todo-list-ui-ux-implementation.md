# Todo List UI/UX Improvement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** TodoListScreen과 CategoryTodoScreen의 5가지 UI/UX 문제 해결 (AppBar 배경, 섹션 헤더, 카테고리 그리드, 추가 카드, 스와이프 액션)

**Architecture:** 기존 화면 3개 수정. MainShell의 SpaceBackground를 재활용하여 중복 제거. CategoryFolderCard를 정사각형 그리드용으로 리디자인. Dismissible을 양방향으로 확장.

**Tech Stack:** Flutter, Riverpod, GoRouter, flutter_screenutil

**Design Doc:** `docs/plans/2026-02-16-todo-list-ui-ux-improvement.md`

---

### Task 1: CategoryFolderCard를 정사각형 그리드 레이아웃으로 변경

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_folder_card.dart` (전체 rewrite)

**Step 1: CategoryFolderCard 레이아웃을 정사각형으로 변경**

기존 가로 Row 레이아웃 → 세로 중앙 정렬 Column 레이아웃으로 변경.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';

class CategoryFolderCard extends StatefulWidget {
  const CategoryFolderCard({
    super.key,
    required this.name,
    this.emoji,
    required this.todoCount,
    required this.completedCount,
    required this.onTap,
    this.onDelete,
  });

  final String name;
  final String? emoji;
  final int todoCount;
  final int completedCount;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  State<CategoryFolderCard> createState() => _CategoryFolderCardState();
}

class _CategoryFolderCardState extends State<CategoryFolderCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.spaceDivider),
          ),
          child: Stack(
            children: [
              // 더보기 버튼 (우상단)
              if (widget.onDelete != null)
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Padding(
                      padding: AppPadding.all8,
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16.w,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              // 중앙 콘텐츠
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.emoji ?? '📁',
                      style: TextStyle(fontSize: 32.sp),
                    ),
                    SizedBox(height: AppSpacing.s8),
                    Text(
                      widget.name,
                      style: AppTextStyles.label_16.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.s4),
                    Text(
                      '${widget.completedCount}/${widget.todoCount} 완료',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/widgets/category_folder_card.dart
git commit -m "refactor: CategoryFolderCard를 정사각형 그리드 레이아웃으로 변경 #16"
```

---

### Task 2: TodoListScreen — Scaffold 배경 통합 + 카테고리 그리드

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart` (대규모 변경)

**Step 1: Scaffold 배경 통합 + 카테고리 섹션 리디자인**

변경사항:
1. `backgroundColor: Colors.transparent` + `extendBodyBehindAppBar: true`
2. body에서 `Stack` + `SpaceBackground` 제거
3. `import '../../../core/widgets/backgrounds/space_background.dart'` 제거
4. ListView padding에 AppBar + 상태바 높이 추가
5. 카테고리 섹션: Row → 그리드 (GridView + shrinkWrap)
6. 섹션 헤더: `subHeading_18` + white
7. `_AddCategoryButton` 삭제 → 그리드 내 추가 카드

전체 파일:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
                ref
                    .read(todoListNotifierProvider.notifier)
                    .addTodo(
                      title: result['title'] as String,
                      categoryId: result['categoryId'] as String?,
                    );
              }
            },
            icon: Icon(Icons.add_rounded, size: 24.w),
          ),
        ],
      ),
      body: _buildBody(context, ref, todosAsync, categoriesAsync),
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16.h,
        left: 20.w,
        right: 20.w,
        bottom: 16.h,
      ),
      children: [
        // ── 카테고리 섹션 헤더 ──
        Text(
          '카테고리',
          style: AppTextStyles.subHeading_18.copyWith(
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.s12),

        // ── 카테고리 2열 그리드 ──
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: AppSpacing.s12,
            mainAxisSpacing: AppSpacing.s12,
          ),
          itemCount: categories.length + 1, // +1 for add card
          itemBuilder: (context, index) {
            // 마지막 아이템: 카테고리 추가 카드
            if (index == categories.length) {
              return _buildAddCategoryCard(context, ref);
            }

            final cat = categories[index];
            final catTodos = todos
                .where((t) => t.categoryId == cat.id)
                .toList();
            final completedCount =
                catTodos.where((t) => t.completed).length;

            return CategoryFolderCard(
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
            );
          },
        ),
        SizedBox(height: AppSpacing.s24),

        // ── 미분류 할일 섹션 ──
        if (uncategorized.isNotEmpty) ...[
          Text(
            '미분류',
            style: AppTextStyles.subHeading_18.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.s8),
          ...uncategorized.map(
            (todo) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Dismissible(
                key: Key(todo.id),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // 카테고리 이동
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
                    return false; // 아이템 유지
                  }
                  return true; // 삭제 진행
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
                      todo.actualMinutes != null && todo.actualMinutes! > 0
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
      ],
    );
  }

  Widget _buildAddCategoryCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _addCategory(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: AppColors.spaceDivider,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.create_new_folder_outlined,
                size: 32.w,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: AppSpacing.s8),
              Text(
                '추가',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final result = await showCategoryAddBottomSheet(context: context);
    if (result != null && context.mounted) {
      ref
          .read(categoryListNotifierProvider.notifier)
          .addCategory(
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
```

Note: `_AddCategoryButton` 클래스 완전 제거됨. `import space_background.dart` 제거됨.

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/screens/todo_list_screen.dart
git commit -m "feat: TodoListScreen 배경 통합 + 카테고리 그리드 + 양방향 스와이프 #16"
```

---

### Task 3: CategoryTodoScreen — Scaffold 배경 통합 + 양방향 스와이프

**Files:**
- Modify: `lib/features/todo/presentation/screens/category_todo_screen.dart` (전체 rewrite)

**Step 1: Scaffold 배경 통합 + 양방향 스와이프 적용**

변경사항:
1. `backgroundColor: Colors.transparent` + `extendBodyBehindAppBar: true`
2. body에서 `Stack` + `SpaceBackground` 제거
3. `import space_background.dart` 제거
4. ListView padding에 AppBar + 상태바 높이 추가
5. Dismissible을 양방향으로 변경 + onLongPress 제거

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
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
      backgroundColor: Colors.transparent,
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
                    );
              }
            },
            icon: Icon(Icons.add_rounded, size: 24.w),
          ),
        ],
      ),
      body: todosAsync.when(
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
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16.h,
              left: 20.w,
              right: 20.w,
              bottom: 16.h,
            ),
            itemCount: categoryTodos.length,
            itemBuilder: (context, index) {
              final todo = categoryTodos[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Dismissible(
                  key: Key(todo.id),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // 카테고리 이동
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
                      return false; // 아이템 유지
                    }
                    return true; // 삭제 진행
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
    );
  }
}
```

Note: `import space_background.dart` 제거됨. `GestureDetector` + `onLongPress` 제거됨.

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/screens/category_todo_screen.dart
git commit -m "feat: CategoryTodoScreen 배경 통합 + 양방향 스와이프 #16"
```

---

### Task 4: 최종 검증

**Step 1: 전체 정적 분석**

Run: `flutter analyze`
Expected: No issues

**Step 2: 시각적 검증 (수동)**

앱 실행 후 확인할 항목:
1. TodoListScreen에서 AppBar 뒤로 별 배경이 보이는지
2. 카테고리가 2열 정사각형 그리드로 표시되는지
3. 그리드 마지막에 '추가' 카드가 표시되는지
4. '카테고리', '미분류' 헤더가 subHeading_18 크기인지
5. 미분류 할일을 왼→오로 스와이프하면 카테고리 이동 바텀시트가 나오는지
6. 미분류 할일을 오→왼으로 스와이프하면 삭제되는지
7. CategoryTodoScreen에서도 동일하게 동작하는지
8. 카테고리 없을 때 빈 카드만 표시되는지

**Step 3: 최종 커밋 (필요 시)**

수동 검증에서 발견된 이슈가 있으면 수정 후 커밋.
