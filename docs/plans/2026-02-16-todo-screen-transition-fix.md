# Todo Screen 페이지 전환 + 간격 수정

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** TodoListScreen과 CategoryTodoScreen의 페이지 전환 시 배경이 투명하게 보이는 문제 수정 + 카테고리 헤더-그리드 간격 축소

**Architecture:** 기존 코드에서 `Colors.transparent` 배경을 사용했으나, 이 화면들은 `context.push()`로 진입하는 서브 라우트. GoRouter 기본 slide-from-right 전환 중 투명 배경이 이전 화면을 노출함. 다른 서브 라우트(about_screen, spaceship_collection_screen 등)와 동일하게 `AppColors.spaceBackground` + `SpaceBackground` Stack 패턴으로 수정.

**Tech Stack:** Flutter, GoRouter, flutter_screenutil

---

### Task 1: TodoListScreen 배경 수정 + 간격 축소

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart`

**Step 1: import 추가 + Scaffold 배경 + body Stack 래핑 + 간격 수정**

3가지 변경:

1. `import '../../../../core/widgets/backgrounds/space_background.dart';` 추가 (app_dialog.dart import 아래)
2. Scaffold `backgroundColor: Colors.transparent` → `AppColors.spaceBackground`
3. `body: _buildBody(...)` → `body: Stack(children: [Positioned.fill(child: SpaceBackground()), _buildBody(...)])`
4. 카테고리 헤더-그리드 사이 `AppSpacing.s12` → `AppSpacing.s8`

```dart
// import 추가 (line 9 아래)
import '../../../../core/widgets/backgrounds/space_background.dart';

// Scaffold 변경
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  appBar: AppBar(...),
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      _buildBody(context, ref, todosAsync, categoriesAsync),
    ],
  ),
);

// 간격 변경 (카테고리 헤더 아래)
SizedBox(height: AppSpacing.s8),  // was s12
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/screens/todo_list_screen.dart
git commit -m "fix: TodoListScreen 페이지 전환 배경 수정 + 카테고리 간격 축소 #16"
```

---

### Task 2: CategoryTodoScreen 배경 수정

**Files:**
- Modify: `lib/features/todo/presentation/screens/category_todo_screen.dart`

**Step 1: import 추가 + Scaffold 배경 + body Stack 래핑**

3가지 변경:

1. `import '../../../../core/widgets/backgrounds/space_background.dart';` 추가 (app_colors.dart import 아래)
2. Scaffold `backgroundColor: Colors.transparent` → `AppColors.spaceBackground`
3. `body: todosAsync.when(...)` → `body: Stack(children: [Positioned.fill(child: SpaceBackground()), todosAsync.when(...)])`

```dart
// import 추가 (line 6 아래)
import '../../../../core/widgets/backgrounds/space_background.dart';

// Scaffold 변경
return Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  appBar: AppBar(...),
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      todosAsync.when(
        data: (todos) { ... },
        loading: () => ...,
        error: (error, _) => ...,
      ),
    ],
  ),
);
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/todo/presentation/screens/category_todo_screen.dart
git commit -m "fix: CategoryTodoScreen 페이지 전환 배경 수정 #16"
```

---

### Task 3: 최종 검증

**Step 1: 전체 정적 분석**

Run: `flutter analyze`
Expected: No issues

**Step 2: 시각적 검증 (수동)**

확인 항목:
1. Home → TodoListScreen 전환 시 slide 애니메이션이 깔끔한지 (이전 화면 비침 없음)
2. TodoListScreen → CategoryTodoScreen 전환도 동일한지
3. 뒤로가기 전환도 정상인지
4. 카테고리 헤더와 그리드 사이 간격이 적절한지
5. AppBar 뒤로 별 배경이 보이는지 (extendBodyBehindAppBar 유지)
