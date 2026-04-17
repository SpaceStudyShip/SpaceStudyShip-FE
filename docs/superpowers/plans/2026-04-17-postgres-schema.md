# PostgreSQL Schema Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Space Study Ship 백엔드용 PostgreSQL 스키마 14개 테이블, 인덱스, 시드 데이터를 Flyway 마이그레이션 파일로 구현하고 Docker + psql로 TDD 검증한다.

**Architecture:** `db/migration/V1__init_schema.sql`에 전체 DDL + 인덱스, `V2`/`V3`에 시드 데이터를 작성. `db/test/*.sql`로 각 도메인별 검증. Docker Compose로 로컬 Postgres 15를 띄우고 `db/scripts/reset.sh`로 migrate, `db/scripts/test.sh`로 테스트.

**Tech Stack:** PostgreSQL 15, Flyway-compatible SQL migrations, Docker Compose, bash + psql (테스트 러너, 외부 의존성 없음).

**Reference Spec:** `docs/superpowers/specs/2026-04-17-postgres-schema-design.md`

**브랜치 권고:** 현재 브랜치(`20260412_#67_소셜_화면_UI_UX_구체화`)는 Flutter 소셜 UI 작업 중. DB 스키마는 별개 영역이므로 `feat/db-schema-initial` 같은 새 브랜치에서 작업 권장.

---

## 📁 File Structure

**생성될 디렉토리/파일:**
```
db/
├── README.md                         # 사용법 문서
├── docker-compose.db.yml             # Postgres 15 컨테이너
├── migration/
│   ├── V1__init_schema.sql           # 14 tables + ~25 indexes
│   ├── V2__seed_exploration_nodes.sql
│   └── V3__seed_badges.sql
├── scripts/
│   ├── reset.sh                      # DB 초기화 + migrate
│   └── test.sh                       # 전체 테스트 실행
└── test/
    ├── 01_auth.sql                   # users + user_devices
    ├── 02_presence.sql               # user_presence
    ├── 03_todos.sql                  # todo_categories + todos
    ├── 04_timer.sql                  # timer_sessions
    ├── 05_fuel.sql                   # user_fuel + fuel_transactions
    ├── 06_exploration.sql            # exploration_nodes + progress
    ├── 07_badges.sql                 # badges + progress
    ├── 08_social.sql                 # friend_requests + friendships
    ├── 09_indexes.sql                # 인덱스 존재 확인
    ├── 10_seeds.sql                  # 시드 데이터 존재 확인
    └── 11_realtime_queries.sql       # 친구 목록 + 랭킹 쿼리
```

**책임 분리:**
- `migration/`: Flyway 버전 마이그레이션만. 배포된 파일은 수정 금지.
- `scripts/`: 로컬 개발 편의 스크립트. 프로덕션과 무관.
- `test/`: 각 파일은 `BEGIN ... ROLLBACK`으로 격리. 같은 DB에서 순차 실행 가능.

---

## Phase 1: 인프라 셋업

### Task 1: Docker Compose + 프로젝트 구조

**Files:**
- Create: `db/docker-compose.db.yml`
- Create: `db/README.md`
- Create: `db/migration/` (빈 디렉토리)
- Create: `db/scripts/` (빈 디렉토리)
- Create: `db/test/` (빈 디렉토리)

- [ ] **Step 1: `db/docker-compose.db.yml` 작성**

```yaml
services:
  postgres:
    image: postgres:15-alpine
    container_name: spacestudyship_postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: spacestudyship
      TZ: Asia/Seoul
    ports:
      - "5432:5432"
    volumes:
      - ./migration:/db/migration:ro
      - ./test:/db/test:ro
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d spacestudyship"]
      interval: 2s
      timeout: 2s
      retries: 10

volumes:
  postgres_data:
```

- [ ] **Step 2: `db/README.md` 작성**

```markdown
# Database Schema

Space Study Ship 백엔드용 PostgreSQL 스키마.

## 로컬 실행

```bash
cd db
docker compose -f docker-compose.db.yml up -d
./scripts/reset.sh    # 스키마 초기화 + 마이그레이션
./scripts/test.sh     # 전체 테스트
```

## 디렉토리

- `migration/V*.sql` — Flyway 호환 마이그레이션
- `test/*.sql` — 도메인별 검증 스크립트 (BEGIN/ROLLBACK 격리)
- `scripts/` — 로컬 편의 스크립트

## 참고

- 설계 스펙: `../docs/superpowers/specs/2026-04-17-postgres-schema-design.md`
- API 스펙: `../docs/api-specs/`
```

- [ ] **Step 3: 디렉토리 생성 및 컨테이너 기동**

```bash
mkdir -p db/migration db/scripts db/test
cd db
docker compose -f docker-compose.db.yml up -d
docker compose -f docker-compose.db.yml ps
```

Expected: `spacestudyship_postgres` 컨테이너가 healthy 상태.

- [ ] **Step 4: Postgres 연결 확인**

```bash
docker exec spacestudyship_postgres psql -U postgres -d spacestudyship -c "SELECT version();"
```

Expected: `PostgreSQL 15.x ...` 출력.

- [ ] **Step 5: 커밋**

```bash
git add db/docker-compose.db.yml db/README.md
git commit -m "chore : DB 스키마 작업용 Docker Compose 환경 구성"
```

---

### Task 2: Reset + Test 스크립트

**Files:**
- Create: `db/scripts/reset.sh`
- Create: `db/scripts/test.sh`

- [ ] **Step 1: `db/scripts/reset.sh` 작성**

```bash
#!/usr/bin/env bash
# DB를 깨끗이 초기화하고 모든 마이그레이션을 순차 적용한다.
set -euo pipefail

CONTAINER=spacestudyship_postgres
DB=spacestudyship

echo "==> Drop & recreate database"
docker exec -i "$CONTAINER" psql -U postgres -d postgres <<SQL
DROP DATABASE IF EXISTS $DB;
CREATE DATABASE $DB;
SQL

echo "==> Apply migrations in order"
for f in $(ls db/migration/V*.sql | sort); do
  echo "--- applying $f"
  docker exec -i "$CONTAINER" psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 < "$f"
done

echo "==> Done"
```

- [ ] **Step 2: `db/scripts/test.sh` 작성**

```bash
#!/usr/bin/env bash
# db/test/*.sql 전체를 순차 실행하고 실패 시 종료.
set -euo pipefail

CONTAINER=spacestudyship_postgres
DB=spacestudyship

shopt -s nullglob
FILES=(db/test/*.sql)
if [ ${#FILES[@]} -eq 0 ]; then
  echo "No test files found in db/test/"
  exit 0
fi

for f in $(ls db/test/*.sql | sort); do
  echo "==> Running $f"
  docker exec -i "$CONTAINER" psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 < "$f"
done

echo ""
echo "✓ All tests passed"
```

- [ ] **Step 3: 실행 권한 부여 및 확인**

```bash
chmod +x db/scripts/reset.sh db/scripts/test.sh
./db/scripts/reset.sh
```

Expected: `Done` 출력. 에러 없어야 함 (아직 마이그레이션 파일 없지만 for 루프가 빈 glob에서 중단될 수 있음).

- [ ] **Step 4: 빈 마이그레이션 디렉토리 대응 — reset.sh 수정**

이전 step에서 `ls db/migration/V*.sql`이 빈 경우 에러. 수정:

```bash
#!/usr/bin/env bash
set -euo pipefail

CONTAINER=spacestudyship_postgres
DB=spacestudyship

echo "==> Drop & recreate database"
docker exec -i "$CONTAINER" psql -U postgres -d postgres <<SQL
DROP DATABASE IF EXISTS $DB;
CREATE DATABASE $DB;
SQL

shopt -s nullglob
MIGRATIONS=(db/migration/V*.sql)

if [ ${#MIGRATIONS[@]} -eq 0 ]; then
  echo "==> No migrations to apply"
else
  echo "==> Apply migrations in order"
  for f in $(ls db/migration/V*.sql | sort); do
    echo "--- applying $f"
    docker exec -i "$CONTAINER" psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 < "$f"
  done
fi

echo "==> Done"
```

- [ ] **Step 5: 재실행 검증**

```bash
./db/scripts/reset.sh
```

Expected: `No migrations to apply` + `Done`.

- [ ] **Step 6: 커밋**

```bash
git add db/scripts/
git commit -m "chore : DB reset/test 스크립트 추가"
```

---

## Phase 2: 스키마 테이블 (도메인별 TDD)

> 각 Task는 **같은 `V1__init_schema.sql` 파일을 증분 추가**하는 방식으로 진행한다. Flyway 버전 1은 한 파일에 모든 DDL을 모으는 것이 표준.

### Task 3: 인증 도메인 (users + user_devices)

**Files:**
- Create: `db/migration/V1__init_schema.sql`
- Create: `db/test/01_auth.sql`

- [ ] **Step 1: `db/test/01_auth.sql` 작성 (RED)**

```sql
-- Test: users + user_devices 스키마 검증
BEGIN;

-- T1: users 테이블에 유효 행 삽입
INSERT INTO users (nickname, social_platform, social_id, email)
VALUES ('luca', 'GOOGLE', 'firebase-uid-1', 'luca@example.com');

-- T2: 닉네임 중복 거부
DO $$ BEGIN
  BEGIN
    INSERT INTO users (nickname, social_platform, social_id)
    VALUES ('luca', 'APPLE', 'firebase-uid-2');
    RAISE EXCEPTION 'FAIL: duplicate nickname must be rejected';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: nickname unique';
  END;
END $$;

-- T3: (social_platform, social_id) 복합 유니크
DO $$ BEGIN
  BEGIN
    INSERT INTO users (nickname, social_platform, social_id)
    VALUES ('other', 'GOOGLE', 'firebase-uid-1');
    RAISE EXCEPTION 'FAIL: duplicate social identity must be rejected';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: social identity unique';
  END;
END $$;

-- T4: social_platform CHECK
DO $$ BEGIN
  BEGIN
    INSERT INTO users (nickname, social_platform, social_id)
    VALUES ('hacker', 'FACEBOOK', 'uid-x');
    RAISE EXCEPTION 'FAIL: invalid social_platform must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: social_platform check';
  END;
END $$;

-- T5: user_devices 삽입
INSERT INTO user_devices (user_id, device_id, device_type, fcm_token, refresh_token)
VALUES (
  (SELECT id FROM users WHERE nickname = 'luca'),
  'device-1', 'IOS', 'fcm-token-x', 'refresh-token-x'
);

-- T6: users 삭제 시 user_devices CASCADE
DELETE FROM users WHERE nickname = 'luca';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM user_devices) != 0 THEN
    RAISE EXCEPTION 'FAIL: user_devices should be CASCADE-deleted';
  END IF;
  RAISE NOTICE 'PASS: CASCADE delete works';
END $$;

ROLLBACK;
SELECT '01_auth.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: `relation "users" does not exist` 에러로 실패.

- [ ] **Step 3: `db/migration/V1__init_schema.sql` 에 auth 도메인 DDL 추가**

```sql
-- =============================================================================
-- V1: Space Study Ship 초기 스키마
-- PostgreSQL 15+, 타임존: Asia/Seoul (날짜 경계 계산에만 사용)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. 인증 도메인
-- -----------------------------------------------------------------------------
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

- [ ] **Step 4: 마이그레이션 재적용 → 테스트 통과 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: 모든 `PASS:` NOTICE 출력 + `01_auth.sql: ALL PASS`.

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/01_auth.sql
git commit -m "feat : users, user_devices 테이블 + 제약조건 검증"
```

---

### Task 4: 학습 도메인 (todo_categories + todos)

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/03_todos.sql`

> Note: `user_presence`는 `todos`에 FK 있으므로 todos 생성 후 Task 5에서 만든다. 파일 번호는 도메인 성격 반영 (03_todos, 02_presence).

- [ ] **Step 1: `db/test/03_todos.sql` 작성 (RED)**

```sql
BEGIN;

INSERT INTO users (nickname, social_platform, social_id)
VALUES ('todoer', 'GOOGLE', 'uid-todo-1') RETURNING id \gset user_

-- T1: todo_categories 삽입
INSERT INTO todo_categories (name, user_id, position_x, position_y)
VALUES ('수학', :user_id, 0.3, 0.4)
RETURNING id \gset cat_

-- T2: position 범위 CHECK
DO $$ BEGIN
  BEGIN
    INSERT INTO todo_categories (name, user_id, position_x, position_y)
    VALUES ('invalid', :'user_id'::BIGINT, 1.5, 0.5);
    RAISE EXCEPTION 'FAIL: position_x out of range must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: position range check';
  END;
END $$;

-- T3: todos 삽입 (배열 컬럼 포함)
INSERT INTO todos (id, user_id, title, scheduled_dates, completed_dates, category_ids, estimated_minutes)
VALUES (
  gen_random_uuid(), :user_id, '미적분 복습',
  ARRAY['2026-04-17'::DATE, '2026-04-18'::DATE],
  ARRAY['2026-04-17'::DATE],
  ARRAY[:'cat_id'::UUID],
  60
);

-- T4: 빈 title 거부
DO $$ BEGIN
  BEGIN
    INSERT INTO todos (id, user_id, title) VALUES (gen_random_uuid(), :'user_id'::BIGINT, '');
    RAISE EXCEPTION 'FAIL: empty title must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: title length check';
  END;
END $$;

-- T5: actual_minutes 기본값 0
DO $$ BEGIN
  IF (SELECT actual_minutes FROM todos WHERE title = '미적분 복습') != 0 THEN
    RAISE EXCEPTION 'FAIL: actual_minutes default should be 0';
  END IF;
  RAISE NOTICE 'PASS: actual_minutes default';
END $$;

-- T6: 배열 contains 쿼리
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM todos WHERE '2026-04-17'::DATE = ANY(scheduled_dates)) THEN
    RAISE EXCEPTION 'FAIL: date contains query failed';
  END IF;
  RAISE NOTICE 'PASS: date contains query';
END $$;

-- T7: user 삭제 시 todos, todo_categories CASCADE
DELETE FROM users WHERE nickname = 'todoer';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM todos) != 0 THEN
    RAISE EXCEPTION 'FAIL: todos should CASCADE';
  END IF;
  IF (SELECT COUNT(*) FROM todo_categories) != 0 THEN
    RAISE EXCEPTION 'FAIL: todo_categories should CASCADE';
  END IF;
  RAISE NOTICE 'PASS: todos + categories CASCADE';
END $$;

ROLLBACK;
SELECT '03_todos.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: `relation "todo_categories" does not exist` 실패.

- [ ] **Step 3: `db/migration/V1__init_schema.sql` 에 todo 도메인 DDL 추가**

```sql
-- -----------------------------------------------------------------------------
-- 2. 학습 도메인 (Todo)
-- -----------------------------------------------------------------------------
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

-- Denormalized by design: DATE[]/UUID[] 배열로 API 스펙 준수 + GIN 인덱스
-- actual_minutes는 timer_sessions 저장 시 서비스 레이어에서 누적 업데이트
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
```

- [ ] **Step 4: 재적용 → 테스트 통과 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: 01_auth + 03_todos 둘 다 PASS.

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/03_todos.sql
git commit -m "feat : todo_categories, todos 테이블 + 배열·CASCADE 검증"
```

---

### Task 5: 프레즌스 (user_presence)

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/02_presence.sql`

- [ ] **Step 1: `db/test/02_presence.sql` 작성 (RED)**

```sql
BEGIN;

INSERT INTO users (nickname, social_platform, social_id)
VALUES ('studier', 'GOOGLE', 'uid-p-1') RETURNING id \gset user_

INSERT INTO todos (id, user_id, title)
VALUES (gen_random_uuid(), :user_id, '코딩 연습')
RETURNING id \gset todo_

-- T1: 초기 삽입 (공부 안 하는 상태)
INSERT INTO user_presence (user_id, last_heartbeat_at)
VALUES (:user_id, NOW());

-- T2: 타이머 시작 (공부 중 전환) — UPSERT
INSERT INTO user_presence (user_id, current_todo_id, session_started_at, last_heartbeat_at)
VALUES (:user_id, :'todo_id'::UUID, NOW(), NOW())
ON CONFLICT (user_id) DO UPDATE SET
  current_todo_id    = EXCLUDED.current_todo_id,
  session_started_at = NOW(),
  last_heartbeat_at  = NOW();

DO $$ BEGIN
  IF (SELECT session_started_at FROM user_presence WHERE user_id = (SELECT id FROM users WHERE nickname='studier')) IS NULL THEN
    RAISE EXCEPTION 'FAIL: session_started_at should be set';
  END IF;
  RAISE NOTICE 'PASS: studying state set';
END $$;

-- T3: todo 삭제 시 current_todo_id SET NULL
DELETE FROM todos WHERE id = :'todo_id'::UUID;
DO $$ BEGIN
  IF (SELECT current_todo_id FROM user_presence WHERE user_id = (SELECT id FROM users WHERE nickname='studier')) IS NOT NULL THEN
    RAISE EXCEPTION 'FAIL: current_todo_id should be set NULL';
  END IF;
  RAISE NOTICE 'PASS: current_todo_id SET NULL on todo delete';
END $$;

-- T4: 1명 user는 1행 presence (PK = user_id)
DO $$ BEGIN
  BEGIN
    INSERT INTO user_presence (user_id, last_heartbeat_at)
    VALUES ((SELECT id FROM users WHERE nickname='studier'), NOW());
    RAISE EXCEPTION 'FAIL: duplicate user_id must be rejected';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: user_presence PK';
  END;
END $$;

-- T5: user 삭제 시 presence CASCADE
DELETE FROM users WHERE nickname = 'studier';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM user_presence) != 0 THEN
    RAISE EXCEPTION 'FAIL: presence should CASCADE';
  END IF;
  RAISE NOTICE 'PASS: user_presence CASCADE';
END $$;

ROLLBACK;
SELECT '02_presence.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 테스트 실행 → 실패**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: `relation "user_presence" does not exist`.

- [ ] **Step 3: `V1__init_schema.sql` 에 presence 추가**

```sql
-- -----------------------------------------------------------------------------
-- 3. 실시간 프레즌스
--    session_started_at IS NULL = 공부 중 아님
--    last_heartbeat_at이 5분 이내 = 온라인
-- -----------------------------------------------------------------------------
CREATE TABLE user_presence (
  user_id            BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  current_todo_id    UUID REFERENCES todos(id) ON DELETE SET NULL,
  session_started_at TIMESTAMPTZ,
  last_heartbeat_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/02_presence.sql
git commit -m "feat : user_presence 테이블 + FK SET NULL·CASCADE 검증"
```

---

### Task 6: 타이머 세션 (timer_sessions)

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/04_timer.sql`

- [ ] **Step 1: `db/test/04_timer.sql` 작성 (RED)**

```sql
BEGIN;

INSERT INTO users (nickname, social_platform, social_id)
VALUES ('timer_user', 'GOOGLE', 'uid-t-1') RETURNING id \gset user_

INSERT INTO todos (id, user_id, title) VALUES (gen_random_uuid(), :user_id, '영어 독해')
RETURNING id \gset todo_

-- T1: 유효 세션 삽입
INSERT INTO timer_sessions (id, user_id, todo_id, todo_title, started_at, ended_at, duration_minutes)
VALUES (gen_random_uuid(), :user_id, :'todo_id'::UUID, '영어 독해',
        NOW() - INTERVAL '30 minutes', NOW(), 25);

-- T2: started_at >= ended_at 거부
DO $$ BEGIN
  BEGIN
    INSERT INTO timer_sessions (id, user_id, started_at, ended_at, duration_minutes)
    VALUES (gen_random_uuid(), (SELECT id FROM users WHERE nickname='timer_user'),
            NOW(), NOW() - INTERVAL '10 minutes', 5);
    RAISE EXCEPTION 'FAIL: started_at >= ended_at must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: started_at < ended_at check';
  END;
END $$;

-- T3: duration_minutes 범위 (1~1440)
DO $$ BEGIN
  BEGIN
    INSERT INTO timer_sessions (id, user_id, started_at, ended_at, duration_minutes)
    VALUES (gen_random_uuid(), (SELECT id FROM users WHERE nickname='timer_user'),
            NOW() - INTERVAL '1 day 2 hours', NOW(), 1441);
    RAISE EXCEPTION 'FAIL: duration > 1440 must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: duration max check';
  END;
END $$;

DO $$ BEGIN
  BEGIN
    INSERT INTO timer_sessions (id, user_id, started_at, ended_at, duration_minutes)
    VALUES (gen_random_uuid(), (SELECT id FROM users WHERE nickname='timer_user'),
            NOW() - INTERVAL '1 minute', NOW(), 0);
    RAISE EXCEPTION 'FAIL: duration 0 must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: duration min check';
  END;
END $$;

-- T4: todo 삭제 시 timer_sessions.todo_id SET NULL (과거 기록 유지)
DELETE FROM todos WHERE id = :'todo_id'::UUID;
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM timer_sessions WHERE todo_id IS NOT NULL) != 0 THEN
    RAISE EXCEPTION 'FAIL: todo_id should SET NULL';
  END IF;
  IF (SELECT COUNT(*) FROM timer_sessions WHERE todo_title = '영어 독해') != 1 THEN
    RAISE EXCEPTION 'FAIL: todo_title snapshot should remain';
  END IF;
  RAISE NOTICE 'PASS: snapshot retained after todo delete';
END $$;

-- T5: user 삭제 시 CASCADE
DELETE FROM users WHERE nickname = 'timer_user';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM timer_sessions) != 0 THEN
    RAISE EXCEPTION 'FAIL: timer_sessions CASCADE';
  END IF;
  RAISE NOTICE 'PASS: timer_sessions CASCADE';
END $$;

ROLLBACK;
SELECT '04_timer.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 3: `V1__init_schema.sql` 에 timer_sessions 추가**

```sql
-- -----------------------------------------------------------------------------
-- 4. 타이머 세션 (append-only)
--    todo_title은 스냅샷. 같은 todo_id가 시점별로 다른 title 가능 → BCNF OK.
-- -----------------------------------------------------------------------------
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

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/04_timer.sql
git commit -m "feat : timer_sessions 테이블 + CHECK·SNAPSHOT 검증"
```

---

### Task 7: 연료 도메인 (user_fuel + fuel_transactions)

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/05_fuel.sql`

- [ ] **Step 1: `db/test/05_fuel.sql` 작성 (RED)**

```sql
BEGIN;

INSERT INTO users (nickname, social_platform, social_id)
VALUES ('fueler', 'GOOGLE', 'uid-f-1') RETURNING id \gset user_

-- T1: user_fuel 초기 행
INSERT INTO user_fuel (user_id) VALUES (:user_id);
DO $$ BEGIN
  IF (SELECT current_fuel FROM user_fuel WHERE user_id = (SELECT id FROM users WHERE nickname='fueler')) != 0 THEN
    RAISE EXCEPTION 'FAIL: initial current_fuel should be 0';
  END IF;
  RAISE NOTICE 'PASS: initial fuel 0';
END $$;

-- T2: GENERATED 컬럼 자동 계산
UPDATE user_fuel SET total_charged = 100 WHERE user_id = :user_id;
DO $$ BEGIN
  IF (SELECT current_fuel FROM user_fuel WHERE user_id = (SELECT id FROM users WHERE nickname='fueler')) != 100 THEN
    RAISE EXCEPTION 'FAIL: current_fuel should be 100 (auto-generated)';
  END IF;
  RAISE NOTICE 'PASS: GENERATED column computes total_charged';
END $$;

UPDATE user_fuel SET total_consumed = 30 WHERE user_id = :user_id;
DO $$ BEGIN
  IF (SELECT current_fuel FROM user_fuel WHERE user_id = (SELECT id FROM users WHERE nickname='fueler')) != 70 THEN
    RAISE EXCEPTION 'FAIL: current_fuel should be 70';
  END IF;
  RAISE NOTICE 'PASS: GENERATED column recomputes';
END $$;

-- T3: GENERATED 컬럼 직접 쓰기 불가
DO $$ BEGIN
  BEGIN
    UPDATE user_fuel SET current_fuel = 999 WHERE user_id = (SELECT id FROM users WHERE nickname='fueler');
    RAISE EXCEPTION 'FAIL: direct write to GENERATED must be rejected';
  EXCEPTION WHEN generated_always THEN
    RAISE NOTICE 'PASS: GENERATED is read-only';
  END;
END $$;

-- T4: total_charged >= total_consumed CHECK
DO $$ BEGIN
  BEGIN
    UPDATE user_fuel SET total_consumed = 200
    WHERE user_id = (SELECT id FROM users WHERE nickname='fueler');
    RAISE EXCEPTION 'FAIL: consumed > charged must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: consumed <= charged check';
  END;
END $$;

-- T5: fuel_transactions 삽입
INSERT INTO fuel_transactions (user_id, type, amount, reason, reference_id, balance_after)
VALUES (:user_id, 'charge', 25, 'STUDY_SESSION', 'session-uuid-1', 95);

-- T6: type CHECK
DO $$ BEGIN
  BEGIN
    INSERT INTO fuel_transactions (user_id, type, amount, reason, reference_id, balance_after)
    VALUES ((SELECT id FROM users WHERE nickname='fueler'), 'refund', 10, 'STUDY_SESSION', 'x', 0);
    RAISE EXCEPTION 'FAIL: invalid type must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: type check';
  END;
END $$;

-- T7: amount > 0
DO $$ BEGIN
  BEGIN
    INSERT INTO fuel_transactions (user_id, type, amount, reason, reference_id, balance_after)
    VALUES ((SELECT id FROM users WHERE nickname='fueler'), 'charge', 0, 'STUDY_SESSION', 'x', 0);
    RAISE EXCEPTION 'FAIL: amount 0 must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: amount > 0 check';
  END;
END $$;

-- T8: user 삭제 시 CASCADE
DELETE FROM users WHERE nickname = 'fueler';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM user_fuel) + (SELECT COUNT(*) FROM fuel_transactions) != 0 THEN
    RAISE EXCEPTION 'FAIL: fuel tables CASCADE';
  END IF;
  RAISE NOTICE 'PASS: fuel CASCADE';
END $$;

ROLLBACK;
SELECT '05_fuel.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 3: `V1__init_schema.sql` 에 fuel 추가**

```sql
-- -----------------------------------------------------------------------------
-- 5. 연료 시스템
--    current_fuel은 GENERATED 컬럼 (직접 쓰기 불가)
-- -----------------------------------------------------------------------------
CREATE TABLE user_fuel (
  user_id         BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_charged   INTEGER NOT NULL DEFAULT 0 CHECK (total_charged >= 0),
  total_consumed  INTEGER NOT NULL DEFAULT 0 CHECK (total_consumed >= 0),
  current_fuel    INTEGER GENERATED ALWAYS AS (total_charged - total_consumed) STORED,
  pending_minutes INTEGER NOT NULL DEFAULT 0,
  last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (total_charged >= total_consumed)
);

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

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/05_fuel.sql
git commit -m "feat : user_fuel(GENERATED), fuel_transactions 테이블 검증"
```

---

### Task 8: 탐험 도메인 (exploration_nodes + user_exploration_progress)

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/06_exploration.sql`

- [ ] **Step 1: `db/test/06_exploration.sql` 작성 (RED)**

```sql
BEGIN;

-- T1: 행성 삽입 (parent_id NULL)
INSERT INTO exploration_nodes (id, name, node_type, icon, parent_id, required_fuel, sort_order, map_x, map_y)
VALUES ('earth', '지구', 'planet', 'earth', NULL, 0, 1, 0.5, 0.5);

-- T2: 행성은 parent_id 없어야
DO $$ BEGIN
  BEGIN
    INSERT INTO exploration_nodes (id, name, node_type, icon, parent_id, required_fuel, sort_order, map_x, map_y)
    VALUES ('fake-planet', 'Fake', 'planet', 'x', 'earth', 0, 2, 0.1, 0.1);
    RAISE EXCEPTION 'FAIL: planet with parent must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: planet no parent';
  END;
END $$;

-- T3: 지역은 parent_id 있어야
DO $$ BEGIN
  BEGIN
    INSERT INTO exploration_nodes (id, name, node_type, icon, parent_id, required_fuel, sort_order, map_x, map_y)
    VALUES ('orphan-region', 'Orphan', 'region', 'x', NULL, 0, 1, 0.2, 0.2);
    RAISE EXCEPTION 'FAIL: region without parent must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: region requires parent';
  END;
END $$;

-- T4: 지역 삽입
INSERT INTO exploration_nodes (id, name, node_type, icon, parent_id, required_fuel, sort_order, map_x, map_y)
VALUES ('region-kr', '한국', 'region', 'kr', 'earth', 0, 1, 0.55, 0.45);

-- T5: map_x/y 범위
DO $$ BEGIN
  BEGIN
    INSERT INTO exploration_nodes (id, name, node_type, icon, required_fuel, sort_order, map_x, map_y)
    VALUES ('invalid-map', 'X', 'planet', 'x', 0, 99, 1.5, 0.5);
    RAISE EXCEPTION 'FAIL: map_x out of range must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: map_x range';
  END;
END $$;

-- T6: user_exploration_progress 삽입 (해금)
INSERT INTO users (nickname, social_platform, social_id)
VALUES ('explorer', 'GOOGLE', 'uid-e-1') RETURNING id \gset user_

INSERT INTO user_exploration_progress (user_id, node_id) VALUES (:user_id, 'earth');

-- T7: (user_id, node_id) 복합 유니크
DO $$ BEGIN
  BEGIN
    INSERT INTO user_exploration_progress (user_id, node_id)
    VALUES ((SELECT id FROM users WHERE nickname='explorer'), 'earth');
    RAISE EXCEPTION 'FAIL: duplicate progress must be rejected';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: progress unique';
  END;
END $$;

-- T8: unlocked_at 기본값
DO $$ BEGIN
  IF (SELECT unlocked_at FROM user_exploration_progress
      WHERE user_id = (SELECT id FROM users WHERE nickname='explorer')
      AND node_id = 'earth') IS NULL THEN
    RAISE EXCEPTION 'FAIL: unlocked_at default should be NOW()';
  END IF;
  RAISE NOTICE 'PASS: unlocked_at default';
END $$;

-- T9: user 삭제 시 CASCADE
DELETE FROM users WHERE nickname = 'explorer';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM user_exploration_progress) != 0 THEN
    RAISE EXCEPTION 'FAIL: progress CASCADE';
  END IF;
  RAISE NOTICE 'PASS: progress CASCADE';
END $$;

ROLLBACK;
SELECT '06_exploration.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 3: `V1__init_schema.sql` 에 exploration 추가**

```sql
-- -----------------------------------------------------------------------------
-- 6. 탐험 (seed 데이터 행성/지역 + 유저 진행도)
--    BCNF: depth 제거(node_type에서 유도), is_unlocked/is_cleared 제거(행 존재로 표현)
-- -----------------------------------------------------------------------------
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

CREATE TABLE user_exploration_progress (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  node_id     VARCHAR(50) NOT NULL REFERENCES exploration_nodes(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, node_id)
);
```

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/06_exploration.sql
git commit -m "feat : exploration_nodes, user_exploration_progress + 계층 제약"
```

---

### Task 9: 뱃지 도메인 (badges + user_badge_progress)

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/07_badges.sql`

- [ ] **Step 1: `db/test/07_badges.sql` 작성 (RED)**

```sql
BEGIN;

-- T1: badges 삽입
INSERT INTO badges (id, name, icon, description, category, rarity, required_value)
VALUES ('first-session', '첫 발자국', 'star', '첫 학습 세션 완료', 'SESSION', 'NORMAL', 1);

-- T2: category CHECK
DO $$ BEGIN
  BEGIN
    INSERT INTO badges (id, name, icon, description, category, rarity, required_value)
    VALUES ('bad-cat', 'Bad', 'x', 'desc', 'UNKNOWN', 'NORMAL', 0);
    RAISE EXCEPTION 'FAIL: invalid category must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: badge category check';
  END;
END $$;

-- T3: rarity CHECK
DO $$ BEGIN
  BEGIN
    INSERT INTO badges (id, name, icon, description, category, rarity, required_value)
    VALUES ('bad-rar', 'Bad', 'x', 'desc', 'SESSION', 'COMMON', 0);
    RAISE EXCEPTION 'FAIL: invalid rarity must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: badge rarity check';
  END;
END $$;

-- T4: user_badge_progress 삽입
INSERT INTO users (nickname, social_platform, social_id)
VALUES ('badger', 'GOOGLE', 'uid-b-1') RETURNING id \gset user_

INSERT INTO user_badge_progress (user_id, badge_id) VALUES (:user_id, 'first-session');

-- T5: is_new 기본값 TRUE
DO $$ BEGIN
  IF NOT (SELECT is_new FROM user_badge_progress
          WHERE user_id = (SELECT id FROM users WHERE nickname='badger')) THEN
    RAISE EXCEPTION 'FAIL: is_new should default TRUE';
  END IF;
  RAISE NOTICE 'PASS: is_new default';
END $$;

-- T6: (user_id, badge_id) 복합 유니크
DO $$ BEGIN
  BEGIN
    INSERT INTO user_badge_progress (user_id, badge_id)
    VALUES ((SELECT id FROM users WHERE nickname='badger'), 'first-session');
    RAISE EXCEPTION 'FAIL: duplicate badge progress must be rejected';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: badge progress unique';
  END;
END $$;

-- T7: CASCADE on user/badge delete
DELETE FROM badges WHERE id = 'first-session';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM user_badge_progress) != 0 THEN
    RAISE EXCEPTION 'FAIL: progress should CASCADE on badge delete';
  END IF;
  RAISE NOTICE 'PASS: badge delete CASCADE';
END $$;

ROLLBACK;
SELECT '07_badges.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 3: `V1__init_schema.sql` 에 badges 추가**

```sql
-- -----------------------------------------------------------------------------
-- 7. 뱃지 (seed + 유저 해금 상태)
-- -----------------------------------------------------------------------------
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

CREATE TABLE user_badge_progress (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_id    VARCHAR(50) NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_new      BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (user_id, badge_id)
);
```

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/07_badges.sql
git commit -m "feat : badges, user_badge_progress + 카테고리·희귀도 검증"
```

---

### Task 10: 소셜 도메인 (friend_requests + friendships)

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/08_social.sql`

- [ ] **Step 1: `db/test/08_social.sql` 작성 (RED)**

```sql
BEGIN;

INSERT INTO users (nickname, social_platform, social_id) VALUES
  ('alice', 'GOOGLE', 'uid-a'),
  ('bob', 'GOOGLE', 'uid-b'),
  ('carol', 'GOOGLE', 'uid-c');

-- T1: 자기 자신에게 요청 불가
DO $$ BEGIN
  BEGIN
    INSERT INTO friend_requests (from_user_id, to_user_id, status)
    VALUES ((SELECT id FROM users WHERE nickname='alice'),
            (SELECT id FROM users WHERE nickname='alice'), 'PENDING');
    RAISE EXCEPTION 'FAIL: self-request must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: no self-request';
  END;
END $$;

-- T2: status CHECK
DO $$ BEGIN
  BEGIN
    INSERT INTO friend_requests (from_user_id, to_user_id, status)
    VALUES ((SELECT id FROM users WHERE nickname='alice'),
            (SELECT id FROM users WHERE nickname='bob'), 'INVALID');
    RAISE EXCEPTION 'FAIL: invalid status must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: status check';
  END;
END $$;

-- T3: PENDING 유니크 (같은 from→to PENDING 중복 방지)
-- 먼저 인덱스를 만들어야 하지만 Task 11에서 생성됨.
-- 이 테스트는 인덱스 생성 전이라 통과되지 않을 수도. 임시로 조건부로 건너뛰고 Task 11에 통합 검증.

-- T4: PENDING 첫 요청은 성공
INSERT INTO friend_requests (from_user_id, to_user_id, status)
VALUES ((SELECT id FROM users WHERE nickname='alice'),
        (SELECT id FROM users WHERE nickname='bob'), 'PENDING');

-- T5: REJECTED 이후 재요청 가능 (동일 from,to + 다른 status 허용)
UPDATE friend_requests SET status = 'REJECTED'
WHERE from_user_id = (SELECT id FROM users WHERE nickname='alice')
  AND to_user_id = (SELECT id FROM users WHERE nickname='bob');

INSERT INTO friend_requests (from_user_id, to_user_id, status)
VALUES ((SELECT id FROM users WHERE nickname='alice'),
        (SELECT id FROM users WHERE nickname='bob'), 'PENDING');

DO $$ BEGIN
  IF (SELECT COUNT(*) FROM friend_requests
      WHERE from_user_id = (SELECT id FROM users WHERE nickname='alice')
      AND to_user_id = (SELECT id FROM users WHERE nickname='bob')) != 2 THEN
    RAISE EXCEPTION 'FAIL: re-request after REJECTED should be allowed';
  END IF;
  RAISE NOTICE 'PASS: re-request after REJECTED';
END $$;

-- T6: friendships 양방향 저장
INSERT INTO friendships (user_id, friend_user_id) VALUES
  ((SELECT id FROM users WHERE nickname='alice'), (SELECT id FROM users WHERE nickname='bob')),
  ((SELECT id FROM users WHERE nickname='bob'), (SELECT id FROM users WHERE nickname='alice'));

DO $$ BEGIN
  IF (SELECT COUNT(*) FROM friendships) != 2 THEN
    RAISE EXCEPTION 'FAIL: bidirectional friendship should have 2 rows';
  END IF;
  RAISE NOTICE 'PASS: bidirectional friendship';
END $$;

-- T7: self-friendship 불가
DO $$ BEGIN
  BEGIN
    INSERT INTO friendships (user_id, friend_user_id)
    VALUES ((SELECT id FROM users WHERE nickname='alice'),
            (SELECT id FROM users WHERE nickname='alice'));
    RAISE EXCEPTION 'FAIL: self-friendship must be rejected';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'PASS: no self-friendship';
  END;
END $$;

-- T8: 유니크 (user_id, friend_user_id)
DO $$ BEGIN
  BEGIN
    INSERT INTO friendships (user_id, friend_user_id)
    VALUES ((SELECT id FROM users WHERE nickname='alice'),
            (SELECT id FROM users WHERE nickname='bob'));
    RAISE EXCEPTION 'FAIL: duplicate friendship must be rejected';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: friendship unique';
  END;
END $$;

-- T9: CASCADE on user delete
DELETE FROM users WHERE nickname = 'alice';
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM friendships) != 0 THEN
    RAISE EXCEPTION 'FAIL: friendships CASCADE';
  END IF;
  IF (SELECT COUNT(*) FROM friend_requests
      WHERE from_user_id NOT IN (SELECT id FROM users)
        OR to_user_id NOT IN (SELECT id FROM users)) != 0 THEN
    RAISE EXCEPTION 'FAIL: friend_requests CASCADE';
  END IF;
  RAISE NOTICE 'PASS: social CASCADE';
END $$;

ROLLBACK;
SELECT '08_social.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 3: `V1__init_schema.sql` 에 social 추가**

```sql
-- -----------------------------------------------------------------------------
-- 8. 소셜 (친구 요청 + 양방향 친구관계)
--    PENDING 유니크는 Task 11의 partial unique index로 보강
-- -----------------------------------------------------------------------------
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

CREATE TABLE friendships (
  id             BIGSERIAL PRIMARY KEY,
  user_id        BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  friend_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, friend_user_id),
  CHECK (user_id <> friend_user_id)
);
```

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/08_social.sql
git commit -m "feat : friend_requests, friendships + 양방향·CASCADE 검증"
```

---

## Phase 3: 인덱스

### Task 11: 전체 인덱스 + PENDING partial unique

**Files:**
- Modify: `db/migration/V1__init_schema.sql` (append)
- Create: `db/test/09_indexes.sql`

- [ ] **Step 1: `db/test/09_indexes.sql` 작성 (RED)**

```sql
BEGIN;

-- T1: 필수 인덱스 존재 확인
DO $$
DECLARE
  required_indexes TEXT[] := ARRAY[
    'idx_users_nickname',
    'idx_users_social',
    'idx_user_devices_user_device',
    'idx_user_devices_refresh_token',
    'idx_user_presence_heartbeat',
    'idx_todo_categories_user',
    'idx_todos_user',
    'idx_todos_scheduled_gin',
    'idx_todos_completed_gin',
    'idx_todos_categories_gin',
    'idx_timer_sessions_user_started',
    'idx_timer_sessions_todo',
    'idx_fuel_tx_user_created',
    'idx_fuel_tx_user_type',
    'idx_exploration_parent_sort',
    'idx_exploration_progress_user_node',
    'idx_badges_category_rarity',
    'idx_badge_progress_user_badge',
    'idx_badge_progress_user_new',
    'idx_friend_requests_pending',
    'idx_friend_requests_received',
    'idx_friendships_user_friend'
  ];
  idx TEXT;
BEGIN
  FOREACH idx IN ARRAY required_indexes LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = idx) THEN
      RAISE EXCEPTION 'FAIL: index % does not exist', idx;
    END IF;
  END LOOP;
  RAISE NOTICE 'PASS: all % indexes exist', array_length(required_indexes, 1);
END $$;

-- T2: friend_requests PENDING partial unique
INSERT INTO users (nickname, social_platform, social_id) VALUES
  ('a1', 'GOOGLE', 'a1'), ('b1', 'GOOGLE', 'b1');

INSERT INTO friend_requests (from_user_id, to_user_id, status)
VALUES ((SELECT id FROM users WHERE nickname='a1'),
        (SELECT id FROM users WHERE nickname='b1'), 'PENDING');

DO $$ BEGIN
  BEGIN
    INSERT INTO friend_requests (from_user_id, to_user_id, status)
    VALUES ((SELECT id FROM users WHERE nickname='a1'),
            (SELECT id FROM users WHERE nickname='b1'), 'PENDING');
    RAISE EXCEPTION 'FAIL: duplicate PENDING must be rejected';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'PASS: partial unique rejects dup PENDING';
  END;
END $$;

-- T3: partial unique는 non-PENDING은 허용
UPDATE friend_requests SET status = 'CANCELLED'
WHERE from_user_id = (SELECT id FROM users WHERE nickname='a1')
  AND to_user_id = (SELECT id FROM users WHERE nickname='b1');

INSERT INTO friend_requests (from_user_id, to_user_id, status)
VALUES ((SELECT id FROM users WHERE nickname='a1'),
        (SELECT id FROM users WHERE nickname='b1'), 'PENDING');

DO $$ BEGIN
  IF (SELECT COUNT(*) FROM friend_requests
      WHERE from_user_id = (SELECT id FROM users WHERE nickname='a1')
      AND to_user_id = (SELECT id FROM users WHERE nickname='b1')) != 2 THEN
    RAISE EXCEPTION 'FAIL: new PENDING after CANCELLED should work';
  END IF;
  RAISE NOTICE 'PASS: partial unique allows new PENDING after CANCELLED';
END $$;

-- T4: is_new partial index만 TRUE 포함
INSERT INTO badges (id, name, icon, description, category, rarity, required_value)
VALUES ('t-badge', 't', 'i', 'd', 'SESSION', 'NORMAL', 1);

INSERT INTO user_badge_progress (user_id, badge_id, is_new)
VALUES ((SELECT id FROM users WHERE nickname='a1'), 't-badge', TRUE);

DO $$
DECLARE
  idx_def TEXT;
BEGIN
  SELECT indexdef INTO idx_def FROM pg_indexes WHERE indexname = 'idx_badge_progress_user_new';
  IF idx_def NOT ILIKE '%is_new = true%' THEN
    RAISE EXCEPTION 'FAIL: idx_badge_progress_user_new should be partial on is_new=TRUE';
  END IF;
  RAISE NOTICE 'PASS: is_new partial index';
END $$;

ROLLBACK;
SELECT '09_indexes.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: 대부분의 인덱스 없음으로 실패.

- [ ] **Step 3: `V1__init_schema.sql` 끝에 모든 인덱스 추가**

```sql
-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

-- users
CREATE UNIQUE INDEX idx_users_nickname ON users(nickname);
CREATE UNIQUE INDEX idx_users_social ON users(social_platform, social_id);

-- user_devices
CREATE UNIQUE INDEX idx_user_devices_user_device ON user_devices(user_id, device_id);
CREATE INDEX idx_user_devices_refresh_token ON user_devices(refresh_token);

-- user_presence (partial: 공부 중인 사용자만)
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

-- user_badge_progress (partial: 신규 뱃지만)
CREATE UNIQUE INDEX idx_badge_progress_user_badge ON user_badge_progress(user_id, badge_id);
CREATE INDEX idx_badge_progress_user_new ON user_badge_progress(user_id)
  WHERE is_new = TRUE;

-- friend_requests (partial: PENDING만 unique)
CREATE UNIQUE INDEX idx_friend_requests_pending
  ON friend_requests(from_user_id, to_user_id) WHERE status = 'PENDING';
CREATE INDEX idx_friend_requests_received
  ON friend_requests(to_user_id, status, created_at DESC) WHERE status = 'PENDING';

-- friendships
CREATE UNIQUE INDEX idx_friendships_user_friend ON friendships(user_id, friend_user_id);
```

> Note: `idx_users_nickname`과 `idx_users_social`은 CREATE TABLE의 `UNIQUE` 제약으로 이미 자동 생성되지만, 명시적 `CREATE UNIQUE INDEX`는 **같은 정의로 실행 시 에러 발생**한다. 해결: CREATE TABLE의 UNIQUE 선언을 제거하고 여기서만 CREATE UNIQUE INDEX로 생성.

- [ ] **Step 4: CREATE TABLE의 중복 UNIQUE 제약 제거**

`V1__init_schema.sql`의 `users` 테이블에서 다음 두 부분 제거:
- `nickname VARCHAR(10) UNIQUE NOT NULL` → `nickname VARCHAR(10) NOT NULL`
- 끝의 `UNIQUE (social_platform, social_id)` 라인 삭제

`user_devices`에서 `UNIQUE (user_id, device_id)` 삭제
`todo_categories`는 명시적 유니크 없음 → 수정 불필요
`timer_sessions`는 명시적 유니크 없음 → 수정 불필요
`user_exploration_progress`에서 `UNIQUE (user_id, node_id)` 삭제
`user_badge_progress`에서 `UNIQUE (user_id, badge_id)` 삭제
`friendships`에서 `UNIQUE (user_id, friend_user_id)` 삭제

- [ ] **Step 5: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: 09_indexes.sql PASS + 이전 테스트 모두 PASS.

- [ ] **Step 6: 커밋**

```bash
git add db/migration/V1__init_schema.sql db/test/09_indexes.sql
git commit -m "feat : 전체 인덱스 + partial unique/GIN 인덱스 검증"
```

---

## Phase 4: 시드 데이터

### Task 12: V2 — 행성/지역 시드

**Files:**
- Create: `db/migration/V2__seed_exploration_nodes.sql`
- Modify: `db/test/10_seeds.sql` (이 태스크에서 생성)

- [ ] **Step 1: `db/test/10_seeds.sql` 작성 (RED)**

```sql
BEGIN;

-- T1: 행성 시드 행 수 확인 (최소 8개: 수,금,지,화,목,토,천,해)
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM exploration_nodes WHERE node_type = 'planet') < 8 THEN
    RAISE EXCEPTION 'FAIL: expect >= 8 planets, got %', (SELECT COUNT(*) FROM exploration_nodes WHERE node_type = 'planet');
  END IF;
  RAISE NOTICE 'PASS: planet seed count';
END $$;

-- T2: 지구는 required_fuel = 0 (기본 해금)
DO $$ BEGIN
  IF (SELECT required_fuel FROM exploration_nodes WHERE id = 'earth') != 0 THEN
    RAISE EXCEPTION 'FAIL: earth should be free';
  END IF;
  RAISE NOTICE 'PASS: earth free';
END $$;

-- T3: 지구의 지역이 있어야 (최소 1개)
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM exploration_nodes WHERE parent_id = 'earth') < 1 THEN
    RAISE EXCEPTION 'FAIL: earth should have at least 1 region';
  END IF;
  RAISE NOTICE 'PASS: earth has regions';
END $$;

-- T4: 모든 지역은 parent가 planet
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM exploration_nodes r
    WHERE r.node_type = 'region'
      AND (r.parent_id IS NULL OR NOT EXISTS (
        SELECT 1 FROM exploration_nodes p WHERE p.id = r.parent_id AND p.node_type = 'planet'
      ))
  ) THEN
    RAISE EXCEPTION 'FAIL: every region must have a planet parent';
  END IF;
  RAISE NOTICE 'PASS: region hierarchy';
END $$;

-- T5: map_x/y는 0~1 범위 (CREATE TABLE의 CHECK가 적용돼야)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM exploration_nodes WHERE map_x NOT BETWEEN 0 AND 1 OR map_y NOT BETWEEN 0 AND 1) THEN
    RAISE EXCEPTION 'FAIL: map coord out of range';
  END IF;
  RAISE NOTICE 'PASS: map coords valid';
END $$;

ROLLBACK;
SELECT '10_seeds.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 실패 확인**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: `expect >= 8 planets, got 0` 실패.

- [ ] **Step 3: `V2__seed_exploration_nodes.sql` 작성**

```sql
-- =============================================================================
-- V2: 행성 및 지역 시드 데이터
-- 멱등 삽입: ON CONFLICT DO UPDATE
-- =============================================================================

-- 8개 행성
INSERT INTO exploration_nodes (id, name, node_type, icon, parent_id, required_fuel, sort_order, description, map_x, map_y) VALUES
  ('mercury', '수성', 'planet', 'mercury', NULL,  50, 1, '태양과 가장 가까운 행성', 0.10, 0.50),
  ('venus',   '금성', 'planet', 'venus',   NULL,  80, 2, '샛별이라 불리는 행성',   0.20, 0.50),
  ('earth',   '지구', 'planet', 'earth',   NULL,   0, 3, '우리가 사는 행성',        0.30, 0.50),
  ('mars',    '화성', 'planet', 'mars',    NULL, 100, 4, '붉은 행성',               0.40, 0.50),
  ('jupiter', '목성', 'planet', 'jupiter', NULL, 200, 5, '태양계 최대 행성',        0.55, 0.50),
  ('saturn',  '토성', 'planet', 'saturn',  NULL, 300, 6, '고리를 가진 행성',        0.70, 0.50),
  ('uranus',  '천왕성', 'planet', 'uranus',NULL, 400, 7, '기울어진 자전축',        0.82, 0.50),
  ('neptune', '해왕성', 'planet', 'neptune',NULL, 500, 8, '가장 먼 행성',          0.92, 0.50)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, required_fuel = EXCLUDED.required_fuel,
  sort_order = EXCLUDED.sort_order, description = EXCLUDED.description,
  map_x = EXCLUDED.map_x, map_y = EXCLUDED.map_y;

-- 지구의 지역 (MVP 샘플: 국가 4개)
INSERT INTO exploration_nodes (id, name, node_type, icon, parent_id, required_fuel, sort_order, description, map_x, map_y) VALUES
  ('earth-kr', '대한민국', 'region', 'kr', 'earth', 10, 1, '한반도',         0.55, 0.45),
  ('earth-jp', '일본',     'region', 'jp', 'earth', 20, 2, '동쪽 섬나라',    0.60, 0.48),
  ('earth-us', '미국',     'region', 'us', 'earth', 30, 3, '북미 대륙',      0.25, 0.40),
  ('earth-eu', '유럽',     'region', 'eu', 'earth', 25, 4, '유럽 대륙',      0.45, 0.35)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, required_fuel = EXCLUDED.required_fuel,
  sort_order = EXCLUDED.sort_order, description = EXCLUDED.description,
  map_x = EXCLUDED.map_x, map_y = EXCLUDED.map_y;
```

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V2__seed_exploration_nodes.sql db/test/10_seeds.sql
git commit -m "feat : V2 행성·지역 시드 + 멱등 삽입 검증"
```

---

### Task 13: V3 — 뱃지 시드

**Files:**
- Create: `db/migration/V3__seed_badges.sql`
- Modify: `db/test/10_seeds.sql` (badge 테스트 추가)

- [ ] **Step 1: `db/test/10_seeds.sql` 에 뱃지 검증 추가**

기존 `ROLLBACK` 직전에 다음 블록 삽입:

```sql
-- T6: 뱃지 시드 존재
DO $$ BEGIN
  IF (SELECT COUNT(*) FROM badges) < 5 THEN
    RAISE EXCEPTION 'FAIL: expect >= 5 badges, got %', (SELECT COUNT(*) FROM badges);
  END IF;
  RAISE NOTICE 'PASS: badge seed count';
END $$;

-- T7: 카테고리·희귀도 유효값만
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM badges
    WHERE category NOT IN ('STUDY_TIME','STREAK','SESSION','EXPLORATION','FUEL','HIDDEN')
       OR rarity NOT IN ('NORMAL','RARE','EPIC','LEGENDARY','HIDDEN')
  ) THEN
    RAISE EXCEPTION 'FAIL: invalid category or rarity in seed';
  END IF;
  RAISE NOTICE 'PASS: badge values valid';
END $$;
```

- [ ] **Step 2: 테스트 실행 → T6 실패**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: `expect >= 5 badges, got 0`.

- [ ] **Step 3: `V3__seed_badges.sql` 작성**

```sql
-- =============================================================================
-- V3: 뱃지 시드
-- =============================================================================

INSERT INTO badges (id, name, icon, description, category, rarity, required_value) VALUES
  -- STUDY_TIME
  ('study-1h',    '1시간 탐험가',   'clock-1',  '누적 학습 1시간 달성',  'STUDY_TIME', 'NORMAL',    60),
  ('study-10h',   '10시간 탐험가',  'clock-10', '누적 학습 10시간 달성', 'STUDY_TIME', 'RARE',      600),
  ('study-100h',  '100시간 탐험가', 'clock-100','누적 학습 100시간 달성','STUDY_TIME', 'EPIC',      6000),
  -- STREAK
  ('streak-3',    '3일 연속',       'flame-3',  '3일 연속 학습',         'STREAK',     'NORMAL',    3),
  ('streak-7',    '7일 연속',       'flame-7',  '1주일 연속 학습',       'STREAK',     'RARE',      7),
  ('streak-30',   '30일 연속',      'flame-30', '30일 연속 학습',        'STREAK',     'EPIC',      30),
  -- SESSION
  ('session-1',   '첫 발걸음',      'star-1',   '첫 학습 세션 완료',     'SESSION',    'NORMAL',    1),
  ('session-100', '100세션',        'star-100', '누적 100세션 완료',     'SESSION',    'RARE',      100),
  -- EXPLORATION
  ('explore-earth','지구 정복',     'earth-flag','지구의 모든 지역 해금','EXPLORATION','RARE',      0),
  -- FUEL
  ('fuel-1000',   '연료 부호',      'fuel-1k',  '누적 충전 연료 1000',   'FUEL',       'EPIC',      1000),
  -- HIDDEN
  ('hidden-night','야행성 탐험가',  'moon',     '???',                  'HIDDEN',     'HIDDEN',    0)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, icon = EXCLUDED.icon, description = EXCLUDED.description,
  category = EXCLUDED.category, rarity = EXCLUDED.rarity, required_value = EXCLUDED.required_value;
```

- [ ] **Step 4: 재적용 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

- [ ] **Step 5: 커밋**

```bash
git add db/migration/V3__seed_badges.sql db/test/10_seeds.sql
git commit -m "feat : V3 뱃지 시드 + 카테고리·희귀도 검증"
```

---

## Phase 5: 실시간 쿼리 검증

### Task 14: 친구 목록 실시간 상태 쿼리

**Files:**
- Create: `db/test/11_realtime_queries.sql`

- [ ] **Step 1: `db/test/11_realtime_queries.sql` 작성**

```sql
BEGIN;

-- 시나리오: alice는 공부 중(heartbeat 방금), bob은 IDLE(heartbeat 2분 전),
-- carol은 OFFLINE(heartbeat 10분 전), alice·bob·carol 모두 alice와 친구
INSERT INTO users (nickname, social_platform, social_id) VALUES
  ('alice', 'GOOGLE', 'uid-alice'),
  ('bob',   'GOOGLE', 'uid-bob'),
  ('carol', 'GOOGLE', 'uid-carol');

-- 친구관계 양방향
WITH a AS (SELECT id FROM users WHERE nickname='alice'),
     b AS (SELECT id FROM users WHERE nickname='bob'),
     c AS (SELECT id FROM users WHERE nickname='carol')
INSERT INTO friendships (user_id, friend_user_id)
SELECT a.id, b.id FROM a,b UNION ALL
SELECT b.id, a.id FROM a,b UNION ALL
SELECT a.id, c.id FROM a,c UNION ALL
SELECT c.id, a.id FROM a,c;

-- alice의 todo
INSERT INTO todos (id, user_id, title)
VALUES (gen_random_uuid(), (SELECT id FROM users WHERE nickname='alice'), '알고리즘 공부')
RETURNING id \gset alice_todo_

-- alice: 공부 중, heartbeat 방금
INSERT INTO user_presence (user_id, current_todo_id, session_started_at, last_heartbeat_at)
VALUES ((SELECT id FROM users WHERE nickname='alice'), :'alice_todo_id'::UUID,
        NOW() - INTERVAL '15 minutes', NOW());

-- bob: IDLE (heartbeat 2분 전, session NULL)
INSERT INTO user_presence (user_id, last_heartbeat_at)
VALUES ((SELECT id FROM users WHERE nickname='bob'), NOW() - INTERVAL '2 minutes');

-- carol: OFFLINE (heartbeat 10분 전)
INSERT INTO user_presence (user_id, last_heartbeat_at)
VALUES ((SELECT id FROM users WHERE nickname='carol'), NOW() - INTERVAL '10 minutes');

-- T1: alice의 친구 목록 쿼리 결과 검증
-- 기대: alice의 친구는 bob, carol. bob=IDLE, carol=OFFLINE. alice 본인은 목록에서 제외.
WITH friend_ids AS (
  SELECT friend_user_id FROM friendships WHERE user_id = (SELECT id FROM users WHERE nickname='alice')
),
result AS (
  SELECT
    u.nickname,
    CASE
      WHEN p.session_started_at IS NOT NULL
       AND p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'STUDYING'
      WHEN p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'IDLE'
      ELSE 'OFFLINE'
    END AS status
  FROM users u
  LEFT JOIN user_presence p ON p.user_id = u.id
  WHERE u.id IN (SELECT friend_user_id FROM friend_ids)
)
SELECT * FROM result;

DO $$
DECLARE
  bob_status TEXT;
  carol_status TEXT;
BEGIN
  SELECT
    CASE
      WHEN p.session_started_at IS NOT NULL
       AND p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'STUDYING'
      WHEN p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'IDLE'
      ELSE 'OFFLINE'
    END INTO bob_status
  FROM users u JOIN user_presence p ON p.user_id = u.id
  WHERE u.nickname = 'bob';
  IF bob_status != 'IDLE' THEN
    RAISE EXCEPTION 'FAIL: bob expected IDLE, got %', bob_status;
  END IF;

  SELECT
    CASE
      WHEN p.session_started_at IS NOT NULL
       AND p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'STUDYING'
      WHEN p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'IDLE'
      ELSE 'OFFLINE'
    END INTO carol_status
  FROM users u JOIN user_presence p ON p.user_id = u.id
  WHERE u.nickname = 'carol';
  IF carol_status != 'OFFLINE' THEN
    RAISE EXCEPTION 'FAIL: carol expected OFFLINE, got %', carol_status;
  END IF;

  RAISE NOTICE 'PASS: bob IDLE, carol OFFLINE';
END $$;

-- T2: alice를 bob의 친구로 보고 bob 시점에서 alice를 조회 → STUDYING
DO $$
DECLARE
  alice_status TEXT;
BEGIN
  SELECT
    CASE
      WHEN p.session_started_at IS NOT NULL
       AND p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'STUDYING'
      WHEN p.last_heartbeat_at > NOW() - INTERVAL '5 minutes' THEN 'IDLE'
      ELSE 'OFFLINE'
    END INTO alice_status
  FROM users u JOIN user_presence p ON p.user_id = u.id
  WHERE u.nickname = 'alice';
  IF alice_status != 'STUDYING' THEN
    RAISE EXCEPTION 'FAIL: alice expected STUDYING, got %', alice_status;
  END IF;
  RAISE NOTICE 'PASS: alice STUDYING';
END $$;

-- T3: current_subject JOIN — alice는 '알고리즘 공부' 표시
DO $$
DECLARE
  subject TEXT;
BEGIN
  SELECT t.title INTO subject
  FROM user_presence p
  LEFT JOIN todos t ON t.id = p.current_todo_id
  WHERE p.user_id = (SELECT id FROM users WHERE nickname='alice');
  IF subject != '알고리즘 공부' THEN
    RAISE EXCEPTION 'FAIL: alice subject expected 알고리즘 공부, got %', subject;
  END IF;
  RAISE NOTICE 'PASS: current_subject JOIN';
END $$;

-- T4: todo 삭제 후 current_subject NULL
DELETE FROM todos WHERE id = :'alice_todo_id'::UUID;
DO $$
DECLARE
  subject TEXT;
BEGIN
  SELECT t.title INTO subject
  FROM user_presence p
  LEFT JOIN todos t ON t.id = p.current_todo_id
  WHERE p.user_id = (SELECT id FROM users WHERE nickname='alice');
  IF subject IS NOT NULL THEN
    RAISE EXCEPTION 'FAIL: subject should be NULL after todo delete';
  END IF;
  RAISE NOTICE 'PASS: subject NULL after todo delete';
END $$;

ROLLBACK;
SELECT '11_realtime_queries.sql: ALL PASS' AS result;
```

- [ ] **Step 2: 테스트 실행 → 전부 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: 이 쿼리는 스키마·데이터만 있으면 동작하므로 바로 PASS.

- [ ] **Step 3: 커밋**

```bash
git add db/test/11_realtime_queries.sql
git commit -m "test : 친구 실시간 상태(STUDYING/IDLE/OFFLINE) 쿼리 검증"
```

---

### Task 15: 랭킹 쿼리 (DAILY)

**Files:**
- Modify: `db/test/11_realtime_queries.sql` (append)

- [ ] **Step 1: `11_realtime_queries.sql` 끝의 `ROLLBACK` 앞에 랭킹 테스트 블록 추가**

```sql
-- ============================================================
-- 랭킹 쿼리 검증
-- ============================================================

-- 오늘 기준 각자 공부 시간: alice 60분, bob 30분, carol 0분
INSERT INTO timer_sessions (id, user_id, started_at, ended_at, duration_minutes) VALUES
  (gen_random_uuid(), (SELECT id FROM users WHERE nickname='alice'),
   date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul' + INTERVAL '10 hours',
   date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul' + INTERVAL '11 hours',
   60),
  (gen_random_uuid(), (SELECT id FROM users WHERE nickname='bob'),
   date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul' + INTERVAL '9 hours',
   date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul' + INTERVAL '9 hours 30 minutes',
   30);

-- T5: alice 시점 DAILY 랭킹 — alice 본인 + 친구 bob, carol 포함, 공부 시간 desc + userId asc
DO $$
DECLARE
  top_nickname TEXT;
  top_minutes INTEGER;
  third_minutes INTEGER;
BEGIN
  WITH scope AS (
    SELECT (SELECT id FROM users WHERE nickname='alice') AS id
    UNION
    SELECT friend_user_id FROM friendships WHERE user_id = (SELECT id FROM users WHERE nickname='alice')
  ),
  period_start AS (
    SELECT date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul' AS ts
  ),
  ranked AS (
    SELECT
      u.nickname,
      COALESCE(SUM(s.duration_minutes), 0) AS minutes,
      RANK() OVER (ORDER BY COALESCE(SUM(s.duration_minutes), 0) DESC, u.id ASC) AS rnk
    FROM scope c
    JOIN users u ON u.id = c.id
    LEFT JOIN timer_sessions s ON s.user_id = u.id AND s.started_at >= (SELECT ts FROM period_start)
    GROUP BY u.id, u.nickname
  )
  SELECT nickname, minutes INTO top_nickname, top_minutes FROM ranked WHERE rnk = 1;

  IF top_nickname != 'alice' OR top_minutes != 60 THEN
    RAISE EXCEPTION 'FAIL: top expected alice/60, got %/%', top_nickname, top_minutes;
  END IF;
  RAISE NOTICE 'PASS: alice tops DAILY ranking with 60min';
END $$;

-- T6: carol 랭킹 확인 (0분, 꼴찌)
DO $$
DECLARE
  carol_rnk BIGINT;
BEGIN
  WITH scope AS (
    SELECT (SELECT id FROM users WHERE nickname='alice') AS id
    UNION
    SELECT friend_user_id FROM friendships WHERE user_id = (SELECT id FROM users WHERE nickname='alice')
  ),
  ranked AS (
    SELECT
      u.nickname,
      RANK() OVER (ORDER BY COALESCE(SUM(s.duration_minutes), 0) DESC, u.id ASC) AS rnk
    FROM scope c
    JOIN users u ON u.id = c.id
    LEFT JOIN timer_sessions s ON s.user_id = u.id
      AND s.started_at >= date_trunc('day', NOW() AT TIME ZONE 'Asia/Seoul') AT TIME ZONE 'Asia/Seoul'
    GROUP BY u.id, u.nickname
  )
  SELECT rnk INTO carol_rnk FROM ranked WHERE nickname = 'carol';

  IF carol_rnk != 3 THEN
    RAISE EXCEPTION 'FAIL: carol expected rank 3, got %', carol_rnk;
  END IF;
  RAISE NOTICE 'PASS: carol rank 3 (0min)';
END $$;
```

- [ ] **Step 2: 테스트 실행 → 통과**

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

Expected: 모든 도메인 + 11_realtime_queries.sql 전부 PASS.

- [ ] **Step 3: 커밋**

```bash
git add db/test/11_realtime_queries.sql
git commit -m "test : DAILY 랭킹 쿼리 + KST 경계 검증"
```

---

## ✅ 완료 후 최종 검증

모든 task 완료 후 반드시 실행:

```bash
./db/scripts/reset.sh && ./db/scripts/test.sh
```

모든 파일에서 `ALL PASS` 출력 확인.

예상 출력 요약:
```
01_auth.sql: ALL PASS
02_presence.sql: ALL PASS
03_todos.sql: ALL PASS
04_timer.sql: ALL PASS
05_fuel.sql: ALL PASS
06_exploration.sql: ALL PASS
07_badges.sql: ALL PASS
08_social.sql: ALL PASS
09_indexes.sql: ALL PASS
10_seeds.sql: ALL PASS
11_realtime_queries.sql: ALL PASS
✓ All tests passed
```

---

## 📐 범위 밖 (이 플랜에서 하지 않는 것)

- Spring Boot 엔티티/Repository/Service 작성 (별도 백엔드 프로젝트)
- API 엔드포인트 구현 (`POST /api/study-status` 등은 별도 API 설계)
- Flyway 실제 통합 (Spring Boot 앱에 Flyway 의존성 추가, application.yml 설정)
- 파티셔닝, 리드 리플리카, 백업 정책
- CI/CD 파이프라인에서 마이그레이션 자동 실행

이 플랜의 산출물(`db/migration/V*.sql`)은 나중에 Spring Boot 프로젝트의 `src/main/resources/db/migration/`으로 **그대로 복사/심볼릭 링크**하여 Flyway가 읽게 하면 된다.
