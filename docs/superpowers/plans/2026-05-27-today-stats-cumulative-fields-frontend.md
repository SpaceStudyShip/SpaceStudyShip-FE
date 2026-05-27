# today-stats 누적 통계 필드 3개 클라이언트 연동 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 백엔드가 추가한 `lifetimeMinutes`/`lifetimeSessionCount`/`monthlyMinutes` 필드를 클라이언트 DTO/Entity 에 노출하고, `todayStatsNotifierProvider` 가 단일 진실 소스가 되도록 누적 통계 provider 를 위임 패턴으로 정리한다.

**Architecture:** Entity 가 6필드 `required` 가 되면 `TodayStats(...)` / `TodayStatsResponseModel(...)` 직접 호출 5곳이 동시에 컴파일 에러 → Task 1 에서 일괄 처리해 중간 상태 컴파일을 보존한다. Task 2 에서 `study_stats_provider` 의 3개 함수를 `todayStatsNotifierProvider.valueOrNull?.X ?? 0` 한 줄로 단순화하여 인증/게스트 분기 책임을 한 곳으로 모은다.

**Tech Stack:** Flutter 3.9, Riverpod 2.6 (riverpod_annotation), Freezed 2.5, build_runner, mocktail, flutter_test

**Spec:** `docs/superpowers/specs/2026-05-27-today-stats-cumulative-fields-frontend-design.md`

---

## File Structure

| 파일 | 작업 | Task |
|---|---|---|
| `lib/features/timer/data/models/today_stats_response_model.dart` | M — 3필드 + `toEntity()` | 1 |
| `lib/features/timer/domain/entities/today_stats.dart` | M — 3필드 + `empty()` | 1 |
| `lib/features/timer/presentation/providers/today_stats_provider.dart` | M — 게스트 분기 6필드 fold | 1 |
| `lib/features/timer/presentation/providers/study_stats_provider.dart` | M — 위임 한 줄로 단순화, `isAuthenticatedProvider` 제거 | 2 |
| `*.freezed.dart`, `*.g.dart` | regenerate via build_runner | 1, 2 |
| `test/features/timer/data/models/today_stats_response_model_test.dart` | M — 6필드 JSON 픽스처 | 1 |
| `test/features/timer/domain/entities/today_stats_test.dart` | M — fixture 2건 6필드 | 1 |
| `test/features/timer/data/repositories/timer_session_repository_impl_test.dart` | M — DTO 픽스처 6필드 | 1 |
| `test/features/timer/presentation/providers/today_stats_provider_test.dart` | M — fixture 6필드 | 1 |
| `test/features/timer/presentation/providers/study_stats_provider_test.dart` | C — 신규, 위임 동작 검증 | 2 |

---

## Task 1: Entity·DTO 6필드 확장 + 모든 호출처 컴파일 에러 해소

**Files:**
- Modify: `lib/features/timer/domain/entities/today_stats.dart` (전체 재작성)
- Modify: `lib/features/timer/data/models/today_stats_response_model.dart` (전체 재작성)
- Modify: `lib/features/timer/presentation/providers/today_stats_provider.dart:14-44` (게스트 분기 fold)
- Modify: `test/features/timer/data/models/today_stats_response_model_test.dart` (전체 재작성)
- Modify: `test/features/timer/domain/entities/today_stats_test.dart` (전체 재작성)
- Modify: `test/features/timer/data/repositories/timer_session_repository_impl_test.dart:170-183` (fixture 갱신)
- Modify: `test/features/timer/presentation/providers/today_stats_provider_test.dart:23-37` (fixture 갱신)

### Step 1: DTO 테스트 갱신 (RED)

`test/features/timer/data/models/today_stats_response_model_test.dart` 를 다음으로 교체.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/data/models/today_stats_response_model.dart';

void main() {
  test('fromJson + toEntity — 6필드 모두 매핑', () {
    final m = TodayStatsResponseModel.fromJson({
      'totalMinutes': 180,
      'sessionCount': 3,
      'streak': 7,
      'lifetimeMinutes': 12450,
      'lifetimeSessionCount': 287,
      'monthlyMinutes': 1820,
    });
    expect(m.totalMinutes, 180);
    expect(m.sessionCount, 3);
    expect(m.streak, 7);
    expect(m.lifetimeMinutes, 12450);
    expect(m.lifetimeSessionCount, 287);
    expect(m.monthlyMinutes, 1820);

    final e = m.toEntity();
    expect(e.totalMinutes, 180);
    expect(e.sessionCount, 3);
    expect(e.streak, 7);
    expect(e.lifetimeMinutes, 12450);
    expect(e.lifetimeSessionCount, 287);
    expect(e.monthlyMinutes, 1820);
  });
}
```

### Step 2: Entity 테스트 갱신 (RED)

`test/features/timer/domain/entities/today_stats_test.dart` 를 다음으로 교체.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/today_stats.dart';

void main() {
  test('TodayStats — 6필드 생성', () {
    const stats = TodayStats(
      totalMinutes: 180,
      sessionCount: 3,
      streak: 7,
      lifetimeMinutes: 12450,
      lifetimeSessionCount: 287,
      monthlyMinutes: 1820,
    );
    expect(stats.totalMinutes, 180);
    expect(stats.lifetimeMinutes, 12450);
    expect(stats.monthlyMinutes, 1820);
  });

  test('TodayStats.empty(): 6필드 모두 0', () {
    expect(
      TodayStats.empty(),
      const TodayStats(
        totalMinutes: 0,
        sessionCount: 0,
        streak: 0,
        lifetimeMinutes: 0,
        lifetimeSessionCount: 0,
        monthlyMinutes: 0,
      ),
    );
  });
}
```

### Step 3: 회귀 가드 fixture 갱신 — `today_stats_provider_test.dart`

`test/features/timer/presentation/providers/today_stats_provider_test.dart:23-37` 의 인증 모드 케이스에서 `TodayStats` fixture 를 6필드로 확장. 다음 블록을 찾아 교체.

```dart
  test('인증 모드: repo.getTodayStats() 결과 그대로 반환', () async {
    when(() => repo.getTodayStats()).thenAnswer(
      (_) async => const TodayStats(
        totalMinutes: 180,
        sessionCount: 3,
        streak: 7,
        lifetimeMinutes: 12450,
        lifetimeSessionCount: 287,
        monthlyMinutes: 1820,
      ),
    );
    container = ProviderContainer(
      overrides: [
        isAuthenticatedProvider.overrideWith((ref) => true),
        timerSessionRepositoryProvider.overrideWith((ref) => repo),
      ],
    );
    final stats = await container.read(todayStatsNotifierProvider.future);
    expect(stats.totalMinutes, 180);
    expect(stats.streak, 7);
    expect(stats.lifetimeMinutes, 12450);
  });
```

게스트 모드 케이스 (line 39-69 부근) 는 `repository.getSessions()` mock 만 사용하므로 fixture 변경 불필요. 단, 마지막 assertion 에 신규 필드 1개만 추가해서 fold 결과 확인:

```dart
    expect(stats.sessionCount, 2);
    expect(stats.totalMinutes, 90);
    expect(stats.streak, 1);
    expect(stats.lifetimeMinutes, 90); // 게스트는 전체 = today 합산
    expect(stats.lifetimeSessionCount, 2);
```

### Step 4: 회귀 가드 fixture 갱신 — `timer_session_repository_impl_test.dart`

`test/features/timer/data/repositories/timer_session_repository_impl_test.dart:170-183` 의 `getTodayStats` 그룹에서 DTO fixture 를 6필드로 확장.

```dart
  group('getTodayStats', () {
    test('성공: TodayStats 반환', () async {
      when(() => remote.getTodayStats()).thenAnswer(
        (_) async => const TodayStatsResponseModel(
          totalMinutes: 180,
          sessionCount: 3,
          streak: 7,
          lifetimeMinutes: 12450,
          lifetimeSessionCount: 287,
          monthlyMinutes: 1820,
        ),
      );
      final stats = await repo.getTodayStats();
      expect(stats.totalMinutes, 180);
      expect(stats.streak, 7);
      expect(stats.lifetimeMinutes, 12450);
    });
  });
```

### Step 5: Entity 필드 추가

`lib/features/timer/domain/entities/today_stats.dart` 를 다음으로 교체.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_stats.freezed.dart';

/// KST 기준 오늘 공부 통계 + 누적 통계 (GET /api/timer-sessions/today-stats).
@freezed
class TodayStats with _$TodayStats {
  const factory TodayStats({
    required int totalMinutes,
    required int sessionCount,
    required int streak,
    required int lifetimeMinutes,
    required int lifetimeSessionCount,
    required int monthlyMinutes,
  }) = _TodayStats;

  factory TodayStats.empty() => const TodayStats(
    totalMinutes: 0,
    sessionCount: 0,
    streak: 0,
    lifetimeMinutes: 0,
    lifetimeSessionCount: 0,
    monthlyMinutes: 0,
  );
}
```

### Step 6: DTO 필드 추가 + toEntity 매핑

`lib/features/timer/data/models/today_stats_response_model.dart` 를 다음으로 교체.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/today_stats.dart';

part 'today_stats_response_model.freezed.dart';
part 'today_stats_response_model.g.dart';

@freezed
class TodayStatsResponseModel with _$TodayStatsResponseModel {
  const TodayStatsResponseModel._();

  const factory TodayStatsResponseModel({
    required int totalMinutes,
    required int sessionCount,
    required int streak,
    required int lifetimeMinutes,
    required int lifetimeSessionCount,
    required int monthlyMinutes,
  }) = _TodayStatsResponseModel;

  factory TodayStatsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TodayStatsResponseModelFromJson(json);

  TodayStats toEntity() => TodayStats(
    totalMinutes: totalMinutes,
    sessionCount: sessionCount,
    streak: streak,
    lifetimeMinutes: lifetimeMinutes,
    lifetimeSessionCount: lifetimeSessionCount,
    monthlyMinutes: monthlyMinutes,
  );
}
```

### Step 7: today_stats_provider 게스트 분기 6필드 fold

`lib/features/timer/presentation/providers/today_stats_provider.dart` 의 `build()` 메서드 전체를 다음으로 교체 (전체 파일 line 14-44 영역).

```dart
  @override
  Future<TodayStats> build() async {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final repository = ref.watch(timerSessionRepositoryProvider);

    if (isAuthenticated) {
      return repository.getTodayStats();
    }

    // 게스트 모드: 로컬 세션 fold (전체가 메모리에 있어 정확)
    final sessions = repository.getSessions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final todaySessions = sessions.where((s) {
      return s.startedAt.isAfter(today.subtract(const Duration(seconds: 1))) &&
          s.startedAt.isBefore(tomorrow);
    }).toList();

    final todayMinutes =
        todaySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final lifetimeMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final monthlyMinutes = sessions
        .where((s) => !s.startedAt.isBefore(monthStart))
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return TodayStats(
      totalMinutes: todayMinutes,
      sessionCount: todaySessions.length,
      streak: todaySessions.isEmpty ? 0 : 1,
      lifetimeMinutes: lifetimeMinutes,
      lifetimeSessionCount: sessions.length,
      monthlyMinutes: monthlyMinutes,
    );
  }
```

### Step 8: build_runner 재생성

Run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `[INFO] Succeeded` 로 종료. `today_stats.freezed.dart`, `today_stats_response_model.freezed.dart`, `today_stats_response_model.g.dart` 가 6필드 반영하여 재생성됨.

### Step 9: 분석·테스트 통과 확인 (GREEN)

Run:
```bash
flutter analyze lib/features/timer test/features/timer
```
Expected: `No issues found!`

```bash
flutter test test/features/timer
```
Expected: 모든 케이스 PASS. 특히:
- `today_stats_response_model_test.dart` — 1 case PASS
- `today_stats_test.dart` — 2 cases PASS
- `today_stats_provider_test.dart` — 2 cases PASS (인증·게스트 분기)
- `timer_session_repository_impl_test.dart` — 기존 케이스 회귀 없음

### Step 10: 커밋

```bash
git add lib/features/timer/domain/entities/today_stats.dart \
        lib/features/timer/domain/entities/today_stats.freezed.dart \
        lib/features/timer/data/models/today_stats_response_model.dart \
        lib/features/timer/data/models/today_stats_response_model.freezed.dart \
        lib/features/timer/data/models/today_stats_response_model.g.dart \
        lib/features/timer/presentation/providers/today_stats_provider.dart \
        test/features/timer/data/models/today_stats_response_model_test.dart \
        test/features/timer/domain/entities/today_stats_test.dart \
        test/features/timer/data/repositories/timer_session_repository_impl_test.dart \
        test/features/timer/presentation/providers/today_stats_provider_test.dart
git commit -m "feat : TodayStats 누적 통계 3필드 추가 + 게스트 분기 6필드 fold #83"
```

---

## Task 2: study_stats_provider 위임 단순화 + 신규 테스트

**Files:**
- Create: `test/features/timer/presentation/providers/study_stats_provider_test.dart`
- Modify: `lib/features/timer/presentation/providers/study_stats_provider.dart:36-65` (3 함수 단순화)

### Step 1: 신규 테스트 작성 (RED)

`test/features/timer/presentation/providers/study_stats_provider_test.dart` 신규 생성:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/timer/domain/entities/today_stats.dart';
import 'package:space_study_ship/features/timer/presentation/providers/study_stats_provider.dart';
import 'package:space_study_ship/features/timer/presentation/providers/today_stats_provider.dart';

void main() {
  test('todayStats 로드 완료 → 3 provider 가 lifetime/monthly 값 위임', () {
    final stats = const TodayStats(
      totalMinutes: 180,
      sessionCount: 3,
      streak: 7,
      lifetimeMinutes: 12450,
      lifetimeSessionCount: 287,
      monthlyMinutes: 1820,
    );

    final container = ProviderContainer(
      overrides: [
        todayStatsNotifierProvider.overrideWith(() {
          return _StubTodayStatsNotifier(stats);
        }),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(totalStudyMinutesProvider), 12450);
    expect(container.read(totalSessionCountProvider), 287);
    expect(container.read(monthlyStudyMinutesProvider), 1820);
  });
}

class _StubTodayStatsNotifier extends TodayStatsNotifier {
  _StubTodayStatsNotifier(this._stats);
  final TodayStats _stats;

  @override
  Future<TodayStats> build() async => _stats;
}
```

### Step 2: 테스트 실패 확인 (RED 검증)

Run:
```bash
flutter test test/features/timer/presentation/providers/study_stats_provider_test.dart
```
Expected: FAIL. `totalStudyMinutesProvider` 가 현재 `timerSessionListNotifierProvider` 의존이라 0 반환 → expected 12450 mismatch.

### Step 3: study_stats_provider 위임 패턴 적용

`lib/features/timer/presentation/providers/study_stats_provider.dart` 의 `// === 월별/전체 통계 ===` 섹션(line 36 이후) ~ `// === Streak ===` 직전 까지의 3개 함수 (`monthlyStudyMinutes`, `totalStudyMinutes`, `totalSessionCount`) 를 다음으로 교체.

```dart
// === 월별/전체 통계 ===

/// 이번 달 공부 시간 (분) — todayStats 위임
@riverpod
int monthlyStudyMinutes(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.monthlyMinutes ?? 0;
}

/// 전체 총 공부 시간 (분) — todayStats 위임
@riverpod
int totalStudyMinutes(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeMinutes ?? 0;
}

/// 전체 세션 수 — todayStats 위임
@riverpod
int totalSessionCount(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeSessionCount ?? 0;
}
```

추가로 파일 상단 import 에 `today_stats_provider.dart` 가 없으면 추가:

```dart
import 'today_stats_provider.dart';
```

`todayStudyMinutes`, `weeklyStudyMinutes`, `currentStreak` 는 변경 없음.

### Step 4: build_runner 재생성

Run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
Expected: `[INFO] Succeeded`. `study_stats_provider.g.dart` 의존성 해시 갱신.

### Step 5: 테스트 통과 확인 (GREEN)

Run:
```bash
flutter test test/features/timer/presentation/providers/study_stats_provider_test.dart
```
Expected: PASS — 1 case.

```bash
flutter test test/features/timer
```
Expected: 전체 PASS (회귀 없음).

```bash
flutter analyze lib/features/timer test/features/timer
```
Expected: `No issues found!`

### Step 6: 커밋

```bash
git add lib/features/timer/presentation/providers/study_stats_provider.dart \
        lib/features/timer/presentation/providers/study_stats_provider.g.dart \
        test/features/timer/presentation/providers/study_stats_provider_test.dart
git commit -m "refactor : study_stats_provider 누적 통계 3개 todayStats 위임 단순화 #83"
```

---

## Final Verification

### Step 1: 전체 분석 통과

Run:
```bash
flutter analyze
```
Expected: `No issues found!` (프로젝트 전체)

### Step 2: 전체 테스트 통과

Run:
```bash
flutter test
```
Expected: 전체 PASS, 회귀 없음.

### Step 3: 호출처 동작 수동 검증

Run:
```bash
flutter run
```
- 인증 사용자로 로그인 → 프로필 화면 진입 → "공부 시간" 카드가 서버 누적값 표시 확인.
- 게스트 모드 → 프로필 화면 진입 → 로컬 세션 합산값 표시 확인 (회귀 없음).

### Step 4: grep 회귀 가드

Run:
```bash
git grep -n 'TodayStats(' -- ':!*.freezed.dart' ':!*.g.dart'
git grep -n 'TodayStatsResponseModel(' -- ':!*.freezed.dart' ':!*.g.dart'
```
Expected: 모든 호출처가 6필드 또는 `.empty()` 사용. 3필드 잔존 호출 없음.

---

## Plan Self-Review

- **Spec coverage**: §3 의 10행 파일 변경표 → 모두 Task 1·2 에 매핑됨. §4.1~4.5 의 코드 블록 → Task 1 Step 5~7 + Task 2 Step 3 에 그대로 반영. §6.1~6.3 의 테스트 → Task 1 Step 1·2·3·4 + Task 2 Step 1 에 반영. §6.4 회귀 가드 4개 파일 → Task 1 Step 1·2·3·4 모두 처리. §8 검증 체크리스트 → Final Verification 4 step 에 반영.
- **Placeholder scan**: TBD/TODO/생략 없음. 모든 코드 블록 완전. import 경로 명시.
- **Type consistency**: `TodayStats` 의 필드명 (`lifetimeMinutes`, `lifetimeSessionCount`, `monthlyMinutes`) 이 Task 1·2 전체에서 일관. `valueOrNull` 패턴 통일. provider 명 (`totalStudyMinutesProvider`, `totalSessionCountProvider`, `monthlyStudyMinutesProvider`) 일치.
