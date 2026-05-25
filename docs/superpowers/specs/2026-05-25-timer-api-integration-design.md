# Timer API 연동 설계서

**작성일:** 2026-05-25
**관련 이슈:** `issue/timer-api-integration.md`
**참고 패턴:** #79 Fuel API 연동 (`issue/fuel-api-integration.md`, `docs/superpowers/specs/2026-05-25-fuel-api-integration-design.md`)

---

## 1. 배경 & 문제 정의

### 1.1 현재 상태
- `lib/features/timer/` 는 SharedPreferences 기반 로컬 전용 구현
  - `TimerSessionLocalDataSource` 가 `guest_timer_sessions` JSON 리스트 보관
  - `TimerSessionRepositoryImpl` 은 로컬에서만 동작
- 타이머 종료 (`TimerNotifier.stop()`) 시 **클라이언트가 직접** 수행:
  1. 세션 저장 (SharedPreferences)
  2. `fuelNotifierProvider.chargeFuel(...)` — 30 분당 1 통 계산
  3. `todoNotifierProvider` 를 통한 `actualMinutes` 누적
  4. 배지 해금 트리거
  5. streak 자동 계산

### 1.2 새 API 가 제공하는 것
`api-docs.json` 의 `Timer` 태그 3 개 엔드포인트:

| Method | Path | 역할 |
|--------|------|------|
| POST | `/api/timer-sessions` | 세션 저장 + 시간 5 단계 검증 + 연료 자동 충전 + `actualMinutes` 자동 누적 (단일 트랜잭션) + Idempotency-Key 지원 |
| GET | `/api/timer-sessions` | 페이지네이션 조회 (startDate/endDate/todoId/page/size) |
| GET | `/api/timer-sessions/today-stats` | KST 기준 오늘 총분 / 세션 수 / streak |

### 1.3 문제
- 데이터 정합성: 클라이언트 계산 → 조작 가능, 다중 기기 불일치
- 코드 중복: 연료 계산·streak·actualMinutes 누적이 클라/서버 양쪽에 존재
- 일관성: #79 Fuel 이 이미 server-first 패턴으로 정렬됨, Timer 만 로컬 전용으로 남으면 패턴 깨짐

---

## 2. 목표 & 비목표

### 2.1 목표 (이번 이슈 범위)
- ✅ Timer API 3 개 엔드포인트 전부 연동
- ✅ 인증 모드 = 서버 권위, 게스트 모드 = 기존 로컬 로직 유지
- ✅ 인증 모드에서 fuel·actualMinutes·streak 계산 책임을 서버로 완전 이양
- ✅ `Idempotency-Key` 사용으로 재시도 시 중복 충전 방지
- ✅ 세션 이력 화면을 서버 페이지네이션으로 전환
- ✅ 오늘 통계 (totalMinutes/sessionCount/streak) 신규 provider 노출

### 2.2 비목표 (별도 이슈로 분리)
- ❌ 백그라운드 ↔ 포그라운드 타이머 재계산 보정 (현재 부재, 새 API 와 별개 문제)
- ❌ 기존 `guest_timer_sessions` SharedPreferences 데이터의 로그인 시 서버 마이그레이션
- ❌ 무한 스크롤 등 페이지네이션 UI 고도화 (provider 만 노출, UI 적용은 후속)
- ❌ 백엔드 시간 검증 거절(`SESSION_TOO_LONG` 등) 빈도 측정·완화 (별도 모니터링 이슈)

---

## 3. 접근 방식 결정

검토된 옵션 3 가지:

| | A. fuel 패턴 거울 (채택) | B. UseCase 레이어 추가 | C. 게스트 모드 제거 |
|---|---|---|---|
| 분기 위치 | Notifier 내부 | UseCase | 분기 없음 |
| Notifier 변경 | 중간 | 작음 | 중간 |
| fuel 패턴 일관성 | ✅ | ❌ | ❌ |
| 게스트 사용성 | 유지 | 유지 | 파괴 |
| 추가 추상화 | 없음 | 신규 | 없음 |

**채택: A. fuel 패턴 거울** — 검증된 패턴, 같은 backend 통합 시리즈에서 일관성 확보, 짧은 PR.

---

## 4. 아키텍처

### 4.1 게스트 모드 흐름 (기존 동작 보존)
```
TimerNotifier.stop()
  └─ LocalTimerSessionRepositoryImpl.addSession (SharedPreferences)
  └─ fuelNotifier.chargeFuel              ← 로컬 계산
  └─ todoNotifier.updateActualMinutes     ← 로컬 계산
  └─ 배지 해금 트리거                       ← 로컬 계산
  └─ streak                                ← 로컬 계산
```

### 4.2 인증 모드 흐름 (신규)
```
TimerNotifier.start()
  └─ 세션 idempotencyKey = UUID v4 발급 (진행 중 보관)

TimerNotifier.stop()
  └─ TimerSessionRepositoryImpl.createSession(
       body  : { todoId?, todoTitle?, startedAt, endedAt, durationMinutes },
       header: Idempotency-Key,
     )
       ↓ POST /api/timer-sessions
       ↓ 응답: TimerSessionCreateResult { session, fuelCharged }
  └─ ref.invalidate(fuelNotifierProvider)          ← 서버 이미 충전
  └─ ref.invalidate(todoNotifierProvider)          ← 서버 이미 actualMinutes 갱신
  └─ ref.invalidate(timerSessionListNotifier)
  └─ ref.invalidate(todayStatsProvider)
  └─ 배지 해금 트리거                                ← 로컬에서 유지 (서버 미제공)
  └─ idempotencyKey 폐기 (성공 시)
```

### 4.3 Repository 분기 (fuel 패턴 동일)
```dart
@Riverpod(keepAlive: true)
TimerSessionRepository timerSessionRepository(Ref ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (isAuthenticated) {
    return TimerSessionRepositoryImpl(
      ref.read(timerSessionRemoteDataSourceProvider),
      ref.read(timerSessionLocalDataSourceProvider), // 캐시
    );
  }
  return LocalTimerSessionRepositoryImpl(
    ref.read(timerSessionLocalDataSourceProvider),
  );
}
```

---

## 5. 컴포넌트 & 파일 변경

### 5.1 신규 파일
```
lib/features/timer/
├── data/
│   ├── datasources/
│   │   └── timer_session_remote_datasource.dart   [신규] Retrofit @RestApi
│   ├── models/
│   │   ├── timer_session_create_request_model.dart   [신규]
│   │   ├── timer_session_create_response_model.dart  [신규] { session, fuelCharged }
│   │   ├── timer_session_page_response_model.dart    [신규]
│   │   └── today_stats_response_model.dart           [신규]
│   └── repositories/
│       └── timer_session_repository_impl.dart        [신규] 서버 backed
├── domain/
│   ├── entities/
│   │   ├── timer_session_create_result.dart          [신규] { session, fuelCharged }
│   │   ├── timer_session_page.dart                   [신규]
│   │   ├── timer_session_filter.dart                 [신규]
│   │   └── today_stats.dart                          [신규]
│   ├── exceptions/
│   │   └── timer_session_exceptions.dart             [신규] sealed class
│   └── repositories/
│       └── timer_session_repository.dart             [수정] createSession/getSessionsPage/getTodayStats 추가
└── presentation/
    └── providers/
        ├── timer_session_provider.dart               [수정] 인증/게스트 분기 + 페이지네이션화
        ├── today_stats_provider.dart                 [신규]
        └── timer_provider.dart                       [수정] stop 분기 + idempotencyKey
```

### 5.2 리네임
- 기존 `TimerSessionRepositoryImpl` → `LocalTimerSessionRepositoryImpl` (fuel 패턴과 동일 명명, 게스트 전용)

### 5.3 인프라
- `lib/core/constants/api_endpoints.dart` 에 `timerSessions`, `timerSessionsTodayStats` 상수 추가

---

## 6. 데이터 흐름 (API 스펙 매핑)

### 6.1 POST /api/timer-sessions
**Request body (`TimerSessionCreateRequest`):**
| 필드 | 타입 | 필수 | 비고 |
|------|------|------|------|
| `todoId` | string (max 36) | 선택 | 연결된 Todo |
| `todoTitle` | string (max 100) | 선택 | Todo 삭제 후 표시용 스냅샷 |
| `startedAt` | ISO 8601 UTC | **필수** | 타이머 시작 시각 |
| `endedAt` | ISO 8601 UTC | **필수** | 타이머 종료 시각 |
| `durationMinutes` | int | **필수** | 일시정지 제외 실제 공부분 |

**Header:**
- `Idempotency-Key`: UUID v4 (앱은 세션 1 회당 1 개 발급, 항상 동봉)

**Response 201 (`TimerSessionCreateResponse`):**
```json
{
  "session": {
    "id": "sess-uuid",
    "todoId": "todo-1",
    "todoTitle": "수학",
    "startedAt": "2026-05-25T01:00:00Z",
    "endedAt": "2026-05-25T02:30:00Z",
    "durationMinutes": 90
  },
  "fuelCharged": 90
}
```

### 6.2 GET /api/timer-sessions
**Query:**
| 파라미터 | 기본값 | 비고 |
|---------|-------|------|
| `startDate` | (없음) | YYYY-MM-DD, 종료일 포함 반열림 |
| `endDate` | (없음) | YYYY-MM-DD |
| `todoId` | (없음) | 특정 Todo 연결 세션만 |
| `page` | 0 | |
| `size` | 20 | 최대 100 |

**Response 200 (`TimerSessionListResponse`):**
```json
{
  "content": [ TimerSessionResponse, ... ],
  "page": 0, "size": 20, "totalElements": 120, "totalPages": 6
}
```
정렬: `startedAt` 내림차순 고정.

### 6.3 GET /api/timer-sessions/today-stats
**Response 200 (`TodayStatsResponse`):**
```json
{ "totalMinutes": 180, "sessionCount": 3, "streak": 7 }
```
KST(Asia/Seoul) 기준.

---

## 7. 에러 처리

### 7.1 매핑 표
| HTTP | code | 사용자 메시지 (한국어, Toss 라이팅) | 처리 |
|------|------|----------------------------------|------|
| 400 | `INVALID_SESSION_TIME` | "타이머 시간 정보가 올바르지 않아요" | 저장 실패 안내, 로컬 캐시에 임시 보관 |
| 400 | `INVALID_DURATION` | "타이머 시간 정보가 올바르지 않아요" | 동일 |
| 400 | `SESSION_TOO_SHORT` | (1 분 미만 → 무시) | 클라이언트 사전 차단 (기존 로직 유지, API 호출 자체 안 함) |
| 400 | `SESSION_TOO_LONG` | "최대 24시간을 초과했어요" | 저장 실패 안내 |
| 400 | `FUTURE_SESSION` | "타이머 시각이 올바르지 않아요" | 사용자 시계 조작 의심, 안내 |
| 404 | `TODO_NOT_FOUND` | "연결된 할 일을 찾을 수 없어요" | `todoId` 빼고 1 회 재시도 (세션은 저장하되 Todo 미연결) |
| 401 | `UNAUTHENTICATED_REQUEST` | (자동 재발급) | 기존 `AuthInterceptor` 큐 사용 |
| network/500 | - | "잠시 후 다시 시도해 주세요" | Idempotency-Key 유지한 채 재시도 가능 |

### 7.2 신규 sealed class
```dart
sealed class TimerSessionException implements Exception {
  const TimerSessionException();
}
class InvalidSessionTime extends TimerSessionException {}
class InvalidDuration   extends TimerSessionException {}
class SessionTooLong    extends TimerSessionException {}
class FutureSession     extends TimerSessionException {}
class LinkedTodoNotFound extends TimerSessionException {}
```

### 7.3 Idempotency-Key 라이프사이클
```
TimerNotifier.start()  → idempotencyKey = const Uuid().v4()
TimerNotifier.pause()  → 유지
TimerNotifier.resume() → 유지
TimerNotifier.stop()
  ├─ POST 호출 시 헤더에 동봉
  ├─ 성공 → idempotencyKey = null (폐기)
  └─ 실패 → 유지 (사용자 재시도 시 동일 키 재사용 → 서버가 멱등 보장)
```

---

## 8. 테스트 전략

| 레이어 | 테스트 종류 | 주요 케이스 |
|-------|----------|-----------|
| Remote DataSource | unit + mock dio | JSON 직렬화/역직렬화, `Idempotency-Key` 헤더 전달 |
| Repository (서버) | unit + mock | 정상 저장 → result 반환, 400 5 종 → 커스텀 예외 매핑, 404 → todoId 빼고 1 회 재시도, 401 → 그대로 throw (interceptor 위임) |
| Repository (로컬, 게스트) | unit | 기존 동작 회귀 가드 |
| Provider 분기 | riverpod test | `isAuthenticatedProvider` true/false 별 올바른 구현체 반환 |
| TimerNotifier | unit | start 시 idempotencyKey 발급, stop 성공 시 fuel/todo/list/today-stats invalidate, 실패 시 키 유지 |
| today_stats_provider | unit | 인증 = 서버 응답, 게스트 = 기존 로컬 계산 |
| Pagination | unit | page=0, totalPages-1 경계, endDate 미포함 반열림 |

`flutter analyze` 0 경고 + 모든 신규 테스트 통과를 verification 게이트로.

---

## 9. 마이그레이션 & 호환성

### 9.1 인증 모드 전환
- 기존 사용자가 로그인하면 → 그 순간부터 서버 권위, 이전 로컬 세션은 표시되지 않음 (별도 마이그레이션 없음, 본 이슈 범위 외)

### 9.2 게스트 모드
- 기존 동작 그대로 (변경 없음)

### 9.3 로그아웃 / 탈퇴
- 기존 fuel 패턴과 동일 위치에서 timer 캐시 invalidate 훅 호출

---

## 10. 위험 & 완화

| 위험 | 영향 | 완화 |
|------|------|------|
| 백그라운드 동기화 부재로 부정확 세션 → 서버 4xx 거절 | 사용자 데이터 손실 가능 | 본 이슈는 메시지 안내 + 로컬 캐시 임시 보관. 별도 이슈에서 백그라운드 보정 |
| 네트워크 실패 시 fuel 충전 누락 | 재시도 안 하면 영구 손실 | Idempotency-Key 유지 + 사용자 재시도 UI |
| Todo 가 인증 모드와 게스트 모드 사이에서 다른 ID 체계 | actualMinutes 누적 위치 모호 | 인증 모드는 서버 todoId, 게스트 모드는 로컬 todoId — repository 분기로 자연 격리 |
| 로컬 캐시와 서버 페이지네이션 결과 비일관 | UI 깜빡임 | 인증 모드에서는 서버 응답을 신뢰, 로컬 캐시는 폴백 전용 |

---

## 11. 다음 단계

1. 본 spec 사용자 리뷰 → 승인
2. `superpowers:writing-plans` 로 Phase/Task 분할 plan 작성 (`docs/superpowers/plans/2026-05-25-timer-api-integration-plan.md`)
3. plan 승인 후 execute-plan + TDD
4. verification → commit (메시지: `feat : Timer Remote DataSource·Repository 구현(server-first + Idempotency-Key) #<issue>`)
