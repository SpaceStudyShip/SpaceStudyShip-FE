# 타이머-할일 연동 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** TodoAddBottomSheet에서 수동 estimatedMinutes 입력을 제거하고, 타이머 기능을 구현하여 할일에 연동된 실제 공부 시간(actualMinutes)을 표시한다.

**Architecture:** 타이머 도메인/데이터 레이어를 새로 구축하고, Riverpod keepAlive 노티파이어로 타이머 상태를 관리한다. 타이머 시작 시 할일을 선택하면 타이머 정지 시 해당 할일의 actualMinutes가 누적 업데이트된다.

**Tech Stack:** Flutter, Riverpod (@riverpod), Freezed, SharedPreferences, dart:async (Timer)

---

## Phase 1: TodoAddBottomSheet에서 estimatedMinutes 입력 제거

### Task 1: TodoAddBottomSheet 수동 시간 입력 제거

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**Step 1: _minutesController 및 예상 시간 입력 필드 제거**

`todo_add_bottom_sheet.dart`에서 다음 변경:

```dart
// 제거할 코드:
// 1. _minutesController 선언 (line 19)
// 2. _minutesController.dispose() (line 30)
// 3. minutes 파싱 로직 (line 38)
// 4. 'estimatedMinutes': minutes 반환값 (line 42)
// 5. 예상 시간 입력 필드 전체 (lines 98-107)
// 6. SizedBox(height: AppSpacing.s12) 간격 (line 96)

// _submit() 변경 후:
void _submit() {
  final title = _titleController.text.trim();
  if (title.isEmpty) return;
  Navigator.of(context).pop({'title': title});
}
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart
git commit -m "refactor: TodoAddBottomSheet에서 수동 예상 시간 입력 제거 #14"
```

---

### Task 2: HomeScreen과 TodoListScreen에서 estimatedMinutes 전달 제거 + actualMinutes 표시

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`

**Step 1: HomeScreen addTodo에서 estimatedMinutes 전달 제거**

`home_screen.dart:304-308`에서 변경:

```dart
// Before:
ref.read(todoListNotifierProvider.notifier).addTodo(
  title: result['title'] as String,
  estimatedMinutes: result['estimatedMinutes'] as int?,
);

// After:
ref.read(todoListNotifierProvider.notifier).addTodo(
  title: result['title'] as String,
);
```

**Step 2: HomeScreen TodoItem subtitle를 actualMinutes로 변경**

`home_screen.dart:348-349`에서 변경:

```dart
// Before:
subtitle: todo.estimatedMinutes != null
    ? '${todo.estimatedMinutes}분'
    : null,

// After:
subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
    ? '${todo.actualMinutes}분 공부'
    : null,
```

**Step 3: TodoListScreen addTodo에서 estimatedMinutes 전달 제거**

`todo_list_screen.dart:37-39`에서 변경:

```dart
// Before:
ref.read(todoListNotifierProvider.notifier).addTodo(
  title: result['title'] as String,
  estimatedMinutes: result['estimatedMinutes'] as int?,
);

// After:
ref.read(todoListNotifierProvider.notifier).addTodo(
  title: result['title'] as String,
);
```

**Step 4: TodoListScreen TodoItem subtitle를 actualMinutes로 변경**

`todo_list_screen.dart:92-94`에서 변경:

```dart
// Before:
subtitle: todo.estimatedMinutes != null
    ? '${todo.estimatedMinutes}분'
    : null,

// After:
subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
    ? '${todo.actualMinutes}분 공부'
    : null,
```

**Step 5: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues

**Step 6: 커밋**

```bash
git add lib/features/home/presentation/screens/home_screen.dart lib/features/todo/presentation/screens/todo_list_screen.dart
git commit -m "refactor: 할일 시간 표시를 estimatedMinutes에서 actualMinutes로 변경 #14"
```

---

## Phase 2: 타이머 상태 관리 구축

### Task 3: TimerState 모델 생성

**Files:**
- Create: `lib/features/timer/presentation/providers/timer_state.dart`

**Step 1: Freezed TimerState 클래스 작성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

enum TimerStatus { idle, running, paused }

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    @Default(TimerStatus.idle) TimerStatus status,
    @Default(Duration.zero) Duration elapsed,
    String? linkedTodoId,
    String? linkedTodoTitle,
  }) = _TimerState;
}
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: TimerState freezed 파일 생성

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/providers/
git commit -m "feat: TimerState Freezed 모델 생성 #14"
```

---

### Task 4: TimerNotifier 구현 (Riverpod keepAlive)

**Files:**
- Create: `lib/features/timer/presentation/providers/timer_provider.dart`

**Step 1: TimerNotifier 작성**

```dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../todo/presentation/providers/todo_provider.dart';
import 'timer_state.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;

  @override
  TimerState build() => const TimerState();

  /// 타이머 시작 (할일 연동 선택)
  void start({String? todoId, String? todoTitle}) {
    _timer?.cancel();

    state = state.copyWith(
      status: TimerStatus.running,
      linkedTodoId: todoId,
      linkedTodoTitle: todoTitle,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  /// 타이머 일시정지
  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// 타이머 재개
  void resume() {
    if (state.status != TimerStatus.paused) return;

    state = state.copyWith(status: TimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  /// 타이머 정지 + 할일 시간 업데이트
  Future<void> stop() async {
    _timer?.cancel();

    final todoId = state.linkedTodoId;
    final elapsedMinutes = state.elapsed.inMinutes;

    // 연동된 할일이 있고 1분 이상 측정 시 actualMinutes 누적
    if (todoId != null && elapsedMinutes > 0) {
      await _updateTodoActualMinutes(todoId, elapsedMinutes);
    }

    state = const TimerState();
  }

  Future<void> _updateTodoActualMinutes(
    String todoId,
    int additionalMinutes,
  ) async {
    final todoNotifier = ref.read(todoListNotifierProvider.notifier);
    final todos = ref.read(todoListNotifierProvider).valueOrNull ?? [];
    final todo = todos.where((t) => t.id == todoId).firstOrNull;

    if (todo != null) {
      final currentMinutes = todo.actualMinutes ?? 0;
      await todoNotifier.updateTodo(
        todo.copyWith(actualMinutes: currentMinutes + additionalMinutes),
      );
    }
  }
}
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: timer_provider.g.dart 생성

**Step 3: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues

**Step 4: 커밋**

```bash
git add lib/features/timer/presentation/providers/
git commit -m "feat: TimerNotifier 구현 (시작/일시정지/정지 + 할일 시간 누적) #14"
```

---

## Phase 3: 타이머 화면에 할일 선택 기능 추가

### Task 5: 할일 선택 바텀시트 위젯 생성

**Files:**
- Create: `lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart`

**Step 1: TodoSelectBottomSheet 작성**

미완료 할일 목록을 표시하고 사용자가 연동할 할일을 선택하는 바텀시트.

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
                '할 일 연동',
                style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
              ),
            ),
          ),

          // 할일 연동 없이 시작 버튼
          Padding(
            padding: AppPadding.horizontal20,
            child: AppButton(
              text: '연동 없이 시작',
              onPressed: () => Navigator.of(context).pop(null),
              width: double.infinity,
              style: AppButtonStyle.outlined,
            ),
          ),
          SizedBox(height: AppSpacing.s12),

          // 미완료 할일 목록
          todosAsync.when(
            data: (todos) {
              final incomplete = todos.where((t) => !t.completed).toList();

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

              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: AppPadding.horizontal20,
                  itemCount: incomplete.length,
                  itemBuilder: (context, index) {
                    final todo = incomplete[index];
                    return _TodoSelectTile(
                      todo: todo,
                      onTap: () => Navigator.of(context).pop(todo),
                    );
                  },
                ),
              );
            },
            loading: () => Padding(
              padding: AppPadding.all20,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
        ],
      ),
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
                Icon(Icons.radio_button_unchecked,
                    color: AppColors.textTertiary, size: 20.w),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    todo.title,
                    style: AppTextStyles.label_16.copyWith(color: Colors.white),
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
Future<TodoEntity?> showTodoSelectBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<TodoEntity?>(
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

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart
git commit -m "feat: 타이머 할일 선택 바텀시트 위젯 구현 #14"
```

---

### Task 6: TimerScreen을 ConsumerStatefulWidget으로 변경 + 기능 구현

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart`

**Step 1: TimerScreen 전체 리팩토링**

StatelessWidget → ConsumerStatefulWidget으로 변경. TimerNotifier를 연동하여 실제 시작/일시정지/정지 기능 구현.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../providers/timer_provider.dart';
import '../providers/timer_state.dart';
import '../widgets/timer_ring_painter.dart';
import '../widgets/todo_select_bottom_sheet.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerNotifierProvider);
    final isRunning = timerState.status == TimerStatus.running;
    final isPaused = timerState.status == TimerStatus.paused;
    final isIdle = timerState.status == TimerStatus.idle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '타이머',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: Colors.white, size: 24.w),
            onPressed: () {
              // TODO: 타이머 기록 화면 (향후 구현)
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 연동된 할일 표시
            if (timerState.linkedTodoTitle != null) ...[
              FadeSlideIn(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded,
                          color: AppColors.primary, size: 16.w),
                      SizedBox(width: AppSpacing.s8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200.w),
                        child: Text(
                          timerState.linkedTodoTitle!,
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s24),
            ],

            // 타이머 링 + 시간 표시
            FadeSlideIn(
              child: SizedBox(
                width: 260.w,
                height: 260.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(260.w, 260.w),
                      painter: TimerRingPainter(
                        progress: _calculateProgress(timerState.elapsed),
                        isRunning: isRunning,
                        strokeWidth: 6.w,
                      ),
                    ),
                    Padding(
                      padding: AppPadding.horizontal16,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDuration(timerState.elapsed),
                              style: AppTextStyles.timer_48.copyWith(
                                color: isRunning
                                    ? AppColors.timerRunning
                                    : Colors.white,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s4),
                            Text(
                              isIdle
                                  ? '집중 시간을 측정해보세요'
                                  : isRunning
                                      ? '집중 중...'
                                      : '일시정지',
                              style: AppTextStyles.tag_12.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s48),

            // 컨트롤 버튼
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: _buildControls(isIdle, isRunning, isPaused),
            ),
            SizedBox(height: AppSpacing.s48),

            // 오늘의 통계 (하드코딩 유지 — 향후 구현)
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: AppPadding.horizontal20,
                child: AppCard(
                  style: AppCardStyle.outlined,
                  padding: AppPadding.all20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SpaceStatItem(
                        icon: Icons.today_rounded,
                        label: '오늘',
                        value: '0시간 0분',
                      ),
                      Container(
                        width: 1,
                        height: 40.h,
                        color: AppColors.spaceDivider,
                      ),
                      SpaceStatItem(
                        icon: Icons.date_range_rounded,
                        label: '이번 주',
                        value: '0시간 0분',
                      ),
                      Container(
                        width: 1,
                        height: 40.h,
                        color: AppColors.spaceDivider,
                      ),
                      SpaceStatItem(
                        icon: Icons.local_fire_department_rounded,
                        label: '연속',
                        value: '0일',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(bool isIdle, bool isRunning, bool isPaused) {
    if (isIdle) {
      return AppButton(
        text: '시작하기',
        onPressed: _onStart,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isRunning)
          AppButton(
            text: '일시정지',
            onPressed: () => ref.read(timerNotifierProvider.notifier).pause(),
            style: AppButtonStyle.outlined,
          ),
        if (isPaused)
          AppButton(
            text: '계속하기',
            onPressed: () => ref.read(timerNotifierProvider.notifier).resume(),
          ),
        SizedBox(width: AppSpacing.s16),
        AppButton(
          text: '정지',
          onPressed: () => ref.read(timerNotifierProvider.notifier).stop(),
          style: AppButtonStyle.outlined,
        ),
      ],
    );
  }

  Future<void> _onStart() async {
    final selectedTodo = await showTodoSelectBottomSheet(context: context);

    if (!mounted) return;

    ref.read(timerNotifierProvider.notifier).start(
      todoId: selectedTodo?.id,
      todoTitle: selectedTodo?.title,
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// 1시간(3600초)을 한 바퀴로 계산. 넘으면 다시 0부터.
  double _calculateProgress(Duration elapsed) {
    const oneHourSeconds = 3600;
    return (elapsed.inSeconds % oneHourSeconds) / oneHourSeconds;
  }
}
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "feat: TimerScreen 기능 구현 (시작/일시정지/정지 + 할일 연동) #14"
```

---

## Phase 4: AppButton style 확인 및 최종 검증

### Task 7: AppButton에 outlined style 존재 확인

**Files:**
- Read: `lib/core/widgets/buttons/app_button.dart`

**Step 1: AppButtonStyle.outlined 존재 확인**

AppButton 위젯에 `AppButtonStyle.outlined` 스타일이 존재하는지 확인.
없으면 `style` 파라미터 사용 부분을 제거하거나 대체 방법 적용.

**Step 2: 필요 시 수정 후 커밋**

---

### Task 8: build_runner 전체 재실행 + flutter analyze

**Step 1: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 모든 generated 파일 정상 생성

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 최종 커밋**

```bash
git add -A
git commit -m "chore: 타이머-할일 연동 코드 생성 파일 업데이트 #14"
```

---

## 변경 요약

### 변경되는 파일
| 파일 | 변경 내용 |
|------|-----------|
| `todo_add_bottom_sheet.dart` | 수동 estimatedMinutes 입력 필드 제거 |
| `home_screen.dart` | estimatedMinutes 전달 제거 + subtitle를 actualMinutes로 변경 |
| `todo_list_screen.dart` | estimatedMinutes 전달 제거 + subtitle를 actualMinutes로 변경 |

### 새로 생성되는 파일
| 파일 | 역할 |
|------|------|
| `timer/presentation/providers/timer_state.dart` | TimerState Freezed 모델 (idle/running/paused, elapsed, linkedTodoId) |
| `timer/presentation/providers/timer_provider.dart` | TimerNotifier (시작/일시정지/정지 + 할일 actualMinutes 누적) |
| `timer/presentation/widgets/todo_select_bottom_sheet.dart` | 타이머 시작 시 연동할 할일 선택 바텀시트 |

### 수정되는 파일
| 파일 | 변경 내용 |
|------|-----------|
| `timer/presentation/screens/timer_screen.dart` | StatelessWidget → ConsumerStatefulWidget, 실제 기능 구현 |

### 데이터 흐름
```
1. 타이머 시작 → 할일 선택 바텀시트 → 선택 또는 '연동 없이 시작'
2. Timer.periodic(1초) → TimerState.elapsed 누적
3. 타이머 정지 → elapsed.inMinutes를 할일 actualMinutes에 누적 저장
4. TodoItem subtitle → "${actualMinutes}분 공부" 표시
```

### 유지되는 것
- `TodoEntity.estimatedMinutes` 필드 — 엔티티/모델에 유지 (백엔드 호환)
- `TodoEntity.actualMinutes` 필드 — 타이머 시간 저장용으로 활용
- 기존 할일 CRUD 로직 — 변경 없음
- SharedPreferences 저장 — todo 데이터는 기존대로 동작
