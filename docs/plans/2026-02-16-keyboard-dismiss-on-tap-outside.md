# 키보드 빈 공간 탭 시 포커스 아웃 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 텍스트 입력이 있는 모든 바텀시트에서 빈 공간 탭 시 키보드가 닫히도록 UX 개선

**Architecture:** 각 바텀시트의 콘텐츠를 `GestureDetector(onTap: unfocus, behavior: translucent)`로 감싸서 빈 영역 탭 시 포커스 해제

**Tech Stack:** Flutter, FocusScope

---

## 분석 결과

키보드를 사용하는 화면 2곳 확인. 둘 다 tap-to-dismiss 미구현.

| 파일 | 위젯 | autofocus | 키보드 닫기 |
|------|------|-----------|-------------|
| `todo_add_bottom_sheet.dart` | TodoAddBottomSheet | true | **없음** |
| `category_add_bottom_sheet.dart` | CategoryAddBottomSheet | true | **없음** |

---

### Task 1: TodoAddBottomSheet에 tap-to-dismiss 추가

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart:97`

**Step 1: SingleChildScrollView을 GestureDetector로 감싸기**

`build()` 메서드 내 `SingleChildScrollView` 바로 위에 `GestureDetector` 추가:

```dart
// 변경 전 (Line 97)
child: SingleChildScrollView(

// 변경 후
child: GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  behavior: HitTestBehavior.translucent,
  child: SingleChildScrollView(
```

닫는 괄호도 맞춰서 추가 (Line 299 부근의 `SingleChildScrollView` 닫는 `)` 뒤에 `)` 하나 추가).

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```text
fix: TodoAddBottomSheet 빈 공간 탭 시 키보드 닫기 추가
```

---

### Task 2: CategoryAddBottomSheet에 tap-to-dismiss 추가

**Files:**
- Modify: `lib/features/todo/presentation/widgets/category_add_bottom_sheet.dart:74`

**Step 1: Column을 GestureDetector로 감싸기**

`build()` 메서드 내 `Column` 바로 위에 `GestureDetector` 추가:

```dart
// 변경 전 (Line 74)
child: Column(

// 변경 후
child: GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  behavior: HitTestBehavior.translucent,
  child: Column(
```

닫는 괄호도 맞춰서 추가 (Line 178 부근의 `Column` 닫는 `)` 뒤에 `)` 하나 추가).

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```text
fix: CategoryAddBottomSheet 빈 공간 탭 시 키보드 닫기 추가
```

---

## 최종 검증

Run: `flutter analyze`
Expected: No issues found

두 Task를 단일 커밋으로 합쳐도 무방:

```text
fix: 바텀시트 빈 공간 탭 시 키보드 닫기 UX 개선
```
