# 타이머-할 일 연동 UI 전반 개선 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 타이머 연동 시 레이아웃 밀림 해결 + 바텀시트 정보 강화 + 종료 결과 다이얼로그 추가

**Architecture:** 연동 칩 뱃지를 제거하고 타이머 링 내부 상태 텍스트 영역에 연동 정보를 조건부 표시. 바텀시트 타일을 2행 구조로 확장. timer_provider의 stop()이 결과 데이터를 반환하도록 변경하여 UI에서 다이얼로그 표시.

**Tech Stack:** Flutter, Riverpod, Freezed, AppDialog

---

### Task 1: timer_provider stop() 반환값 변경

stop()이 종료 결과 다이얼로그에 필요한 데이터를 반환하도록 변경한다. 현재는 `Future<void>`이지만 세션 시간, 연동 정보 등을 담은 record를 반환하도록 한다.

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_provider.dart:79-91`

**Step 1: stop() 메서드 반환 타입을 record로 변경**

`timer_provider.dart`의 `stop()` 메서드를 아래와 같이 변경:

```dart
/// 타이머 정지 + 할일 시간 업데이트
/// 반환: ({Duration sessionDuration, String? todoTitle, int? totalMinutes})
Future<({Duration sessionDuration, String? todoTitle, int? totalMinutes})?> stop() async {
  _timer?.cancel();

  final todoId = state.linkedTodoId;
  final todoTitle = state.linkedTodoTitle;
  final sessionDuration = state.elapsed;
  final elapsedMinutes = sessionDuration.inMinutes;

  int? totalMinutes;

  // 연동된 할일이 있고 1분 이상 측정 시 actualMinutes 누적
  if (todoId != null && elapsedMinutes > 0) {
    totalMinutes = await _updateTodoActualMinutes(todoId, elapsedMinutes);
  }

  // 1분 미만 세션은 null 반환 (다이얼로그 생략)
  final result = sessionDuration.inMinutes >= 1
      ? (sessionDuration: sessionDuration, todoTitle: todoTitle, totalMinutes: totalMinutes)
      : null;

  state = const TimerState();
  return result;
}
```

**Step 2: _updateTodoActualMinutes 반환값 변경**

누적 시간을 반환하도록 수정:

```dart
Future<int?> _updateTodoActualMinutes(
  String todoId,
  int additionalMinutes,
) async {
  final todoNotifier = ref.read(todoListNotifierProvider.notifier);
  final todos = ref.read(todoListNotifierProvider).valueOrNull ?? [];
  final todo = todos.where((t) => t.id == todoId).firstOrNull;

  if (todo != null) {
    final currentMinutes = todo.actualMinutes ?? 0;
    final newTotal = currentMinutes + additionalMinutes;
    await todoNotifier.updateTodo(
      todo.copyWith(actualMinutes: newTotal),
    );
    return newTotal;
  }
  return null;
}
```

**Step 3: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/providers/timer_provider.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_provider.dart
git commit -m "refactor: timer stop()이 세션 결과 데이터를 반환하도록 변경"
```

---

### Task 2: 타이머 링 내부 연동 표시로 이동

기존 타이머 위 연동 칩 뱃지(59~95행)를 제거하고, 링 내부 상태 텍스트(129~138행)를 조건부로 변경한다.

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:57-145`

**Step 1: 연동 칩 뱃지 블록 제거**

`timer_screen.dart`에서 58~95행(연동된 할일 표시 if 블록 + SizedBox) 전체 삭제:

```dart
// 삭제할 부분 (58~95행):
// 연동된 할일 표시
if (timerState.linkedTodoTitle != null) ...[
  FadeSlideIn(
    child: Container(
      ...
    ),
  ),
  SizedBox(height: AppSpacing.s24),
],
```

**Step 2: 링 내부 상태 텍스트를 _buildStatusText 메서드로 추출**

기존 상태 텍스트 영역(Column 내부의 Text 위젯)을 조건부 위젯으로 교체:

```dart
// 타이머 링 내부 Column children에서 상태 텍스트 부분을 교체
SizedBox(height: AppSpacing.s4),
_buildStatusText(timerState, isIdle, isRunning),
```

**Step 3: _buildStatusText 메서드 구현**

`_TimerScreenState` 클래스에 아래 메서드 추가:

```dart
Widget _buildStatusText(TimerState timerState, bool isIdle, bool isRunning) {
  // 연동된 할일이 있고 idle이 아닌 경우 → 할일 제목 표시
  if (timerState.linkedTodoTitle != null && !isIdle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.link_rounded,
          color: isRunning ? AppColors.primary : AppColors.textSecondary,
          size: 14.w,
        ),
        SizedBox(width: AppSpacing.s4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 160.w),
          child: Text(
            timerState.linkedTodoTitle!,
            style: AppTextStyles.tag_12.copyWith(
              color: isRunning ? AppColors.primary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 연동 없음 → 기존 상태 텍스트
  return Text(
    isIdle
        ? '집중 시간을 측정해보세요'
        : isRunning
            ? '집중 중...'
            : '일시정지',
    style: AppTextStyles.tag_12.copyWith(
      color: AppColors.textSecondary,
    ),
  );
}
```

**Step 4: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/screens/timer_screen.dart`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "feat: 연동 정보를 타이머 링 내부로 이동하여 레이아웃 밀림 해결"
```

---

### Task 3: 바텀시트 할 일 항목 정보 강화

`_TodoSelectTile`에 2행 정보(카테고리, 예상 시간, 누적 시간)를 추가한다.

**Files:**
- Modify: `lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart:13,108-118,132-185`

**Step 1: TodoSelectBottomSheet에 categories 데이터 추가**

바텀시트에서 카테고리 목록을 watch하고 _TodoSelectTile에 전달:

```dart
// TodoSelectBottomSheet의 build 내부, todosAsync.when data 블록에서
// incomplete 리스트 아래에 categories 추가
final categoriesAsync = ref.watch(categoryListNotifierProvider);
final categories = categoriesAsync.valueOrNull ?? [];
```

import 추가:
```dart
import '../../../todo/domain/entities/todo_category_entity.dart';
```

SliverList의 delegate에서 _TodoSelectTile에 categories 전달:

```dart
return _TodoSelectTile(
  todo: todo,
  categories: categories,
  onTap: () => Navigator.of(context).pop(todo),
);
```

**Step 2: _TodoSelectTile을 2행 구조로 변경**

```dart
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
```

**Step 3: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart
git commit -m "feat: 바텀시트 할 일 항목에 카테고리, 예상/누적 시간 정보 추가"
```

---

### Task 4: 타이머 종료 결과 다이얼로그

타이머 종료 시 AppDialog의 customContent를 활용하여 결과 요약을 보여준다.

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart` (_buildControls 내 stop 호출 부분 + _onStop 메서드 추가)

**Step 1: 종료 버튼의 onPressed를 _onStop 메서드로 변경**

`_buildControls`에서 종료 버튼:

```dart
// 기존:
onPressed: () => ref.read(timerNotifierProvider.notifier).stop(),

// 변경:
onPressed: _onStop,
```

**Step 2: _onStop 메서드 + _showResultDialog 메서드 구현**

`_TimerScreenState` 클래스에 추가:

```dart
Future<void> _onStop() async {
  final result = await ref.read(timerNotifierProvider.notifier).stop();
  if (!mounted || result == null) return;
  _showResultDialog(result);
}

void _showResultDialog(
  ({Duration sessionDuration, String? todoTitle, int? totalMinutes}) result,
) {
  final sessionText = _formatDuration(result.sessionDuration);

  AppDialog.show(
    context: context,
    title: '수고했어요!',
    emotion: AppDialogEmotion.success,
    customContent: Column(
      children: [
        _buildResultRow('이번 세션', sessionText),
        if (result.todoTitle != null) ...[
          Padding(
            padding: AppPadding.vertical12,
            child: Divider(
              color: AppColors.spaceDivider,
              height: 1,
            ),
          ),
          _buildResultRow('연동 할 일', result.todoTitle!),
          if (result.totalMinutes != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.s8),
              child: _buildResultRow(
                '누적 시간',
                _formatMinutes(result.totalMinutes!),
              ),
            ),
        ],
      ],
    ),
  );
}

Widget _buildResultRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppTextStyles.tag_12.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      Flexible(
        child: Text(
          value,
          style: AppTextStyles.label_16.copyWith(
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}

String _formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0) {
    return '$hours시간 $minutes분';
  }
  return '$minutes분';
}
```

**Step 3: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/screens/timer_screen.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "feat: 타이머 종료 시 세션 결과 요약 다이얼로그 추가"
```

---

### Task 5: 전체 통합 검증

**Step 1: flutter analyze 전체 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 최종 커밋 (필요 시)**

변경 파일 3개 최종 확인:
- `lib/features/timer/presentation/providers/timer_provider.dart`
- `lib/features/timer/presentation/screens/timer_screen.dart`
- `lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart`
