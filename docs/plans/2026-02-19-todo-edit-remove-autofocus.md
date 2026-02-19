# 할일 수정 시 자동 포커스 제거 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 할일 수정 바텀시트에서 자동 키보드 팝업을 제거하여, 사용자가 텍스트필드를 탭해야 포커스되도록 변경한다.

**Architecture:** `TodoAddBottomSheet`가 생성/수정 모드를 모두 담당하므로, `autofocus`를 수정 모드일 때 `false`로 전환. 생성 모드는 기존대로 `true` 유지.

**Tech Stack:** Flutter, AppTextField

---

### Task 1: TodoAddBottomSheet — 수정 모드 autofocus 제거

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart:152`

**Step 1: autofocus를 모드에 따라 분기**

현재 코드 (line 148-154):
```dart
child: AppTextField(
  controller: _titleController,
  hintText: '할 일을 입력하세요',
  onSubmitted: (_) => _submit(),
  autofocus: true,
  showBorder: false,
),
```

변경 후:
```dart
child: AppTextField(
  controller: _titleController,
  hintText: '할 일을 입력하세요',
  onSubmitted: (_) => _submit(),
  autofocus: !_isEditMode,
  showBorder: false,
),
```

- `_isEditMode`는 이미 `widget.initialTodo != null`로 정의되어 있음 (line 41)
- 생성 모드(`_isEditMode == false`) → `autofocus: true` (기존 동작 유지)
- 수정 모드(`_isEditMode == true`) → `autofocus: false` (사용자가 탭해야 포커스)

**Step 2: 빌드 확인**

Run: `flutter analyze lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart
git commit -m "fix: 할일 수정 시 자동 키보드 팝업 제거, 탭하여 포커스 #27"
```
