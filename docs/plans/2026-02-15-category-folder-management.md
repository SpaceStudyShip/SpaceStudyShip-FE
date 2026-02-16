# 카테고리 폴더 관리 구현 계획서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** TodoListScreen을 카테고리 폴더 기반으로 개편하여, 폴더 탭 시 Hero 애니메이션으로 해당 카테고리 할일 목록을 보여주고, 할일의 카테고리 이동/선택 기능을 제공한다.

**Architecture:** TodoListScreen을 [카테고리 폴더 카드 + 미분류 할일] 구조로 개편한다. 폴더 탭 → Hero 애니메이션 → CategoryTodoScreen(새 화면)으로 전환. TodoAddBottomSheet에 카테고리 칩 선택 추가. 할일 길게 누르기 → 카테고리 이동 바텀시트. 백엔드(Entity/Model/Repository/UseCase/Provider)는 이미 완성되어 있으므로 Presentation 레이어만 구현한다.

**Tech Stack:** Flutter, Riverpod, Freezed, GoRouter, Hero Animation

---

## 이미 구현된 것 (건드리지 않음)

- `TodoEntity` (id, title, completed, **categoryId**, estimatedMinutes, actualMinutes, createdAt, updatedAt)
- `TodoCategoryEntity` (id, name, emoji, createdAt)
- `TodoRepository` + `LocalTodoRepositoryImpl` (CRUD + 카테고리 CRUD)
- `TodoListNotifier` (addTodo에 categoryId 파라미터 이미 있음)
- `CategoryListNotifier` (addCategory, deleteCategory 이미 있음)
- `CategoryFolderCard` 위젯 (폴더 카드 UI 이미 있음)
- `TodoItem` 위젯 (할일 아이템 UI 이미 있음)
- `AppDialog` 위젯 (confirm 다이얼로그 이미 있음 — `AppDialog.confirm()`)

---

## 이전 계획서 v1 점검 결과 (6개 문제 수정됨)

1. **Task 순서 의존성 꼬임** → Task 재배치: 독립 위젯 먼저, 의존 화면은 나중에
2. **Hero 애니메이션 child 불일치** → Hero를 이모지+이름 Row만 감싸기 (양쪽 동일 위젯)
3. **GoRouter query parameter 취약** → `extra` 파라미터로 데이터 전달
4. **AlertDialog 직접 사용** → `AppDialog.confirm()` 사용 (프로젝트 기존 위젯)
5. **중첩 AsyncValue** → 두 provider 모두 data일 때만 컨텐츠 렌더링, 통합 로딩/에러 처리
6. **CategoryMoveBottomSheet 같은 카테고리 탭** → isSelected 시 바텀시트만 닫기 (불필요한 update 방지)

---

## Task 1: CategoryAddBottomSheet 생성

**Files:**
- Create: `lib/features/todo/presentation/widgets/category_add_bottom_sheet.dart`

**의존성:** 없음 (독립 위젯)

**Step 1: 카테고리 추가 바텀시트 구현**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';

/// 이모지 프리셋 목록
const _emojiPresets = [
  '📁', '📚', '📐', '🔬', '🎨', '💻', '🎵', '🏃', '📝', '🌍',
  '🧮', '📖', '✏️', '🔭', '🎯', '💡', '🧪', '📊', '🗂️', '⭐',
];

class CategoryAddBottomSheet extends StatefulWidget {
  const CategoryAddBottomSheet({super.key});

  @override
  State<CategoryAddBottomSheet> createState() => _CategoryAddBottomSheetState();
}

class _CategoryAddBottomSheetState extends State<CategoryAddBottomSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '📁';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop({'name': name, 'emoji': _selectedEmoji});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // 제목
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '카테고리 추가',
                  style: AppTextStyles.subHeading_18.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 이름 입력 필드
            Padding(
              padding: AppPadding.horizontal20,
              child: AppTextField(
                controller: _nameController,
                hintText: '카테고리 이름 (예: 수학, 영어)',
                onSubmitted: (_) => _submit(),
                autofocus: true,
              ),
            ),
            SizedBox(height: AppSpacing.s16),

            // 이모지 선택
            Padding(
              padding: AppPadding.horizontal20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '아이콘 선택',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s8),
            SizedBox(
              height: 48.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: AppPadding.horizontal20,
                itemCount: _emojiPresets.length,
                itemBuilder: (context, index) {
                  final emoji = _emojiPresets[index];
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      width: 44.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: AppRadius.medium,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.spaceDivider,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.s20),

            // 추가 버튼
            Padding(
              padding: AppPadding.horizontal20,
              child: AppButton(
                text: '추가하기',
                onPressed:
                    _nameController.text.trim().isEmpty ? null : _submit,
                width: double.infinity,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 추가 바텀시트를 표시하는 헬퍼 함수
Future<Map<String, dynamic>?> showCategoryAddBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => const CategoryAddBottomSheet(),
  );
}
```

**Step 2: flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/widgets/category_add_bottom_sheet.dart
git commit -m "feat: CategoryAddBottomSheet 위젯 추가 (이름 + 이모지 선택) #16"
```

---

## Task 2: CategoryMoveBottomSheet 생성 (길게 누르기 → 카테고리 이동)

**Files:**
- Create: `lib/features/todo/presentation/widgets/category_move_bottom_sheet.dart`

**의존성:** 없음 (독립 위젯)

**Step 1: 카테고리 이동 바텀시트 구현**

**핵심 포인트:**
- `isSelected` 상태인 항목 탭 시 → `pop(null)` (바텀시트만 닫기, 불필요한 update 방지)
- 다른 카테고리 탭 시 → `pop(categoryId)` 또는 `pop('')` (미분류)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../providers/todo_provider.dart';

class CategoryMoveBottomSheet extends ConsumerWidget {
  const CategoryMoveBottomSheet({
    super.key,
    this.currentCategoryId,
  });

  final String? currentCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // 제목
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '카테고리 이동',
                style: AppTextStyles.subHeading_18.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 미분류 옵션
          _CategoryOption(
            emoji: '📋',
            name: '미분류',
            isSelected: currentCategoryId == null,
            onTap: () {
              if (currentCategoryId == null) {
                Navigator.of(context).pop(); // 이미 미분류 → 닫기만
              } else {
                Navigator.of(context).pop(''); // 미분류로 이동
              }
            },
          ),

          // 카테고리 목록
          categoriesAsync.when(
            data: (categories) => Column(
              children: categories.map((cat) {
                final isSelected = cat.id == currentCategoryId;
                return _CategoryOption(
                  emoji: cat.emoji ?? '📁',
                  name: cat.name,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      Navigator.of(context).pop(); // 이미 같은 카테고리 → 닫기만
                    } else {
                      Navigator.of(context).pop(cat.id); // 해당 카테고리로 이동
                    }
                  },
                );
              }).toList(),
            ),
            loading: () => Padding(
              padding: AppPadding.all16,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => const SizedBox.shrink(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12.h),
        ],
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.emoji,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.label_16.copyWith(color: Colors.white),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                size: 20.w,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 이동 바텀시트를 표시하는 헬퍼 함수
/// 반환값: 카테고리 ID (빈 문자열 = 미분류, null = 취소 또는 변경 없음)
Future<String?> showCategoryMoveBottomSheet({
  required BuildContext context,
  String? currentCategoryId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => CategoryMoveBottomSheet(
      currentCategoryId: currentCategoryId,
    ),
  );
}
```

**Step 2: flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/widgets/category_move_bottom_sheet.dart
git commit -m "feat: CategoryMoveBottomSheet 위젯 추가 (길게 누르기 → 카테고리 이동) #16"
```

---

## Task 3: TodoAddBottomSheet에 카테고리 칩 선택 추가

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**의존성:** 없음 (기존 파일 수정, 외부 import 없음)

**Step 1: StatefulWidget → ConsumerStatefulWidget 변경 + 카테고리 칩 추가**

전체 코드 교체:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../providers/todo_provider.dart';

class TodoAddBottomSheet extends ConsumerStatefulWidget {
  const TodoAddBottomSheet({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  ConsumerState<TodoAddBottomSheet> createState() => _TodoAddBottomSheetState();
}

class _TodoAddBottomSheetState extends ConsumerState<TodoAddBottomSheet> {
  final _titleController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop({
      'title': title,
      'categoryId': _selectedCategoryId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // 제목
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '할 일 추가',
                  style: AppTextStyles.subHeading_18.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 제목 입력 필드
            Padding(
              padding: AppPadding.horizontal20,
              child: AppTextField(
                controller: _titleController,
                hintText: '할 일을 입력하세요',
                onSubmitted: (_) => _submit(),
                autofocus: true,
              ),
            ),
            SizedBox(height: AppSpacing.s16),

            // 카테고리 칩 선택
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppPadding.horizontal20,
                      child: Text(
                        '카테고리',
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s8),
                    SizedBox(
                      height: 36.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: AppPadding.horizontal20,
                        children: [
                          // 미분류 칩
                          _CategoryChip(
                            label: '미분류',
                            isSelected: _selectedCategoryId == null,
                            onTap: () =>
                                setState(() => _selectedCategoryId = null),
                          ),
                          SizedBox(width: AppSpacing.s8),
                          // 카테고리 칩들
                          ...categories.map((cat) => Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: _CategoryChip(
                                  label: '${cat.emoji ?? "📁"} ${cat.name}',
                                  isSelected: _selectedCategoryId == cat.id,
                                  onTap: () => setState(
                                      () => _selectedCategoryId = cat.id),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            SizedBox(height: AppSpacing.s16),

            // 추가 버튼
            Padding(
              padding: AppPadding.horizontal20,
              child: AppButton(
                text: '추가하기',
                onPressed:
                    _titleController.text.trim().isEmpty ? null : _submit,
                width: double.infinity,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.spaceDivider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.tag_12.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 할일 추가 바텀시트를 표시하는 헬퍼 함수
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
  String? initialCategoryId,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) =>
        TodoAddBottomSheet(initialCategoryId: initialCategoryId),
  );
}
```

변경점:
- `StatefulWidget` → `ConsumerStatefulWidget` (카테고리 목록 watch 필요)
- `initialCategoryId` 파라미터 추가
- 카테고리 칩 가로 스크롤 리스트 추가 (미분류 + 카테고리들)
- 반환값에 `categoryId` 추가: `{'title': title, 'categoryId': _selectedCategoryId}`
- `showTodoAddBottomSheet`에 `initialCategoryId` 파라미터 추가

**Step 2: 기존 호출부 확인**

`TodoListScreen`과 `HomeScreen`에서 `showTodoAddBottomSheet`를 호출하는 부분은 `initialCategoryId`가 optional이므로 기존 코드 수정 없이 호환됨.

단, 반환값에서 `categoryId`를 사용하도록 호출부를 Task 5에서 업데이트한다.

**Step 3: flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart
git commit -m "feat: TodoAddBottomSheet에 카테고리 칩 선택 추가 #16"
```

---

## Task 4: CategoryTodoScreen + 라우트 추가

**Files:**
- Create: `lib/features/todo/presentation/screens/category_todo_screen.dart`
- Modify: `lib/routes/route_paths.dart`
- Modify: `lib/routes/app_router.dart`

**의존성:** Task 2 (CategoryMoveBottomSheet), Task 3 (TodoAddBottomSheet with initialCategoryId)

**Step 1: route_paths.dart에 카테고리 할일 경로 추가**

`lib/routes/route_paths.dart`의 Home 하위 화면 섹션에 추가:

```dart
  // 카테고리별 할일 목록
  static const categoryTodo = '/home/todo/category/:categoryId';
  static String categoryTodoPath(String categoryId) =>
      '/home/todo/category/$categoryId';
```

**Step 2: CategoryTodoScreen 생성**

**Hero 애니메이션 포인트:**
- AppBar title에 `Hero(tag: 'category_$categoryId')` 사용
- Hero child는 이모지+이름 `Row` (TodoListScreen의 Hero child와 동일 구조)
- `Material(color: Colors.transparent)`로 감싸서 Hero 전환 시 텍스트 스타일 유지

**GoRouter `extra` 사용:**
- `state.extra as Map<String, dynamic>?`로 name/emoji 전달받음 (query parameter 대신)

```dart
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
```

**Step 3: app_router.dart에 라우트 등록**

`lib/routes/app_router.dart`에서:

1. import 추가:
```dart
import '../features/todo/presentation/screens/category_todo_screen.dart';
```

2. todoList GoRoute의 `routes: [...]` 안 기존 `todo/:id` 라우트 아래에 추가:
```dart
// 카테고리별 할일 목록
GoRoute(
  path: 'category/:categoryId',
  name: 'categoryTodo',
  builder: (context, state) {
    final categoryId = state.pathParameters['categoryId']!;
    final extra = state.extra as Map<String, dynamic>?;
    return CategoryTodoScreen(
      categoryId: categoryId,
      categoryName: extra?['name'] as String? ?? '카테고리',
      categoryEmoji: extra?['emoji'] as String?,
    );
  },
),
```

**Step 4: flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 5: Commit**

```bash
git add lib/features/todo/presentation/screens/category_todo_screen.dart lib/routes/route_paths.dart lib/routes/app_router.dart
git commit -m "feat: CategoryTodoScreen + 라우트 추가 (Hero 애니메이션, GoRouter extra) #16"
```

---

## Task 5: TodoListScreen 개편 (카테고리 폴더 + 미분류)

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`

**의존성:** Task 1~4 전부

**핵심 변경점:**
1. `categoriesAsync` watch 추가
2. 카테고리 폴더 카드 섹션 (Hero + GoRouter extra)
3. 미분류 할일 섹션 (categoryId == null 필터)
4. 길게 누르기 → 카테고리 이동 바텀시트
5. 카테고리 추가/삭제 (`AppDialog.confirm` 사용)
6. 빈 상태일 때 "카테고리 만들기" 유도 버튼
7. **Hero child:** 이모지+이름 Row만 감싸기 (CategoryTodoScreen과 동일 구조)

**Step 1: 전체 코드 교체**

```dart
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
    AsyncValue<List<dynamic>> todosAsync,
    AsyncValue<List<dynamic>> categoriesAsync,
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
```

**Step 2: flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/screens/todo_list_screen.dart
git commit -m "feat: TodoListScreen 카테고리 폴더 + 미분류 구조로 개편 #16"
```

---

## Task 6: 전체 통합 검증

**Step 1: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 2: flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 3: 수동 테스트 체크리스트**

- [ ] TodoListScreen: 카테고리 없을 때 "카테고리 만들기" 버튼 표시
- [ ] "카테고리 만들기" 탭 → CategoryAddBottomSheet 열림
- [ ] 이름 + 이모지 선택 → 카테고리 생성 → 폴더 카드 표시
- [ ] 폴더 카드 탭 → Hero 애니메이션 → CategoryTodoScreen 전환
- [ ] CategoryTodoScreen: 해당 카테고리 할일만 표시
- [ ] CategoryTodoScreen: + 버튼 → 할일 추가 → 자동으로 해당 카테고리 할당
- [ ] TodoAddBottomSheet: 카테고리 칩 선택 가능, 미선택 시 미분류
- [ ] 미분류 할일 길게 누르기 → CategoryMoveBottomSheet → 카테고리 이동
- [ ] CategoryTodoScreen에서도 길게 누르기 → 카테고리 이동 (다른 폴더로)
- [ ] 같은 카테고리 탭 시 바텀시트만 닫힘 (불필요한 update 없음)
- [ ] 카테고리 삭제 시 AppDialog 확인 → 할일 미분류로 이동
- [ ] 스와이프 삭제 정상 동작 (미분류 + 폴더 내부 모두)
- [ ] 뒤로가기 시 Hero 역방향 애니메이션

**Step 4: Commit (generated 파일 포함)**

```bash
git add -A
git commit -m "chore: 카테고리 폴더 관리 통합 검증 완료 #16"
```
