# Dismissible 삭제 에러 수정

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 할일 스와이프 삭제 시 DismissibleState 에러를 수정한다.

**Architecture:** `deleteTodo`의 `invalidateSelf()` 호출이 AsyncLoading 상태 전이를 유발하여 Dismissible 위젯 트리 충돌 발생. 낙관적 상태 업데이트(optimistic update)로 교체하여 Loading 상태 없이 즉시 리스트에서 제거한다.

**Tech Stack:** Flutter, Riverpod

---

## 원인 분석

```
onDismissed 발생 → deleteTodo() 호출
→ invalidateSelf() → AsyncLoading 상태 전이
→ 위젯 트리 전체 리빌드 → Dismissible이 이미 dismissed 상태인데 다시 빌드 시도
→ DismissibleState 에러
```

## Task 1: TodoListNotifier.deleteTodo 낙관적 업데이트 적용

**Files:**
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart:107-111`

**Step 1: deleteTodo를 낙관적 업데이트로 변경**

기존:
```dart
Future<void> deleteTodo(String id) async {
  final useCase = ref.read(deleteTodoUseCaseProvider);
  await useCase.execute(id);
  ref.invalidateSelf();
}
```

변경:
```dart
Future<void> deleteTodo(String id) async {
  // 낙관적 업데이트: Loading 없이 즉시 리스트에서 제거
  state = AsyncData(
    state.valueOrNull?.where((t) => t.id != id).toList() ?? [],
  );
  final useCase = ref.read(deleteTodoUseCaseProvider);
  await useCase.execute(id);
}
```

**Step 2: flutter analyze 검증**

```bash
flutter analyze
```

Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/providers/todo_provider.dart
git commit -m "fix: Dismissible 삭제 시 DismissibleState 에러 수정 #16"
```
