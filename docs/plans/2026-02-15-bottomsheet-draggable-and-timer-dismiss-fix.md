# 바텀시트 드래그 확장 + 타이머 dismiss 시작 버그 수정

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** (1) 할일 연동 바텀시트를 DraggableScrollableSheet으로 교체하여 유튜브 댓글창처럼 드래그 확장 가능하게 한다. (2) 타이머 바텀시트를 닫기(dismiss)만 했을 때 타이머가 시작되지 않도록 수정한다.

**Architecture:** TodoSelectBottomSheet를 DraggableScrollableSheet으로 감싸 초기 40% → 최대 90% 확장 가능하게 변경. "연동 없이 시작"과 dismiss를 구분하기 위해 반환 타입을 `Object?`로 변경하여 `null`(dismiss) / `true`("연동없이시작") / `TodoEntity`(할일선택) 세 가지 경우를 구분한다.

**Tech Stack:** Flutter, DraggableScrollableSheet, Riverpod

---

## 원인 분석

### 이슈 1: 바텀시트 높이 고정
- `TodoSelectBottomSheet`: `ConstrainedBox(maxHeight: 300.h)`로 할일 목록 높이 제한
- 할일이 많을 때 스크롤은 되지만 시트 자체가 확장되지 않음

### 이슈 2: dismiss 시 타이머 시작
```
"연동 없이 시작" → pop(null) → _onStart에서 null → start() 호출
바텀시트 닫기    → 자동 null 반환  → _onStart에서 null → start() 호출  ← 버그!
```
두 경우 모두 `null`을 반환하여 구분 불가

---

## Task 1: TodoSelectBottomSheet DraggableScrollableSheet 적용 + dismiss 구분

**Files:**
- Modify: `lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart`

**Step 1: 전체 파일 수정**

- 반환 타입을 `Object?`로 변경 (null=dismiss, true=연동없이시작, TodoEntity=할일선택)
- DraggableScrollableSheet으로 감싸서 드래그 확장 가능하게
- ConstrainedBox 제거 → Expanded ListView로 교체

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../todo/domain/entities/todo_entity.dart';
import '../../../todo/presentation/providers/todo_provider.dart';

class TodoSelectBottomSheet extends ConsumerWidget {
  const TodoSelectBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: AppRadius.modal,
          ),
          child: Column(
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
                    '할 일 연동',
                    style: AppTextStyles.subHeading_18.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 연동 없이 시작 버튼
              Padding(
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
              SizedBox(height: AppSpacing.s12),

              // 미완료 할일 목록 (Expanded로 남은 공간 채움)
              Expanded(
                child: todosAsync.when(
                  data: (todos) {
                    final incomplete =
                        todos.where((t) => !t.completed).toList();

                    if (incomplete.isEmpty) {
                      return Padding(
                        padding: AppPadding.all20,
                        child: SpaceEmptyState(
                          icon: Icons.check_circle_outline,
                          title: '미완료 할 일이 없어요',
                          subtitle: '할 일을 추가한 뒤 연동해보세요',
                          iconSize: 32,
                          animated: false,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: AppPadding.horizontal20,
                      itemCount: incomplete.length,
                      itemBuilder: (context, index) {
                        final todo = incomplete[index];
                        return _TodoSelectTile(
                          todo: todo,
                          onTap: () => Navigator.of(context).pop(todo),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TodoSelectTile extends StatelessWidget {
  const _TodoSelectTile({required this.todo, required this.onTap});

  final TodoEntity todo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    todo.title,
                    style:
                        AppTextStyles.label_16.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (todo.actualMinutes != null && todo.actualMinutes! > 0)
                  Text(
                    '${todo.actualMinutes}분',
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
```

**Step 2: Commit**

```bash
git add lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart
git commit -m "feat: TodoSelectBottomSheet DraggableScrollableSheet 적용 + 반환타입 구분 #16"
```

---

## Task 2: 타이머 _onStart dismiss 시 시작 방지

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:252-260`

**Step 1: _onStart 메서드 수정**

```dart
  Future<void> _onStart() async {
    final result = await showTodoSelectBottomSheet(context: context);

    if (!mounted) return;

    // null = dismiss → 타이머 시작하지 않음
    if (result == null) return;

    // true = "연동 없이 시작" → 할일 연동 없이 타이머 시작
    // TodoEntity = 할일 선택 → 해당 할일과 연동하여 타이머 시작
    final todo = result is TodoEntity ? result : null;
    ref
        .read(timerNotifierProvider.notifier)
        .start(todoId: todo?.id, todoTitle: todo?.title);
  }
```

**Step 2: flutter analyze 검증**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "fix: 바텀시트 dismiss 시 타이머 시작 방지 #16"
```

---

## Task 3: 최종 검증

수동 테스트 체크리스트:
- [ ] 타이머 시작 → 바텀시트 위로 드래그 → 전체 할일 목록 보임
- [ ] 바텀시트 닫기(배경 탭/아래로 드래그) → 타이머 시작 안 됨
- [ ] "연동 없이 시작" 탭 → 타이머 시작됨 (할일 연동 없음)
- [ ] 할일 선택 탭 → 타이머 시작됨 (해당 할일 연동)
- [ ] 오버플로우 없음
