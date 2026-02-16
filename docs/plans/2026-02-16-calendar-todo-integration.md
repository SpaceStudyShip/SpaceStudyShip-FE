# Calendar + Todo 연동 구현 계획서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 홈 화면 하단 시트를 캘린더 통합 시트로 개편하여, 투두메이트 스타일의 날짜 기반 할일 관리 기능을 구현한다.

**Architecture:** TodoEntity/TodoModel에 `scheduledDate: DateTime?` 필드를 추가하고, SpaceCalendar 커스텀 위젯을 생성하여 HomeScreen의 DraggableScrollableSheet에 통합한다. CalendarBuilders로 우주 테마에 맞는 완전 커스텀 셀 렌더링을 구현한다. 기존 TodoListScreen은 카테고리 관리 전용으로 유지.

**Tech Stack:** Flutter, table_calendar (CalendarBuilders), intl (이미 설치됨), Riverpod (@riverpod), Freezed

**커밋 태그:** 모든 커밋에 `#17` 태그 필수

---

## Task 1: TodoEntity에 scheduledDate 필드 추가

**Files:**
- Modify: `lib/features/todo/domain/entities/todo_entity.dart`

**Step 1: TodoEntity에 scheduledDate 추가**

`todo_entity.dart`에 `DateTime? scheduledDate` 필드를 `actualMinutes` 다음에 추가:

```dart
@freezed
class TodoEntity with _$TodoEntity {
  const factory TodoEntity({
    required String id,
    required String title,
    @Default(false) bool completed,
    String? categoryId,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime? scheduledDate,   // ← 추가
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TodoEntity;
}
```

**Step 2: build_runner 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/space_study_ship && flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `todo_entity.freezed.dart` 재생성, 빌드 성공

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: 이슈 0건

**Step 4: 커밋**

```bash
git add lib/features/todo/domain/entities/todo_entity.dart lib/features/todo/domain/entities/todo_entity.freezed.dart
git commit -m "feat: TodoEntity에 scheduledDate 필드 추가 #17"
```

---

## Task 2: TodoModel에 scheduledDate 필드 추가 + 변환 Extension 갱신

**Files:**
- Modify: `lib/features/todo/data/models/todo_model.dart`

**Step 1: TodoModel에 scheduledDate 추가**

```dart
@JsonKey(name: 'scheduled_date') DateTime? scheduledDate,  // actualMinutes 다음에 추가
```

**Step 2: toEntity() Extension에 scheduledDate 추가**

```dart
scheduledDate: scheduledDate,  // actualMinutes 다음에 추가
```

**Step 3: toModel() Extension에 scheduledDate 추가**

```dart
scheduledDate: scheduledDate,  // actualMinutes 다음에 추가
```

**Step 4: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `.freezed.dart`, `.g.dart` 재생성 성공

**Step 5: flutter analyze → 커밋**

```bash
flutter analyze
git add lib/features/todo/data/models/todo_model.dart lib/features/todo/data/models/todo_model.freezed.dart lib/features/todo/data/models/todo_model.g.dart
git commit -m "feat: TodoModel에 scheduledDate 필드 추가 + 변환 Extension 갱신 #17"
```

---

## Task 3: Repository/UseCase/Provider에 scheduledDate 파라미터 전파

**Files:**
- Modify: `lib/features/todo/domain/repositories/todo_repository.dart`
- Modify: `lib/features/todo/domain/usecases/create_todo_usecase.dart`
- Modify: `lib/features/todo/data/repositories/local_todo_repository_impl.dart`
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart`

**Step 1: TodoRepository.createTodo에 `DateTime? scheduledDate` 파라미터 추가**

**Step 2: CreateTodoUseCase.execute에 `DateTime? scheduledDate` 파라미터 추가 + 전달**

**Step 3: LocalTodoRepositoryImpl.createTodo에 `DateTime? scheduledDate` 파라미터 추가**

TodoModel 생성 시 `scheduledDate: scheduledDate` 전달.

**Step 4: TodoListNotifier.addTodo에 `DateTime? scheduledDate` 파라미터 추가**

```dart
Future<void> addTodo({
  required String title,
  String? categoryId,
  int? estimatedMinutes,
  DateTime? scheduledDate,  // ← 추가
}) async {
  final useCase = ref.read(createTodoUseCaseProvider);
  await useCase.execute(
    title: title,
    categoryId: categoryId,
    estimatedMinutes: estimatedMinutes,
    scheduledDate: scheduledDate,  // ← 추가
  );
  ref.invalidateSelf();
}
```

**Step 5: build_runner → flutter analyze → 커밋**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
git add lib/features/todo/domain/repositories/todo_repository.dart lib/features/todo/domain/usecases/create_todo_usecase.dart lib/features/todo/data/repositories/local_todo_repository_impl.dart lib/features/todo/presentation/providers/todo_provider.dart lib/features/todo/presentation/providers/todo_provider.g.dart
git commit -m "feat: Repository/UseCase/Provider에 scheduledDate 파라미터 전파 #17"
```

---

## Task 4: table_calendar 의존성 추가 + intl 로케일 초기화

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`

**Step 1: pubspec.yaml에 table_calendar 추가**

`# UI/UX 레이아웃` 그룹 하단에:

```yaml
  table_calendar: ^3.1.3 # 캘린더 위젯 (주간/월간 전환)
```

**Step 2: flutter pub get**

Run: `flutter pub get`

**Step 3: main.dart에 intl 한국어 로케일 초기화 추가**

import:
```dart
import 'package:intl/date_symbol_data_local.dart';
```

`WidgetsFlutterBinding.ensureInitialized();` 바로 아래:
```dart
await initializeDateFormatting('ko_KR', null);
```

**Step 4: flutter analyze → 커밋**

```bash
flutter analyze
git add pubspec.yaml pubspec.lock lib/main.dart
git commit -m "feat: table_calendar 의존성 추가 + intl 한국어 로케일 초기화 #17"
```

---

## Task 5: 캘린더 날짜 Provider 추가

**Files:**
- Modify: `lib/features/todo/presentation/providers/todo_provider.dart`

**Step 1: 날짜별 할일 필터 Provider 3종 추가**

`todo_provider.dart` 하단에:

```dart
// === 날짜별 할일 필터 ===

@riverpod
List<TodoEntity> todosForDate(Ref ref, DateTime date) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  final normalizedDate = DateTime(date.year, date.month, date.day);
  return todos.where((t) {
    if (t.scheduledDate == null) return false;
    final scheduled = DateTime(
      t.scheduledDate!.year,
      t.scheduledDate!.month,
      t.scheduledDate!.day,
    );
    return scheduled == normalizedDate;
  }).toList();
}

// === 미지정 할일 필터 ===

@riverpod
List<TodoEntity> unscheduledTodos(Ref ref) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  return todos.where((t) => t.scheduledDate == null).toList();
}

// === 날짜별 할일 맵 (캘린더 마커용) ===

@riverpod
Map<DateTime, List<TodoEntity>> todosByDateMap(Ref ref) {
  final todos = ref.watch(todoListNotifierProvider).valueOrNull ?? [];
  final map = <DateTime, List<TodoEntity>>{};
  for (final todo in todos) {
    if (todo.scheduledDate != null) {
      final key = DateTime(
        todo.scheduledDate!.year,
        todo.scheduledDate!.month,
        todo.scheduledDate!.day,
      );
      map.putIfAbsent(key, () => []).add(todo);
    }
  }
  return map;
}
```

**Step 2: build_runner → flutter analyze → 커밋**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
git add lib/features/todo/presentation/providers/todo_provider.dart lib/features/todo/presentation/providers/todo_provider.g.dart
git commit -m "feat: 캘린더 날짜별 할일 필터 Provider 3종 추가 #17"
```

---

## Task 6: SpaceCalendar 커스텀 위젯 생성

**Files:**
- Create: `lib/features/home/presentation/widgets/space_calendar.dart`

이 위젯이 캘린더 UI 커스텀의 핵심. CalendarBuilders로 우주 테마 셀을 완전 커스텀 렌더링한다.

**Step 1: SpaceCalendar StatelessWidget 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../todo/domain/entities/todo_entity.dart';

/// 우주 테마 캘린더 위젯
///
/// table_calendar를 CalendarBuilders로 완전 커스텀하여
/// 다크 우주 배경에 어울리는 캘린더를 제공한다.
///
/// [isCompact] true: 주간 스트립 (접힌 시트용, 헤더 없음)
/// [isCompact] false: 월간/주간 토글 (펼친 시트용, 헤더 있음)
class SpaceCalendar extends StatelessWidget {
  const SpaceCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
    this.isCompact = false,
    this.calendarFormat = CalendarFormat.month,
    this.onFormatChanged,
    this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final List<TodoEntity> Function(DateTime day) eventLoader;
  final bool isCompact;
  final CalendarFormat calendarFormat;
  final void Function(CalendarFormat)? onFormatChanged;
  final void Function(DateTime)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<TodoEntity>(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: isCompact ? CalendarFormat.week : calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: 'ko_KR',
      headerVisible: !isCompact,
      daysOfWeekHeight: 20.h,
      rowHeight: isCompact ? 42.h : 48.h,
      availableCalendarFormats: const {
        CalendarFormat.month: '월간',
        CalendarFormat.week: '주간',
      },
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      eventLoader: eventLoader,

      // === 커스텀 헤더 스타일 (펼친 상태에서만 표시) ===
      headerStyle: HeaderStyle(
        formatButtonVisible: !isCompact,
        titleCentered: true,
        headerPadding: EdgeInsets.symmetric(vertical: 8.h),
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
          borderRadius: AppRadius.chip,
        ),
        formatButtonTextStyle: AppTextStyles.tag_12.copyWith(
          color: AppColors.primary,
        ),
        titleTextFormatter: (date, locale) =>
            DateFormat('yyyy년 M월', locale).format(date),
        titleTextStyle: AppTextStyles.subHeading_18.copyWith(
          color: Colors.white,
        ),
        leftChevronIcon: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: 20.w,
          ),
        ),
        rightChevronIcon: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: 20.w,
          ),
        ),
      ),

      // === 요일 헤더 스타일 ===
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTextStyles.tag_12.copyWith(
          color: AppColors.textTertiary,
        ),
        weekendStyle: AppTextStyles.tag_12.copyWith(
          color: AppColors.textTertiary.withValues(alpha: 0.6),
        ),
      ),

      // === CalendarStyle 기본값 (CalendarBuilders 미적용 셀 대비) ===
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: EdgeInsets.all(2.w),
      ),

      // === CalendarBuilders: 우주 테마 커스텀 셀 렌더링 ===
      calendarBuilders: CalendarBuilders(
        // 기본 날짜 셀
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day,
            textColor: Colors.white,
          );
        },

        // 선택된 날짜 — 글로우 원형
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day,
            textColor: Colors.white,
            fontWeight: FontWeight.bold,
            backgroundColor: AppColors.primary,
            showGlow: true,
          );
        },

        // 오늘 날짜 — 테두리 원형 (filled X)
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day,
            textColor: AppColors.primary,
            fontWeight: FontWeight.bold,
            borderColor: AppColors.primary,
          );
        },

        // 주말 셀
        weekendBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            day: day,
            textColor: Colors.white.withValues(alpha: 0.6),
          );
        },

        // 도트 마커 — 할일 있는 날짜에 작은 점
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          return Positioned(
            bottom: 2.h,
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 커스텀 날짜 셀 빌더
  Widget _buildDayCell({
    required DateTime day,
    required Color textColor,
    FontWeight fontWeight = FontWeight.normal,
    Color? backgroundColor,
    Color? borderColor,
    bool showGlow = false,
  }) {
    return Center(
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: AppTextStyles.label_16.copyWith(
            color: textColor,
            fontWeight: fontWeight,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: 이슈 0건

**Step 3: 커밋**

```bash
git add lib/features/home/presentation/widgets/space_calendar.dart
git commit -m "feat: SpaceCalendar 우주 테마 커스텀 캘린더 위젯 생성 #17"
```

---

## Task 7: HomeScreen 접힌 시트에 SpaceCalendar 적용

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: import 추가**

```dart
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/space_calendar.dart';
```

**Step 2: _HomeScreenState에 캘린더 상태 변수 추가**

기존 상태 변수 영역에:

```dart
// 캘린더 상태
DateTime _focusedDay = DateTime.now();
DateTime _selectedDay = DateTime.now();
CalendarFormat _calendarFormat = CalendarFormat.month;
```

**Step 3: _buildCollapsedSheet를 주간 캘린더 + 할일 카운트로 교체**

```dart
Widget _buildCollapsedSheet(ScrollController scrollController) {
  final todosByDate = ref.watch(todosByDateMapProvider);
  final todayKey = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final todayTodoCount = todosByDate[todayKey]?.where((t) => !t.completed).length ?? 0;

  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      _buildDragHandle(),

      // 주간 캘린더 스트립 (컴팩트 모드)
      Padding(
        padding: AppPadding.horizontal20,
        child: SpaceCalendar(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          isCompact: true,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _sheetController.animateTo(
              0.85,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            final key = DateTime(day.year, day.month, day.day);
            return todosByDate[key] ?? [];
          },
        ),
      ),

      // 오늘의 할일 카운트 + 펼치기 안내
      GestureDetector(
        onTap: () {
          _sheetController.animateTo(
            0.85,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Row(
            children: [
              Text(
                '오늘의 할 일',
                style: AppTextStyles.label_16.copyWith(color: Colors.white),
              ),
              SizedBox(width: AppSpacing.s8),
              Text(
                '$todayTodoCount개',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppColors.textTertiary,
                size: 20.w,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
```

**Step 4: DraggableScrollableSheet 사이즈 조정**

```dart
DraggableScrollableSheet(
  controller: _sheetController,
  initialChildSize: 0.25,   // ← 0.22에서 0.25로 (주간 캘린더 공간)
  minChildSize: 0.25,       // ← 0.22에서 0.25로
  maxChildSize: 0.85,       // ← 0.6에서 0.85로
  snap: true,
  snapSizes: const [0.25, 0.85],  // ← 변경
  builder: ...
```

**Step 5: _onSheetChanged 판단 기준 조정**

```dart
void _onSheetChanged() {
  final expanded = _sheetController.size > 0.4;  // ← 0.3에서 0.4로
  if (expanded != _isSheetExpanded) {
    setState(() => _isSheetExpanded = expanded);
  }
}
```

**Step 6: flutter analyze → 커밋**

```bash
flutter analyze
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat: HomeScreen 접힌 시트에 SpaceCalendar 주간 스트립 적용 #17"
```

---

## Task 8: HomeScreen 펼친 시트에 SpaceCalendar + 할일 목록 적용

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: _buildExpandedSheet를 캘린더 + 할일 목록으로 교체**

```dart
Widget _buildExpandedSheet(ScrollController scrollController) {
  final selectedKey = DateTime(
    _selectedDay.year,
    _selectedDay.month,
    _selectedDay.day,
  );
  final todosForSelected = ref.watch(todosForDateProvider(selectedKey));
  final unscheduled = ref.watch(unscheduledTodosProvider);
  final todosByDate = ref.watch(todosByDateMapProvider);
  final dateLabel = DateFormat('M/d', 'ko_KR').format(_selectedDay);

  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      _buildDragHandle(),

      // 월간/주간 토글 캘린더
      Padding(
        padding: AppPadding.horizontal20,
        child: SpaceCalendar(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          isCompact: false,
          calendarFormat: _calendarFormat,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            final key = DateTime(day.year, day.month, day.day);
            return todosByDate[key] ?? [];
          },
        ),
      ),

      SizedBox(height: AppSpacing.s16),

      // ── 선택된 날짜의 할일 섹션 ──
      Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
        child: Row(
          children: [
            _buildSectionTitle('$dateLabel 할일'),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                final result = await showTodoAddBottomSheet(
                  context: context,
                  initialScheduledDate: _selectedDay,
                );
                if (result != null && mounted) {
                  ref.read(todoListNotifierProvider.notifier).addTodo(
                    title: result['title'] as String,
                    categoryId: result['categoryId'] as String?,
                    scheduledDate: result['scheduledDate'] as DateTime?,
                  );
                }
              },
              child: Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 24.w,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.s8),

      if (todosForSelected.isEmpty)
        Padding(
          padding: AppPadding.horizontal20,
          child: _buildEmptyTodoCard(),
        )
      else
        ...todosForSelected.map((todo) => _buildTodoRow(todo)),

      // ── 카테고리 관리 버튼 ──
      Padding(
        padding: AppPadding.horizontal20,
        child: TextButton(
          onPressed: () => context.push(RoutePaths.todoList),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '카테고리 관리',
                style: AppTextStyles.label_16.copyWith(color: AppColors.primary),
              ),
              SizedBox(width: AppSpacing.s4),
              Icon(Icons.arrow_forward_rounded, size: 16.w, color: AppColors.primary),
            ],
          ),
        ),
      ),

      // ── 날짜 미지정 할일 섹션 ──
      if (unscheduled.isNotEmpty) ...[
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
          child: _buildSectionTitle('날짜 미지정'),
        ),
        SizedBox(height: AppSpacing.s8),
        ...unscheduled.map((todo) => _buildTodoRow(todo)),
      ],

      SizedBox(height: AppSpacing.s40),
    ],
  );
}
```

**Step 2: _buildTodoRow 헬퍼 추가**

```dart
Widget _buildTodoRow(TodoEntity todo) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
    child: Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: AppPadding.horizontal20,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: AppRadius.large,
        ),
        child: Icon(Icons.delete_outline, color: AppColors.error, size: 24.w),
      ),
      onDismissed: (_) {
        ref.read(todoListNotifierProvider.notifier).deleteTodo(todo.id);
      },
      child: TodoItem(
        title: todo.title,
        subtitle: todo.actualMinutes != null && todo.actualMinutes! > 0
            ? '${todo.actualMinutes}분 공부'
            : null,
        isCompleted: todo.completed,
        onToggle: () {
          ref.read(todoListNotifierProvider.notifier).toggleTodo(todo);
        },
      ),
    ),
  );
}
```

**Step 3: 기존 `_buildEmptyTodoCard` 문구 수정**

```dart
Widget _buildEmptyTodoCard() {
  return AppCard(
    style: AppCardStyle.outlined,
    padding: AppPadding.all24,
    child: SpaceEmptyState(
      icon: Icons.edit_note_rounded,
      title: '할 일이 없어요',
      subtitle: '+ 버튼을 눌러 추가해보세요',
      iconSize: 40,
      animated: false,
    ),
  );
}
```

**Step 4: 시트 접힘 시 캘린더 포맷 자동 연동**

`_onSheetChanged`에 캘린더 포맷 리셋 로직 추가:

```dart
void _onSheetChanged() {
  final expanded = _sheetController.size > 0.4;
  if (expanded != _isSheetExpanded) {
    setState(() {
      _isSheetExpanded = expanded;
      // 시트 접힘 → 월간 포맷으로 리셋 (다음 펼침 시 월간부터 시작)
      if (!expanded) {
        _calendarFormat = CalendarFormat.month;
      }
    });
  }
}
```

**Step 5: import 추가 (이미 Task 7에서 추가했으나 확인)**

TodoEntity import 추가 (todosForDateProvider 사용):
```dart
import '../../../todo/domain/entities/todo_entity.dart';
```

**Step 6: flutter analyze → 커밋**

```bash
flutter analyze
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat: HomeScreen 펼친 시트에 월간 캘린더 + 할일 목록 적용 #17"
```

---

## Task 9: TodoAddBottomSheet에 날짜 선택 칩 추가

**Files:**
- Modify: `lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart`

**Step 1: TodoAddBottomSheet에 initialScheduledDate 파라미터 추가**

```dart
class TodoAddBottomSheet extends ConsumerStatefulWidget {
  const TodoAddBottomSheet({
    super.key,
    this.initialCategoryId,
    this.initialScheduledDate,
  });

  final String? initialCategoryId;
  final DateTime? initialScheduledDate;
  // ...
}
```

**Step 2: _TodoAddBottomSheetState에 상태 변수 + initState 추가**

```dart
DateTime? _selectedScheduledDate;

@override
void initState() {
  super.initState();
  _selectedCategoryId = widget.initialCategoryId;
  _selectedScheduledDate = widget.initialScheduledDate ?? DateTime.now();
  _titleController.addListener(() => setState(() {}));
}
```

**Step 3: _submit에서 scheduledDate 반환**

```dart
void _submit() {
  final title = _titleController.text.trim();
  if (title.isEmpty) return;
  Navigator.of(context).pop({
    'title': title,
    'categoryId': _selectedCategoryId,
    'scheduledDate': _selectedScheduledDate,
  });
}
```

**Step 4: 카테고리 칩 아래에 날짜 선택 UI 추가**

카테고리 칩 섹션과 "추가하기" 버튼 사이에 예정일 선택 칩을 추가:

```dart
// 날짜 선택 칩
Padding(
  padding: AppPadding.horizontal20,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '예정일',
        style: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
      ),
      SizedBox(height: AppSpacing.s8),
      Row(
        children: [
          GestureDetector(
            onTap: () => _showDatePicker(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: AppRadius.chip,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 14.w, color: AppColors.primary),
                  SizedBox(width: AppSpacing.s4),
                  Text(
                    _selectedScheduledDate != null
                        ? DateFormat('M/d (E)', 'ko_KR').format(_selectedScheduledDate!)
                        : '날짜 미지정',
                    style: AppTextStyles.tag_12.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s8),
          if (_selectedScheduledDate != null)
            GestureDetector(
              onTap: () => setState(() => _selectedScheduledDate = null),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.chip,
                  border: Border.all(color: AppColors.spaceDivider),
                ),
                child: Text(
                  '미지정',
                  style: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    ],
  ),
),
SizedBox(height: AppSpacing.s16),
```

**Step 5: _showDatePicker 메서드 추가**

```dart
Future<void> _showDatePicker() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedScheduledDate ?? DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2030),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.spaceSurface,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    setState(() => _selectedScheduledDate = picked);
  }
}
```

**Step 6: import + showTodoAddBottomSheet 헬퍼 갱신**

```dart
import 'package:intl/intl.dart';
```

```dart
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
  String? initialCategoryId,
  DateTime? initialScheduledDate,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => TodoAddBottomSheet(
      initialCategoryId: initialCategoryId,
      initialScheduledDate: initialScheduledDate,
    ),
  );
}
```

**Step 7: flutter analyze → 커밋**

```bash
flutter analyze
git add lib/features/todo/presentation/widgets/todo_add_bottom_sheet.dart
git commit -m "feat: TodoAddBottomSheet에 날짜 선택 칩 추가 #17"
```

---

## Task 10: 최종 검증

**Files:**
- Verify: 전체 프로젝트

**Step 1: TodoListScreen/CategoryTodoScreen 확인**

TodoListScreen과 CategoryTodoScreen에서 `addTodo` 호출 시 `scheduledDate`를 전달하지 않아도 기본값 null (미지정)이 되므로 변경 불필요. 확인만.

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: 이슈 0건

**Step 3: 전체 빌드**

Run: `flutter build apk --debug`
Expected: 빌드 성공

**Step 4: 필요 시 미세 수정 커밋**

```bash
git add -A && git commit -m "fix: 캘린더 통합 최종 검증 및 미세 수정 #17"
```

---

## 작업 순서 요약

| Task | 내용 | 파일 수 | 신규/수정 | 의존성 |
|------|------|---------|----------|--------|
| 1 | TodoEntity scheduledDate 추가 | 1 | Modify | 없음 |
| 2 | TodoModel scheduledDate + Extension | 1 | Modify | Task 1 |
| 3 | Repository/UseCase/Provider 전파 | 4 | Modify | Task 2 |
| 4 | table_calendar + intl 초기화 | 2 | Modify | 없음 |
| 5 | 캘린더 Provider 3종 | 1 | Modify | Task 3 |
| 6 | **SpaceCalendar 위젯** | 1 | **Create** | Task 4 |
| 7 | HomeScreen 접힌 시트 | 1 | Modify | Task 5, 6 |
| 8 | HomeScreen 펼친 시트 | 1 | Modify | Task 7 |
| 9 | TodoAddBottomSheet 날짜 선택 | 1 | Modify | Task 3 |
| 10 | 최종 검증 | 0 | Verify | All |

## 핵심 커스텀 포인트 (SpaceCalendar)

| 요소 | 기본 table_calendar | 우주 테마 커스텀 |
|------|--------------------|--------------:|
| 선택된 날짜 | 파란 원 배경 | primary 글로우 원형 + boxShadow |
| 오늘 날짜 | 빨간/파란 filled 원 | primary 테두리만 (outlined) |
| 도트 마커 | 작은 사각/원점 | primary 글로우 점 (boxShadow) |
| 헤더 화살표 | 기본 아이콘 | 원형 배경 + primary 아이콘 |
| 포맷 버튼 | 기본 텍스트 버튼 | primary 테두리 chip 스타일 |
| 주말 텍스트 | 빨간색 | 60% 투명도 흰색 |
