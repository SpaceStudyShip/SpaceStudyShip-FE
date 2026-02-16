# CodeRabbit 리뷰 방어적 코딩 수정 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit PR 리뷰에서 지적된 3가지 실제 코드 이슈(앱 크래시 방지)를 수정한다.

**Architecture:** SharedPreferences JSON 손상 방어, 초기화 실패 시 graceful degradation, async 후 mounted 체크 추가

**Tech Stack:** Flutter, Riverpod, SharedPreferences, Freezed

---

## 분석 요약

CodeRabbit이 17개 코멘트를 남겼으나, **계획 문서(docs/) 대상 7개**와 **이미 해결된 2개**, **불필요 1개**를 제외하면 실제 수정이 필요한 항목은 **3개**뿐이다.

| 항목 | 파일 | 심각도 | 설명 |
|------|------|--------|------|
| A | `local_todo_datasource.dart` | 높음 | JSON 손상 시 앱 크래시 |
| B | `main.dart` | 높음 | SharedPreferences 실패 시 Todo 화면 진입 크래시 |
| C | `todo_list_screen.dart` | 낮음 | await 후 mounted 미체크 → setState assertion error |

---

### Task 1: LocalTodoDataSource JSON 디코딩 방어 처리

**Files:**
- Modify: `lib/features/todo/data/datasources/local_todo_datasource.dart:18-26, 35-43`

**Step 1: getTodos()에 try-catch 추가**

```dart
List<TodoModel> getTodos() {
  final jsonString = _prefs.getString(_todosKey);
  if (jsonString == null) return [];

  try {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // JSON 손상 시 데이터 초기화하고 빈 리스트 반환
    _prefs.remove(_todosKey);
    return [];
  }
}
```

**Step 2: getCategories()에 동일 패턴 적용**

```dart
List<TodoCategoryModel> getCategories() {
  final jsonString = _prefs.getString(_categoriesKey);
  if (jsonString == null) return [];

  try {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => TodoCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    _prefs.remove(_categoriesKey);
    return [];
  }
}
```

**Step 3: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

**Step 4: 커밋**

```text
fix: LocalTodoDataSource JSON 디코딩 방어 처리 추가 #17
```

---

### Task 2: SharedPreferences 초기화 실패 시 graceful degradation

**Files:**
- Modify: `lib/main.dart:172-194`
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart:24-26`

**Step 1: TodoListNotifier에서 UnimplementedError 안전 처리**

`localTodoDataSourceProvider`가 throw하더라도 `TodoListNotifier.build()`에서 catch하면 된다.
하지만 이미 `FutureOr<List<TodoEntity>> build()`는 `LocalTodoRepositoryImpl`을 거치므로,
가장 간단한 수정은 **main.dart에서 실패 시에도 빈 데이터소스를 제공하는 것**이다.

`main.dart` 수정:

```dart
// ============================================================
// 7. SharedPreferences 초기화 (Todo 로컬 저장용)
// ============================================================
late final SharedPreferences prefs;
try {
  prefs = await SharedPreferences.getInstance();
} catch (e) {
  debugPrint('❌ [SharedPreferences] 초기화 실패: $e');
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

**문제**: `prefs`가 초기화되지 않았을 수 있다. `late` 변수 접근 시 에러 발생.

**대안 — 더 안전한 접근**: 실패 경로에서도 override 제공

```dart
late final SharedPreferences? prefs;
try {
  prefs = await SharedPreferences.getInstance();
} catch (e) {
  debugPrint('❌ [SharedPreferences] 초기화 실패: $e');
  prefs = null;
}

if (prefs != null) {
  runApp(
    ProviderScope(
      overrides: [
        localTodoDataSourceProvider.overrideWithValue(
          LocalTodoDataSource(prefs!),
        ),
      ],
      child: const MyApp(),
    ),
  );
} else {
  // SharedPreferences 실패 시에도 앱 실행 (Todo 기능은 에러 상태로 표시)
  runApp(const ProviderScope(child: MyApp()));
}
```

**그리고** `todo_provider.dart`의 `localTodoDataSourceProvider`에서 에러 메시지 개선:

```dart
@riverpod
LocalTodoDataSource localTodoDataSource(Ref ref) {
  throw StateError(
    'LocalTodoDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}
```

**핵심**: `TodoListNotifier.build()`가 `FutureOr`를 반환하므로, 이 에러는 `AsyncError` 상태로 전환되어 UI에서 `todosAsync.when(error: ...)` 핸들러에 의해 처리된다. 따라서 앱 크래시는 발생하지 않는다.

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```text
fix: SharedPreferences 실패 시 graceful degradation 적용 #17
```

---

### Task 3: todo_list_screen.dart await 후 mounted 체크

**Files:**
- Modify: `lib/features/todo/presentation/screens/todo_list_screen.dart:348-362`

**Step 1: await 사이에 mounted 체크 추가**

```dart
if (confirmed == true && mounted) {
  if (_selectedTodoIds.isNotEmpty) {
    await ref
        .read(todoListNotifierProvider.notifier)
        .deleteTodos(_selectedTodoIds.toList());
  }
  if (!mounted) return;
  if (_selectedCategoryIds.isNotEmpty) {
    await ref
        .read(categoryListNotifierProvider.notifier)
        .deleteCategories(_selectedCategoryIds.toList());
  }
  if (!mounted) return;
  _toggleEditMode();
}
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze`
Expected: No issues

**Step 3: 커밋**

```text
fix: 일괄 삭제 await 후 mounted 체크 추가 #17
```

---

## 최종 검증

Run: `flutter analyze`
Expected: No issues found

모든 Task 완료 후 단일 커밋으로 합쳐도 무방:
```text
fix: CodeRabbit 방어적 코딩 개선 (JSON 방어, SP 실패 처리, mounted 체크) #17
```
