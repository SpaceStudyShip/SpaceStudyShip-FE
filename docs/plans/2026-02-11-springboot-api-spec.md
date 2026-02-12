# Spring Boot Backend API Specification & Flutter Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Supabase → Spring Boot 백엔드로 마이그레이션하고, Firebase ID Token 기반 소셜 로그인 + JWT 인증 시스템을 구축한다.

**Architecture:** Flutter 앱 → Firebase Auth (Google/Kakao/Apple) → Spring Boot REST API → JWT (accessToken + refreshToken). 클라이언트는 Firebase에서 받은 idToken을 서버로 전송하고, 서버는 이를 검증 후 자체 JWT를 발급한다.

**Tech Stack:** Flutter + Dio + Retrofit / Spring Boot 3.x + Spring Security + Firebase Admin SDK + JPA/MySQL + Redis(토큰 블랙리스트)

---

## Part 1: API 명세 (REST API Specification)

### 1.1 공통 사항

**Base URL:** `https://api.spacestudyship.com/api/v1`

**인증 헤더:**
```
Authorization: Bearer <accessToken>
```

**공통 에러 응답:**
```json
{
  "status": 401,
  "error": "UNAUTHORIZED",
  "message": "액세스 토큰이 만료되었습니다",
  "timestamp": "2026-02-11T12:00:00Z"
}
```

**공통 에러 코드:**

| HTTP | error | 설명 |
|------|-------|------|
| 400 | BAD_REQUEST | 잘못된 요청 (파라미터 누락/형식 오류) |
| 401 | UNAUTHORIZED | 인증 실패 (토큰 만료/무효) |
| 403 | FORBIDDEN | 권한 부족 |
| 404 | NOT_FOUND | 리소스 없음 |
| 409 | CONFLICT | 중복 데이터 |
| 429 | TOO_MANY_REQUESTS | 요청 제한 초과 |
| 500 | INTERNAL_ERROR | 서버 내부 오류 |

**페이징 공통 응답:**
```json
{
  "content": [...],
  "page": 0,
  "size": 20,
  "totalElements": 150,
  "totalPages": 8,
  "hasNext": true
}
```

---

### 1.2 인증 API (Auth)

#### POST /auth/login — 소셜 로그인 (회원가입 겸용)

Firebase에서 받은 ID Token으로 로그인/회원가입을 처리한다. 신규 사용자는 자동으로 계정을 생성하고 랜덤 닉네임을 부여한다.

**Request:**
```json
{
  "socialPlatform": "KAKAO",
  "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "fcmToken": "fcm-device-token-here",
  "deviceType": "IOS",
  "deviceId": "550e8400-e29b-41d4-a716-446655440000"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| socialPlatform | String | O | GOOGLE, KAKAO, APPLE |
| idToken | String | O | Firebase ID Token |
| fcmToken | String | X | FCM 푸시 토큰 (null 허용 = 시뮬레이터) |
| deviceType | String | O | IOS, ANDROID |
| deviceId | String | O | 기기 고유 UUID |

**Response (200 OK):**
```json
{
  "userId": 1,
  "nickname": "민첩한괴도5308",
  "profileImageUrl": null,
  "tokens": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4..."
  },
  "isNewUser": true
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| userId | Long | 서버 사용자 ID |
| nickname | String | 닉네임 (신규: 랜덤 생성) |
| profileImageUrl | String? | 프로필 이미지 URL |
| tokens.accessToken | String | JWT 액세스 토큰 (1시간) |
| tokens.refreshToken | String | JWT 리프레시 토큰 (14일) |
| isNewUser | Boolean | 신규 가입 여부 |

**에러:**

| HTTP | error | 상황 |
|------|-------|------|
| 400 | INVALID_TOKEN | Firebase ID Token 검증 실패 |
| 400 | UNSUPPORTED_PLATFORM | 지원하지 않는 소셜 플랫폼 |

---

#### POST /auth/refresh — 토큰 갱신

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

**Response (200 OK):**
```json
{
  "accessToken": "eyJhbGciOiJIUzUxMiJ9...(new)",
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9...(new)"
}
```

**에러:**

| HTTP | error | 상황 |
|------|-------|------|
| 401 | INVALID_REFRESH_TOKEN | 리프레시 토큰 만료/무효 |

---

#### POST /auth/logout — 로그아웃

인증 필요. 현재 기기의 리프레시 토큰을 무효화한다.

**Request:**
```json
{
  "deviceId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200 OK):**
```json
{
  "message": "로그아웃 완료"
}
```

---

#### DELETE /auth/withdraw — 회원 탈퇴

인증 필요. 계정과 모든 데이터를 삭제한다.

**Response (200 OK):**
```json
{
  "message": "회원 탈퇴 완료"
}
```

---

### 1.3 사용자 API (User)

#### GET /users/me — 내 프로필 조회

**Response (200 OK):**
```json
{
  "userId": 1,
  "nickname": "민첩한괴도5308",
  "profileImageUrl": null,
  "statusMessage": "우주 정복을 꿈꾸는 탐험가",
  "representativeBadgeIds": [3, 7, 12],
  "representativeSpaceshipId": "default",
  "stats": {
    "totalStudyMinutes": 7652,
    "totalFuel": 142.5,
    "currentFuel": 3.5,
    "unlockedLocations": 8,
    "totalLocations": 25,
    "currentStreakDays": 5,
    "maxStreakDays": 23
  },
  "socialPlatform": "KAKAO",
  "createdAt": "2026-01-15T09:00:00Z"
}
```

---

#### PATCH /users/me — 프로필 수정

**Request:**
```json
{
  "nickname": "우주탐험가루카",
  "statusMessage": "목표: 화성 도달!",
  "representativeBadgeIds": [3, 7],
  "representativeSpaceshipId": "mars_explorer"
}
```

**Response (200 OK):** 수정된 프로필 (GET /users/me 동일 형식)

**에러:**

| HTTP | error | 상황 |
|------|-------|------|
| 409 | DUPLICATE_NICKNAME | 닉네임 중복 |

---

#### GET /users/{userId} — 다른 사용자 프로필 조회

친구/그룹 멤버의 프로필을 조회한다 (공개 정보만).

**Response (200 OK):**
```json
{
  "userId": 2,
  "nickname": "공부벌레",
  "profileImageUrl": null,
  "statusMessage": "매일 열공!",
  "representativeBadgeIds": [1, 5],
  "representativeSpaceshipId": "blue_rocket",
  "stats": {
    "totalStudyMinutes": 12000,
    "currentStreakDays": 15,
    "maxStreakDays": 45,
    "unlockedLocations": 12
  }
}
```

---

### 1.4 Todo API

#### GET /todos — 할 일 목록 조회

**Query Parameters:**

| 파라미터 | 타입 | 기본값 | 설명 |
|----------|------|--------|------|
| date | String | today | 조회 날짜 (YYYY-MM-DD) |
| completed | Boolean? | null | null=전체, true=완료, false=미완료 |

**Response (200 OK):**
```json
{
  "date": "2026-02-11",
  "todos": [
    {
      "id": 1,
      "title": "알고리즘 2문제 풀기",
      "estimatedMinutes": 30,
      "completed": false,
      "sortOrder": 0,
      "createdAt": "2026-02-11T08:00:00Z",
      "completedAt": null
    },
    {
      "id": 2,
      "title": "영어 단어 50개 외우기",
      "estimatedMinutes": 20,
      "completed": true,
      "sortOrder": 1,
      "createdAt": "2026-02-11T08:01:00Z",
      "completedAt": "2026-02-11T10:30:00Z"
    }
  ],
  "summary": {
    "total": 4,
    "completed": 1,
    "remaining": 3
  }
}
```

---

#### POST /todos — 할 일 생성

**Request:**
```json
{
  "title": "프로젝트 회의 준비",
  "estimatedMinutes": 60,
  "date": "2026-02-11"
}
```

**Response (201 Created):** 생성된 Todo 객체

---

#### PATCH /todos/{id} — 할 일 수정

**Request:**
```json
{
  "title": "프로젝트 회의 준비 (수정)",
  "estimatedMinutes": 45,
  "completed": true
}
```

**Response (200 OK):** 수정된 Todo 객체

---

#### DELETE /todos/{id} — 할 일 삭제

**Response (204 No Content)**

---

#### PATCH /todos/reorder — 할 일 순서 변경

**Request:**
```json
{
  "todoOrders": [
    {"id": 3, "sortOrder": 0},
    {"id": 1, "sortOrder": 1},
    {"id": 2, "sortOrder": 2}
  ]
}
```

**Response (200 OK):**
```json
{
  "message": "순서 변경 완료"
}
```

---

### 1.5 타이머 API (Timer)

#### POST /timer/start — 타이머 시작

**Request:**
```json
{
  "todoId": 1,
  "startedAt": "2026-02-11T14:00:00Z"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| todoId | Long? | X | 연결된 할 일 (null = 자유 집중) |
| startedAt | String | O | ISO 8601 시작 시각 |

**Response (201 Created):**
```json
{
  "sessionId": 42,
  "todoId": 1,
  "startedAt": "2026-02-11T14:00:00Z",
  "status": "RUNNING"
}
```

---

#### POST /timer/stop — 타이머 종료 (Tier 2: 서버 검증)

서버에서 연료를 계산하고 지급한다. 클라이언트는 서버 응답의 연료 값을 신뢰한다.

**Request:**
```json
{
  "sessionId": 42,
  "endedAt": "2026-02-11T15:03:27Z"
}
```

**Response (200 OK):**
```json
{
  "sessionId": 42,
  "todoId": 1,
  "startedAt": "2026-02-11T14:00:00Z",
  "endedAt": "2026-02-11T15:03:27Z",
  "totalMinutes": 63,
  "rewards": {
    "baseFuel": 1.05,
    "hourlyBonus": 0.1,
    "boosterMultiplier": 1.0,
    "totalFuel": 1.15
  },
  "currentFuel": 4.65,
  "status": "COMPLETED"
}
```

| 필드 | 설명 |
|------|------|
| baseFuel | 기본 연료 (분/60) |
| hourlyBonus | 정각 보너스 (60분당 0.1통) |
| boosterMultiplier | 부스터 배율 (기본 1.0) |
| totalFuel | 최종 획득 연료 |
| currentFuel | 잔여 연료 (서버 기준) |

---

#### GET /timer/history — 타이머 기록 조회

**Query Parameters:**

| 파라미터 | 타입 | 기본값 | 설명 |
|----------|------|--------|------|
| from | String | 7일 전 | 시작 날짜 (YYYY-MM-DD) |
| to | String | today | 종료 날짜 (YYYY-MM-DD) |
| page | Int | 0 | 페이지 번호 |
| size | Int | 20 | 페이지 크기 |

**Response (200 OK):**
```json
{
  "content": [
    {
      "sessionId": 42,
      "todoId": 1,
      "todoTitle": "알고리즘 2문제 풀기",
      "startedAt": "2026-02-11T14:00:00Z",
      "endedAt": "2026-02-11T15:03:27Z",
      "totalMinutes": 63,
      "earnedFuel": 1.15
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 35,
  "totalPages": 2,
  "hasNext": true,
  "dailySummary": {
    "totalMinutes": 180,
    "totalFuel": 3.45,
    "sessionCount": 3
  }
}
```

---

### 1.6 연료 API (Fuel)

#### GET /fuel — 현재 연료 조회

**Response (200 OK):**
```json
{
  "currentFuel": 3.5,
  "totalEarnedFuel": 142.5,
  "totalSpentFuel": 139.0
}
```

---

#### GET /fuel/history — 연료 내역 조회

**Query Parameters:** page, size, type (EARN/SPEND/ALL)

**Response (200 OK):**
```json
{
  "content": [
    {
      "id": 100,
      "type": "EARN",
      "amount": 1.15,
      "source": "TIMER",
      "description": "63분 집중 (정각 보너스 포함)",
      "balanceAfter": 4.65,
      "createdAt": "2026-02-11T15:03:27Z"
    },
    {
      "id": 99,
      "type": "SPEND",
      "amount": -3.0,
      "source": "EXPLORATION",
      "description": "제주 해금",
      "balanceAfter": 3.5,
      "createdAt": "2026-02-10T20:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 200,
  "totalPages": 10,
  "hasNext": true
}
```

---

### 1.7 탐험 API (Exploration)

#### GET /exploration/tree — 탐험 트리 조회

전체 탐험 트리를 반환한다 (지구 > 국내/아시아/우주 > 장소).

**Response (200 OK):**
```json
{
  "tree": [
    {
      "id": "solar_system",
      "name": "태양계",
      "nodeType": "SYSTEM",
      "depth": 0,
      "icon": "☀️",
      "children": [
        {
          "id": "earth",
          "name": "지구",
          "nodeType": "PLANET",
          "depth": 1,
          "icon": "🌍",
          "isUnlocked": true,
          "children": [
            {
              "id": "korea",
              "name": "대한민국",
              "nodeType": "REGION",
              "depth": 2,
              "icon": "🇰🇷",
              "requiredFuel": 0,
              "isUnlocked": true,
              "isCleared": true,
              "rewardSpaceshipId": null,
              "children": [
                {
                  "id": "seoul",
                  "name": "서울",
                  "nodeType": "LOCATION",
                  "depth": 3,
                  "icon": "🏙️",
                  "requiredFuel": 0,
                  "isUnlocked": true,
                  "isCleared": true,
                  "description": "대한민국의 수도"
                }
              ]
            }
          ]
        }
      ]
    }
  ],
  "progress": {
    "totalLocations": 25,
    "unlockedLocations": 8,
    "clearedLocations": 5
  }
}
```

---

#### POST /exploration/unlock — 장소 해금 (Tier 2: 서버 검증)

**Request:**
```json
{
  "nodeId": "jeju"
}
```

**Response (200 OK):**
```json
{
  "nodeId": "jeju",
  "name": "제주",
  "isUnlocked": true,
  "spentFuel": 3.0,
  "currentFuel": 0.5,
  "rewardSpaceshipId": null,
  "rewardBadgeId": null
}
```

**에러:**

| HTTP | error | 상황 |
|------|-------|------|
| 400 | INSUFFICIENT_FUEL | 연료 부족 |
| 400 | ALREADY_UNLOCKED | 이미 해금됨 |
| 400 | PREREQUISITE_NOT_MET | 선행 조건 미충족 |

---

### 1.8 소셜 API (Social)

#### 1.8.1 친구 (Friends)

##### GET /friends — 친구 목록

**Query Parameters:** page, size

**Response (200 OK):**
```json
{
  "content": [
    {
      "userId": 2,
      "nickname": "공부벌레",
      "profileImageUrl": null,
      "weeklyStudyMinutes": 1110,
      "currentStreakDays": 15,
      "isOnline": false,
      "representativeBadgeIds": [1, 5]
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 23,
  "totalPages": 2,
  "hasNext": true
}
```

---

##### POST /friends/request — 친구 요청 보내기

**Request:**
```json
{
  "targetUserId": 5
}
```
또는 친구 코드로:
```json
{
  "friendCode": "LUCA2024"
}
```

**Response (201 Created):**
```json
{
  "requestId": 10,
  "targetUserId": 5,
  "targetNickname": "열공러",
  "status": "PENDING"
}
```

---

##### GET /friends/requests — 받은 친구 요청 목록

**Response (200 OK):**
```json
{
  "requests": [
    {
      "requestId": 11,
      "fromUserId": 7,
      "fromNickname": "우주탐험가",
      "fromProfileImageUrl": null,
      "createdAt": "2026-02-10T15:00:00Z"
    }
  ]
}
```

---

##### PATCH /friends/requests/{requestId} — 친구 요청 수락/거절

**Request:**
```json
{
  "action": "ACCEPT"
}
```

| action | 설명 |
|--------|------|
| ACCEPT | 수락 |
| REJECT | 거절 |

**Response (200 OK):**
```json
{
  "requestId": 11,
  "status": "ACCEPTED"
}
```

---

##### DELETE /friends/{userId} — 친구 삭제

**Response (204 No Content)**

---

##### GET /friends/code — 내 친구 코드 조회

**Response (200 OK):**
```json
{
  "friendCode": "LUCA2024"
}
```

---

##### GET /friends/search?query={query} — 친구 검색

닉네임 또는 친구 코드로 검색.

**Response (200 OK):**
```json
{
  "users": [
    {
      "userId": 5,
      "nickname": "열공러",
      "profileImageUrl": null,
      "isFriend": false,
      "isPending": false
    }
  ]
}
```

---

#### 1.8.2 그룹 (Groups)

##### GET /groups — 내 그룹 목록

**Response (200 OK):**
```json
{
  "ownedGroups": [
    {
      "groupId": 1,
      "name": "취준생 스터디",
      "memberCount": 12,
      "weeklyTotalMinutes": 7620,
      "inviteCode": "ABC123",
      "isOwner": true
    }
  ],
  "joinedGroups": [
    {
      "groupId": 5,
      "name": "영어 마스터",
      "memberCount": 25,
      "weeklyTotalMinutes": 18720,
      "inviteCode": "ENG456",
      "isOwner": false
    }
  ],
  "ownedCount": 2,
  "maxOwnedCount": 3
}
```

---

##### POST /groups — 그룹 생성

**Request:**
```json
{
  "name": "개발자 모임"
}
```

**Response (201 Created):**
```json
{
  "groupId": 3,
  "name": "개발자 모임",
  "inviteCode": "DEV789",
  "memberCount": 1,
  "isOwner": true
}
```

**에러:**

| HTTP | error | 상황 |
|------|-------|------|
| 400 | MAX_OWNED_GROUPS | 최대 그룹 생성 수 초과 (3개) |
| 409 | DUPLICATE_GROUP_NAME | 그룹명 중복 |

---

##### POST /groups/join — 초대 코드로 그룹 참여

**Request:**
```json
{
  "inviteCode": "DEV789"
}
```

**Response (200 OK):**
```json
{
  "groupId": 3,
  "name": "개발자 모임",
  "memberCount": 9
}
```

---

##### GET /groups/{groupId} — 그룹 상세

**Response (200 OK):**
```json
{
  "groupId": 1,
  "name": "취준생 스터디",
  "inviteCode": "ABC123",
  "isOwner": true,
  "createdAt": "2026-01-01T00:00:00Z",
  "stats": {
    "weeklyTotalMinutes": 7620,
    "weeklyAvgMinutes": 635,
    "activeMemberCount": 10,
    "totalMemberCount": 12
  },
  "members": [
    {
      "userId": 2,
      "nickname": "공부벌레",
      "weeklyStudyMinutes": 1110,
      "isOwner": false
    }
  ]
}
```

---

##### DELETE /groups/{groupId} — 그룹 삭제 (방장만)

**Response (204 No Content)**

---

##### POST /groups/{groupId}/leave — 그룹 탈퇴

**Response (200 OK):**
```json
{
  "message": "그룹 탈퇴 완료"
}
```

---

#### 1.8.3 랭킹 (Ranking)

##### GET /rankings — 랭킹 조회

**Query Parameters:**

| 파라미터 | 타입 | 기본값 | 설명 |
|----------|------|--------|------|
| type | String | WEEKLY | WEEKLY, ALL_TIME |
| scope | String | GLOBAL | GLOBAL, FRIENDS, GROUP |
| groupId | Long? | null | scope=GROUP일 때 필수 |
| page | Int | 0 | 페이지 번호 |
| size | Int | 50 | 페이지 크기 |

**Response (200 OK):**
```json
{
  "myRank": {
    "rank": 3,
    "userId": 1,
    "nickname": "민첩한괴도5308",
    "studyMinutes": 765,
    "profileImageUrl": null
  },
  "rankings": [
    {
      "rank": 1,
      "userId": 2,
      "nickname": "공부벌레",
      "studyMinutes": 1110,
      "profileImageUrl": null
    },
    {
      "rank": 2,
      "userId": 3,
      "nickname": "열공러",
      "studyMinutes": 920,
      "profileImageUrl": null
    }
  ],
  "page": 0,
  "size": 50,
  "totalElements": 1500,
  "totalPages": 30,
  "hasNext": true
}
```

---

### 1.9 미션 API (Mission)

#### GET /missions — 미션 목록

**Query Parameters:** type (DAILY/WEEKLY/MONTHLY/HIDDEN/ALL)

**Response (200 OK):**
```json
{
  "daily": {
    "missions": [
      {
        "missionId": 1,
        "title": "오늘의 출석",
        "description": "앱에 접속하세요",
        "type": "DAILY",
        "rewardFuel": 0.1,
        "isCompleted": true,
        "progress": {"current": 1, "target": 1},
        "completedAt": "2026-02-11T08:00:00Z"
      },
      {
        "missionId": 2,
        "title": "1시간 집중",
        "description": "누적 1시간 공부하세요",
        "type": "DAILY",
        "rewardFuel": 0.5,
        "isCompleted": false,
        "progress": {"current": 35, "target": 60}
      }
    ],
    "completedCount": 3,
    "totalCount": 5,
    "allCompletedBonus": 1.0
  },
  "weekly": {
    "missions": [...],
    "completedCount": 1,
    "totalCount": 4
  },
  "hidden": {
    "discoveredCount": 1,
    "totalHint": "숨겨진 미션이 있어요..."
  }
}
```

---

#### POST /missions/{missionId}/claim — 미션 보상 수령

**Response (200 OK):**
```json
{
  "missionId": 1,
  "rewardFuel": 0.1,
  "currentFuel": 3.6,
  "bonusReward": null
}
```

**에러:**

| HTTP | error | 상황 |
|------|-------|------|
| 400 | MISSION_NOT_COMPLETED | 미션 미완료 |
| 400 | ALREADY_CLAIMED | 이미 수령함 |

---

### 1.10 뱃지 API (Badge)

#### GET /badges — 뱃지 목록

**Response (200 OK):**
```json
{
  "badges": [
    {
      "badgeId": 1,
      "name": "견습 비행사",
      "description": "총 10시간 공부 달성",
      "category": "TIME",
      "rarity": "NORMAL",
      "iconUrl": "https://...",
      "isEarned": true,
      "earnedAt": "2026-01-20T00:00:00Z",
      "progress": {"current": 10, "target": 10}
    },
    {
      "badgeId": 2,
      "name": "스타 파일럿",
      "description": "총 100시간 공부 달성",
      "category": "TIME",
      "rarity": "RARE",
      "iconUrl": "https://...",
      "isEarned": false,
      "progress": {"current": 75, "target": 100}
    }
  ],
  "earnedCount": 12,
  "totalCount": 45
}
```

---

### 1.11 우주선 API (Spaceship)

#### GET /spaceships — 우주선 목록

**Response (200 OK):**
```json
{
  "spaceships": [
    {
      "spaceshipId": "default",
      "name": "기본 우주선",
      "rarity": "NORMAL",
      "isAnimated": false,
      "iconUrl": "https://...",
      "lottieUrl": null,
      "riveUrl": null,
      "isUnlocked": true,
      "unlockCondition": "기본 제공"
    },
    {
      "spaceshipId": "mars_explorer",
      "name": "화성 탐사선",
      "rarity": "EPIC",
      "isAnimated": true,
      "iconUrl": "https://...",
      "lottieUrl": null,
      "riveUrl": "https://.../mars_explorer.riv",
      "isUnlocked": false,
      "unlockCondition": "화성 해금 시 획득"
    }
  ],
  "unlockedCount": 5,
  "totalCount": 20
}
```

---

### 1.12 스트릭 API (Streak)

#### GET /streak — 스트릭 정보

**Response (200 OK):**
```json
{
  "currentStreakDays": 5,
  "maxStreakDays": 23,
  "isActiveToday": true,
  "streakProtectionRemaining": 1,
  "weeklyCalendar": [
    {"date": "2026-02-05", "studied": true, "protected": false},
    {"date": "2026-02-06", "studied": true, "protected": false},
    {"date": "2026-02-07", "studied": false, "protected": true},
    {"date": "2026-02-08", "studied": true, "protected": false},
    {"date": "2026-02-09", "studied": true, "protected": false},
    {"date": "2026-02-10", "studied": true, "protected": false},
    {"date": "2026-02-11", "studied": true, "protected": false}
  ]
}
```

---

### 1.13 통계 API (Statistics)

#### GET /statistics/weekly — 주간 통계

**Response (200 OK):**
```json
{
  "weekStart": "2026-02-10",
  "weekEnd": "2026-02-16",
  "totalStudyMinutes": 765,
  "dailyStudyMinutes": [120, 90, 45, 0, 0, 0, 0],
  "totalFuelEarned": 14.2,
  "todosCompleted": 18,
  "sessionsCount": 12,
  "avgSessionMinutes": 63,
  "bestHour": 14,
  "bestDay": "MONDAY"
}
```

---

### 1.14 푸시 알림 API (Notification)

#### PATCH /notifications/fcm-token — FCM 토큰 업데이트

토큰 갱신 시 호출.

**Request:**
```json
{
  "fcmToken": "new-fcm-token-here",
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "deviceType": "IOS"
}
```

**Response (200 OK):**
```json
{
  "message": "FCM 토큰 업데이트 완료"
}
```

---

## Part 2: Flutter 클라이언트 구현 계획

### Task 1: 패키지 추가 및 환경 설정

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/constants/api_endpoints.dart`
- Modify: `.env`

**Step 1: pubspec.yaml에 소셜 로그인 패키지 추가**

```yaml
# 추가할 패키지
kakao_flutter_sdk_user: ^1.9.5  # 카카오 로그인
sign_in_with_apple: ^6.1.3      # 애플 로그인
firebase_auth: ^5.5.1            # Firebase Auth (ID Token 발급)
```

**Step 2: API 엔드포인트 상수 파일 생성**

```dart
// lib/core/constants/api_endpoints.dart
abstract class ApiEndpoints {
  // Auth
  static const login = '/api/v1/auth/login';
  static const refresh = '/api/v1/auth/refresh';
  static const logout = '/api/v1/auth/logout';
  static const withdraw = '/api/v1/auth/withdraw';

  // User
  static const userMe = '/api/v1/users/me';
  static String user(int userId) => '/api/v1/users/$userId';

  // Todo
  static const todos = '/api/v1/todos';
  static String todo(int id) => '/api/v1/todos/$id';
  static const todoReorder = '/api/v1/todos/reorder';

  // Timer
  static const timerStart = '/api/v1/timer/start';
  static const timerStop = '/api/v1/timer/stop';
  static const timerHistory = '/api/v1/timer/history';

  // Fuel
  static const fuel = '/api/v1/fuel';
  static const fuelHistory = '/api/v1/fuel/history';

  // Exploration
  static const explorationTree = '/api/v1/exploration/tree';
  static const explorationUnlock = '/api/v1/exploration/unlock';

  // Social - Friends
  static const friends = '/api/v1/friends';
  static const friendRequest = '/api/v1/friends/request';
  static const friendRequests = '/api/v1/friends/requests';
  static const friendCode = '/api/v1/friends/code';
  static const friendSearch = '/api/v1/friends/search';
  static String friendRequestAction(int requestId) =>
      '/api/v1/friends/requests/$requestId';
  static String friendDelete(int userId) => '/api/v1/friends/$userId';

  // Social - Groups
  static const groups = '/api/v1/groups';
  static const groupJoin = '/api/v1/groups/join';
  static String group(int groupId) => '/api/v1/groups/$groupId';
  static String groupLeave(int groupId) => '/api/v1/groups/$groupId/leave';

  // Rankings
  static const rankings = '/api/v1/rankings';

  // Missions
  static const missions = '/api/v1/missions';
  static String missionClaim(int missionId) =>
      '/api/v1/missions/$missionId/claim';

  // Badges
  static const badges = '/api/v1/badges';

  // Spaceships
  static const spaceships = '/api/v1/spaceships';

  // Streak
  static const streak = '/api/v1/streak';

  // Statistics
  static const statisticsWeekly = '/api/v1/statistics/weekly';

  // Notifications
  static const fcmToken = '/api/v1/notifications/fcm-token';
}
```

**Step 3: .env 파일에 서버 URL 추가**

```
API_BASE_URL=http://localhost:8080
```

**Step 4: flutter pub get 실행**

Run: `flutter pub get`

**Step 5: Commit**

```bash
git add pubspec.yaml lib/core/constants/api_endpoints.dart .env
git commit -m "feat: 소셜 로그인 패키지 추가 및 API 엔드포인트 상수 정의"
```

---

### Task 2: Dio 클라이언트 및 Auth Interceptor 구축

**Files:**
- Create: `lib/core/services/dio/dio_client.dart`
- Create: `lib/core/services/dio/interceptors/auth_interceptor.dart`
- Create: `lib/core/services/dio/interceptors/logging_interceptor.dart`
- Create: `lib/core/services/storage/secure_storage_service.dart`

**Step 1: SecureStorageService 구현**

```dart
// lib/core/services/storage/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _userIdKey = 'USER_ID';

  // Access Token
  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);
  static Future<void> setAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  // Refresh Token
  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);
  static Future<void> setRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  // User ID
  static Future<String?> getUserId() => _storage.read(key: _userIdKey);
  static Future<void> setUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  // 전체 삭제 (로그아웃 시)
  static Future<void> clearAll() => _storage.deleteAll();
}
```

**Step 2: AuthInterceptor 구현 (자동 토큰 주입 + 갱신)**

```dart
// lib/core/services/dio/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';
import '../../../constants/api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  // 인증이 필요없는 경로
  static const _publicPaths = [
    ApiEndpoints.login,
    ApiEndpoints.refresh,
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 공개 API는 토큰 불필요
    if (_publicPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    final token = await SecureStorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // accessToken 만료 → refresh 시도
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // 원래 요청 재시도
        final token = await SecureStorageService.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } else {
        // refresh 실패 → 로그아웃 처리
        await SecureStorageService.clearAll();
        // TODO: GoRouter로 로그인 화면 이동
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await SecureStorageService.setAccessToken(newAccessToken);
      await SecureStorageService.setRefreshToken(newRefreshToken);

      return true;
    } catch (_) {
      return false;
    }
  }
}
```

**Step 3: DioClient 구현**

```dart
// lib/core/services/dio/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'interceptors/auth_interceptor.dart';

part 'dio_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.addAll([
    AuthInterceptor(dio),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[Dio] $obj'),
    ),
  ]);

  return dio;
}
```

**Step 4: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 5: Commit**

```bash
git add lib/core/services/
git commit -m "feat: Dio 클라이언트, AuthInterceptor, SecureStorage 구축"
```

---

### Task 3: Auth Feature 구현 (Domain + Data Layer)

**Files:**
- Create: `lib/features/auth/domain/entities/auth_token_entity.dart`
- Create: `lib/features/auth/domain/entities/login_result_entity.dart`
- Create: `lib/features/auth/domain/repositories/auth_repository.dart`
- Create: `lib/features/auth/data/models/login_request_model.dart`
- Create: `lib/features/auth/data/models/login_response_model.dart`
- Create: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Create: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Create: `lib/features/auth/presentation/providers/auth_provider.dart`

**Step 1: Entity 정의**

```dart
// lib/features/auth/domain/entities/auth_token_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_token_entity.freezed.dart';
part 'auth_token_entity.g.dart';

@freezed
class AuthTokenEntity with _$AuthTokenEntity {
  const factory AuthTokenEntity({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokenEntity;

  factory AuthTokenEntity.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenEntityFromJson(json);
}
```

```dart
// lib/features/auth/domain/entities/login_result_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_token_entity.dart';
part 'login_result_entity.freezed.dart';
part 'login_result_entity.g.dart';

@freezed
class LoginResultEntity with _$LoginResultEntity {
  const factory LoginResultEntity({
    required int userId,
    required String nickname,
    String? profileImageUrl,
    required AuthTokenEntity tokens,
    required bool isNewUser,
  }) = _LoginResultEntity;

  factory LoginResultEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginResultEntityFromJson(json);
}
```

**Step 2: Repository 인터페이스**

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
import '../entities/login_result_entity.dart';

abstract class AuthRepository {
  Future<LoginResultEntity> login({
    required String socialPlatform,
    required String idToken,
    String? fcmToken,
    required String deviceType,
    required String deviceId,
  });

  Future<void> logout(String deviceId);
  Future<void> withdraw();
  Future<bool> isLoggedIn();
}
```

**Step 3: Data Model + DataSource + Repository Impl**

(Retrofit 기반 DataSource, Repository Impl은 Domain 인터페이스를 구현)

**Step 4: Auth Provider**

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<LoginResultEntity?> build() async {
    // 앱 시작 시 저장된 토큰 확인
    final token = await SecureStorageService.getAccessToken();
    if (token == null) return null;
    // 토큰이 있으면 유저 정보 조회 시도
    // ...
  }

  Future<void> loginWithGoogle() async { ... }
  Future<void> loginWithKakao() async { ... }
  Future<void> loginWithApple() async { ... }
  Future<void> logout() async { ... }
}
```

**Step 5: build_runner 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 6: Commit**

```bash
git add lib/features/auth/
git commit -m "feat: Auth 도메인/데이터 레이어 구현 (로그인/로그아웃/토큰 관리)"
```

---

### Task 4: 로그인 화면 연동 (Google + Kakao + Apple)

**Files:**
- Modify: `lib/features/auth/presentation/screens/login_screen.dart`
- Modify: `lib/features/auth/presentation/screens/onboarding_screen.dart`
- Modify: `lib/features/auth/presentation/screens/splash_screen.dart`

**Step 1: login_screen.dart에 Google/Kakao/Apple 버튼 추가**

현재 Google 버튼 하나만 있으므로 3개 소셜 로그인 버튼으로 확장.

**Step 2: splash_screen.dart에 자동 로그인 체크**

저장된 토큰이 있으면 home으로, 없으면 login으로 이동.

**Step 3: Commit**

```bash
git add lib/features/auth/presentation/
git commit -m "feat: 소셜 로그인 화면 연동 (Google, Kakao, Apple)"
```

---

### Task 5: Todo Feature 구현 (Full Stack)

**Files:**
- Create: `lib/features/home/domain/entities/todo_entity.dart`
- Create: `lib/features/home/domain/repositories/todo_repository.dart`
- Create: `lib/features/home/domain/usecases/get_todos_usecase.dart`
- Create: `lib/features/home/domain/usecases/create_todo_usecase.dart`
- Create: `lib/features/home/domain/usecases/update_todo_usecase.dart`
- Create: `lib/features/home/domain/usecases/delete_todo_usecase.dart`
- Create: `lib/features/home/data/models/todo_model.dart`
- Create: `lib/features/home/data/datasources/todo_remote_datasource.dart`
- Create: `lib/features/home/data/repositories/todo_repository_impl.dart`
- Create: `lib/features/home/presentation/providers/todo_provider.dart`
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

Tier 1 (Optimistic Updates) 전략으로 구현. 로컬 우선 저장 후 백그라운드 서버 동기화.

**Step 1~6:** Entity → Repository Interface → DataSource → Impl → Provider → UI 연동

**Step 7: Commit**

```bash
git commit -m "feat: Todo CRUD 구현 (Optimistic Updates, Tier 1)"
```

---

### Task 6: Timer Feature 구현 (Full Stack)

**Files:**
- Create: `lib/features/timer/domain/entities/timer_session_entity.dart`
- Create: `lib/features/timer/domain/repositories/timer_repository.dart`
- Create: `lib/features/timer/data/...`
- Create: `lib/features/timer/presentation/providers/timer_provider.dart`

Tier 2 (Server-Validated) 전략. 타이머 시작은 클라이언트, 종료 시 서버에서 연료 계산.

**Step 1~6:** Entity → Repository → DataSource → Impl → Provider → UI 연동

**Step 7: Commit**

```bash
git commit -m "feat: 타이머 시작/종료/기록 구현 (Server-Validated, Tier 2)"
```

---

### Task 7: Exploration Feature 구현 (Full Stack)

Tier 2 전략. 장소 해금은 서버가 연료 검증 후 처리.

**Step 1~5:** Entity → Repository → DataSource → Impl → Provider → UI 연동

**Step 6: Commit**

```bash
git commit -m "feat: 탐험 트리 조회 및 장소 해금 구현 (Server-Validated)"
```

---

### Task 8: Social Feature 구현 (친구/그룹/랭킹)

Tier 3 (Server-Only) 전략. 항상 서버에서 최신 데이터를 가져오고 캐시는 읽기 전용.

**Step 1~6:** 친구 → 그룹 → 랭킹 순서로 구현

**Step 7: Commit**

```bash
git commit -m "feat: 소셜 기능 구현 (친구/그룹/랭킹, Server-Only Tier 3)"
```

---

### Task 9: 미션/뱃지/우주선/스트릭/통계 구현

나머지 기능을 순차적으로 구현.

**Step 1~5:** 각 도메인별 Entity → Provider → UI 연동

---

## Part 3: 데이터 동기화 전략 요약

| Tier | 대상 | 전략 | 이유 |
|------|------|------|------|
| **Tier 1** | Todo CRUD, 프로필 편집 | Optimistic Updates (로컬 먼저) | 즉각 반응 UX |
| **Tier 2** | 타이머 종료→연료, 장소 해금 | Server-Validated (서버 검증) | 치트 방지 |
| **Tier 3** | 랭킹, 친구 목록, 그룹 | Server-Only (항상 서버) | 실시간 정확성 |

---

## Part 4: JWT 토큰 생명주기

```
accessToken:  1시간 유효 → 만료 시 자동 갱신
refreshToken: 14일 유효 → 만료 시 재로그인 필요

Flow:
1. API 호출 → AuthInterceptor가 accessToken 자동 주입
2. 401 응답 → AuthInterceptor가 refreshToken으로 갱신 시도
3. 갱신 성공 → 새 토큰 저장 → 원래 요청 재시도
4. 갱신 실패 → 토큰 삭제 → 로그인 화면 이동
```

---

## Part 5: Firebase ID Token 소셜 로그인 흐름

```
[Flutter 앱]
1. Google/Kakao/Apple SDK로 소셜 로그인
2. Firebase Auth에 credential 전달 → Firebase ID Token 발급
3. POST /auth/login { socialPlatform, idToken, fcmToken, deviceType, deviceId }

[Spring Boot 서버]
4. Firebase Admin SDK로 idToken 검증
5. Firebase UID로 사용자 조회/생성
6. 자체 JWT (accessToken + refreshToken) 발급
7. Response 반환

[Flutter 앱]
8. accessToken, refreshToken을 SecureStorage에 저장
9. isNewUser == true → 온보딩 화면
10. isNewUser == false → 홈 화면
```
