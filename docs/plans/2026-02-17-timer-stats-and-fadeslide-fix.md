# 타이머 통계 연동 + FadeSlideIn 수정 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 타이머 화면의 하드코딩된 통계를 실제 데이터로 연동하고, FadeSlideIn 애니메이션이 탭 전환 시 재생되도록 수정

**Architecture:** Clean Architecture 구조로 타이머 세션을 SharedPreferences에 로컬 저장. timer_provider의 stop()에서 세션 기록 저장. 통계 provider가 세션 데이터를 집계하여 UI에 반영. FadeSlideIn은 VisibilityDetector 없이 StatefulShellRoute의 특성을 고려하여 수정.

**Tech Stack:** Flutter, Riverpod(@riverpod), Freezed, SharedPreferences, GoRouter(StatefulShellRoute)

---

## FadeSlideIn 문제 분석

**근본 원인:** `StatefulShellRoute.indexedStack`를 사용하여 5개 탭이 동시에 빌드됨. FadeSlideIn은 `initState()`에서 1회만 `_controller.forward()` 호출. 타이머 탭이 안 보이는 상태에서 이미 애니메이션 완료 → 탭 전환 시 정적 상태.

**해결:** FadeSlideIn의 initState에서 `TickerMode.of(context)` 또는 VisibilityDetector를 사용하는 대신, 더 단순한 접근 — **FadeSlideIn을 제거하고 일반 위젯으로 교체**. 타이머 화면은 상시 사용하는 화면이므로 진입 애니메이션보다 즉시 표시가 UX적으로 나음. 또는 TabAware 방식으로 수정.

---

### Task 1: 타이머 세션 Entity + Model 생성

타이머 세션 기록을 위한 도메인 엔티티와 데이터 모델을 생성한다.

**Files:**
- Create: `lib/features/timer/domain/entities/timer_session_entity.dart`
- Create: `lib/features/timer/data/models/timer_session_model.dart`

**Step 1: 디렉토리 생성**

Run: `mkdir -p lib/features/timer/domain/entities lib/features/timer/data/models`

**Step 2: TimerSessionEntity 생성**

Create `lib/features/timer/domain/entities/timer_session_entity.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_session_entity.freezed.dart';

@freezed
class TimerSessionEntity with _$TimerSessionEntity {
  const factory TimerSessionEntity({
    required String id,
    String? todoId,
    String? todoTitle,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMinutes,
  }) = _TimerSessionEntity;
}
```

**Step 3: TimerSessionModel 생성**

Create `lib/features/timer/data/models/timer_session_model.dart`:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/timer_session_entity.dart';

part 'timer_session_model.freezed.dart';
part 'timer_session_model.g.dart';

@freezed
class TimerSessionModel with _$TimerSessionModel {
  const factory TimerSessionModel({
    required String id,
    @JsonKey(name: 'todo_id') String? todoId,
    @JsonKey(name: 'todo_title') String? todoTitle,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'ended_at') required DateTime endedAt,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
  }) = _TimerSessionModel;

  factory TimerSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TimerSessionModelFromJson(json);
}

extension TimerSessionModelX on TimerSessionModel {
  TimerSessionEntity toEntity() => TimerSessionEntity(
        id: id,
        todoId: todoId,
        todoTitle: todoTitle,
        startedAt: startedAt,
        endedAt: endedAt,
        durationMinutes: durationMinutes,
      );
}

extension TimerSessionEntityX on TimerSessionEntity {
  TimerSessionModel toModel() => TimerSessionModel(
        id: id,
        todoId: todoId,
        todoTitle: todoTitle,
        startedAt: startedAt,
        endedAt: endedAt,
        durationMinutes: durationMinutes,
      );
}
```

**Step 4: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: .freezed.dart, .g.dart 파일 생성

**Step 5: flutter analyze**

Run: `flutter analyze lib/features/timer/domain/ lib/features/timer/data/`
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/timer/domain/ lib/features/timer/data/
git commit -m "feat: 타이머 세션 Entity, Model 생성 (Clean Architecture)"
```

---

### Task 2: 로컬 DataSource + Repository 생성

SharedPreferences 기반 로컬 저장소와 Repository를 생성한다.

**Files:**
- Create: `lib/features/timer/data/datasources/timer_session_local_datasource.dart`
- Create: `lib/features/timer/domain/repositories/timer_session_repository.dart`
- Create: `lib/features/timer/data/repositories/timer_session_repository_impl.dart`

**Step 1: 디렉토리 생성**

Run: `mkdir -p lib/features/timer/data/datasources lib/features/timer/domain/repositories lib/features/timer/data/repositories`

**Step 2: LocalDataSource 생성**

Create `lib/features/timer/data/datasources/timer_session_local_datasource.dart`:

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_session_model.dart';

class TimerSessionLocalDataSource {
  static const _sessionsKey = 'guest_timer_sessions';

  final SharedPreferences _prefs;

  TimerSessionLocalDataSource(this._prefs);

  List<TimerSessionModel> getSessions() {
    final jsonString = _prefs.getString(_sessionsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => TimerSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_sessionsKey);
      return [];
    }
  }

  Future<void> saveSessions(List<TimerSessionModel> sessions) async {
    final jsonString = json.encode(sessions.map((e) => e.toJson()).toList());
    await _prefs.setString(_sessionsKey, jsonString);
  }

  Future<void> addSession(TimerSessionModel session) async {
    final sessions = getSessions();
    sessions.add(session);
    await saveSessions(sessions);
  }

  Future<void> clearSessions() async {
    await _prefs.remove(_sessionsKey);
  }
}
```

**Step 3: Repository 인터페이스 생성**

Create `lib/features/timer/domain/repositories/timer_session_repository.dart`:

```dart
import '../entities/timer_session_entity.dart';

abstract class TimerSessionRepository {
  List<TimerSessionEntity> getSessions();
  Future<void> addSession(TimerSessionEntity session);
  Future<void> clearSessions();
}
```

**Step 4: Repository 구현 생성**

Create `lib/features/timer/data/repositories/timer_session_repository_impl.dart`:

```dart
import '../../domain/entities/timer_session_entity.dart';
import '../../domain/repositories/timer_session_repository.dart';
import '../datasources/timer_session_local_datasource.dart';
import '../models/timer_session_model.dart';

class TimerSessionRepositoryImpl implements TimerSessionRepository {
  final TimerSessionLocalDataSource _localDataSource;

  TimerSessionRepositoryImpl(this._localDataSource);

  @override
  List<TimerSessionEntity> getSessions() {
    return _localDataSource.getSessions().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addSession(TimerSessionEntity session) async {
    await _localDataSource.addSession(session.toModel());
  }

  @override
  Future<void> clearSessions() async {
    await _localDataSource.clearSessions();
  }
}
```

**Step 5: flutter analyze**

Run: `flutter analyze lib/features/timer/data/ lib/features/timer/domain/`
Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/timer/data/ lib/features/timer/domain/
git commit -m "feat: 타이머 세션 로컬 DataSource, Repository 생성"
```

---

### Task 3: Provider 레이어 + 통계 계산 Provider 생성

세션 저장 Provider, 통계 계산 Provider를 생성한다.

**Files:**
- Create: `lib/features/timer/presentation/providers/timer_session_provider.dart`

**Step 1: timer_session_provider.dart 생성**

Create `lib/features/timer/presentation/providers/timer_session_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/timer_session_local_datasource.dart';
import '../../data/repositories/timer_session_repository_impl.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../../domain/repositories/timer_session_repository.dart';

part 'timer_session_provider.g.dart';

// === DataSource & Repository ===

@riverpod
TimerSessionLocalDataSource timerSessionLocalDataSource(Ref ref) {
  throw StateError(
    'TimerSessionLocalDataSource가 초기화되지 않았습니다. '
    'SharedPreferences 초기화를 확인하세요.',
  );
}

@riverpod
TimerSessionRepository timerSessionRepository(Ref ref) {
  final dataSource = ref.watch(timerSessionLocalDataSourceProvider);
  return TimerSessionRepositoryImpl(dataSource);
}

// === Session List ===

@riverpod
class TimerSessionListNotifier extends _$TimerSessionListNotifier {
  @override
  List<TimerSessionEntity> build() {
    final repository = ref.watch(timerSessionRepositoryProvider);
    return repository.getSessions();
  }

  Future<void> addSession(TimerSessionEntity session) async {
    final repository = ref.read(timerSessionRepositoryProvider);
    await repository.addSession(session);
    state = repository.getSessions();
  }
}

// === 통계 Providers ===

DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

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

/// 연속 공부 일수 (streak)
@riverpod
int currentStreak(Ref ref) {
  final sessions = ref.watch(timerSessionListNotifierProvider);
  if (sessions.isEmpty) return 0;

  // 세션이 있는 날짜 집합
  final studyDates = sessions
      .map((s) => _normalizeDate(s.startedAt))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // 최신순

  if (studyDates.isEmpty) return 0;

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

**Step 2: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: timer_session_provider.g.dart 생성

**Step 3: main.dart에 override 추가**

`lib/main.dart`의 ProviderScope overrides에 timerSessionLocalDataSourceProvider override 추가.

기존 localTodoDataSourceProvider override 아래에 추가:

```dart
if (prefs != null)
  timerSessionLocalDataSourceProvider.overrideWithValue(
    TimerSessionLocalDataSource(prefs),
  ),
```

import 추가:
```dart
import 'features/timer/data/datasources/timer_session_local_datasource.dart';
import 'features/timer/presentation/providers/timer_session_provider.dart';
```

**Step 4: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_session_provider.dart lib/features/timer/presentation/providers/timer_session_provider.g.dart lib/main.dart
git commit -m "feat: 타이머 세션 Provider + 통계 계산 Provider 생성"
```

---

### Task 4: timer_provider stop()에서 세션 저장

타이머 종료 시 세션 기록을 자동으로 저장한다.

**Files:**
- Modify: `lib/features/timer/presentation/providers/timer_provider.dart`

**Step 1: import 추가**

```dart
import '../../domain/entities/timer_session_entity.dart';
import 'timer_session_provider.dart';
```

**Step 2: stop() 메서드에 세션 저장 로직 추가**

stop()에서 state를 리셋하기 직전에, 1분 이상 세션이면 기록을 저장한다:

```dart
// state = const TimerState(); 직전에 추가:

// 1분 이상 세션이면 기록 저장
if (sessionDuration.inMinutes >= 1) {
  final session = TimerSessionEntity(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    todoId: todoId,
    todoTitle: todoTitle,
    startedAt: DateTime.now().subtract(sessionDuration),
    endedAt: DateTime.now(),
    durationMinutes: elapsedMinutes,
  );
  await ref.read(timerSessionListNotifierProvider.notifier).addSession(session);
}
```

**Step 3: flutter analyze**

Run: `flutter analyze lib/features/timer/`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/providers/timer_provider.dart
git commit -m "feat: 타이머 종료 시 세션 기록 자동 저장"
```

---

### Task 5: 타이머 화면 통계 섹션 실데이터 연동

하드코딩된 통계를 provider 데이터로 교체한다.

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart:109-149`

**Step 1: import 추가**

```dart
import '../providers/timer_session_provider.dart';
```

**Step 2: build() 내 통계 변수 추가**

`build()` 메서드 상단, isIdle 선언 아래에:

```dart
final todayMinutes = ref.watch(todayStudyMinutesProvider);
final weeklyMinutes = ref.watch(weeklyStudyMinutesProvider);
final streak = ref.watch(currentStreakProvider);
```

**Step 3: 통계 카드의 하드코딩 값 교체**

기존:
```dart
SpaceStatItem(
  icon: Icons.today_rounded,
  label: '오늘',
  value: '0시간 0분',
),
```

변경:
```dart
SpaceStatItem(
  icon: Icons.today_rounded,
  label: '오늘',
  value: _formatMinutes(todayMinutes),
),
```

나머지 2개도 동일 패턴:
- `'0시간 0분'` → `_formatMinutes(weeklyMinutes)`
- `'0일'` → `'$streak일'`

**Step 4: flutter analyze**

Run: `flutter analyze lib/features/timer/presentation/screens/timer_screen.dart`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "feat: 타이머 화면 통계를 실제 세션 데이터로 연동"
```

---

### Task 6: FadeSlideIn 제거 (타이머 화면)

StatefulShellRoute.indexedStack 환경에서 FadeSlideIn이 보이지 않는 상태에서 애니메이션을 완료해버리는 문제를 해결한다. 타이머 화면은 상시 사용 화면이므로 진입 애니메이션을 제거하고 즉시 표시한다.

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart`

**Step 1: FadeSlideIn 래핑 제거**

3곳의 FadeSlideIn을 제거하고 child를 직접 사용:

1. 타이머 링: `FadeSlideIn(child: SizedBox(260...))` → `SizedBox(260...)`
2. 컨트롤 버튼: `FadeSlideIn(delay: ..., child: _buildControls(...))` → `_buildControls(...)`
3. 통계 카드: `FadeSlideIn(delay: ..., child: Padding(...))` → `Padding(...)`

**Step 2: FadeSlideIn import 제거 (사용처 없으면)**

```dart
// 사용처가 없으면 제거:
import '../../../../core/widgets/animations/entrance_animations.dart';
```

**Step 3: flutter analyze**

Run: `flutter analyze lib/features/timer/presentation/screens/timer_screen.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "fix: 타이머 화면 FadeSlideIn 제거 (IndexedStack 환경에서 미동작)"
```

---

### Task 7: 전체 통합 검증

**Step 1: flutter analyze 전체**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 변경 파일 확인**

변경/생성된 파일 목록:
- `lib/features/timer/domain/entities/timer_session_entity.dart` (NEW)
- `lib/features/timer/data/models/timer_session_model.dart` (NEW)
- `lib/features/timer/data/datasources/timer_session_local_datasource.dart` (NEW)
- `lib/features/timer/domain/repositories/timer_session_repository.dart` (NEW)
- `lib/features/timer/data/repositories/timer_session_repository_impl.dart` (NEW)
- `lib/features/timer/presentation/providers/timer_session_provider.dart` (NEW)
- `lib/features/timer/presentation/providers/timer_provider.dart` (MODIFIED)
- `lib/features/timer/presentation/screens/timer_screen.dart` (MODIFIED)
- `lib/main.dart` (MODIFIED)
- Generated: `.freezed.dart`, `.g.dart` 파일들
