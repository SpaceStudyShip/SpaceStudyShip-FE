# CodeRabbit Nitpick 리뷰 수정 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit PR 리뷰의 nitpick 8개 중 실용적 가치가 있는 5개를 선별하여 수정

**Architecture:** 기존 코드 패턴 유지하면서 방어적 코딩, API 일관성, 에러 피드백 개선

**Tech Stack:** Flutter, Riverpod, Freezed, SharedPreferences

---

## CodeRabbit 리뷰 분석 결과

### 수정 대상 (5개)

| # | 파일 | 내용 | 이유 |
|---|------|------|------|
| 1 | `category_add_bottom_sheet.dart` | edit mode에서 id 포함 | 방어적 코딩, 비용 0 |
| 2 | `category_select_bottom_sheet.dart` | error 케이스 피드백 | UX — 사용자가 에러 인지 불가 |
| 3 | `todo_list_screen.dart` | `_editCategory` WidgetRef 파라미터 제거 | 불필요한 파라미터, 코드 간결화 |
| 4 | `todo_add_bottom_sheet.dart` | `initialCategoryId` → `initialCategoryIds` | 다중 태그 API 일관성 |
| 5 | `local_todo_repository_impl.dart` | `createCategory` updatedAt 초기값 | createTodo와 패턴 일관성 |

### 무시 대상 (3개)

| # | 파일 | 내용 | 무시 이유 |
|---|------|------|----------|
| 6 | `docs/plans/*.md` | 코드 블록 언어 지정 (MD040) | 이미 완료된 계획 문서, CI 미체크 |
| 7 | `docs/plans/*.md` | `flutter pub run` → `dart run` | 프로젝트 전체 컨벤션 문제, PR 범위 밖 |
| 8 | `dismissible_todo_item.dart` | async void 경고 | Flutter 표준 패턴, CodeRabbit도 "일반적으로 허용" 인정 |

---

## Task 1: category_add_bottom_sheet — edit mode에서 id 포함

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_add_bottom_sheet.dart:65-68`

**Step 1: 수정 모드 시 id를 결과 맵에 포함**

```dart
// Before
void _submit() {
  final name = _nameController.text.trim();
  if (name.isEmpty) return;
  Navigator.of(context).pop({'name': name, 'emoji': _selectedEmoji});
}

// After
void _submit() {
  final name = _nameController.text.trim();
  if (name.isEmpty) return;
  Navigator.of(context).pop({
    if (_isEditMode) 'id': widget.initialCategory!.id,
    'name': name,
    'emoji': _selectedEmoji,
  });
}
```

**Step 2: 검증 — flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

## Task 2: category_select_bottom_sheet — error 피드백 추가

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_select_bottom_sheet.dart:122-126`

**Step 1: error 케이스에 에러 메시지 표시**

```dart
// Before
error: (e, st) => const SizedBox.shrink(),

// After
error: (e, st) => Padding(
  padding: AppPadding.all16,
  child: Text(
    '카테고리 목록을 불러오지 못했어요',
    style: AppTextStyles.tag_12.copyWith(color: AppColors.error),
  ),
),
```

**Step 2: 검증 — flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

## Task 3: todo_list_screen — _editCategory WidgetRef 파라미터 제거

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`
  - Line 223: 호출부 수정
  - Line 330-349: 메서드 시그니처 수정

**Step 1: _editCategory 메서드에서 WidgetRef ref 파라미터 제거**

```dart
// Before
Future<void> _editCategory(
  BuildContext context,
  WidgetRef ref,
  TodoCategoryEntity cat,
) async { ... }

// After
Future<void> _editCategory(
  BuildContext context,
  TodoCategoryEntity cat,
) async { ... }
```

ConsumerState의 `ref`를 직접 사용하므로 파라미터 불필요.

**Step 2: 호출부 수정**

```dart
// Before (line ~223)
onLongPress: _isEditMode ? null : () => _editCategory(context, ref, cat),

// After
onLongPress: _isEditMode ? null : () => _editCategory(context, cat),
```

**Step 3: 검증 — flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

## Task 4: todo_add_bottom_sheet — initialCategoryId → initialCategoryIds

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`
  - Lines 17-23: 생성자 파라미터 변경
  - Lines 56-58: initState 로직 간소화
  - Lines 489-501: 헬퍼 함수 시그니처 변경
- Modify: `lib/features/todo/presentation/screens/category_todo_screen.dart:62`
  - 호출부 수정

**Step 1: 위젯 생성자 변경**

```dart
// Before
const TodoAddBottomSheet({
  super.key,
  this.initialCategoryId,
  this.initialScheduledDates,
  this.initialTodo,
});

final String? initialCategoryId;

// After
const TodoAddBottomSheet({
  super.key,
  this.initialCategoryIds,
  this.initialScheduledDates,
  this.initialTodo,
});

final List<String>? initialCategoryIds;
```

**Step 2: initState 로직 수정**

```dart
// Before
_selectedCategoryIds = widget.initialCategoryId != null
    ? [widget.initialCategoryId!]
    : [];

// After
_selectedCategoryIds = widget.initialCategoryIds != null
    ? List<String>.from(widget.initialCategoryIds!)
    : [];
```

**Step 3: 헬퍼 함수 시그니처 변경**

```dart
// Before
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
  String? initialCategoryId,
  ...
}) {
  return ... TodoAddBottomSheet(
    initialCategoryId: initialCategoryId,
    ...
  );
}

// After
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
  List<String>? initialCategoryIds,
  ...
}) {
  return ... TodoAddBottomSheet(
    initialCategoryIds: initialCategoryIds,
    ...
  );
}
```

**Step 4: 호출부 수정 (category_todo_screen.dart)**

```dart
// Before
initialCategoryId: categoryId,

// After
initialCategoryIds: [categoryId],
```

**Step 5: 검증 — flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

## Task 5: local_todo_repository_impl — createCategory updatedAt 초기값

**Files:**
- Modify: `lib/features/todo/data/repositories/local_todo_repository_impl.dart:84-89`

**Step 1: createCategory에 updatedAt 초기값 추가**

```dart
// Before
final model = TodoCategoryModel(
  id: _uuid.v4(),
  name: name,
  emoji: emoji,
  createdAt: DateTime.now(),
);

// After
final now = DateTime.now();
final model = TodoCategoryModel(
  id: _uuid.v4(),
  name: name,
  emoji: emoji,
  createdAt: now,
  updatedAt: now,
);
```

createTodo와 동일한 패턴으로 일관성 확보.

**Step 2: 검증 — flutter analyze**

Run: `flutter analyze`
Expected: No issues found

---

## Task 6: 최종 커밋

**Step 1: 전체 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 커밋**

```text
fix: CodeRabbit nitpick 리뷰 반영 (5건) #21
```

변경 내용:
- edit mode 결과 맵에 id 포함
- 카테고리 로딩 에러 피드백 추가
- _editCategory 불필요한 WidgetRef 파라미터 제거
- initialCategoryId → initialCategoryIds (다중 태그 API 일관성)
- createCategory에 updatedAt 초기값 추가
