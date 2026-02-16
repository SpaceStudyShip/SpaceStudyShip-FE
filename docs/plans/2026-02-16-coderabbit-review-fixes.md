# CodeRabbit PR #18 리뷰 개선사항 적용 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit이 PR #18에서 지적한 코드 품질 이슈 중 현재 #17 브랜치에 남아있는 4가지를 수정한다.

**Architecture:** 기존 파일만 수정. 에러 메시지 사용자 친화화, 로딩 UX 개선, 초기화 안전성 강화.

**Tech Stack:** Flutter, Riverpod, SharedPreferences

---

## 이슈 분류 (Triage)

### 이미 #17에서 해결됨 (Skip)
| CodeRabbit 이슈 | 현재 상태 |
|---|---|
| deleteTodo 롤백 누락 | ✅ try-catch + previousState 롤백 완료 |
| onDismissed 삭제 복구 불가 | ✅ DismissibleTodoItem의 confirmDismiss 패턴 적용 |
| AsyncValue\<List\<dynamic\>\> 타입 | ✅ TodoEntity/TodoCategoryEntity 명시 |
| Hero 애니메이션 출발점 누락 | ✅ Hero 미사용 (plan docs에만 존재) |

### 수정 필요 (4개)
1. `todo_list_screen.dart:144-146` — 새로고침 시 로딩 스피너가 기존 데이터를 가림
2. `todo_list_screen.dart:150-165` — 에러 객체 UI 직접 노출
3. `category_todo_screen.dart:112-117` — 에러 객체 UI 직접 노출
4. `main.dart:175` — SharedPreferences 초기화 에러 처리 누락

---

## Task 1: TodoListScreen 로딩 UX 개선

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart:144-146`

**문제:** `invalidateSelf()` 후 `isLoading`이 true가 되면 기존 데이터가 있어도 스피너로 대체됨.

**수정:**

```dart
// Before
if (todosAsync.isLoading || categoriesAsync.isLoading) {
  return const Center(child: CircularProgressIndicator());
}

// After — 캐시된 데이터가 있으면 스피너 대신 기존 데이터 유지
if (!todosAsync.hasValue && !categoriesAsync.hasValue) {
  if (todosAsync.isLoading || categoriesAsync.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
}
```

**Commit:** `fix: TodoListScreen 새로고침 시 기존 데이터 유지 #17`

---

## Task 2: TodoListScreen 에러 메시지 사용자 친화화

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart:148-165`

**문제:** `'오류: $todosError'`로 내부 에러 객체 노출 → 스택 트레이스/내부 구현 세부사항 유출 가능.

**수정:**

```dart
// Before
if (todosError != null) {
  return Center(
    child: Text(
      '오류: $todosError',
      style: AppTextStyles.label_16.copyWith(color: AppColors.error),
    ),
  );
}
if (categoriesError != null) {
  return Center(
    child: Text(
      '오류: $categoriesError',
      style: AppTextStyles.label_16.copyWith(color: AppColors.error),
    ),
  );
}

// After
if (todosError != null || categoriesError != null) {
  return Center(
    child: Text(
      '데이터를 불러오지 못했어요',
      style: AppTextStyles.label_16.copyWith(color: AppColors.error),
    ),
  );
}
```

**Commit:** Task 1과 함께 커밋

---

## Task 3: CategoryTodoScreen 에러 메시지 사용자 친화화

**Files:**
- Modify: `lib/features/todo/presentation/screens/category_todo_screen.dart:112-117`

**문제:** 동일하게 `'오류: $error'`로 내부 에러 노출.

**수정:**

```dart
// Before
error: (error, _) => Center(
  child: Text(
    '오류: $error',
    style: AppTextStyles.label_16.copyWith(color: AppColors.error),
  ),
),

// After
error: (_, __) => Center(
  child: Text(
    '데이터를 불러오지 못했어요',
    style: AppTextStyles.label_16.copyWith(color: AppColors.error),
  ),
),
```

**Commit:** `fix: 에러 메시지 사용자 친화화 (내부 객체 노출 제거) #17`

---

## Task 4: SharedPreferences 초기화 에러 처리

**Files:**
- Modify: `lib/main.dart:172-182`

**문제:** Firebase, FCM, Analytics 등 다른 초기화는 try-catch가 있지만 SharedPreferences만 예외 처리 없음. 저장소 손상 시 앱 시작 불가.

**수정:**

```dart
// Before
final prefs = await SharedPreferences.getInstance();

runApp(
  ProviderScope(
    overrides: [
      localTodoDataSourceProvider.overrideWithValue(
        LocalTodoDataSource(prefs),
      ),
    ],
    child: const MyApp(),
  ),
);

// After
late final SharedPreferences prefs;
try {
  prefs = await SharedPreferences.getInstance();
} catch (e) {
  debugPrint('❌ [SharedPreferences] 초기화 실패: $e');
  // SharedPreferences 실패해도 앱은 시작 — 빈 저장소로 대체
  runApp(const ProviderScope(child: MyApp()));
  return;
}

runApp(
  ProviderScope(
    overrides: [
      localTodoDataSourceProvider.overrideWithValue(
        LocalTodoDataSource(prefs),
      ),
    ],
    child: const MyApp(),
  ),
);
```

**Commit:** `fix: SharedPreferences 초기화 에러 처리 추가 #17`

---

## 검증

1. `flutter analyze` — 0 이슈
2. 수동 테스트:
   - 배치 삭제 후 스피너 대신 목록 유지 확인
   - 에러 시 "데이터를 불러오지 못했어요" 메시지 확인
   - 앱 정상 시작 확인
