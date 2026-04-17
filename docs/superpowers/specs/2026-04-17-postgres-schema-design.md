# PostgreSQL 스키마 설계 — Space Study Ship

**Date:** 2026-04-17
**Status:** Design
**Scope:** MVP(P0) 백엔드 데이터베이스 스키마 전체 + 실시간 친구 학습 상태 추적

---

## 1. 개요

Space Study Ship(우주공부선)은 우주 탐험 테마의 학습 게이미피케이션 Flutter 앱이다. 백엔드는 Spring Boot + PostgreSQL로 구현되며, 본 문서는 MVP 범위의 전체 DB 스키마와 친구 간 실시간 학습 상태 가시화 기능의 데이터 설계를 정의한다.

### 설계 목표

- API 스펙(`docs/api-specs/00~07`)이 요구하는 모든 데이터 요구사항 충족
- BCNF 원칙 준수하되, 읽기 빈도가 높은 경로는 성능 우선 denormalization 허용
- 모바일 환경(화면 OFF → WebSocket 단절) 특성을 고려한 실시간 전략
- Flyway 기반 마이그레이션으로 버전 관리
- MVP 단계에서 과도한 최적화(파티셔닝 등) 배제

### 범위

**In scope:**
- 14개 테이블 전체 DDL
- 인덱스 전략
- 친구 실시간 상태 추적 메커니즘
- 시드 데이터 관리 (행성·지역·뱃지)
- KST 타임존 고정 전략

**Out of scope (향후 별도 설계):**
- 파티셔닝 (`timer_sessions` 월별 파티션)
- 리드 리플리카 구성
- 백업·복원 정책
- 미션·우주선 컬렉션 등 P1 기능

---

## 2. 기반 결정사항

| 항목 | 결정 | 근거 |
|-----|-----|-----|
| DB 버전 | PostgreSQL 15+ | `GENERATED ALWAYS ... STORED`, GIN 인덱스 안정성 |
| 스키마 전략 | Flat (`public` 단일 스키마) | JPA 단순화, 교차 쿼리 부담 없음 |
| 타임존 | `TIMESTAMPTZ` 저장 + 날짜 경계는 `Asia/Seoul` | MVP는 국내 사용자 타겟. 해외 확장 시 유저별 TZ 마이그레이션 가능 |
| ID 규칙 | `BIGSERIAL`(users, friendships 등) / `UUID`(todos, sessions — 클라 생성 허용) / `VARCHAR`(badges, planets 등 seed) | API 스펙에 맞춤 |
| 삭제 정책 | Hard delete + CASCADE FK | API 스펙 `"cascading delete of all user data"` 준수. Firebase 삭제는 같은 서비스 트랜잭션에서 호출 |
| 실시간 전략 | Heartbeat + 30초 Polling (WebSocket 배제) | iOS 백그라운드에서 WebSocket 유지 불가, OS Doze 모드 등 고려 |
| 마이그레이션 | Flyway (`V{n}__*.sql`) | Spring Boot 표준, schema_version 자동 관리 |

### 실시간 전략 요약

```
[타이머 시작]
  POST /api/study-status (studying=true, todoId)
    → INSERT/UPDATE user_presence SET session_started_at=NOW(), last_heartbeat_at=NOW()

[앱 포그라운드 3분 주기]
  PATCH /api/study-status (heartbeat)
    → UPDATE user_presence SET last_heartbeat_at=NOW()

[타이머 종료]
  POST /api/study-status (studying=false) + POST /api/timer-sessions
    → UPDATE user_presence SET session_started_at=NULL

[친구 목록 화면 30초 polling]
  GET /api/friends
    → SELECT ... CASE
        WHEN session_started_at IS NOT NULL AND last_heartbeat < NOW()-'5 min'::interval THEN 'STUDYING'
        WHEN last_heartbeat > NOW()-'5 min'::interval THEN 'IDLE'
        ELSE 'OFFLINE'
      END
```

화면이 꺼져도 타이머는 클라이언트 로컬 `DateTime` 기반으로 정확하게 동작(참고: `.claude/rules/08_TIMER_ARCHITECTURE.md`). 서버 presence는 5분 이상 heartbeat가 끊기면 자동으로 OFFLINE 처리되어 친구 목록에서 자연스럽게 제거된다.

---

## 3. 테이블 스키마

총 14개 테이블. 카테고리별 분류.

```
인증 (2)        users, user_devices
프레즌스 (1)    user_presence
학습 (3)        todo_categories, todos, timer_sessions
연료 (2)        user_fuel, fuel_transactions
탐험 (2)        exploration_nodes, user_exploration_progress
뱃지 (2)        badges, user_badge_progress
소셜 (2)        friend_requests, friendships
```

### 3.1 인증

```sql
-- 1. users
CREATE TABLE users (
  id              BIGSERIAL PRIMARY KEY,
  nickname        VARCHAR(10) UNIQUE NOT NULL,
  social_platform VARCHAR(10) NOT NULL CHECK (social_platform IN ('GOOGLE','APPLE')),
  social_id       VARCHAR(255) NOT NULL,
  email           VARCHAR(255),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (social_platform, social_id)
);

-- 2. user_devices
CREATE TABLE user_devices (
  id            BIGSERIAL PRIMARY KEY,
  user_id       BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id     VARCHAR(255) NOT NULL,
  device_type   VARCHAR(10) NOT NULL CHECK (device_type IN ('IOS','ANDROID')),
  fcm_token     VARCHAR(255),
  refresh_token VARCHAR(512) NOT NULL,
  last_login_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, device_id)
);
```

### 3.2 실시간 프레즌스

```sql
-- 3. user_presence
--    session_started_at IS NOT NULL = 공부 중
--    last_heartbeat_at이 5분 이내 = 온라인
CREATE TABLE user_presence (
  user_id            BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  current_todo_id    UUID REFERENCES todos(id) ON DELETE SET NULL,
  session_started_at TIMESTAMPTZ,
  last_heartbeat_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 3.3 학습

```sql
-- 4. todo_categories
CREATE TABLE todo_categories (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name       VARCHAR(20) NOT NULL,
  icon_id    VARCHAR(50),
  position_x DOUBLE PRECISION CHECK (position_x BETWEEN 0 AND 1),
  position_y DOUBLE PRECISION CHECK (position_y BETWEEN 0 AND 1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 5. todos
--    DENORMALIZATION: 배열 컬럼 + actual_minutes 캐시 (성능)
CREATE TABLE todos (
  id                UUID PRIMARY KEY,
  user_id           BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title             VARCHAR(100) NOT NULL CHECK (length(title) >= 1),
  scheduled_dates   DATE[] NOT NULL DEFAULT '{}',
  completed_dates   DATE[] NOT NULL DEFAULT '{}',
  category_ids      UUID[] NOT NULL DEFAULT '{}',
  estimated_minutes INTEGER CHECK (estimated_minutes >= 0),
  actual_minutes    INTEGER NOT NULL DEFAULT 0 CHECK (actual_minutes >= 0),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. timer_sessions (append-only)
--    todo_title은 스냅샷(BCNF 위반 아님: 시점별로 다른 값 가능)
CREATE TABLE timer_sessions (
  id               UUID PRIMARY KEY,
  user_id          BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  todo_id          UUID REFERENCES todos(id) ON DELETE SET NULL,
  todo_title       VARCHAR(100),
  started_at       TIMESTAMPTZ NOT NULL,
  ended_at         TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL CHECK (duration_minutes BETWEEN 1 AND 1440),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (started_at < ended_at)
);
```

**`todos.actual_minutes` 유지 정책**
- `POST /api/timer-sessions` 저장 시 동일 트랜잭션 내에서 `UPDATE todos SET actual_minutes = actual_minutes + ? WHERE id = ?` 실행
- `todo_id` 없이 저장된 세션은 `actual_minutes` 변경 없음
- Todo 삭제 시 CASCADE로 자연스럽게 함께 삭제

**`todos` 배열 컬럼 유지 정책**
- `scheduled_dates`, `completed_dates`, `category_ids`는 API 스펙 그대로 배열 유지
- GIN 인덱스로 `date = ANY(...)`, `uuid = ANY(...)` 쿼리 최적화
- `todo_categories` 삭제 시 서비스 레이어에서 `UPDATE todos SET category_ids = array_remove(category_ids, ?) WHERE ? = ANY(category_ids)` 호출하여 일관성 유지

### 3.4 연료

```sql
-- 7. user_fuel (1:1 with users)
--    current_fuel은 GENERATED 컬럼 — BCNF 준수 + 쓰기 비용 0
CREATE TABLE user_fuel (
  user_id         BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_charged   INTEGER NOT NULL DEFAULT 0 CHECK (total_charged >= 0),
  total_consumed  INTEGER NOT NULL DEFAULT 0 CHECK (total_consumed >= 0),
  current_fuel    INTEGER GENERATED ALWAYS AS (total_charged - total_consumed) STORED,
  pending_minutes INTEGER NOT NULL DEFAULT 0,
  last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (total_charged >= total_consumed)
);

-- 8. fuel_transactions
--    balance_after는 시점별 스냅샷(시간 축 덕분에 같은 user_id 여러 값 가능 → BCNF OK)
CREATE TABLE fuel_transactions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type           VARCHAR(10) NOT NULL CHECK (type IN ('charge','consume')),
  amount         INTEGER NOT NULL CHECK (amount > 0),
  reason         VARCHAR(30) NOT NULL CHECK (reason IN ('STUDY_SESSION','EXPLORATION_UNLOCK')),
  reference_id   VARCHAR(50) NOT NULL,
  balance_after  INTEGER NOT NULL CHECK (balance_after >= 0),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**원자성 보장**: 타이머 세션 저장 또는 탐험 해금 시 한 트랜잭션 안에서 다음 3개 DML을 묶는다:
1. `INSERT INTO timer_sessions` (또는 `INSERT INTO user_exploration_progress`)
2. `UPDATE user_fuel SET total_charged|total_consumed = ... + ?`
3. `INSERT INTO fuel_transactions ...`

### 3.5 탐험

```sql
-- 9. exploration_nodes (seed data, BCNF 준수: depth 제거)
CREATE TABLE exploration_nodes (
  id            VARCHAR(50) PRIMARY KEY,
  name          VARCHAR(50) NOT NULL,
  node_type     VARCHAR(10) NOT NULL CHECK (node_type IN ('planet','region')),
  icon          VARCHAR(20) NOT NULL,
  parent_id     VARCHAR(50) REFERENCES exploration_nodes(id),
  required_fuel INTEGER NOT NULL DEFAULT 0 CHECK (required_fuel >= 0),
  sort_order    INTEGER NOT NULL DEFAULT 0,
  description   VARCHAR(200),
  map_x         DOUBLE PRECISION NOT NULL CHECK (map_x BETWEEN 0 AND 1),
  map_y         DOUBLE PRECISION NOT NULL CHECK (map_y BETWEEN 0 AND 1),
  CHECK (
    (node_type = 'planet' AND parent_id IS NULL) OR
    (node_type = 'region' AND parent_id IS NOT NULL)
  )
);
-- depth는 응답 시 CASE WHEN node_type='planet' THEN 2 ELSE 3 END 로 계산

-- 10. user_exploration_progress (BCNF: boolean 제거, 행 존재 자체가 unlocked)
CREATE TABLE user_exploration_progress (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  node_id     VARCHAR(50) NOT NULL REFERENCES exploration_nodes(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, node_id)
);
-- is_unlocked = 행 존재 여부
-- is_cleared (region) = 행 존재 여부 (region은 해금=클리어)
-- is_cleared (planet) = 모든 자식 region의 progress 행이 존재
```

### 3.6 뱃지

```sql
-- 11. badges (seed data)
CREATE TABLE badges (
  id             VARCHAR(50) PRIMARY KEY,
  name           VARCHAR(50) NOT NULL,
  icon           VARCHAR(50) NOT NULL,
  description    VARCHAR(200) NOT NULL,
  category       VARCHAR(20) NOT NULL
                 CHECK (category IN ('STUDY_TIME','STREAK','SESSION','EXPLORATION','FUEL','HIDDEN')),
  rarity         VARCHAR(10) NOT NULL
                 CHECK (rarity IN ('NORMAL','RARE','EPIC','LEGENDARY','HIDDEN')),
  required_value INTEGER NOT NULL DEFAULT 0
);

-- 12. user_badge_progress
CREATE TABLE user_badge_progress (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_id    VARCHAR(50) NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_new      BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (user_id, badge_id)
);
```

`is_new`에 관한 현 API 스펙의 공백: 컬럼은 존재한다고 명시됐지만, 이를 false로 변경하는 엔드포인트는 정의되지 않았다. 구현 시 두 가지 선택지:
1. `PATCH /api/badges/acknowledge` 엔드포인트 신설 — 서버가 "new" 상태를 관리
2. 클라이언트가 본 뱃지 ID 목록을 로컬에 보관 — 서버는 `is_new` 컬럼 제거

본 스키마는 API 스펙 원문 준수를 위해 컬럼을 유지한다. 구현 단계에서 결정.

### 3.7 소셜

```sql
-- 13. friend_requests
CREATE TABLE friend_requests (
  id           BIGSERIAL PRIMARY KEY,
  from_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  to_user_id   BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status       VARCHAR(10) NOT NULL
               CHECK (status IN ('PENDING','ACCEPTED','REJECTED','CANCELLED')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (from_user_id <> to_user_id)
);

-- 14. friendships (양방향 저장: A→B, B→A 두 행)
CREATE TABLE friendships (
  id             BIGSERIAL PRIMARY KEY,
  user_id        BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  friend_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, friend_user_id),
  CHECK (user_id <> friend_user_id)
);
```

친구 수락 시 서비스 레이어에서 동일 트랜잭션으로 두 행 INSERT:
```sql
INSERT INTO friendships (user_id, friend_user_id) VALUES
  ($from_user_id, $to_user_id),
  ($to_user_id, $from_user_id);
UPDATE friend_requests SET status = 'ACCEPTED', updated_at = NOW() WHERE id = $request_id;
```

---

## 4. 인덱스 전략

```sql
-- users
CREATE UNIQUE INDEX idx_users_nickname ON users(nickname);
CREATE UNIQUE INDEX idx_users_social ON users(social_platform, social_id);

-- user_devices
CREATE UNIQUE INDEX idx_user_devices_user_device ON user_devices(user_id, device_id);
CREATE INDEX idx_user_devices_refresh_token ON user_devices(refresh_token);

-- user_presence (Partial: 공부 중인 사용자만)
CREATE INDEX idx_user_presence_heartbeat ON user_presence(last_heartbeat_at)
  WHERE session_started_at IS NOT NULL;

-- todo_categories
CREATE INDEX idx_todo_categories_user ON todo_categories(user_id);

-- todos (GIN for arrays)
CREATE INDEX idx_todos_user ON todos(user_id, created_at DESC);
CREATE INDEX idx_todos_scheduled_gin ON todos USING GIN (scheduled_dates);
CREATE INDEX idx_todos_completed_gin ON todos USING GIN (completed_dates);
CREATE INDEX idx_todos_categories_gin ON todos USING GIN (category_ids);

-- timer_sessions
CREATE INDEX idx_timer_sessions_user_started ON timer_sessions(user_id, started_at DESC);
CREATE INDEX idx_timer_sessions_todo ON timer_sessions(todo_id) WHERE todo_id IS NOT NULL;

-- fuel_transactions
CREATE INDEX idx_fuel_tx_user_created ON fuel_transactions(user_id, created_at DESC);
CREATE INDEX idx_fuel_tx_user_type ON fuel_transactions(user_id, type, created_at DESC);

-- exploration_nodes
CREATE INDEX idx_exploration_parent_sort ON exploration_nodes(parent_id, sort_order);

-- user_exploration_progress
CREATE UNIQUE INDEX idx_exploration_progress_user_node ON user_exploration_progress(user_id, node_id);

-- badges
CREATE INDEX idx_badges_category_rarity ON badges(category, rarity, required_value);

-- user_badge_progress (Partial: 신규 뱃지만)
CREATE UNIQUE INDEX idx_badge_progress_user_badge ON user_badge_progress(user_id, badge_id);
CREATE INDEX idx_badge_progress_user_new ON user_badge_progress(user_id)
  WHERE is_new = TRUE;

-- friend_requests (Partial: PENDING만 unique)
CREATE UNIQUE INDEX idx_friend_requests_pending
  ON friend_requests(from_user_id, to_user_id) WHERE status = 'PENDING';
CREATE INDEX idx_friend_requests_received
  ON friend_requests(to_user_id, status, created_at DESC) WHERE status = 'PENDING';

-- friendships
CREATE UNIQUE INDEX idx_friendships_user_friend ON friendships(user_id, friend_user_id);
```

**인덱스 설계 원칙**
- 복합 인덱스 컬럼 순서는 쿼리의 `WHERE` + `ORDER BY` 패턴과 일치
- Partial 인덱스 적극 활용: PENDING 요청, 신규 뱃지, 공부 중인 사용자
- GIN 인덱스: `DATE[]`, `UUID[]` 컬럼의 `= ANY(...)` 쿼리
- FK 컬럼 자동 인덱스 없음 → 조회 패턴 있는 컬럼만 명시적 추가

---

## 5. 실시간 쿼리 패턴

### 5.1 Heartbeat 최초 진입 (타이머 시작)

```sql
INSERT INTO user_presence (user_id, current_todo_id, session_started_at, last_heartbeat_at)
VALUES ($1, $2, NOW(), NOW())
ON CONFLICT (user_id) DO UPDATE SET
  current_todo_id    = EXCLUDED.current_todo_id,
  session_started_at = NOW(),
  last_heartbeat_at  = NOW();
```

### 5.2 Heartbeat 주기 갱신 (3분마다)

```sql
UPDATE user_presence SET last_heartbeat_at = NOW() WHERE user_id = $1;
```

### 5.3 타이머 종료

```sql
UPDATE user_presence
SET session_started_at = NULL, current_todo_id = NULL, last_heartbeat_at = NOW()
WHERE user_id = $1;
```

### 5.4 친구 목록 + 실시간 상태 (핵심)

```sql
WITH friend_ids AS (
  SELECT friend_user_id FROM friendships WHERE user_id = $1
),
weekly AS (
  SELECT user_id, SUM(duration_minutes) AS weekly_minutes
  FROM timer_sessions
  WHERE user_id IN (SELECT friend_user_id FROM friend_ids)
    AND started_at >= date_trunc('week', NOW() AT TIME ZONE 'Asia/Seoul')
                      AT TIME ZONE 'Asia/Seoul'
  GROUP BY user_id
)
SELECT
  u.id           AS user_id,
  u.nickname,
  CASE
    WHEN p.session_started_at IS NOT NULL
     AND p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'STUDYING'
    WHEN p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'IDLE'
    ELSE 'OFFLINE'
  END AS status,
  CASE
    WHEN p.session_started_at IS NOT NULL
     THEN EXTRACT(EPOCH FROM (NOW() - p.session_started_at))/60
    ELSE NULL
  END AS study_duration_minutes,
  t.title          AS current_subject,
  COALESCE(w.weekly_minutes, 0) AS weekly_study_duration_minutes
FROM users u
LEFT JOIN user_presence p ON p.user_id = u.id
LEFT JOIN todos t         ON t.id = p.current_todo_id
LEFT JOIN weekly w        ON w.user_id = u.id
WHERE u.id IN (SELECT friend_user_id FROM friend_ids)
ORDER BY
  CASE status WHEN 'STUDYING' THEN 1 WHEN 'IDLE' THEN 2 ELSE 3 END,
  weekly_study_duration_minutes DESC;
```

### 5.5 랭킹 (DAILY 예시)

```sql
WITH scope AS (
  SELECT $1::BIGINT AS id
  UNION
  SELECT friend_user_id FROM friendships WHERE user_id = $1
),
period_start AS (
  SELECT date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul' AS ts
)
SELECT
  u.id,
  u.nickname,
  COALESCE(SUM(s.duration_minutes), 0) AS study_duration_minutes,
  RANK() OVER (ORDER BY COALESCE(SUM(s.duration_minutes), 0) DESC, u.id ASC) AS rank
FROM scope c
JOIN users u ON u.id = c.id
LEFT JOIN timer_sessions s
  ON s.user_id = u.id AND s.started_at >= (SELECT ts FROM period_start)
GROUP BY u.id, u.nickname;
```

WEEKLY/MONTHLY는 `date_trunc('week', ...)` / `date_trunc('month', ...)` 로 치환.

### 5.6 오늘 할 일 조회 (GIN 인덱스 활용)

```sql
SELECT *
FROM todos
WHERE user_id = $1 AND $2::DATE = ANY(scheduled_dates)
ORDER BY created_at DESC;
```

### 5.7 Today stats (타이머 화면용)

```sql
WITH today_sessions AS (
  SELECT duration_minutes
  FROM timer_sessions
  WHERE user_id = $1
    AND started_at >= date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul'
),
streak AS (
  SELECT COUNT(*) AS days
  FROM (
    SELECT DISTINCT (started_at AT TIME ZONE 'Asia/Seoul')::DATE AS study_date
    FROM timer_sessions
    WHERE user_id = $1
  ) d
  WHERE study_date >= CURRENT_DATE - INTERVAL '365 days'
  -- 실제 streak 로직은 서비스 레이어에서 연속 계산
)
SELECT
  COALESCE(SUM(duration_minutes), 0) AS total_minutes,
  COUNT(*) AS session_count
FROM today_sessions;
```

연속 일수(streak) 로직은 쿼리로 표현하기 복잡하므로 서비스 레이어에서 날짜 리스트를 받아 계산하는 편이 명확하다.

---

## 6. 시드 데이터 & 마이그레이션

### 디렉토리 구조

```
src/main/resources/db/migration/
├── V1__init_schema.sql                # 모든 DDL (14 tables + indexes)
├── V2__seed_exploration_nodes.sql     # 행성 + 지역 (~50 rows)
├── V3__seed_badges.sql                # 뱃지 (~30 rows)
└── V4__...                            # 이후 스키마·시드 변경
```

### 원칙

- `V{n}__*.sql` 버전 순차 적용. **배포된 마이그레이션은 수정 금지**.
- 시드 데이터 업데이트는 새 마이그레이션에서 `INSERT ... ON CONFLICT (id) DO UPDATE SET ...` 멱등 패턴 사용.
- Flyway `schema_version` 테이블이 배포 상태 자동 관리.

### 시드 데이터 예시

`V2__seed_exploration_nodes.sql`:
```sql
INSERT INTO exploration_nodes (id, name, node_type, icon, parent_id, required_fuel, sort_order, description, map_x, map_y) VALUES
  ('earth',     '지구',   'planet', 'earth', NULL, 0,     1, '공부 탐험의 시작점', 0.5, 0.5),
  ('mars',      '화성',   'planet', 'mars',  NULL, 100,   2, '붉은 행성', 0.7, 0.3),
  ('region-kr', '한국',   'region', 'kr',    'earth', 0,  1, '대한민국', 0.55, 0.45),
  -- ...
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  icon = EXCLUDED.icon,
  required_fuel = EXCLUDED.required_fuel,
  sort_order = EXCLUDED.sort_order,
  description = EXCLUDED.description,
  map_x = EXCLUDED.map_x,
  map_y = EXCLUDED.map_y;
```

---

## 7. 성능 및 운영 지침

| 항목 | 값 | 비고 |
|-----|-----|-----|
| 커넥션 풀 | HikariCP `maximum-pool-size: 10` | Spring Boot 기본값, 사용자 < 1만 기준 충분 |
| 쿼리 타임아웃 | 5초 | 랭킹 등 복잡 쿼리 대응 |
| Heartbeat 클라이언트 주기 | 3분 | 포그라운드 기준 |
| Heartbeat OFFLINE 판정 | 5분 | 3분 주기의 여유치 |
| 친구 목록 폴링 주기 | 30초 | 클라이언트 |
| 리드 리플리카 | 불필요 | 사용자 > 10,000 도달 시 ranking 전용 리플리카 검토 |
| 파티셔닝 | 불필요 | `timer_sessions` 10M rows 도달 시 월별 파티션 검토 |

### 탈퇴 플로우

**순서: Firebase 삭제 → DB 삭제.** 각 단계의 실패 시나리오:

1. **Firebase 삭제 호출** (Spring Boot Firebase Admin SDK)
   - 실패 시: 아직 DB 손대지 않음. 에러 반환, 사용자 재시도 가능.
2. **DB 트랜잭션 시작 → `DELETE FROM users WHERE id = ?`** (CASCADE 전파)
   - 실패 시: 사용자는 Firebase 계정이 이미 삭제돼 재로그인 불가. DB에는 고아 행 존재. 별도 배치 잡으로 청소.

**반대 순서(DB 먼저)를 피하는 이유**: DB 삭제 성공 + Firebase 삭제 실패 시, 사용자가 Firebase로 재로그인하면 서버는 유효한 ID Token을 받지만 `users` 테이블에 행이 없어 혼란 발생(자동 회원가입 로직 오작동 등). Firebase 먼저 지우면 이 경로가 원천 차단된다.

---

## 8. BCNF 감사 결과 요약

| 테이블 | 정규화 상태 | 비고 |
|-------|-----|-----|
| users | BCNF ✓ | |
| user_devices | BCNF ✓ | |
| user_presence | BCNF ✓ | `is_studying` boolean 제거, `session_started_at IS NULL` 로 표현 |
| todo_categories | BCNF ✓ | |
| todos | **Denormalized (의도적)** | 배열 컬럼 + `actual_minutes` 캐시 — 읽기 빈도 우선 |
| timer_sessions | BCNF ✓ | `todo_title` 스냅샷은 시점별 다른 값 허용 → FD 아님 |
| user_fuel | BCNF ✓ | `current_fuel`을 GENERATED 컬럼으로 해결 |
| fuel_transactions | BCNF ✓ | `balance_after`는 시점별 스냅샷 |
| exploration_nodes | BCNF ✓ | `depth` 제거, 쿼리에서 `CASE` 로 계산 |
| user_exploration_progress | BCNF ✓ | `is_unlocked`/`is_cleared` boolean 제거, 행 존재로 표현 |
| badges | BCNF ✓ | |
| user_badge_progress | BCNF ✓ | |
| friend_requests | BCNF ✓ | |
| friendships | BCNF ✓ | 양방향 저장은 denormalization이 아닌 설계 선택 |

---

## 9. 향후 고려사항

### MVP 이후 확장

- **파티셔닝**: `timer_sessions`가 10M rows 넘으면 `started_at` 기준 월별 RANGE 파티션
- **리드 리플리카**: 랭킹 쿼리 전용 slave 분리 (사용자 > 10k)
- **해외 확장 시 타임존**: `users.timezone VARCHAR(32)` 추가 + KST 하드코딩 부분 치환
- **Soft delete**: 법적 감사 요건 발생 시 `deleted_at` 도입 검토
- **Materialized view**: 주간 누적 랭킹을 materialized view로 캐시 (5분 주기 refresh)

### API 스펙과의 연결

본 문서는 `docs/api-specs/00_common.md` ~ `07_social.md` 에 정의된 모든 엔드포인트를 수용한다.
- 신규 컬럼/테이블 추가 시 반드시 API 스펙 동기화 필요
- 본 문서에서 추가 엔드포인트를 암시한 부분:
  - `PATCH /api/badges/{id}/acknowledge` (is_new 플래그 끄기) — 현재 스펙 없음, 클라이언트가 자체 추적 시 생략 가능
  - `POST /api/study-status`, `PATCH /api/study-status` (presence heartbeat) — 현재 스펙 없음, 별도 설계 필요

---

## 10. 참고

- API 스펙: `docs/api-specs/`
- 타이머 알고리즘: `.claude/rules/08_TIMER_ARCHITECTURE.md`
- 아키텍처 가이드: `.claude/rules/01_ARCHITECTURE.md`
