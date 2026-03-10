# 홈 화면 Todo Bank + Slidable 스와이프 액션 구현

**Goal:** 홈 화면 바텀시트에 todo bank 섹션을 추가하고, 할일 스와이프 액션을 flutter_slidable로 개선하여 날짜별 할일 관리 UX를 향상시킨다.

**Architecture:** 기존 HomeScreen 바텀시트에 todo bank 섹션 추가. TodoListScreen은 변경 없음. DismissibleTodoItem을 Dismissible에서 flutter_slidable의 Slidable로 교체.

**Tech Stack:** Flutter · Riverpod · flutter_slidable · table_calendar

**관련 이슈:** #51

---

## 구현 내용

### 1. Todo Bank (홈 화면 바텀시트)

**변경 파일:**
- `lib/features/todo/presentation/providers/todo_provider.dart` — `todosNotForDate` provider 추가
- `lib/features/todo/presentation/providers/todo_provider.g.dart` — 코드 생성
- `lib/features/home/presentation/screens/home_screen.dart` — `_buildTodoBankSection`, `_addTodoToDate` 추가

**동작:**
- 홈 화면 캘린더에서 날짜 선택 후, 해당 날짜에 배정되지 않은 할일 목록을 "할 일 추가" 섹션으로 표시
- 할일을 탭하면 선택된 날짜의 scheduledDates에 추가되어 즉시 해당 날짜 할일 목록에 나타남
- 다른 날짜를 선택하면 해당 날짜에 미배정된 할일이 다시 bank에 표시됨
- scheduledDates가 비어있는 할일(미지정)은 bank에 표시하지 않음

### 2. Slidable 스와이프 액션

**변경 파일:**
- `lib/features/todo/presentation/widgets/dismissible_todo_item.dart` — Dismissible → Slidable 교체
- `pubspec.yaml` / `pubspec.lock` — flutter_slidable 패키지 추가

**동작:**
- **좌→우 (startActionPane):** 카테고리 이동 — `primaryLight` 색상
- **우→좌 (endActionPane):**
  - 날짜에서 제거 (contextDate가 있을 때만) — `accentGoldLight` 색상
  - 삭제 — `error` 색상
- CustomSlidableAction + 투명 배경 + 아이콘/텍스트만 표시 (다크 우주 테마에 어울리는 미니멀 스타일)
- 타이머 연동 중인 할일은 제거/삭제 차단

### 3. 변경하지 않은 것

- TodoListScreen (카테고리 그리드 중심 레이아웃 유지)
- CategoryTodoScreen 및 라우팅
- 기존 할일 CRUD 로직
