# 타이머 백그라운드 동작 수정 (Timestamp 기반)

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 앱이 백그라운드로 갈 때 타이머가 멈추는 문제를 해결한다. `Timer.periodic`의 1초 카운팅 대신 `DateTime` 타임스탬프 기반으로 경과 시간을 계산하여 백그라운드 시간도 정확히 반영한다.

**Architecture:** `TimerState`에 `startTime`(시작 시각)과 `accumulatedBeforePause`(일시정지 전 누적)를 추가한다. `elapsed`는 실시간 계산: `DateTime.now() - startTime + accumulatedBeforePause`. `Timer.periodic`은 UI 갱신 트리거 용도로만 사용한다.

**Tech Stack:** Flutter, Riverpod, Freezed, DateTime

---

## 현재 문제

```
Timer.periodic(1초) → elapsed += 1초 (매 tick)
백그라운드 진입 → periodic 중단 → elapsed 증가 안 함
포그라운드 복귀 → periodic 재개 → 백그라운드 시간 누락
```

## 해결 원리

```
start() → startTime = DateTime.now()
periodic(1초) → elapsed = DateTime.now() - startTime + accumulated (UI 갱신용)
백그라운드 진입 → periodic 중단 (문제 없음)
포그라운드 복귀 → periodic 재개 → 첫 tick에서 정확한 elapsed 계산
pause() → accumulated += DateTime.now() - startTime, startTime = null
resume() → startTime = DateTime.now() (accumulated 유지)
stop() → 최종 elapsed로 할일 업데이트
```

---

## Task 1: TimerState에 타임스탬프 필드 추가

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_state.dart`

**Step 1: startTime, accumulatedBeforePause 필드 추가**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

enum TimerStatus { idle, running, paused }

@freezed
class TimerState with _$TimerState {
  const TimerState._();

  const factory TimerState({
    @Default(TimerStatus.idle) TimerStatus status,
    @Default(Duration.zero) Duration accumulatedBeforePause,
    DateTime? startTime,
    String? linkedTodoId,
    String? linkedTodoTitle,
  }) = _TimerState;

  /// 실시간 경과 시간 계산
  Duration get elapsed {
    if (status == TimerStatus.running && startTime != null) {
      return accumulatedBeforePause +
          DateTime.now().difference(startTime!);
    }
    return accumulatedBeforePause;
  }
}
```

변경점:
- `elapsed` 필드 제거 → `elapsed` getter로 교체 (실시간 계산)
- `startTime`: running 시작 시각
- `accumulatedBeforePause`: pause 전까지 누적된 시간
- `const TimerState._()` 추가 (getter를 위한 private constructor)

**Step 2: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_state.dart lib/features/timer/presentation/providers/timer_state.freezed.dart
git commit -m "feat: TimerState 타임스탬프 기반으로 변경 (startTime + accumulatedBeforePause) #16"
```

---

## Task 2: TimerNotifier 타임스탬프 기반으로 수정

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_provider.dart`

**Step 1: start/pause/resume/stop 수정**

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
      startTime: DateTime.now(),
      accumulatedBeforePause: Duration.zero,
      linkedTodoId: todoId,
      linkedTodoTitle: todoTitle,
    );

    _startPeriodicUiUpdate();
  }

  /// 타이머 일시정지
  void pause() {
    _timer?.cancel();

    // 현재까지 경과 시간을 accumulated에 저장
    state = state.copyWith(
      status: TimerStatus.paused,
      accumulatedBeforePause: state.elapsed,
      startTime: null,
    );
  }

  /// 타이머 재개
  void resume() {
    if (state.status != TimerStatus.paused) return;

    state = state.copyWith(
      status: TimerStatus.running,
      startTime: DateTime.now(),
    );

    _startPeriodicUiUpdate();
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

  /// UI 갱신용 periodic timer (시간 계산에는 사용하지 않음)
  void _startPeriodicUiUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // state를 다시 설정하여 UI 리빌드 트리거
      // elapsed getter가 DateTime.now() 기반으로 정확한 값 반환
      state = state.copyWith();
    });
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

변경점:
- `start()`: `startTime = DateTime.now()`, `accumulatedBeforePause = Duration.zero`
- `pause()`: `accumulatedBeforePause = state.elapsed` (현재 경과 저장), `startTime = null`
- `resume()`: `startTime = DateTime.now()` (accumulated 유지)
- `_startPeriodicUiUpdate()`: `state.copyWith()`로 UI 리빌드만 트리거
- `stop()`: `state.elapsed`에서 정확한 경과 시간 가져옴

**Step 2: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: flutter analyze 검증**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_provider.dart lib/features/timer/presentation/providers/timer_provider.g.dart
git commit -m "feat: TimerNotifier 타임스탬프 기반 경과시간 계산으로 변경 #16"
```

---

## Task 3: TimerScreen elapsed 참조 확인

**Files:**
- Verify: `lib/features/timer/presentation/screens/timer_screen.dart`

`timerState.elapsed`를 사용하는 부분이 이미 getter를 호출하므로 변경 불필요.
확인할 부분:
- `_formatDuration(timerState.elapsed)` — getter 호출 ✅
- `_calculateProgress(timerState.elapsed)` — getter 호출 ✅

만약 Freezed가 `elapsed`를 필드로 인식하여 `copyWith`에 포함시키는 문제가 있으면 확인 필요.

**Step 1: flutter analyze + 실행 테스트**

```bash
flutter analyze
```

**Step 2: Commit (변경 있을 경우만)**

---

## Task 4: 최종 검증

수동 테스트 체크리스트:
- [ ] 타이머 시작 → 포그라운드에서 정상 카운팅
- [ ] 타이머 실행 중 → 홈 버튼 → 30초 대기 → 앱 복귀 → 약 30초 증가 확인
- [ ] 타이머 실행 중 → 화면 끄기 → 1분 대기 → 화면 켜기 → 약 1분 증가 확인
- [ ] 일시정지 → 백그라운드 → 복귀 → 일시정지 유지 (시간 증가 안 함)
- [ ] 계속하기 → 정상 재개
- [ ] 종료 → 연동된 할일에 시간 정확히 반영
