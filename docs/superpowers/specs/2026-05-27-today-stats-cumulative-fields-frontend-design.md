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

서버가 반환하기 시작한 누적 필드 3개를 클라이언트가 수신·노출한다. `todayStatsNotifierProvider` 가 **단일 진실 소스(single source of truth)** 가 되도록 정리한다.

- **인증 모드**: 서버 응답을 그대로 신뢰 — 이미 동작 중.
- **게스트 모드**: 기존에는 3필드만 채웠지만, 이제 로컬 세션을 fold 해서 6필드 모두 채운다. 이슈 명시("게스트 모드는 로컬 전체 세션이 메모리에 있어 정확함")와 일치.

`study_stats_provider.dart` 의 누적 통계 3개 함수는 단순히 `todayStatsNotifierProvider.valueOrNull?.X ?? 0` 한 줄로 위임 — 자체 분기 로직 제거. 더 이상 `isAuthenticatedProvider` 를 watch 하지 않는다.

---

## 3. 변경 범위 — 파일 목록

| 파일 | 변경 내용 |
|---|---|
| `lib/features/timer/data/models/today_stats_response_model.dart` | 필드 3개 (`lifetimeMinutes`, `lifetimeSessionCount`, `monthlyMinutes`) 추가 + `toEntity()` 매핑 갱신 |
| `lib/features/timer/domain/entities/today_stats.dart` | 동일 3필드 추가 + `TodayStats.empty()` 의 0 초기값 6필드로 확장 |
| `lib/features/timer/presentation/providers/today_stats_provider.dart` | **게스트 분기에서 6필드 모두 로컬 fold 로 채우도록 확장**. 컴파일 에러 회피 + 단일 진실 소스 보장 |
| `lib/features/timer/presentation/providers/study_stats_provider.dart` | `totalStudyMinutes`, `totalSessionCount`, `monthlyStudyMinutes` 를 `todayStatsNotifierProvider` 위임 한 줄로 단순화. `isAuthenticatedProvider` watch 제거 |
| `*.freezed.dart`, `*.g.dart` | `flutter pub run build_runner build --delete-conflicting-outputs` 로 재생성 |
| `test/features/timer/data/models/today_stats_response_model_test.dart` | 기존 케이스에 새 필드 3개 직렬화·매핑 검증 추가 |
| `test/features/timer/domain/entities/today_stats_test.dart` | fixture 6필드로 확장 (회귀 가드) |
| `test/features/timer/data/repositories/timer_session_repository_impl_test.dart` | fixture 6필드로 확장 (회귀 가드) |
| `test/features/timer/presentation/providers/today_stats_provider_test.dart` | fixture 6필드로 확장 (회귀 가드) |
| `test/features/timer/presentation/providers/study_stats_provider_test.dart` | **신규 파일**. 위임 동작 1 케이스 |

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

### 4.3 today_stats_provider 게스트 분기 — 6필드 fold 로 확장

Entity 가 6필드 `required` 가 되면서 현재 게스트 분기(`today_stats_provider.dart:39`) 가 컴파일 에러. 게스트 모드에서는 로컬 세션 전체가 메모리에 있으므로 fold 로 정확하게 계산 가능 — 이슈가 명시한 의도와 일치.

```dart
@override
Future<TodayStats> build() async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final repository = ref.watch(timerSessionRepositoryProvider);

  if (isAuthenticated) {
    return repository.getTodayStats();
  }

  // 게스트 모드: 로컬 세션 fold
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

기존 streak 계산("오늘 세션 있으면 1, 없으면 0") 은 변경하지 않음 — 이슈 범위 밖.

### 4.4 study_stats_provider 단순화 — `todayStatsNotifierProvider` 위임

3개 함수를 한 줄로 단순화. 더 이상 `isAuthenticatedProvider` 를 watch 하지 않고, 분기 책임을 전부 `todayStatsNotifierProvider` 에 위임. 시그니처는 동기 `int` 그대로 유지 — 로딩/에러시 `valueOrNull?.X ?? 0` fallback.

```dart
import 'today_stats_provider.dart';

@riverpod
int totalStudyMinutes(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeMinutes ?? 0;
}

@riverpod
int totalSessionCount(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.lifetimeSessionCount ?? 0;
}

@riverpod
int monthlyStudyMinutes(Ref ref) {
  return ref.watch(todayStatsNotifierProvider).valueOrNull?.monthlyMinutes ?? 0;
}
```

**손대지 않는 함수**: `todayStudyMinutes`, `weeklyStudyMinutes`, `currentStreak`. 이슈가 명시한 3개만 변경.

### 4.5 무효화 트리거 — 변경 없음

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

작업 난이도가 낮으므로 **이슈가 명시한 테스트 + 회귀 가드 (fixture 갱신)** 만 진행. trivial 한 분기는 케이스 추가하지 않는다.

### 6.1 DTO — `today_stats_response_model_test.dart`

기존 테스트의 JSON 픽스처에 새 필드 3개 추가하고 6필드 모두 `toEntity()` 매핑이 동작하는지 한 케이스로 검증.

### 6.2 신규 — `study_stats_provider_test.dart`

`todayStatsNotifierProvider` override 한 줄로 위임 동작만 검증. **로드 완료 1 케이스만**:

- `lifetimeMinutes=12450`, `lifetimeSessionCount=287`, `monthlyMinutes=1820` 인 `TodayStats` 주입 → 3 provider 가 각각 일치하는 값 반환.

loading/error 분기는 Riverpod 표준 동작 (`valueOrNull` 이 null 반환) 이므로 별도 케이스 불필요.

### 6.3 회귀 가드 — fixture 6필드 갱신

DTO/Entity 가 6필드 `required` 가 되면서 기존 픽스처는 컴파일 에러. 다음 4개 파일에서 6필드로 확장 (추가 필드는 모두 0):

| 파일:라인 | 갱신 |
|---|---|
| `today_stats_test.dart:6` | `TodayStats(...)` 6필드 |
| `today_stats_test.dart:15` | `TodayStats(...)` 6필드 모두 0 (`empty()` 비교 대상) |
| `today_stats_provider_test.dart:26` | `TodayStats(...)` 6필드 |
| `timer_session_repository_impl_test.dart:173-177` | `TodayStatsResponseModel(...)` 6필드 |

기존 테스트 케이스 자체는 추가하지 않음. 컴파일 통과만 확보.

---

## 7. 명시적 비범위(Out of Scope)

다음은 이 이슈에서 **건드리지 않는다**. 별도 이슈로 다룰 사안:

- `todayStudyMinutes`, `weeklyStudyMinutes`, `currentStreak` provider — 이슈가 지목한 3개만 변경.
- `today_stats_provider.dart` 게스트 분기의 **streak 계산 로직** — 현재 "오늘 있으면 1, 없으면 0" 단순 로직 그대로. lifetime/monthly 필드 추가만 진행.
- `today_stats_provider.dart` 의 인증 분기 — 이미 `repository.getTodayStats()` 위임 패턴 동작 중. 변경 없음.
- 새 invalidate 트리거 — 기존 4곳(timer save 1, auth 3) 으로 충분.
- UI 신규 컴포넌트 — 시그니처가 동일해서 호출처(profile_screen, badge_provider) 수정 불필요.
- 백엔드 작업 — 이미 완료, `docs/api-docs.json` 동기화 끝남.

---

## 8. 검증 체크리스트

- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` 성공
- [ ] `flutter analyze` 경고 0
- [ ] `flutter test test/features/timer/` 전부 통과
- [ ] `git grep -n 'TodayStats('` 결과의 모든 호출처 — 신규 6필드 또는 `.empty()` 사용 일관 (§6.4 4개 파일 갱신 완료 여부 확인)
- [ ] `git grep -n 'TodayStatsResponseModel('` 결과 — `timer_session_repository_impl_test.dart` 픽스처 6필드 갱신 완료
- [ ] profile_screen / badge_provider 호출처 — 코드 미수정 상태로 정상 동작 (시그니처 동일)
- [ ] flutter run 으로 인증 사용자 프로필 화면 진입 → "공부 시간" 카드가 누적값 표시 (서버 정확값 검증)
