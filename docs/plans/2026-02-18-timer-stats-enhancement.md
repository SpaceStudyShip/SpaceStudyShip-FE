# 타이머 통계 보강 및 홈 Streak 연동 구현 플랜

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 통계 Provider를 전용 파일로 분리하여 확장성 확보, 누락된 통계(전체/이번달/세션수) 추가, 기록 화면에 요약 헤더 표시, 홈 화면 streak 하드코딩 제거

**Architecture:** 기존 `timer_session_provider.dart`에 혼재된 통계 Provider들을 `study_stats_provider.dart`로 분리 → 새 통계 3개 추가 → 기록 화면 상단에 요약 카드 삽입 → 홈 화면 하드코딩된 streak을 실제 Provider로 교체. 통계 전용 파일로 분리함으로써 소셜, 프로필 등 다른 feature에서도 단일 import로 모든 통계에 접근 가능.

**Tech Stack:** Flutter, Riverpod (@riverpod annotation), flutter_screenutil

---

## 확장성 설계 근거

### 왜 별도 파일로 분리하는가?

**현재 구조의 문제:**
- `timer_session_provider.dart`에 DataSource, Repository, SessionList, 통계, DateGroup이 모두 혼재
- 다른 feature에서 streak만 필요해도 전체 파일을 import해야 함
- 통계가 늘어날수록 파일이 비대해짐

**분리 후 구조:**
```
timer/presentation/providers/
├── timer_session_provider.dart     # DataSource, Repository, SessionList, DateGroup (데이터 소유)
└── study_stats_provider.dart       # 모든 통계 Provider (파생 데이터)
```

**장점:**
- 소셜/프로필/홈에서 `study_stats_provider.dart` 하나만 import
- 통계 추가 시 `study_stats_provider.dart`만 수정
- 데이터 소유(`timer_session_provider`)와 파생 통계(`study_stats_provider`) 관심사 분리
- 기존 cross-feature import 패턴과 일관 (home→todo, todo→timer 등 이미 존재)

### 통계 Provider 전체 현황

| Provider | 기존 | 신규 | 예상 사용처 |
|----------|------|------|------------|
| `todayStudyMinutesProvider` | ✅ | 이동 | 타이머, 홈 |
| `weeklyStudyMinutesProvider` | ✅ | 이동 | 타이머, 소셜 |
| `currentStreakProvider` | ✅ | 이동 | 타이머, 홈, 프로필 |
| `totalStudyMinutesProvider` | - | ✅ | 기록, 프로필 |
| `monthlyStudyMinutesProvider` | - | ✅ | 기록 |
| `totalSessionCountProvider` | - | ✅ | 기록, 프로필 |

---

## Task 1: 통계 Provider 전용 파일 분리 + 신규 추가

**Files:**
- Create: `lib/features/timer/presentation/providers/study_stats_provider.dart`
- Modify: `lib/features/timer/presentation/providers/timer_session_provider.dart` (기존 통계 제거)
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart` (import 변경)
- Auto-gen: `lib/features/timer/presentation/providers/study_stats_provider.g.dart`
- Auto-gen: `lib/features/timer/presentation/providers/timer_session_provider.g.dart` (재생성)

**Step 1: `study_stats_provider.dart` 생성**

`lib/features/timer/presentation/providers/study_stats_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'timer_session_provider.dart';

part 'study_stats_provider.g.dart';

// === 공통 유틸 ===

DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

// === 일별/주별 통계 ===

/// 오늘 공부 시간 (분)
@riverpod
int todayStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final today = _normalizeDate(DateTime.now());

  return sessions
      .where((s) => _normalizeDate(s.startedAt) == today)
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 이번 주 공부 시간 (분) — 최근 7일
@riverpod
int weeklyStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final now = DateTime.now();
  final weekStart = _normalizeDate(now.subtract(const Duration(days: 6)));

  return sessions
      .where((s) => !_normalizeDate(s.startedAt).isBefore(weekStart))
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

// === 월별/전체 통계 ===

/// 이번 달 공부 시간 (분)
@riverpod
int monthlyStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  return sessions
      .where((s) => !s.startedAt.isBefore(monthStart))
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 전체 총 공부 시간 (분)
@riverpod
int totalStudyMinutes(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 전체 세션 수
@riverpod
int totalSessionCount(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  return sessions.length;
}

// === Streak ===

/// 연속 공부 일수 (streak)
@riverpod
int currentStreak(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  if (sessions.isEmpty) return 0;

  // 세션이 있는 날짜 집합
  final studyDates =
      sessions.map((s) => _normalizeDate(s.startedAt)).toSet().toList()
        ..sort((a, b) => b.compareTo(a)); // 최신순

  final today = _normalizeDate(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));

  // 오늘 또는 어제 공부하지 않았으면 streak 0
  if (studyDates.first != today && studyDates.first != yesterday) return 0;

  int streak = 1;
  for (int i = 1; i < studyDates.length; i++) {
    final diff = studyDates[i - 1].difference(studyDates[i]).inDays;
    if (diff == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
```

**Step 2: `timer_session_provider.dart`에서 통계 관련 코드 제거**

`timer_session_provider.dart`에서 삭제할 부분:
- `_normalizeDate` 함수 (line 46)
- `todayStudyMinutes` provider (lines 48-57)
- `weeklyStudyMinutes` provider (lines 59-69)
- `currentStreak` provider (lines 71-98)

삭제 후 파일은 다음만 남김:
- DataSource & Repository providers
- `TimerSessionListNotifier`
- `DateGroup` 클래스
- `sortedDateGroups` provider

**Step 3: `timer_screen.dart` import 변경**

```dart
// 기존 import만으로는 통계 Provider를 찾을 수 없으므로 추가:
import '../providers/study_stats_provider.dart';
```

(`timer_session_provider.dart` import은 `timerSessionListNotifierProvider` 등 다른 용도로 유지)

**Step 4: 코드 생성 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 5: 분석 통과 확인**

```bash
flutter analyze
```

**Step 6: 커밋**

```bash
git add lib/features/timer/presentation/providers/study_stats_provider.dart \
        lib/features/timer/presentation/providers/study_stats_provider.g.dart \
        lib/features/timer/presentation/providers/timer_session_provider.dart \
        lib/features/timer/presentation/providers/timer_session_provider.g.dart \
        lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "refactor: 통계 Provider를 study_stats_provider.dart로 분리 + 전체/이번달/세션수 추가 #27"
```

---

## Task 2: 기록 화면에 요약 헤더 추가

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_history_screen.dart`

**Step 1: import 추가**

`timer_history_screen.dart`의 import에 추가:
```dart
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../providers/study_stats_provider.dart';
```

**Step 2: 타이틀 아래에 요약 통계 카드 삽입**

`build()` 메서드에서 "고정 타이틀" 아래의 `SizedBox(height: AppSpacing.s20)` 부분(line 91)을 다음으로 교체:

```dart
SizedBox(height: AppSpacing.s20),
// 요약 통계
Consumer(
  builder: (context, ref, _) {
    final totalMinutes = ref.watch(totalStudyMinutesProvider);
    final monthlyMinutes = ref.watch(monthlyStudyMinutesProvider);
    final sessionCount = ref.watch(totalSessionCountProvider);
    return Padding(
      padding: AppPadding.horizontal20,
      child: AppCard(
        style: AppCardStyle.outlined,
        padding: AppPadding.all16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SpaceStatItem(
              icon: Icons.school_rounded,
              label: '전체',
              value: formatMinutes(totalMinutes),
            ),
            Container(
              width: 1,
              height: 32.h,
              color: AppColors.spaceDivider,
            ),
            SpaceStatItem(
              icon: Icons.calendar_month_rounded,
              label: '이번 달',
              value: formatMinutes(monthlyMinutes),
            ),
            Container(
              width: 1,
              height: 32.h,
              color: AppColors.spaceDivider,
            ),
            SpaceStatItem(
              icon: Icons.timer_outlined,
              label: '세션',
              value: '$sessionCount회',
            ),
          ],
        ),
      ),
    );
  },
),
SizedBox(height: AppSpacing.s16),
```

**Step 3: 분석 통과 확인**

```bash
flutter analyze
```

**Step 4: 커밋**

```bash
git add lib/features/timer/presentation/screens/timer_history_screen.dart
git commit -m "feat: 기록 화면 상단에 전체/이번달/세션 수 요약 카드 추가 #27"
```

---

## Task 3: 홈 화면 streak 하드코딩 제거

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: import 추가**

```dart
import '../../../timer/presentation/providers/study_stats_provider.dart';
```

**Step 2: 하드코딩 상태 변수 제거**

`_HomeScreenState`에서 삭제 (lines 43-44):
```dart
final int _streakDays = 5;      // 삭제
final bool _isStreakActive = true; // 삭제
```

**Step 3: AppBar title을 Consumer로 교체**

기존 (lines 110-119):
```dart
title: _streakDays > 0
    ? FadeSlideIn(
        child: StreakBadge(
          days: _streakDays,
          isActive: _isStreakActive,
          showLabel: true,
          size: StreakBadgeSize.large,
        ),
      )
    : null,
```

변경 후:
```dart
title: Consumer(
  builder: (context, ref, _) {
    final streakDays = ref.watch(currentStreakProvider);
    if (streakDays <= 0) return const SizedBox.shrink();
    return FadeSlideIn(
      child: StreakBadge(
        days: streakDays,
        isActive: true,
        showLabel: true,
        size: StreakBadgeSize.large,
      ),
    );
  },
),
```

**Step 4: 분석 통과 확인**

```bash
flutter analyze
```

**Step 5: 커밋**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "fix: 홈 화면 streak 하드코딩 제거, currentStreakProvider 연동 #27"
```

---

## 검증 체크리스트

- [ ] `flutter analyze` — 에러 없음
- [ ] 타이머 세션 기록 후 기록 화면 요약 카드에 반영되는지 확인
- [ ] Todo 삭제 후에도 기록 화면에 해당 세션의 할일 제목이 표시되는지 확인
- [ ] 홈 화면 streak이 실제 공부 기록 기반으로 표시되는지 확인
- [ ] 공부 기록이 없을 때 홈 화면에 streak 배지가 표시되지 않는지 확인
- [ ] `timer_screen.dart`가 정상적으로 통계를 표시하는지 확인 (기존 기능 유지)

## 향후 확장 시나리오 (참고용, 이번 구현 범위 아님)

| 기능 | import | 사용할 Provider |
|------|--------|----------------|
| 프로필 화면 통계 | `study_stats_provider.dart` | `totalStudyMinutes`, `totalSessionCount`, `currentStreak` |
| 소셜 주간 랭킹 | `study_stats_provider.dart` | `weeklyStudyMinutes` |
| 홈 화면 오늘 요약 | `study_stats_provider.dart` | `todayStudyMinutes`, `currentStreak` |
