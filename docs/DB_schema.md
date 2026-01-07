# 🗄️ DB 스키마: 우주공부선 (StudyShip)

> Spring Boot + MySQL 환경

---

## 1. 스키마 개요

### ERD 구조

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              MASTER DATA                                │
├─────────────────────────────────────────────────────────────────────────┤
│  levels            location_categories       locations                  │
│  badge_categories  badges                    ships                      │
│  missions                                                               │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              USER DATA                                  │
├─────────────────────────────────────────────────────────────────────────┤
│  users ◄──┬── social_accounts                                          │
│           ├── user_settings                                             │
│           ├── todos                                                     │
│           ├── timer_sessions                                            │
│           ├── fuel_histories                                            │
│           ├── study_daily_records                                       │
│           ├── user_locations                                            │
│           ├── user_badges                                               │
│           ├── user_ships                                                │
│           ├── user_missions                                             │
│           ├── notifications                                             │
│           └── nickname_change_histories                                 │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              SOCIAL DATA                                │
├─────────────────────────────────────────────────────────────────────────┤
│  friendships                friend_requests                             │
│  friend_request_cooldowns                                               │
│  groups                     group_members                               │
│  group_rejoin_cooldowns     group_name_change_histories                 │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 데이터베이스 생성

```sql
-- 데이터베이스 생성
CREATE DATABASE studyship
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE studyship;
```

---

## 3. 마스터 테이블 (Master Data)

### 3-1. levels (레벨)

```sql
CREATE TABLE levels (
    level INT NOT NULL PRIMARY KEY,
    required_study_time INT NOT NULL COMMENT '필요 누적 공부시간 (분)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_required_study_time (required_study_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='레벨 마스터';

-- 초기 데이터
INSERT INTO levels (level, required_study_time) VALUES
(1, 0),
(2, 300),       -- 5시간
(3, 900),       -- 15시간
(4, 1800),      -- 30시간
(5, 3000),      -- 50시간
(6, 4800),      -- 80시간
(7, 7200),      -- 120시간
(8, 10200),     -- 170시간
(9, 14400),     -- 240시간
(10, 20000),    -- 333시간
(11, 26400),    -- 440시간
(12, 33600),    -- 560시간
(13, 42000),    -- 700시간
(14, 51600),    -- 860시간
(15, 63000),    -- 1050시간
(20, 120000),   -- 2000시간
(25, 210000),   -- 3500시간
(30, 360000);   -- 6000시간
```

---

### 3-2. location_categories (장소 카테고리)

```sql
CREATE TABLE location_categories (
    category_id VARCHAR(50) NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200) NULL,
    display_order INT NOT NULL DEFAULT 0,
    unlock_condition_type ENUM('default', 'category_complete') NOT NULL DEFAULT 'default',
    required_category_id VARCHAR(50) NULL COMMENT '선행 완료 필요 카테고리',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_display_order (display_order),
    CONSTRAINT fk_location_categories_required 
        FOREIGN KEY (required_category_id) REFERENCES location_categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='장소 카테고리 마스터';

-- 초기 데이터
INSERT INTO location_categories (category_id, name, description, display_order, unlock_condition_type, required_category_id) VALUES
('korea', '국내', '대한민국 여행지', 1, 'default', NULL),
('overseas', '해외', '세계 여러 나라', 2, 'category_complete', 'korea'),
('space', '우주', '우주 탐험', 3, 'category_complete', 'overseas');
```

---

### 3-3. locations (장소)

```sql
CREATE TABLE locations (
    location_id VARCHAR(50) NOT NULL PRIMARY KEY,
    category_id VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    image_url VARCHAR(500) NULL,
    required_fuel DECIMAL(10,1) NOT NULL DEFAULT 0 COMMENT '필요 연료',
    reward_ship_id VARCHAR(50) NULL COMMENT '해금 시 보상 공부선',
    display_order INT NOT NULL DEFAULT 0,
    is_default TINYINT(1) NOT NULL DEFAULT 0 COMMENT '기본 해금 여부',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_category_id (category_id),
    INDEX idx_display_order (display_order),
    CONSTRAINT fk_locations_category 
        FOREIGN KEY (category_id) REFERENCES location_categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='장소 마스터';

-- 국내
INSERT INTO locations (location_id, category_id, name, required_fuel, display_order, is_default) VALUES
('seoul', 'korea', '서울', 0, 1, 1),
('busan', 'korea', '부산', 1.0, 2, 0),
('jeju', 'korea', '제주', 3.0, 3, 0),
('daejeon', 'korea', '대전', 2.0, 4, 0),
('gangneung', 'korea', '강릉', 2.0, 5, 0);

-- 해외
INSERT INTO locations (location_id, category_id, name, required_fuel, display_order) VALUES
('japan', 'overseas', '일본', 5.0, 1),
('china', 'overseas', '중국', 5.0, 2),
('thailand', 'overseas', '태국', 7.0, 3),
('usa', 'overseas', '미국', 10.0, 4),
('france', 'overseas', '프랑스', 10.0, 5);

-- 우주
INSERT INTO locations (location_id, category_id, name, required_fuel, reward_ship_id, display_order) VALUES
('moon', 'space', '달', 20.0, 'ship_moon', 1),
('mars', 'space', '화성', 30.0, 'ship_mars', 2),
('jupiter', 'space', '목성', 50.0, 'ship_jupiter', 3),
('saturn', 'space', '토성', 70.0, 'ship_saturn', 4),
('neptune', 'space', '해왕성', 100.0, 'ship_neptune', 5);
```

---

### 3-4. badge_categories (뱃지 카테고리)

```sql
CREATE TABLE badge_categories (
    category_id VARCHAR(50) NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='뱃지 카테고리 마스터';

-- 초기 데이터
INSERT INTO badge_categories (category_id, name, display_order) VALUES
('time', '시간 누적', 1),
('streak', '스트릭', 2),
('explore', '탐험', 3),
('social', '소셜', 4),
('hidden', '히든', 5);
```

---

### 3-5. badges (뱃지)

```sql
CREATE TABLE badges (
    badge_id VARCHAR(50) NOT NULL PRIMARY KEY,
    category_id VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    image_url VARCHAR(500) NULL,
    rarity ENUM('common', 'rare', 'epic', 'legendary', 'hidden') NOT NULL DEFAULT 'common',
    condition_type VARCHAR(50) NOT NULL COMMENT '조건 타입',
    condition_value INT NULL COMMENT '조건 값',
    condition_description VARCHAR(200) NULL COMMENT '획득 조건 설명',
    display_order INT NOT NULL DEFAULT 0,
    is_hidden TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_category_id (category_id),
    INDEX idx_rarity (rarity),
    INDEX idx_condition_type (condition_type),
    CONSTRAINT fk_badges_category 
        FOREIGN KEY (category_id) REFERENCES badge_categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='뱃지 마스터';

-- 시간 누적 뱃지
INSERT INTO badges (badge_id, category_id, name, description, rarity, condition_type, condition_value, condition_description, display_order) VALUES
('time_10h', 'time', '견습 탐험가', '총 10시간 공부 달성', 'common', 'total_study_time', 600, '총 10시간 공부', 1),
('time_50h', 'time', '초보 탐험가', '총 50시간 공부 달성', 'common', 'total_study_time', 3000, '총 50시간 공부', 2),
('time_100h', 'time', '스타 파일럿', '총 100시간 공부 달성', 'rare', 'total_study_time', 6000, '총 100시간 공부', 3),
('time_500h', 'time', '베테랑 탐험가', '총 500시간 공부 달성', 'epic', 'total_study_time', 30000, '총 500시간 공부', 4),
('time_1000h', 'time', '레전드', '총 1000시간 공부 달성', 'legendary', 'total_study_time', 60000, '총 1000시간 공부', 5);

-- 스트릭 뱃지
INSERT INTO badges (badge_id, category_id, name, description, rarity, condition_type, condition_value, condition_description, display_order) VALUES
('streak_3', 'streak', '3일 연속', '3일 연속 공부', 'common', 'streak_days', 3, '3일 연속 공부', 1),
('streak_7', 'streak', '일주일 연속', '7일 연속 공부', 'common', 'streak_days', 7, '7일 연속 공부', 2),
('streak_30', 'streak', '한 달 연속', '30일 연속 공부', 'rare', 'streak_days', 30, '30일 연속 공부', 3),
('streak_100', 'streak', '100일 연속', '100일 연속 공부', 'epic', 'streak_days', 100, '100일 연속 공부', 4),
('streak_365', 'streak', '1년 연속', '365일 연속 공부', 'legendary', 'streak_days', 365, '365일 연속 공부', 5);

-- 탐험 뱃지
INSERT INTO badges (badge_id, category_id, name, description, rarity, condition_type, condition_value, condition_description, display_order) VALUES
('explore_korea', 'explore', '국내 완주', '국내 모든 장소 해금', 'rare', 'category_complete', NULL, '국내 모든 장소 해금', 1),
('explore_overseas', 'explore', '세계 일주', '해외 모든 장소 해금', 'epic', 'category_complete', NULL, '해외 모든 장소 해금', 2),
('explore_space', 'explore', '우주 정복', '우주 모든 장소 해금', 'legendary', 'category_complete', NULL, '우주 모든 장소 해금', 3);

-- 소셜 뱃지
INSERT INTO badges (badge_id, category_id, name, description, rarity, condition_type, condition_value, condition_description, display_order) VALUES
('social_first_friend', 'social', '첫 친구', '첫 번째 친구 추가', 'common', 'friends_count', 1, '친구 1명 추가', 1),
('social_10_friends', 'social', '인기인', '친구 10명 달성', 'rare', 'friends_count', 10, '친구 10명', 2),
('social_50_friends', 'social', '사교계의 별', '친구 50명 달성', 'epic', 'friends_count', 50, '친구 50명', 3),
('social_first_group', 'social', '그룹 창설자', '첫 그룹 생성', 'common', 'groups_created', 1, '그룹 1개 생성', 4);

-- 히든 뱃지
INSERT INTO badges (badge_id, category_id, name, description, rarity, condition_type, condition_value, condition_description, display_order, is_hidden) VALUES
('hidden_night', 'hidden', '한밤의 탐험가', '새벽 3시에 공부 시작', 'hidden', 'night_study', 3, '???', 1, 1),
('hidden_marathon', 'hidden', '마라토너', '5시간 연속 공부', 'hidden', 'continuous_study', 300, '???', 2, 1),
('hidden_perfect_week', 'hidden', '퍼펙트 위크', '주 7일 모든 일일미션 완료', 'hidden', 'perfect_week', 1, '???', 3, 1);
```

---

### 3-6. ships (공부선 스킨)

```sql
CREATE TABLE ships (
    ship_id VARCHAR(50) NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    image_url VARCHAR(500) NOT NULL,
    animation_url VARCHAR(500) NULL COMMENT 'Rive 애니메이션 URL',
    rarity ENUM('common', 'rare', 'epic', 'legendary') NOT NULL DEFAULT 'common',
    ship_type ENUM('static', 'animated') NOT NULL DEFAULT 'static',
    obtain_method VARCHAR(200) NULL COMMENT '획득 방법',
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    display_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_rarity (rarity),
    INDEX idx_ship_type (ship_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='공부선 스킨 마스터';

-- 기본 공부선
INSERT INTO ships (ship_id, name, description, image_url, rarity, ship_type, obtain_method, is_default, display_order) VALUES
('ship_basic', '기본 공부선', '모든 탐험가의 첫 공부선', '/ships/basic.png', 'common', 'static', '기본 제공', 1, 1),
('ship_red', '레드 공부선', '열정의 빨간색', '/ships/red.png', 'common', 'static', '10시간 달성', 0, 2),
('ship_blue', '블루 공부선', '차분한 파란색', '/ships/blue.png', 'common', 'static', '부산 해금', 0, 3),
('ship_green', '그린 공부선', '자연의 초록색', '/ships/green.png', 'common', 'static', '대전 해금', 0, 4);

-- 국가 테마 공부선
INSERT INTO ships (ship_id, name, description, image_url, rarity, ship_type, obtain_method, display_order) VALUES
('ship_japan', '일본 테마', '일본 스타일 공부선', '/ships/japan.png', 'rare', 'static', '일본 해금', 10),
('ship_china', '중국 테마', '중국 스타일 공부선', '/ships/china.png', 'rare', 'static', '중국 해금', 11),
('ship_usa', '미국 테마', '미국 스타일 공부선', '/ships/usa.png', 'rare', 'static', '미국 해금', 12),
('ship_france', '프랑스 테마', '프랑스 스타일 공부선', '/ships/france.png', 'rare', 'static', '프랑스 해금', 13);

-- 우주 공부선 (애니메이션)
INSERT INTO ships (ship_id, name, description, image_url, animation_url, rarity, ship_type, obtain_method, display_order) VALUES
('ship_moon', '달 탐사선', '달을 탐험하는 공부선', '/ships/moon.png', '/ships/moon.riv', 'epic', 'animated', '달 해금', 20),
('ship_mars', '화성 탐사선', '화성을 탐험하는 공부선', '/ships/mars.png', '/ships/mars.riv', 'epic', 'animated', '화성 해금', 21),
('ship_jupiter', '목성 탐사선', '목성을 탐험하는 공부선', '/ships/jupiter.png', '/ships/jupiter.riv', 'legendary', 'animated', '목성 해금', 22),
('ship_saturn', '토성 탐사선', '토성을 탐험하는 공부선', '/ships/saturn.png', '/ships/saturn.riv', 'legendary', 'animated', '토성 해금', 23),
('ship_neptune', '해왕성 탐사선', '해왕성을 탐험하는 공부선', '/ships/neptune.png', '/ships/neptune.riv', 'legendary', 'animated', '해왕성 해금', 24);
```

---

### 3-7. missions (미션)

```sql
CREATE TABLE missions (
    mission_id VARCHAR(50) NOT NULL PRIMARY KEY,
    mission_type ENUM('daily', 'weekly', 'hidden') NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    reward_fuel DECIMAL(10,1) NOT NULL DEFAULT 0,
    condition_type VARCHAR(50) NOT NULL COMMENT '조건 타입',
    condition_value INT NOT NULL COMMENT '목표 값',
    display_order INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_mission_type (mission_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='미션 마스터';

-- 일일 미션
INSERT INTO missions (mission_id, mission_type, title, description, reward_fuel, condition_type, condition_value, display_order) VALUES
('daily_attendance', 'daily', '오늘의 출석', '앱에 접속하세요', 0.1, 'attendance', 1, 1),
('daily_first_focus', 'daily', '첫 집중', '오늘 첫 타이머를 완료하세요', 0.2, 'first_timer', 1, 2),
('daily_todo_3', 'daily', 'Todo 3개 완료', 'Todo 3개를 완료하세요', 0.3, 'todo_complete', 3, 3),
('daily_1hour', 'daily', '1시간 집중', '오늘 1시간 이상 공부하세요', 0.5, 'daily_study_time', 60, 4),
('daily_early_bird', 'daily', '얼리버드', '오전 9시 전에 공부를 시작하세요', 0.3, 'early_bird', 9, 5);

-- 주간 미션
INSERT INTO missions (mission_id, mission_type, title, description, reward_fuel, condition_type, condition_value, display_order) VALUES
('weekly_10hour', 'weekly', '주간 목표', '이번 주 10시간 공부하세요', 2.0, 'weekly_study_time', 600, 1),
('weekly_5days', 'weekly', '꾸준함의 힘', '이번 주 5일 이상 접속하세요', 1.0, 'weekly_attendance', 5, 2),
('weekly_todo_20', 'weekly', 'Todo 마스터', '이번 주 Todo 20개 완료하세요', 1.5, 'weekly_todo_complete', 20, 3),
('weekly_friend', 'weekly', '소셜 탐험가', '친구 1명을 추가하세요', 1.0, 'add_friend', 1, 4);

-- 히든 미션
INSERT INTO missions (mission_id, mission_type, title, description, reward_fuel, condition_type, condition_value, display_order) VALUES
('hidden_night', 'hidden', '한밤의 탐험가', '새벽 3시에 공부 시작', 3.0, 'night_study', 3, 1),
('hidden_marathon', 'hidden', '마라토너', '5시간 연속 공부', 10.0, 'continuous_study', 300, 2),
('hidden_perfect_week', 'hidden', '퍼펙트 위크', '주 7일 모든 일일미션 완료', 10.0, 'perfect_week', 7, 3);
```

---

## 4. 사용자 테이블 (User Data)

### 4-1. users (사용자)

```sql
CREATE TABLE users (
    user_id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT 'UUID',
    nickname VARCHAR(12) NULL UNIQUE,
    profile_image_url VARCHAR(500) NULL,
    bio VARCHAR(50) NULL COMMENT '자기소개',
    goal VARCHAR(30) NULL COMMENT '목표',
    friend_code VARCHAR(20) NOT NULL UNIQUE COMMENT '친구 코드',
    
    -- 레벨/연료
    level INT NOT NULL DEFAULT 1,
    total_study_time INT NOT NULL DEFAULT 0 COMMENT '총 공부시간 (분)',
    current_fuel DECIMAL(10,1) NOT NULL DEFAULT 0 COMMENT '현재 연료',
    total_fuel_earned DECIMAL(10,1) NOT NULL DEFAULT 0 COMMENT '총 획득 연료',
    total_fuel_spent DECIMAL(10,1) NOT NULL DEFAULT 0 COMMENT '총 사용 연료',
    
    -- 스트릭
    current_streak INT NOT NULL DEFAULT 0 COMMENT '현재 연속일',
    max_streak INT NOT NULL DEFAULT 0 COMMENT '최대 연속일',
    last_study_date DATE NULL COMMENT '마지막 공부 날짜',
    
    -- 현재 위치/공부선
    current_location_id VARCHAR(50) NULL,
    representative_ship_id VARCHAR(50) NULL,
    
    -- 상태
    onboarding_completed TINYINT(1) NOT NULL DEFAULT 0,
    accepts_friend_requests TINYINT(1) NOT NULL DEFAULT 1,
    status ENUM('active', 'withdrawal_pending', 'deleted') NOT NULL DEFAULT 'active',
    withdrawal_requested_at DATETIME NULL,
    scheduled_deletion_at DATETIME NULL,
    
    -- 통계
    groups_created_count INT NOT NULL DEFAULT 0 COMMENT '생성한 그룹 수',
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_nickname (nickname),
    INDEX idx_friend_code (friend_code),
    INDEX idx_level (level),
    INDEX idx_status (status),
    INDEX idx_current_streak (current_streak),
    CONSTRAINT fk_users_location 
        FOREIGN KEY (current_location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_users_ship 
        FOREIGN KEY (representative_ship_id) REFERENCES ships(ship_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='사용자';
```

---

### 4-2. social_accounts (소셜 계정)

```sql
CREATE TABLE social_accounts (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    provider ENUM('google', 'kakao', 'apple') NOT NULL,
    provider_id VARCHAR(255) NOT NULL COMMENT '소셜 제공자 사용자 ID',
    email VARCHAR(255) NULL,
    connected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_provider_provider_id (provider, provider_id),
    INDEX idx_user_id (user_id),
    CONSTRAINT fk_social_accounts_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='소셜 계정 연동';
```

---

### 4-3. user_settings (사용자 설정)

```sql
CREATE TABLE user_settings (
    user_id VARCHAR(36) NOT NULL PRIMARY KEY,
    push_enabled TINYINT(1) NOT NULL DEFAULT 1,
    streak_reminder TINYINT(1) NOT NULL DEFAULT 1,
    friend_request_notification TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_user_settings_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='사용자 설정';
```

---

### 4-4. nickname_change_histories (닉네임 변경 이력)

```sql
CREATE TABLE nickname_change_histories (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    old_nickname VARCHAR(12) NULL,
    new_nickname VARCHAR(12) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_changed_at (changed_at),
    CONSTRAINT fk_nickname_histories_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='닉네임 변경 이력';
```

---

### 4-5. todos (할 일)

```sql
CREATE TABLE todos (
    todo_id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT 'UUID',
    user_id VARCHAR(36) NOT NULL,
    title VARCHAR(100) NOT NULL,
    todo_date DATE NOT NULL COMMENT '할 일 날짜',
    is_completed TINYINT(1) NOT NULL DEFAULT 0,
    completed_at DATETIME NULL,
    display_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_user_date (user_id, todo_date),
    INDEX idx_todo_date (todo_date),
    CONSTRAINT fk_todos_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='할 일';
```

---

### 4-6. timer_sessions (타이머 세션)

```sql
CREATE TABLE timer_sessions (
    session_id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT 'UUID',
    user_id VARCHAR(36) NOT NULL,
    todo_id VARCHAR(36) NULL COMMENT '연결된 Todo',
    
    status ENUM('running', 'paused', 'completed', 'auto_ended') NOT NULL DEFAULT 'running',
    started_at DATETIME NOT NULL,
    paused_at DATETIME NULL,
    ended_at DATETIME NULL,
    
    -- 시간 기록
    total_duration INT NOT NULL DEFAULT 0 COMMENT '총 시간 (초)',
    total_paused_duration INT NOT NULL DEFAULT 0 COMMENT '총 일시정지 시간 (초)',
    
    -- 연료 보상
    base_fuel DECIMAL(10,1) NOT NULL DEFAULT 0,
    bonus_fuel DECIMAL(10,1) NOT NULL DEFAULT 0,
    total_fuel DECIMAL(10,1) NOT NULL DEFAULT 0,
    
    -- 기록 날짜 (자정 처리용)
    record_date DATE NOT NULL COMMENT '기록될 날짜 (시작 기준)',
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_user_status (user_id, status),
    INDEX idx_record_date (record_date),
    INDEX idx_started_at (started_at),
    CONSTRAINT fk_timer_sessions_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_timer_sessions_todo 
        FOREIGN KEY (todo_id) REFERENCES todos(todo_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='타이머 세션';
```

---

### 4-7. study_daily_records (일별 공부 기록)

```sql
CREATE TABLE study_daily_records (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    record_date DATE NOT NULL,
    total_study_time INT NOT NULL DEFAULT 0 COMMENT '총 공부시간 (분)',
    session_count INT NOT NULL DEFAULT 0 COMMENT '세션 수',
    todo_completed_count INT NOT NULL DEFAULT 0 COMMENT '완료한 Todo 수',
    fuel_earned DECIMAL(10,1) NOT NULL DEFAULT 0 COMMENT '획득 연료',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_date (user_id, record_date),
    INDEX idx_user_id (user_id),
    INDEX idx_record_date (record_date),
    CONSTRAINT fk_study_daily_records_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='일별 공부 기록';
```

---

### 4-8. fuel_histories (연료 내역)

```sql
CREATE TABLE fuel_histories (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    fuel_type ENUM('earned', 'spent') NOT NULL,
    amount DECIMAL(10,1) NOT NULL COMMENT '양수: 획득, 음수: 사용',
    source VARCHAR(50) NOT NULL COMMENT 'timer, mission, location_unlock 등',
    source_id VARCHAR(36) NULL COMMENT '관련 ID (세션ID, 미션ID 등)',
    description VARCHAR(200) NULL,
    balance_after DECIMAL(10,1) NOT NULL COMMENT '거래 후 잔액',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_user_type (user_id, fuel_type),
    INDEX idx_created_at (created_at),
    CONSTRAINT fk_fuel_histories_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='연료 내역';
```

---

### 4-9. user_locations (사용자 장소 해금)

```sql
CREATE TABLE user_locations (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    location_id VARCHAR(50) NOT NULL,
    unlocked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_location (user_id, location_id),
    INDEX idx_user_id (user_id),
    CONSTRAINT fk_user_locations_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_locations_location 
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='사용자 장소 해금';
```

---

### 4-10. user_badges (사용자 뱃지)

```sql
CREATE TABLE user_badges (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    badge_id VARCHAR(50) NOT NULL,
    is_representative TINYINT(1) NOT NULL DEFAULT 0 COMMENT '대표 뱃지 여부',
    representative_order INT NULL COMMENT '대표 뱃지 순서 (1,2,3)',
    earned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_badge (user_id, badge_id),
    INDEX idx_user_id (user_id),
    INDEX idx_representative (user_id, is_representative),
    CONSTRAINT fk_user_badges_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_badges_badge 
        FOREIGN KEY (badge_id) REFERENCES badges(badge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='사용자 뱃지';
```

---

### 4-11. user_ships (사용자 공부선)

```sql
CREATE TABLE user_ships (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    ship_id VARCHAR(50) NOT NULL,
    obtained_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_ship (user_id, ship_id),
    INDEX idx_user_id (user_id),
    CONSTRAINT fk_user_ships_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_ships_ship 
        FOREIGN KEY (ship_id) REFERENCES ships(ship_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='사용자 공부선';
```

---

### 4-12. user_missions (사용자 미션 진행)

```sql
CREATE TABLE user_missions (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    mission_id VARCHAR(50) NOT NULL,
    period_key VARCHAR(20) NOT NULL COMMENT '기간 키 (daily: 2024-01-15, weekly: 2024-W03)',
    current_progress INT NOT NULL DEFAULT 0,
    is_completed TINYINT(1) NOT NULL DEFAULT 0,
    completed_at DATETIME NULL,
    is_claimed TINYINT(1) NOT NULL DEFAULT 0 COMMENT '보상 수령 여부',
    claimed_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_mission_period (user_id, mission_id, period_key),
    INDEX idx_user_id (user_id),
    INDEX idx_period_key (period_key),
    INDEX idx_user_period (user_id, period_key),
    CONSTRAINT fk_user_missions_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_missions_mission 
        FOREIGN KEY (mission_id) REFERENCES missions(mission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='사용자 미션 진행';
```

---

### 4-13. daily_mission_bonus (일일 미션 보너스)

```sql
CREATE TABLE daily_mission_bonuses (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    bonus_date DATE NOT NULL,
    is_claimed TINYINT(1) NOT NULL DEFAULT 0,
    claimed_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_date (user_id, bonus_date),
    INDEX idx_user_id (user_id),
    CONSTRAINT fk_daily_mission_bonus_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='일일 미션 전체 완료 보너스';
```

---

### 4-14. notifications (알림)

```sql
CREATE TABLE notifications (
    notification_id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT 'UUID',
    user_id VARCHAR(36) NOT NULL,
    notification_type VARCHAR(50) NOT NULL COMMENT '알림 타입',
    title VARCHAR(100) NOT NULL,
    body VARCHAR(500) NULL,
    data JSON NULL COMMENT '추가 데이터',
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    read_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created_at (created_at),
    CONSTRAINT fk_notifications_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='알림';
```

---

## 5. 소셜 테이블 (Social Data)

### 5-1. friendships (친구 관계)

```sql
CREATE TABLE friendships (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    friend_id VARCHAR(36) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_friend (user_id, friend_id),
    INDEX idx_user_id (user_id),
    INDEX idx_friend_id (friend_id),
    CONSTRAINT fk_friendships_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_friendships_friend 
        FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='친구 관계 (양방향 저장)';
```

---

### 5-2. friend_requests (친구 요청)

```sql
CREATE TABLE friend_requests (
    request_id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT 'UUID',
    from_user_id VARCHAR(36) NOT NULL,
    to_user_id VARCHAR(36) NOT NULL,
    status ENUM('pending', 'accepted', 'rejected') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at DATETIME NULL,
    
    UNIQUE KEY uk_from_to_pending (from_user_id, to_user_id, status),
    INDEX idx_from_user_id (from_user_id),
    INDEX idx_to_user_id (to_user_id),
    INDEX idx_to_user_status (to_user_id, status),
    CONSTRAINT fk_friend_requests_from 
        FOREIGN KEY (from_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_friend_requests_to 
        FOREIGN KEY (to_user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='친구 요청';
```

---

### 5-3. friend_request_cooldowns (친구 요청 쿨다운)

```sql
CREATE TABLE friend_request_cooldowns (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    from_user_id VARCHAR(36) NOT NULL,
    to_user_id VARCHAR(36) NOT NULL,
    cooldown_until DATETIME NOT NULL COMMENT '쿨다운 종료 시간',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_from_to (from_user_id, to_user_id),
    INDEX idx_cooldown_until (cooldown_until),
    CONSTRAINT fk_friend_cooldowns_from 
        FOREIGN KEY (from_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_friend_cooldowns_to 
        FOREIGN KEY (to_user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='친구 요청 쿨다운 (거절 후 5분)';
```

---

### 5-4. groups (그룹)

```sql
CREATE TABLE `groups` (
    group_id VARCHAR(36) NOT NULL PRIMARY KEY COMMENT 'UUID',
    name VARCHAR(20) NOT NULL,
    description VARCHAR(100) NULL,
    invite_code VARCHAR(20) NOT NULL UNIQUE,
    owner_id VARCHAR(36) NOT NULL,
    member_count INT NOT NULL DEFAULT 1,
    max_members INT NOT NULL DEFAULT 20,
    name_change_count INT NOT NULL DEFAULT 0 COMMENT '이름 변경 횟수',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_owner_id (owner_id),
    INDEX idx_invite_code (invite_code),
    CONSTRAINT fk_groups_owner 
        FOREIGN KEY (owner_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='그룹';
```

---

### 5-5. group_members (그룹 멤버)

```sql
CREATE TABLE group_members (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    group_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    role ENUM('owner', 'member') NOT NULL DEFAULT 'member',
    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_group_user (group_id, user_id),
    INDEX idx_group_id (group_id),
    INDEX idx_user_id (user_id),
    CONSTRAINT fk_group_members_group 
        FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE,
    CONSTRAINT fk_group_members_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='그룹 멤버';
```

---

### 5-6. group_rejoin_cooldowns (그룹 재가입 쿨다운)

```sql
CREATE TABLE group_rejoin_cooldowns (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    group_id VARCHAR(36) NOT NULL,
    cooldown_until DATETIME NOT NULL COMMENT '재가입 가능 시간',
    reason ENUM('left', 'kicked') NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_group (user_id, group_id),
    INDEX idx_cooldown_until (cooldown_until),
    CONSTRAINT fk_group_cooldowns_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_group_cooldowns_group 
        FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='그룹 재가입 쿨다운 (24시간)';
```

---

### 5-7. group_name_change_histories (그룹 이름 변경 이력)

```sql
CREATE TABLE group_name_change_histories (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    group_id VARCHAR(36) NOT NULL,
    old_name VARCHAR(20) NOT NULL,
    new_name VARCHAR(20) NOT NULL,
    changed_by VARCHAR(36) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_group_id (group_id),
    CONSTRAINT fk_group_name_histories_group 
        FOREIGN KEY (group_id) REFERENCES `groups`(group_id) ON DELETE CASCADE,
    CONSTRAINT fk_group_name_histories_user 
        FOREIGN KEY (changed_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='그룹 이름 변경 이력';
```

---

## 6. 랭킹/통계용 뷰 (Views)

### 6-1. 주간 공부 통계 뷰

```sql
CREATE VIEW v_weekly_study_stats AS
SELECT 
    user_id,
    YEARWEEK(record_date, 1) AS year_week,
    SUM(total_study_time) AS weekly_study_time,
    SUM(session_count) AS weekly_session_count,
    SUM(todo_completed_count) AS weekly_todo_count,
    SUM(fuel_earned) AS weekly_fuel_earned,
    COUNT(DISTINCT record_date) AS active_days
FROM study_daily_records
WHERE record_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY user_id, YEARWEEK(record_date, 1);
```

---

### 6-2. 그룹별 주간 통계 뷰

```sql
CREATE VIEW v_group_weekly_stats AS
SELECT 
    gm.group_id,
    gm.user_id,
    u.nickname,
    u.profile_image_url,
    u.level,
    COALESCE(SUM(sdr.total_study_time), 0) AS weekly_study_time
FROM group_members gm
JOIN users u ON gm.user_id = u.user_id
LEFT JOIN study_daily_records sdr 
    ON gm.user_id = sdr.user_id 
    AND sdr.record_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY gm.group_id, gm.user_id, u.nickname, u.profile_image_url, u.level;
```

---

## 7. 인덱스 추가 (성능 최적화)

```sql
-- 랭킹 조회 최적화
ALTER TABLE users ADD INDEX idx_ranking (status, total_study_time DESC);

-- 주간 랭킹용 (study_daily_records 기반)
ALTER TABLE study_daily_records ADD INDEX idx_weekly_ranking (record_date, user_id, total_study_time);

-- 친구 목록 + 주간 통계 조인 최적화
ALTER TABLE friendships ADD INDEX idx_friend_stats (user_id, friend_id);

-- 그룹 랭킹 최적화
ALTER TABLE group_members ADD INDEX idx_group_ranking (group_id, user_id);

-- 미션 조회 최적화
ALTER TABLE user_missions ADD INDEX idx_mission_status (user_id, period_key, is_completed, is_claimed);

-- 알림 목록 최적화
ALTER TABLE notifications ADD INDEX idx_notification_list (user_id, is_read, created_at DESC);
```

---

## 8. 스키마 요약

### 테이블 목록

| 구분 | 테이블명 | 설명 |
|------|----------|------|
| **Master** | levels | 레벨 마스터 |
| | location_categories | 장소 카테고리 |
| | locations | 장소 |
| | badge_categories | 뱃지 카테고리 |
| | badges | 뱃지 |
| | ships | 공부선 스킨 |
| | missions | 미션 |
| **User** | users | 사용자 |
| | social_accounts | 소셜 계정 |
| | user_settings | 사용자 설정 |
| | nickname_change_histories | 닉네임 변경 이력 |
| | todos | 할 일 |
| | timer_sessions | 타이머 세션 |
| | study_daily_records | 일별 공부 기록 |
| | fuel_histories | 연료 내역 |
| | user_locations | 사용자 장소 해금 |
| | user_badges | 사용자 뱃지 |
| | user_ships | 사용자 공부선 |
| | user_missions | 사용자 미션 진행 |
| | daily_mission_bonuses | 일일 미션 보너스 |
| | notifications | 알림 |
| **Social** | friendships | 친구 관계 |
| | friend_requests | 친구 요청 |
| | friend_request_cooldowns | 친구 요청 쿨다운 |
| | groups | 그룹 |
| | group_members | 그룹 멤버 |
| | group_rejoin_cooldowns | 그룹 재가입 쿨다운 |
| | group_name_change_histories | 그룹 이름 변경 이력 |

### 테이블 수

| 구분 | 개수 |
|------|------|
| 마스터 테이블 | 7개 |
| 사용자 테이블 | 14개 |
| 소셜 테이블 | 7개 |
| 뷰 | 2개 |
| **총계** | **30개** |

---
