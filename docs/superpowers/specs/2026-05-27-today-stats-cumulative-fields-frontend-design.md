# today-stats 누적 통계 필드 3개 클라이언트 연동 — Design Spec

- **Issue**: `issue/today-stats-cumulative-fields-frontend.md` (Frontend #83)
- **Backend pair**: 이미 머지됨. `GET /api/timer-sessions/today-stats` 응답에 누적 필드 3개 추가 완료. `docs/api-docs.json` 의 `TodayStatsResponse` 가 6필드(`totalMinutes`, `sessionCount`, `streak`, `lifetimeMinutes`, `lifetimeSessionCount`, `monthlyMinutes`)로 갱신됨.
- **Branch**: `20260526_#83_today_stats_누적_통계_필드_3개_클라이언트_연동`

---

## 1. 문제 정의

인증 사용자의 누적 통계(전체 공부 시간 / 전체 세션 수 / 이번 달 공부 시간) 가 클라이언트에서 잘못 계산되고 있다.

**현재 동작**

`lib/features/timer/presentation/providers/study_stats_provider.dart` 의 3개 provider —
`totalStudyMinutes`, `totalSessionCount`, `monthlyStudyMinutes` — 가 전부 로컬 `timerSessionListNotifierProvider` 의 결과를 fold 해서 계산한다.

인증 모드에서 `timerSessionListNotifierProvider` 는 서버 페이지네이션(`size=20`) 의 **첫 페이지만** 보유한다. 결과적으로:

- 프로필 화면 (`profile_screen.dart:83`) 의 "공부 시간" 통계 카드가 최근 20세션만 합산.
- 뱃지 해금 (`badge_provider.dart:53,55`) 의 "총 100시간 공부" / "총 50회 세션 완료" 류 조건이 영구 미해금.

게스트 모드는 모든 세션이 인메모리(로컬 저장) 에 있어 fold 합산이 정확하다 — 분기 처리 필요.

---

## 2. 솔루션 개요

서버가 반환하기 시작한 누적 필드 3개를 클라이언트가 수신·노출한다. 인증 모드는 서버 값을 신뢰하고, 게스트 모드는 현재 로컬 합산 로직을 그대로 유지한다.

`today_stats_provider.dart` 에 이미 존재하는 인증/게스트 분기 패턴을 그대로 활용한다 — 새 provider 를 만들지 않고 기존 `todayStatsNotifierProvider` 결과를 `study_stats_provider` 에서 끌어 쓴다.

---

## 3. 변경 범위 — 파일 목록

| 파일 | 변경 내용 |
|---|---|
| `lib/features/timer/data/models/today_stats_response_model.dart` | 필드 3개 (`lifetimeMinutes`, `lifetimeSessionCount`, `monthlyMinutes`) 추가 + `toEntity()` 매핑 갱신 |
| `lib/features/timer/domain/entities/today_stats.dart` | 동일 3필드 추가 + `TodayStats.empty()` 의 0 초기값 6필드로 확장 |
| `lib/features/timer/presentation/providers/study_stats_provider.dart` | `totalStudyMinutes`, `totalSessionCount`, `monthlyStudyMinutes` 에 인증/게스트 분기 추가 |
| `*.freezed.dart`, `*.g.dart` | `flutter pub run build_runner build --delete-conflicting-outputs` 로 재생성 |
| `test/features/timer/data/models/today_stats_response_model_test.dart` | 새 필드 직렬화 + `toEntity()` 매핑 검증 추가 |
| `test/features/timer/domain/entities/today_stats_test.dart` | 새 필드 + `empty()` 검증 추가 |
| `test/features/timer/presentation/providers/study_stats_provider_test.dart` | **신규 파일**. 3개 provider 의 인증/게스트 분기 검증 |
| `test/features/timer/presentation/providers/today_stats_provider_test.dart` | 회귀 가드 — 기존 케이스 통과 유지 (변경 없음) |

---

## 4. 상세 설계

### 4.1 DTO — `today_stats_response_model.dart`

```dart
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

서버 스펙(api-docs.json:1277) 에 따라 6필드 모두 non-null `int` (0 보장). `required` 그대로 사용.

### 4.2 Entity — `today_stats.dart`

```dart
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

### 4.3 Provider 리팩터링 — `study_stats_provider.dart`

3개 함수에 인증/게스트 분기 추가. 시그니처는 **동기 `int` 그대로 유지** — 인증 모드에서 `todayStatsNotifierProvider` 가 로딩 중이거나 에러일 때는 `valueOrNull?.X ?? 0` 패턴으로 0 fallback.

```dart
import '../../../auth/presentation/providers/auth_provider.dart';
import 'today_stats_provider.dart';

@riverpod
int totalStudyMinutes(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeMinutes ?? 0;
  }
  final sessions =
      ref.watch(timerSessionListNotifierProvider).valueOrNull ?? [];
  return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

@riverpod
int totalSessionCount(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeSessionCount ?? 0;
  }
  final sessions =
      ref.watch(timerSessionListNotifierProvider).valueOrNull ?? [];
  return sessions.length;
}

@riverpod
int monthlyStudyMinutes(Ref ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return ref.watch(todayStatsNotifierProvider).valueOrNull?.monthlyMinutes ?? 0;
  }
  final sessions =
      ref.watch(timerSessionListNotifierProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  return sessions
      .where((s) => !s.startedAt.isBefore(monthStart))
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
}
```

**손대지 않는 함수**: `todayStudyMinutes`, `weeklyStudyMinutes`, `currentStreak`. 이슈가 명시한 3개만 변경.

### 4.4 무효화 트리거 — 변경 없음

`todayStatsNotifierProvider` 는 이미 4곳에서 invalidate 된다:

- `lib/features/timer/presentation/providers/timer_provider.dart:174` — 세션 저장 후
- `lib/features/auth/presentation/providers/auth_provider.dart:334` — 로그인 후
- `lib/features/auth/presentation/providers/auth_provider.dart:369` — 로그아웃 후
- `lib/features/auth/presentation/providers/auth_provider.dart:463` — 탈퇴 후

신규 누적 필드도 동일 시점에 자동 갱신됨. 추가 invalidate 트리거 불필요.

---

## 5. 호출처 영향

### 5.1 `profile_screen.dart:83`

```dart
final totalMinutes = ref.watch(totalStudyMinutesProvider);
```

시그니처 동일 → 코드 변경 없음.
**동작 변화**: 인증 사용자는 최근 20세션 → 전체 누적값으로 정확해짐.
**과도기 UX**: 첫 진입 / invalidate 직후 `todayStatsNotifierProvider` 로딩 동안 0 표시 가능 (기존 코드도 빈 상태에서 0 표시였으므로 신규 깜빡임 아님).

### 5.2 `badge_provider.dart:53,55`

```dart
final totalMinutes = ref.read(totalStudyMinutesProvider);
final sessionCount = ref.read(totalSessionCountProvider);
```

시그니처 동일 → 코드 변경 없음.
**동작 변화**: "총 100시간 공부", "총 50회 세션" 류 뱃지가 정확한 누적값으로 평가됨 → 정상 해금 가능.

---

## 6. 테스트 계획

### 6.1 DTO 테스트 — `today_stats_response_model_test.dart`

기존 케이스에 새 필드 3개 직렬화·엔티티 매핑 추가:

```dart
test('fromJson + toEntity — 6필드 모두', () {
  final m = TodayStatsResponseModel.fromJson({
    'totalMinutes': 180,
    'sessionCount': 3,
    'streak': 7,
    'lifetimeMinutes': 12450,
    'lifetimeSessionCount': 287,
    'monthlyMinutes': 1820,
  });
  expect(m.lifetimeMinutes, 12450);
  expect(m.lifetimeSessionCount, 287);
  expect(m.monthlyMinutes, 1820);

  final e = m.toEntity();
  expect(e.lifetimeMinutes, 12450);
  expect(e.lifetimeSessionCount, 287);
  expect(e.monthlyMinutes, 1820);
});
```

### 6.2 Entity 테스트 — `today_stats_test.dart`

`TodayStats.empty()` 가 6필드 모두 0 반환하는지 검증:

```dart
test('empty() — 6 필드 모두 0', () {
  final e = TodayStats.empty();
  expect(e.totalMinutes, 0);
  expect(e.sessionCount, 0);
  expect(e.streak, 0);
  expect(e.lifetimeMinutes, 0);
  expect(e.lifetimeSessionCount, 0);
  expect(e.monthlyMinutes, 0);
});
```

### 6.3 Provider 테스트 — `study_stats_provider_test.dart` (신규)

`isAuthenticatedProvider` overrride + `todayStatsNotifierProvider` override + `timerSessionListNotifierProvider` override 로 4가지 시나리오 검증:

1. **인증 + todayStats 로드 완료** → `totalStudyMinutes = lifetimeMinutes`, `totalSessionCount = lifetimeSessionCount`, `monthlyStudyMinutes = monthlyMinutes`
2. **인증 + todayStats 로딩 중** (AsyncLoading) → 세 provider 모두 0 반환
3. **인증 + todayStats 에러** (AsyncError) → 세 provider 모두 0 반환 (valueOrNull fallback)
4. **게스트 + 로컬 세션 N개** → 기존 합산 로직 결과
5. **게스트 + 로컬 세션 비어있음** → 0 반환

### 6.4 회귀 가드

`today_stats_provider_test.dart` 의 기존 2개 케이스 (인증 모드, 게스트 모드) 가 그대로 통과해야 한다. `TodayStats` 생성자에 필드 3개가 추가되므로 테스트 픽스처 업데이트 필요 (모두 0 으로) — 컴파일 통과만 확보.

---

## 7. 명시적 비범위(Out of Scope)

다음은 이 이슈에서 **건드리지 않는다**. 별도 이슈로 다룰 사안:

- `todayStudyMinutes`, `weeklyStudyMinutes`, `currentStreak` provider — 이슈가 지목한 3개만 변경.
- `today_stats_provider.dart` 의 게스트 분기 — 현재 로컬 계산 그대로 유지.
- `today_stats_provider.dart` 의 인증 분기 — 이미 `repository.getTodayStats()` 위임 패턴 동작 중.
- 새 invalidate 트리거 — 기존 4곳으로 충분.
- UI 신규 컴포넌트 — 시그니처가 동일해서 호출처 수정 불필요.
- 백엔드 작업 — 이미 완료, `docs/api-docs.json` 동기화 끝남.

---

## 8. 검증 체크리스트

- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` 성공
- [ ] `flutter analyze` 경고 0
- [ ] `flutter test test/features/timer/` 전부 통과
- [ ] 기존 `today_stats_provider_test.dart` 회귀 없음 (TodayStats 생성자 인자 추가만 반영)
- [ ] `git grep -n 'TodayStats('` 결과의 모든 호출처 — 신규 6필드 또는 `.empty()` 사용 일관
