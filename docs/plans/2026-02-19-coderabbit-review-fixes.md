# CodeRabbit 리뷰 피드백 수정 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit PR 리뷰에서 제기된 실질적 버그 및 UX 이슈 4건 수정

**Architecture:** 타이머 기능 내 4개 파일의 소규모 수정. 각각 독립적이며 순서 무관.

**Tech Stack:** Flutter, Riverpod, Dart

---

## Task 1: timer_provider.dart — DateTime.now() 타이밍 정확도 수정

**문제:** `stop()` 메서드에서 `_updateTodoActualMinutes` await 이후 `DateTime.now()`를 호출하여 세션 startedAt/endedAt 시각이 실제보다 늦게 기록됨.

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_provider.dart:83-111`

**Step 1: 코드 수정**

`stop()` 메서드 상단에서 `endedAt`을 한 번 캡처하고, 이후 DateTime.now() 직접 호출을 제거:

```dart
  Future<({Duration sessionDuration, String? todoTitle, int? totalMinutes})?>
  stop() async {
    _timer?.cancel();

    final todoId = state.linkedTodoId;
    final todoTitle = state.linkedTodoTitle;
    final sessionDuration = state.elapsed;
    final elapsedMinutes = sessionDuration.inMinutes;
    final endedAt = DateTime.now();  // ← 비동기 작업 전에 캡처

    int? totalMinutes;

    if (todoId != null && elapsedMinutes > 0) {
      totalMinutes = await _updateTodoActualMinutes(todoId, elapsedMinutes);
    }

    if (sessionDuration.inMinutes >= 1) {
      final session = TimerSessionEntity(
        id: endedAt.millisecondsSinceEpoch.toString(),  // ← endedAt 사용
        todoId: todoId,
        todoTitle: todoTitle,
        startedAt: endedAt.subtract(sessionDuration),   // ← endedAt 사용
        endedAt: endedAt,                                // ← endedAt 사용
        durationMinutes: elapsedMinutes,
      );
      await ref
          .read(timerSessionListNotifierProvider.notifier)
          .addSession(session);
    }

    final result = sessionDuration.inMinutes >= 1
        ? (
            sessionDuration: sessionDuration,
            todoTitle: todoTitle,
            totalMinutes: totalMinutes,
          )
        : null;

    state = const TimerState();
    return result;
  }
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/providers/timer_provider.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_provider.dart
git commit -m "fix: 타이머 세션 startedAt/endedAt 타임스탬프 정확도 개선"
```

---

## Task 2: timer_format_utils.dart — "X시간 0분" → "X시간" 표시 수정

**문제:** `formatMinutes(60)` → "1시간 0분" (부자연스러움). "1시간"이 자연스러운 한국어 표현.

**Files:**
- Modify: `lib/features/timer/presentation/utils/timer_format_utils.dart:7-12`

**Step 1: 코드 수정**

```dart
String formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0 && minutes > 0) return '$hours시간 $minutes분';
  if (hours > 0) return '$hours시간';
  return '$minutes분';
}
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/utils/timer_format_utils.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/utils/timer_format_utils.dart
git commit -m "fix: formatMinutes에서 정각 시간 표시 개선 (1시간 0분 → 1시간)"
```

---

## Task 3: todo_select_bottom_sheet.dart — ref.watch 위치 수정

**문제:** `ref.watch(categoryListNotifierProvider)`가 `todosAsync.when(data: ...)` 콜백 내부에서 조건부 호출됨. Riverpod 의존성 그래프 불안정 유발 가능.

**Files:**
- Modify: `lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart:19-42`

**Step 1: 코드 수정**

`build()` 메서드 최상단에서 모든 ref.watch를 무조건 호출:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListNotifierProvider);
    final categoriesAsync = ref.watch(categoryListNotifierProvider);  // ← 최상단으로 이동
    final categories = categoriesAsync.valueOrNull ?? [];             // ← 최상단으로 이동

    return DraggableScrollableSheet(
      // ... (기존 코드 유지)
      builder: (context, scrollController) {
        return Container(
          // ... (기존 코드 유지)
          child: todosAsync.when(
            data: (todos) {
              final incomplete = todos
                  .where((t) => !t.isFullyCompleted)
                  .toList();

              // ↓ 아래 두 줄 삭제 (위로 이동했으므로)
              // final categoriesAsync = ref.watch(categoryListNotifierProvider);
              // final categories = categoriesAsync.valueOrNull ?? [];

              return CustomScrollView(
                // ... (기존 코드 유지, categories는 클로저로 접근)
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart
git commit -m "fix: ref.watch를 when() 콜백 밖으로 이동하여 Riverpod 의존성 안정화"
```

---

## Task 4: todo_select_bottom_sheet.dart — actualMinutes 레이블 추가

**문제:** `_buildInfoItems()`에서 actualMinutes를 `'${todo.actualMinutes}분'`으로 표시. '예상 X분'과 구별 불가.

**Files:**
- Modify: `lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart:213-216`

**Step 1: 코드 수정**

```dart
    // 누적 실제 시간
    if (todo.actualMinutes != null && todo.actualMinutes! > 0) {
      items.add('누적 ${todo.actualMinutes}분');
    }
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart`
Expected: No issues found

**Step 3: Commit**

Task 3과 Task 4가 같은 파일이므로, Task 3 커밋 이후 별도 커밋:

```bash
git add lib/features/timer/presentation/widgets/todo_select_bottom_sheet.dart
git commit -m "fix: 할일 선택 바텀시트에서 누적 시간 레이블 추가"
```

---

## 스킵 사유 (참고)

| # | 이슈 | 스킵 사유 |
|---|------|-----------|
| 1 | docs MD040 마크다운 | 문서 린트 닛픽, 기능 무관 |
| 2 | space_calendar 마커 오버랩 | 추측성 우려, 확인 안 됨 |
| 4 | SharedPreferences 크래시 | `SharedPreferences.getInstance()`는 모바일에서 실패하지 않음. 기존 StateError는 개발자 실수 감지용이며 적절함 |
