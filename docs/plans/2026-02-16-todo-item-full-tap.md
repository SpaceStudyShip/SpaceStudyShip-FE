# TodoItem 전체 영역 탭 토글 구현

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** TodoItem 위젯에서 체크박스뿐 아니라 전체 영역을 탭해도 완료 토글되도록 UX 개선

**Architecture:** `_buildCheckbox()`의 내부 `GestureDetector` 제거 → 외부 `GestureDetector`의 `onTapUp`에서 `onTap ?? onToggle` 호출. `onTap`이 설정된 경우(편집 모드 등)는 `onTap` 우선, 미설정 시 `onToggle` 실행.

**Tech Stack:** Flutter, TodoItem StatefulWidget

---

### Task 1: TodoItem 전체 영역 탭 토글로 변경

**Files:**
- Modify: `lib/core/widgets/space/todo_item.dart`

**Step 1: 외부 GestureDetector의 onTapUp 변경**

기존 (67행):
```dart
widget.onTap?.call();
```

변경:
```dart
(widget.onTap ?? widget.onToggle).call();
```

이렇게 하면:
- `onTap` 설정됨 (편집 모드): 전체 탭 → 선택 토글
- `onTap` 미설정 (일반 모드): 전체 탭 → 완료 토글

**Step 2: _buildCheckbox() 내부 GestureDetector 제거**

기존:
```dart
Widget _buildCheckbox() {
  return GestureDetector(
    onTap: widget.onToggle,
    child: AnimatedContainer(...),
  );
}
```

변경:
```dart
Widget _buildCheckbox() {
  return AnimatedContainer(...);
}
```

외부 GestureDetector가 전체 영역을 처리하므로 체크박스 자체의 GestureDetector는 불필요.

**Step 3: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```bash
git add lib/core/widgets/space/todo_item.dart
git commit -m "fix: TodoItem 전체 영역 탭으로 완료 토글 UX 개선 #16"
```
