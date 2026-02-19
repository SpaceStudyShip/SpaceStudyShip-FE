# Timer History Screen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 타이머 세션 기록을 날짜별로 그룹화하여 보여주는 기록 화면 구현 (infinite_scroll_pagination 적용)

**Architecture:** 로컬 데이터(SharedPreferences)를 날짜 단위로 페이지네이션하여 표시. `infinite_scroll_pagination` 패키지(이미 pubspec.yaml에 존재)의 `PagingController` + `PagedListView`를 사용. 한 페이지 = 7일치 날짜 그룹. 날짜 그룹이 페이지 경계에서 잘리지 않도록 날짜 단위로 슬라이싱.

**Tech Stack:** Flutter, Riverpod, flutter_screenutil, GoRouter, infinite_scroll_pagination 5.x (기존 의존성)

**Pagination Strategy:**
- 데이터 소스: SharedPreferences (로컬, 전체 로드)
- 페이지 단위: 날짜 그룹 7개씩 (7일치)
- PagingController<int, DateGroup>: pageKey = 날짜 그룹 시작 index
- 전체 세션 → 날짜별 그룹화 → 그룹을 7개씩 잘라서 페이지로 제공
- 더 이상 그룹이 없으면 lastPage (nextPageKey = null)

---

### Task 1: DateGroup 모델 + 날짜별 그룹화 Provider 추가

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_session_provider.dart`

**Step 1: DateGroup 클래스 정의 + sortedDateGroups Provider 추가**

`timer_session_provider.dart` 맨 아래에 추가:

```dart
/// 날짜별 세션 그룹 (페이지네이션 아이템 단위)
class DateGroup {
  final DateTime date;
  final List<TimerSessionEntity> sessions;
  final int totalMinutes;

  DateGroup({
    required this.date,
    required this.sessions,
  }) : totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 전체 세션을 날짜별로 그룹화 (최신순 정렬)
@riverpod
List<DateGroup> sortedDateGroups(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final grouped = <DateTime, List<TimerSessionEntity>>{};

  for (final session in sessions) {
    final date = _normalizeDate(session.startedAt);
    grouped.putIfAbsent(date, () => []).add(session);
  }

  // 각 그룹 내부: 최신 시작 시간 순
  for (final list in grouped.values) {
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // 날짜 최신순 정렬
  final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

  return sortedKeys
      .map((date) => DateGroup(date: date, sessions: grouped[date]!))
      .toList();
}
```

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_session_provider.dart lib/features/timer/presentation/providers/timer_session_provider.g.dart
git commit -m "feat: 타이머 세션 DateGroup 모델 + 날짜별 그룹화 Provider 추가 #27"
```

---

### Task 2: TimerHistoryScreen 생성 (infinite_scroll_pagination 적용)

**Files:**
- Create: `lib/features/timer/presentation/screens/timer_history_screen.dart`

**Step 1: 화면 위젯 작성**

레이아웃: AppBar(뒤로가기만, title 없음) + 화면 상단 "기록" 타이틀 + PagedSliverList (날짜별 그룹)

핵심 구조:
- `ConsumerStatefulWidget` (PagingController 생명주기 관리)
- `PagingController<int, DateGroup>`: pageKey = 그룹 시작 인덱스, pageSize = 7
- `fetchPage`: `sortedDateGroupsProvider`에서 슬라이싱
- CustomScrollView + SliverToBoxAdapter(타이틀) + PagedSliverList(세션 그룹)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../providers/timer_session_provider.dart';

const _pageSize = 7; // 한 페이지 = 7일치 날짜 그룹

class TimerHistoryScreen extends ConsumerStatefulWidget {
  const TimerHistoryScreen({super.key});

  @override
  ConsumerState<TimerHistoryScreen> createState() => _TimerHistoryScreenState();
}

class _TimerHistoryScreenState extends ConsumerState<TimerHistoryScreen> {
  late final PagingController<int, DateGroup> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, DateGroup>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        final loaded = state.items?.length ?? 0;
        final allGroups = ref.read(sortedDateGroupsProvider);
        return loaded >= allGroups.length ? null : loaded;
      },
      fetchPage: (pageKey) {
        final allGroups = ref.read(sortedDateGroupsProvider);
        final end = (pageKey + _pageSize).clamp(0, allGroups.length);
        return allGroups.sublist(pageKey, end);
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 세션 목록이 변경되면 PagingController 리프레시
    ref.listen(timerSessionListNotifierProvider, (_, __) {
      _pagingController.refresh();
    });

    final allGroups = ref.watch(sortedDateGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          if (allGroups.isEmpty)
            const Center(
              child: SpaceEmptyState(
                icon: Icons.history_rounded,
                title: '기록이 없어요',
                subtitle: '타이머를 사용하면 여기에 기록됩니다',
              ),
            )
          else
            _buildPagedList(context),
        ],
      ),
    );
  }

  Widget _buildPagedList(BuildContext context) {
    // PagingListener가 CustomScrollView 전체를 감싸야 함 (sliver 내부 불가)
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => CustomScrollView(
        slivers: [
          // 상단 여백 + "기록" 타이틀
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
                left: 20.w,
                right: 20.w,
                bottom: AppSpacing.s24,
              ),
              child: Text(
                '기록',
                style: AppTextStyles.heading_20.copyWith(color: Colors.white),
              ),
            ),
          ),
          // 페이지네이션 리스트
          PagedSliverList<int, DateGroup>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<DateGroup>(
              itemBuilder: (context, dateGroup, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildDateGroup(dateGroup),
              ),
              noItemsFoundIndicatorBuilder: (_) => const SizedBox.shrink(),
              newPageProgressIndicatorBuilder: (_) => Padding(
                padding: EdgeInsets.all(AppSpacing.s16),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(DateGroup dateGroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 헤더 + 총 시간
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDateHeader(dateGroup.date),
              style: AppTextStyles.label_16.copyWith(color: Colors.white),
            ),
            Text(
              _formatMinutes(dateGroup.totalMinutes),
              style: AppTextStyles.tag_12.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s8),
        // 세션 목록
        ...dateGroup.sessions.map(
          (session) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s8),
            child: _buildSessionTile(session),
          ),
        ),
        SizedBox(height: AppSpacing.s16),
      ],
    );
  }

  Widget _buildSessionTile(TimerSessionEntity session) {
    final timeRange =
        '${DateFormat('HH:mm').format(session.startedAt)} – ${DateFormat('HH:mm').format(session.endedAt)}';

    return Container(
      padding: AppPadding.listItemPadding,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: Row(
        children: [
          // 좌측: 시간 범위 + 할일 제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeRange,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (session.todoTitle != null) ...[
                  SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 12.w,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Text(
                          session.todoTitle!,
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 우측: 소요 시간
          Text(
            _formatMinutes(session.durationMinutes),
            style: AppTextStyles.label_16.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return '오늘';
    if (date == yesterday) return '어제';
    return DateFormat('M월 d일 (E)', 'ko_KR').format(date);
  }

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) return '$hours시간 $minutes분';
    return '$minutes분';
  }
}
```

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_history_screen.dart
git commit -m "feat: 타이머 기록 화면 생성 (infinite_scroll_pagination 적용) #27"
```

---

### Task 3: 라우터 연결 + 타이머 화면 네비게이션 연결

**Files:**
- Modify: `lib/routes/app_router.dart:211-215` — PlaceholderScreen → TimerHistoryScreen
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:49-51` — TODO 제거, GoRouter push 연결

**Step 1: app_router.dart에서 PlaceholderScreen을 TimerHistoryScreen으로 교체**

```dart
// Before (line 213-215)
builder: (context, state) =>
    const PlaceholderScreen(title: '타이머 기록'),

// After
builder: (context, state) =>
    const TimerHistoryScreen(),
```

import 추가:
```dart
import '../features/timer/presentation/screens/timer_history_screen.dart';
```

**Step 2: timer_screen.dart에서 history 버튼 onPressed 구현**

```dart
// Before (line 49-51)
onPressed: () {
  // TODO: 타이머 기록 화면 (향후 구현)
},

// After
onPressed: () => context.push(RoutePaths.timerHistory),
```

import 추가 (필요 시):
```dart
import 'package:go_router/go_router.dart';
import '../../../../routes/route_paths.dart';
```

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/routes/app_router.dart lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "feat: 타이머 기록 화면 라우터 연결 및 네비게이션 구현 #27"
```

---

### Summary of Changes

| What | Before | After |
|------|--------|-------|
| `/timer/history` 라우트 | PlaceholderScreen | TimerHistoryScreen |
| 타이머 AppBar 기록 버튼 | TODO 빈 onPressed | `context.push(RoutePaths.timerHistory)` |
| 날짜 그룹화 Provider | 없음 | `sortedDateGroupsProvider` |
| 페이지네이션 | 없음 | `infinite_scroll_pagination` (7일/페이지) |
| 신규 파일 | 0 | 1개 (`timer_history_screen.dart`) |
| 수정 파일 | 0 | 3개 (provider, router, timer_screen) |
| 신규 클래스 | 0 | 1개 (`DateGroup`) |
