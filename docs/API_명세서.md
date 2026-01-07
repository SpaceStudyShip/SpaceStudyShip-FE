# 📡 API 명세서: 우주공부선 (StudyShip)

> Spring Boot + MySQL 환경

---

## 1. API 개요

### Base URL

```
Production: https://api.studyship.app/v1
Development: http://localhost:8080/v1
```

### 인증

| 헤더 | 값 | 설명 |
|------|-----|------|
| Authorization | Bearer {access_token} | JWT 토큰 |

### 공통 요청 헤더

```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {access_token}
```

### 공통 응답 형식

#### 성공 응답

```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2024-01-15T09:30:00Z"
}
```

#### 에러 응답

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": { ... }
  },
  "timestamp": "2024-01-15T09:30:00Z"
}
```

### 공통 에러 코드

| HTTP | 코드 | 설명 |
|------|------|------|
| 400 | BAD_REQUEST | 잘못된 요청 |
| 401 | UNAUTHORIZED | 인증 필요 |
| 403 | FORBIDDEN | 권한 없음 |
| 404 | NOT_FOUND | 리소스 없음 |
| 409 | CONFLICT | 충돌 (중복 등) |
| 422 | UNPROCESSABLE | 처리 불가 |
| 429 | TOO_MANY_REQUESTS | 요청 한도 초과 |
| 500 | INTERNAL_ERROR | 서버 오류 |

### 페이지네이션

```json
{
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "size": 20,
    "totalElements": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

---

## 2. Auth (인증)

### AUTH-001. 소셜 로그인

```
POST /auth/login
```

#### Request Body

```json
{
  "provider": "google",
  "accessToken": "ya29.a0AfH6SMBx..."
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| provider | String | ✓ | `google` / `kakao` / `apple` |
| accessToken | String | ✓ | 소셜 로그인 액세스 토큰 |

#### Response 200

```json
{
  "success": true,
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600,
    "isNewUser": true,
    "profile": {
      "nickname": null,
      "profileImageUrl": "https://lh3.googleusercontent.com/...",
      "email": "user@gmail.com",
      "onboardingCompleted": false
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 401 | INVALID_SOCIAL_TOKEN | 유효하지 않은 소셜 토큰 |
| 500 | SOCIAL_AUTH_ERROR | 소셜 인증 서버 오류 |

---

### AUTH-002. 토큰 갱신

```
POST /auth/refresh
```

#### Request Body

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 401 | INVALID_REFRESH_TOKEN | 유효하지 않은 리프레시 토큰 |
| 401 | TOKEN_EXPIRED | 토큰 만료 |

---

### AUTH-003. 로그아웃

```
POST /auth/logout
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "로그아웃되었습니다."
  }
}
```

---

## 3. Users (사용자)

### USER-001. 온보딩 완료

```
POST /users/onboarding
```

#### Request Body

```json
{
  "nickname": "우주탐험가",
  "goal": "취업 준비"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| nickname | String | ✓ | 닉네임 (2~12자) |
| goal | String | | 목표 (최대 30자) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "우주탐험가",
    "goal": "취업 준비",
    "friendCode": "SPACE1234",
    "onboardingCompleted": true,
    "initialRewards": {
      "defaultLocation": {
        "locationId": "seoul",
        "name": "서울"
      },
      "defaultShip": {
        "shipId": "ship_basic",
        "name": "기본 공부선"
      }
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | INVALID_NICKNAME_LENGTH | 닉네임 길이 미충족 (2~12자) |
| 409 | NICKNAME_ALREADY_EXISTS | 닉네임 중복 |
| 422 | FORBIDDEN_WORD_INCLUDED | 금칙어 포함 |

---

### USER-002. 닉네임 중복 확인

```
GET /users/nickname/check?nickname={nickname}
```

#### Query Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| nickname | String | ✓ | 확인할 닉네임 |

#### Response 200

```json
{
  "success": true,
  "data": {
    "nickname": "우주탐험가",
    "available": true
  }
}
```

```json
{
  "success": true,
  "data": {
    "nickname": "관리자",
    "available": false,
    "reason": "FORBIDDEN_WORD"
  }
}
```

---

### USER-003. 닉네임 변경

```
PATCH /users/nickname
```

#### Request Body

```json
{
  "nickname": "새로운닉네임"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "nickname": "새로운닉네임",
    "remainingChanges": 2,
    "nextChangeAvailableAt": null
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | CHANGE_LIMIT_EXCEEDED | 변경 횟수 초과 |
| 429 | CHANGE_COOLDOWN | 쿨다운 기간 |

---

### USER-004. 계정 탈퇴 요청

```
POST /users/withdrawal
```

#### Request Body

```json
{
  "reason": "더 이상 사용하지 않음"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "scheduledDeletionAt": "2024-01-22T09:30:00Z",
    "message": "7일 후에 계정이 삭제됩니다."
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | HAS_OWNED_GROUPS | 소유한 그룹 존재 (위임 필요) |

---

### USER-005. 계정 탈퇴 취소

```
DELETE /users/withdrawal
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "탈퇴 요청이 취소되었습니다."
  }
}
```

---

## 4. Profile (프로필)

### PROFILE-001. 내 프로필 조회

```
GET /profile
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "우주탐험가",
    "profileImageUrl": "https://lh3.googleusercontent.com/...",
    "bio": "열심히 공부하는 취준생입니다",
    "goal": "취업 준비",
    "level": 5,
    "totalStudyTime": 7652,
    "totalFuelEarned": 142.5,
    "currentFuel": 23.8,
    "currentStreak": 7,
    "maxStreak": 23,
    "unlockedLocationsCount": 8,
    "totalLocationsCount": 15,
    "badgesCount": 12,
    "shipsCount": 5,
    "representativeBadges": [
      {
        "badgeId": "time_100h",
        "name": "스타 파일럿",
        "imageUrl": "/badges/time_100h.png",
        "rarity": "rare"
      }
    ],
    "representativeShip": {
      "shipId": "ship_mars",
      "name": "화성 탐사선",
      "imageUrl": "/ships/mars.png",
      "animationUrl": "/ships/mars.riv",
      "rarity": "epic"
    },
    "friendCode": "SPACE1234",
    "acceptsFriendRequests": true,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### PROFILE-002. 다른 사용자 프로필 조회

```
GET /profile/{userId}
```

#### Path Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| userId | String | ✓ | 사용자 UUID |

#### Response 200

```json
{
  "success": true,
  "data": {
    "userId": "660e8400-e29b-41d4-a716-446655440001",
    "nickname": "공부왕",
    "profileImageUrl": "https://...",
    "bio": "하루 5시간 공부 목표",
    "goal": "코딩테스트 준비",
    "level": 8,
    "totalStudyTime": 15230,
    "currentStreak": 15,
    "representativeBadges": [...],
    "representativeShip": {...},
    "isFriend": false,
    "friendStatus": "none"
  }
}
```

| friendStatus | 설명 |
|--------------|------|
| none | 관계 없음 |
| pending_sent | 내가 요청 보냄 |
| pending_received | 상대가 요청 보냄 |
| friend | 친구 |

---

### PROFILE-003. 프로필 수정

```
PATCH /profile
```

#### Request Body

```json
{
  "bio": "열심히 공부 중!",
  "goal": "대기업 취업"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| bio | String | | 자기소개 (최대 50자) |
| goal | String | | 목표 (최대 30자) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "bio": "열심히 공부 중!",
    "goal": "대기업 취업",
    "updatedAt": "2024-01-15T09:30:00Z"
  }
}
```

---

### PROFILE-004. 대표 뱃지 설정

```
PUT /profile/representative-badges
```

#### Request Body

```json
{
  "badgeIds": ["time_100h", "streak_30", "explore_korea"]
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| badgeIds | Array[String] | ✓ | 뱃지 ID 목록 (최대 3개) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "representativeBadges": [
      {
        "badgeId": "time_100h",
        "name": "스타 파일럿",
        "imageUrl": "/badges/time_100h.png",
        "rarity": "rare"
      },
      ...
    ]
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | EXCEEDS_MAX_BADGES | 최대 3개 초과 |
| 400 | BADGE_NOT_OWNED | 보유하지 않은 뱃지 |

---

### PROFILE-005. 대표 공부선 설정

```
PUT /profile/representative-ship
```

#### Request Body

```json
{
  "shipId": "ship_mars"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "representativeShip": {
      "shipId": "ship_mars",
      "name": "화성 탐사선",
      "imageUrl": "/ships/mars.png",
      "animationUrl": "/ships/mars.riv",
      "rarity": "epic"
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | SHIP_NOT_OWNED | 보유하지 않은 공부선 |

---

## 5. Todos (할 일)

### TODO-001. Todo 목록 조회

```
GET /todos?date={date}
```

#### Query Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| date | String | | 조회 날짜 (YYYY-MM-DD, 기본: 오늘) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "date": "2024-01-15",
    "todos": [
      {
        "todoId": "550e8400-e29b-41d4-a716-446655440001",
        "title": "알고리즘 2문제 풀기",
        "isCompleted": true,
        "completedAt": "2024-01-15T14:30:00Z",
        "createdAt": "2024-01-15T09:00:00Z",
        "displayOrder": 1
      },
      {
        "todoId": "550e8400-e29b-41d4-a716-446655440002",
        "title": "영어 단어 50개 암기",
        "isCompleted": false,
        "completedAt": null,
        "createdAt": "2024-01-15T09:05:00Z",
        "displayOrder": 2
      }
    ],
    "totalCount": 5,
    "completedCount": 3
  }
}
```

---

### TODO-002. Todo 생성

```
POST /todos
```

#### Request Body

```json
{
  "title": "알고리즘 2문제 풀기",
  "date": "2024-01-15"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| title | String | ✓ | 제목 (최대 100자) |
| date | String | | 날짜 YYYY-MM-DD (기본: 오늘) |

#### Response 201

```json
{
  "success": true,
  "data": {
    "todoId": "550e8400-e29b-41d4-a716-446655440001",
    "title": "알고리즘 2문제 풀기",
    "date": "2024-01-15",
    "isCompleted": false,
    "createdAt": "2024-01-15T09:00:00Z",
    "displayOrder": 1
  }
}
```

---

### TODO-003. Todo 수정

```
PATCH /todos/{todoId}
```

#### Path Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| todoId | String | ✓ | Todo UUID |

#### Request Body

```json
{
  "title": "알고리즘 3문제 풀기"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "todoId": "550e8400-e29b-41d4-a716-446655440001",
    "title": "알고리즘 3문제 풀기",
    "updatedAt": "2024-01-15T10:00:00Z"
  }
}
```

---

### TODO-004. Todo 완료/취소

```
PATCH /todos/{todoId}/completion
```

#### Request Body

```json
{
  "isCompleted": true
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "todoId": "550e8400-e29b-41d4-a716-446655440001",
    "isCompleted": true,
    "completedAt": "2024-01-15T14:30:00Z",
    "missionProgress": {
      "missionId": "daily_todo_3",
      "title": "Todo 3개 완료",
      "currentProgress": 3,
      "requiredProgress": 3,
      "isCompleted": true
    }
  }
}
```

---

### TODO-005. Todo 삭제

```
DELETE /todos/{todoId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "Todo가 삭제되었습니다."
  }
}
```

---

### TODO-006. Todo 순서 변경

```
PUT /todos/order
```

#### Request Body

```json
{
  "todoOrders": [
    { "todoId": "550e8400-...-001", "displayOrder": 1 },
    { "todoId": "550e8400-...-002", "displayOrder": 2 },
    { "todoId": "550e8400-...-003", "displayOrder": 3 }
  ]
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "순서가 변경되었습니다."
  }
}
```

---

## 6. Timer (타이머)

### TIMER-001. 타이머 시작

```
POST /timer/start
```

#### Request Body

```json
{
  "todoId": "550e8400-e29b-41d4-a716-446655440001"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| todoId | String | | 연결할 Todo UUID |

#### Response 201

```json
{
  "success": true,
  "data": {
    "sessionId": "660e8400-e29b-41d4-a716-446655440000",
    "status": "running",
    "startedAt": "2024-01-15T09:00:00Z",
    "recordDate": "2024-01-15",
    "todo": {
      "todoId": "550e8400-e29b-41d4-a716-446655440001",
      "title": "알고리즘 2문제 풀기"
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | SESSION_ALREADY_ACTIVE | 이미 진행 중인 세션 존재 |

---

### TIMER-002. 타이머 일시정지

```
POST /timer/{sessionId}/pause
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "sessionId": "660e8400-e29b-41d4-a716-446655440000",
    "status": "paused",
    "pausedAt": "2024-01-15T09:45:00Z",
    "totalDuration": 2700,
    "autoEndAt": "2024-01-15T10:15:00Z"
  }
}
```

---

### TIMER-003. 타이머 재개

```
POST /timer/{sessionId}/resume
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "sessionId": "660e8400-e29b-41d4-a716-446655440000",
    "status": "running",
    "resumedAt": "2024-01-15T09:50:00Z",
    "totalDuration": 2700
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | SESSION_AUTO_ENDED | 일시정지 30분 초과로 자동 종료됨 |

---

### TIMER-004. 타이머 종료

```
POST /timer/{sessionId}/end
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "sessionId": "660e8400-e29b-41d4-a716-446655440000",
    "duration": 65,
    "fuelEarned": {
      "baseFuel": 1.1,
      "bonusFuel": 0.1,
      "totalFuel": 1.2
    },
    "currentFuel": 25.0,
    "streak": {
      "updated": true,
      "days": 8
    },
    "level": {
      "levelUp": false,
      "currentLevel": 5,
      "progressPercent": 78.5
    },
    "missionsCompleted": [
      {
        "missionId": "daily_1hour",
        "title": "1시간 집중",
        "rewardFuel": 0.5
      }
    ],
    "badgesEarned": [],
    "todo": {
      "todoId": "550e8400-e29b-41d4-a716-446655440001",
      "title": "알고리즘 2문제 풀기"
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | DURATION_TOO_SHORT | 1분 미만 |

---

### TIMER-005. 진행 중인 세션 조회

```
GET /timer/active
```

#### Response 200 - 세션 있음

```json
{
  "success": true,
  "data": {
    "hasActiveSession": true,
    "session": {
      "sessionId": "660e8400-e29b-41d4-a716-446655440000",
      "status": "running",
      "startedAt": "2024-01-15T09:00:00Z",
      "totalDuration": 2700,
      "pausedAt": null,
      "todo": {
        "todoId": "550e8400-e29b-41d4-a716-446655440001",
        "title": "알고리즘 2문제 풀기"
      }
    }
  }
}
```

#### Response 200 - 세션 없음

```json
{
  "success": true,
  "data": {
    "hasActiveSession": false,
    "session": null
  }
}
```

---

### TIMER-006. 세션 복구

```
POST /timer/{sessionId}/recover
```

#### Request Body

```json
{
  "lastKnownDuration": 2700
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| lastKnownDuration | Integer | ✓ | 마지막 알려진 경과 시간 (초) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "sessionId": "660e8400-e29b-41d4-a716-446655440000",
    "recovered": true,
    "totalDuration": 2850,
    "status": "running"
  }
}
```

---

## 7. Fuel (연료)

### FUEL-001. 연료 현황 조회

```
GET /fuel
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "currentFuel": 23.8,
    "totalEarned": 142.5,
    "totalSpent": 118.7,
    "todayEarned": 2.3,
    "thisWeekEarned": 15.8
  }
}
```

---

### FUEL-002. 연료 내역 조회

```
GET /fuel/history?type={type}&page={page}&size={size}
```

#### Query Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| type | String | | `earned` / `spent` / `all` (기본: all) |
| page | Integer | | 페이지 (기본: 0) |
| size | Integer | | 개수 (기본: 20) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "history": [
      {
        "id": 1234,
        "fuelType": "earned",
        "amount": 1.2,
        "source": "timer",
        "description": "65분 공부 완료",
        "balanceAfter": 25.0,
        "createdAt": "2024-01-15T10:05:00Z"
      },
      {
        "id": 1235,
        "fuelType": "spent",
        "amount": -3.0,
        "source": "location_unlock",
        "description": "제주 해금",
        "balanceAfter": 22.0,
        "createdAt": "2024-01-15T10:10:00Z"
      }
    ],
    "pagination": {
      "page": 0,
      "size": 20,
      "totalElements": 150,
      "totalPages": 8,
      "hasNext": true
    }
  }
}
```

---

## 8. Level (레벨)

### LEVEL-001. 레벨 정보 조회

```
GET /level
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "currentLevel": 5,
    "totalStudyTime": 7652,
    "currentLevelRequiredTime": 3000,
    "nextLevelRequiredTime": 4800,
    "progressPercent": 78.5,
    "timeToNextLevel": 348
  }
}
```

---

## 9. Locations (장소/탐험)

### LOCATION-001. 장소 목록 조회

```
GET /locations
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "categoryId": "korea",
        "name": "국내",
        "isUnlocked": true,
        "unlockCondition": null,
        "totalCount": 5,
        "unlockedCount": 3,
        "locations": [
          {
            "locationId": "seoul",
            "name": "서울",
            "imageUrl": "/locations/seoul.png",
            "requiredFuel": 0,
            "isUnlocked": true,
            "unlockedAt": "2024-01-01T00:00:00Z",
            "rewardShip": null
          },
          {
            "locationId": "busan",
            "name": "부산",
            "imageUrl": "/locations/busan.png",
            "requiredFuel": 1.0,
            "isUnlocked": true,
            "unlockedAt": "2024-01-05T10:00:00Z",
            "rewardShip": null
          },
          {
            "locationId": "jeju",
            "name": "제주",
            "imageUrl": "/locations/jeju.png",
            "requiredFuel": 3.0,
            "isUnlocked": false,
            "unlockedAt": null,
            "rewardShip": null
          }
        ]
      },
      {
        "categoryId": "overseas",
        "name": "해외",
        "isUnlocked": false,
        "unlockCondition": "국내 모든 장소를 해금하세요",
        "totalCount": 5,
        "unlockedCount": 0,
        "locations": [...]
      },
      {
        "categoryId": "space",
        "name": "우주",
        "isUnlocked": false,
        "unlockCondition": "해외 모든 장소를 해금하세요",
        "totalCount": 5,
        "unlockedCount": 0,
        "locations": [...]
      }
    ],
    "totalLocations": 15,
    "unlockedLocations": 3,
    "currentLocationId": "seoul"
  }
}
```

---

### LOCATION-002. 장소 해금

```
POST /locations/{locationId}/unlock
```

#### Path Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| locationId | String | ✓ | 장소 ID |

#### Response 200

```json
{
  "success": true,
  "data": {
    "location": {
      "locationId": "jeju",
      "name": "제주",
      "imageUrl": "/locations/jeju.png",
      "unlockedAt": "2024-01-15T10:00:00Z"
    },
    "spentFuel": 3.0,
    "remainingFuel": 20.8,
    "rewardShip": null,
    "badgeEarned": {
      "badgeId": "explore_korea",
      "name": "국내 완주",
      "imageUrl": "/badges/explore_korea.png"
    },
    "categoryUnlocked": true,
    "newCategory": {
      "categoryId": "overseas",
      "name": "해외"
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | CATEGORY_LOCKED | 카테고리 미해금 |
| 400 | ALREADY_UNLOCKED | 이미 해금된 장소 |
| 400 | INSUFFICIENT_FUEL | 연료 부족 |

---

### LOCATION-003. 현재 위치 변경

```
PUT /locations/current
```

#### Request Body

```json
{
  "locationId": "busan"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "currentLocation": {
      "locationId": "busan",
      "name": "부산",
      "imageUrl": "/locations/busan.png"
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | LOCATION_NOT_UNLOCKED | 해금되지 않은 장소 |

---

## 10. Friends (친구)

### FRIEND-001. 친구 목록 조회

```
GET /friends?sortBy={sortBy}&page={page}&size={size}
```

#### Query Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| sortBy | String | | `studyTime` / `nickname` / `recent` (기본: studyTime) |
| page | Integer | | 페이지 (기본: 0) |
| size | Integer | | 개수 (기본: 20) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "friends": [
      {
        "userId": "660e8400-e29b-41d4-a716-446655440001",
        "nickname": "공부왕",
        "profileImageUrl": "https://...",
        "level": 8,
        "thisWeekStudyTime": 1523,
        "currentStreak": 15,
        "representativeBadges": [...],
        "isOnline": true
      }
    ],
    "pagination": {
      "totalElements": 23,
      "page": 0,
      "hasNext": true
    }
  }
}
```

---

### FRIEND-002. 친구 검색

```
GET /friends/search?query={query}
```

#### Query Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| query | String | ✓ | 닉네임 또는 친구 코드 |

#### Response 200

```json
{
  "success": true,
  "data": {
    "users": [
      {
        "userId": "660e8400-e29b-41d4-a716-446655440001",
        "nickname": "공부왕",
        "profileImageUrl": "https://...",
        "level": 8,
        "friendStatus": "none",
        "acceptsFriendRequests": true
      }
    ]
  }
}
```

---

### FRIEND-003. 친구 요청 보내기

```
POST /friends/requests
```

#### Request Body

```json
{
  "userId": "660e8400-e29b-41d4-a716-446655440001"
}
```

#### Response 201

```json
{
  "success": true,
  "data": {
    "requestId": "770e8400-e29b-41d4-a716-446655440000",
    "toUser": {
      "userId": "660e8400-e29b-41d4-a716-446655440001",
      "nickname": "공부왕"
    },
    "status": "pending",
    "createdAt": "2024-01-15T10:00:00Z"
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | ALREADY_FRIEND | 이미 친구 |
| 400 | REQUEST_ALREADY_SENT | 이미 요청 보냄 |
| 400 | REQUEST_NOT_ACCEPTED | 상대방 친구 요청 수신 OFF |
| 429 | REQUEST_COOLDOWN | 쿨다운 중 (거절 후 5분) |

---

### FRIEND-004. 받은 친구 요청 목록

```
GET /friends/requests/received
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "requests": [
      {
        "requestId": "770e8400-e29b-41d4-a716-446655440000",
        "fromUser": {
          "userId": "550e8400-e29b-41d4-a716-446655440000",
          "nickname": "열공러",
          "profileImageUrl": "https://...",
          "level": 5
        },
        "createdAt": "2024-01-15T09:00:00Z"
      }
    ],
    "totalCount": 2
  }
}
```

---

### FRIEND-005. 보낸 친구 요청 목록

```
GET /friends/requests/sent
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "requests": [
      {
        "requestId": "770e8400-e29b-41d4-a716-446655440001",
        "toUser": {
          "userId": "660e8400-e29b-41d4-a716-446655440001",
          "nickname": "공부왕",
          "profileImageUrl": "https://...",
          "level": 8
        },
        "createdAt": "2024-01-15T10:00:00Z"
      }
    ],
    "totalCount": 1
  }
}
```

---

### FRIEND-006. 친구 요청 수락

```
POST /friends/requests/{requestId}/accept
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "friend": {
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "nickname": "열공러",
      "profileImageUrl": "https://...",
      "level": 5
    },
    "missionProgress": {
      "missionId": "weekly_friend",
      "title": "친구 1명 추가",
      "currentProgress": 1,
      "requiredProgress": 1,
      "isCompleted": true
    }
  }
}
```

---

### FRIEND-007. 친구 요청 거절

```
POST /friends/requests/{requestId}/reject
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "친구 요청을 거절했습니다."
  }
}
```

---

### FRIEND-008. 보낸 친구 요청 취소

```
DELETE /friends/requests/{requestId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "친구 요청을 취소했습니다."
  }
}
```

---

### FRIEND-009. 친구 삭제

```
DELETE /friends/{userId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "친구가 삭제되었습니다."
  }
}
```

---

### FRIEND-010. 친구 요청 수신 설정

```
PUT /friends/settings
```

#### Request Body

```json
{
  "acceptsFriendRequests": false
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "acceptsFriendRequests": false
  }
}
```

---

## 11. Groups (그룹)

### GROUP-001. 내 그룹 목록 조회

```
GET /groups
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "ownedGroups": [
      {
        "groupId": "880e8400-e29b-41d4-a716-446655440000",
        "name": "취준생 스터디",
        "description": "함께 취업 준비해요",
        "memberCount": 12,
        "maxMembers": 20,
        "thisWeekTotalTime": 7620,
        "myRank": 3,
        "isOwner": true,
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "ownedGroupsCount": 2,
    "maxOwnedGroups": 3,
    "joinedGroups": [
      {
        "groupId": "880e8400-e29b-41d4-a716-446655440001",
        "name": "영어 마스터",
        "description": "영어 공부 그룹",
        "memberCount": 18,
        "maxMembers": 20,
        "thisWeekTotalTime": 9360,
        "myRank": 5,
        "isOwner": false,
        "createdAt": "2024-01-05T00:00:00Z"
      }
    ]
  }
}
```

---

### GROUP-002. 그룹 상세 조회

```
GET /groups/{groupId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "groupId": "880e8400-e29b-41d4-a716-446655440000",
    "name": "취준생 스터디",
    "description": "함께 취업 준비해요",
    "inviteCode": "STUDY2024",
    "owner": {
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "nickname": "우주탐험가",
      "profileImageUrl": "https://..."
    },
    "memberCount": 12,
    "maxMembers": 20,
    "thisWeekTotalTime": 7620,
    "thisWeekAverageTime": 635,
    "activeMembersCount": 10,
    "members": [
      {
        "userId": "660e8400-e29b-41d4-a716-446655440001",
        "nickname": "공부왕",
        "profileImageUrl": "https://...",
        "level": 8,
        "role": "member",
        "thisWeekStudyTime": 1523,
        "rank": 1,
        "joinedAt": "2024-01-02T00:00:00Z"
      },
      ...
    ],
    "myRole": "owner",
    "canRejoinAt": null,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

---

### GROUP-003. 그룹 생성

```
POST /groups
```

#### Request Body

```json
{
  "name": "취준생 스터디",
  "description": "함께 취업 준비해요"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| name | String | ✓ | 그룹명 (2~20자) |
| description | String | | 설명 (최대 100자) |

#### Response 201

```json
{
  "success": true,
  "data": {
    "groupId": "880e8400-e29b-41d4-a716-446655440000",
    "name": "취준생 스터디",
    "description": "함께 취업 준비해요",
    "inviteCode": "STUDY2024",
    "createdAt": "2024-01-15T10:00:00Z"
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | GROUP_LIMIT_EXCEEDED | 그룹 생성 한도 초과 (3개) |
| 400 | INVALID_GROUP_NAME | 그룹명 길이 미충족 |
| 422 | FORBIDDEN_WORD_INCLUDED | 금칙어 포함 |

---

### GROUP-004. 그룹 참여 (초대 코드)

```
POST /groups/join
```

#### Request Body

```json
{
  "inviteCode": "STUDY2024"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "group": {
      "groupId": "880e8400-e29b-41d4-a716-446655440000",
      "name": "취준생 스터디",
      "description": "함께 취업 준비해요",
      "memberCount": 13,
      "maxMembers": 20
    }
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 404 | INVALID_INVITE_CODE | 유효하지 않은 초대 코드 |
| 400 | ALREADY_MEMBER | 이미 참여 중 |
| 400 | GROUP_FULL | 그룹 정원 초과 |
| 429 | REJOIN_COOLDOWN | 재가입 쿨다운 중 (24시간) |

---

### GROUP-005. 그룹 정보 수정

```
PATCH /groups/{groupId}
```

#### Request Body

```json
{
  "name": "취준생 스터디 2024",
  "description": "2024년 취업 목표!"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "groupId": "880e8400-e29b-41d4-a716-446655440000",
    "name": "취준생 스터디 2024",
    "description": "2024년 취업 목표!",
    "nameChangeRemaining": 2
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 403 | NOT_GROUP_OWNER | 그룹장만 수정 가능 |
| 400 | NAME_CHANGE_LIMIT_EXCEEDED | 이름 변경 횟수 초과 |

---

### GROUP-006. 그룹 나가기

```
POST /groups/{groupId}/leave
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "그룹에서 나왔습니다.",
    "canRejoinAt": "2024-01-16T10:00:00Z"
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | OWNER_CANNOT_LEAVE | 그룹장은 위임 후 탈퇴 가능 |

---

### GROUP-007. 그룹장 위임

```
POST /groups/{groupId}/transfer-ownership
```

#### Request Body

```json
{
  "newOwnerId": "660e8400-e29b-41d4-a716-446655440001"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "newOwner": {
      "userId": "660e8400-e29b-41d4-a716-446655440001",
      "nickname": "공부왕"
    },
    "message": "그룹장이 위임되었습니다."
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 403 | NOT_GROUP_OWNER | 그룹장만 가능 |
| 400 | USER_NOT_MEMBER | 해당 사용자가 멤버가 아님 |

---

### GROUP-008. 멤버 강퇴

```
DELETE /groups/{groupId}/members/{userId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "멤버를 강퇴했습니다."
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 403 | NOT_GROUP_OWNER | 그룹장만 가능 |
| 400 | CANNOT_KICK_OWNER | 그룹장은 강퇴 불가 |

---

### GROUP-009. 그룹 삭제

```
DELETE /groups/{groupId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "그룹이 삭제되었습니다."
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 403 | NOT_GROUP_OWNER | 그룹장만 가능 |

---

### GROUP-010. 초대 코드 재생성

```
POST /groups/{groupId}/invite-code/regenerate
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "inviteCode": "NEWSTUDY24"
  }
}
```

---

## 12. Rankings (랭킹)

### RANKING-001. 전체 랭킹 조회

```
GET /rankings?period={period}&page={page}&size={size}
```

#### Query Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| period | String | | `weekly` / `allTime` (기본: weekly) |
| page | Integer | | 페이지 (기본: 0) |
| size | Integer | | 개수 (기본: 50) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "period": "weekly",
    "myRanking": {
      "rank": 156,
      "studyTime": 1523,
      "rankChange": 12
    },
    "rankings": [
      {
        "rank": 1,
        "userId": "550e8400-e29b-41d4-a716-446655440001",
        "nickname": "전설의공부왕",
        "profileImageUrl": "https://...",
        "level": 25,
        "studyTime": 4200,
        "representativeBadges": [...]
      },
      ...
    ],
    "pagination": {
      "totalElements": 5000,
      "page": 0,
      "hasNext": true
    }
  }
}
```

---

### RANKING-002. 친구 랭킹 조회

```
GET /rankings/friends?period={period}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "period": "weekly",
    "myRanking": {
      "rank": 5,
      "studyTime": 1523,
      "rankChange": 2
    },
    "rankings": [
      {
        "rank": 1,
        "userId": "660e8400-e29b-41d4-a716-446655440001",
        "nickname": "공부왕",
        "profileImageUrl": "https://...",
        "level": 8,
        "studyTime": 2100,
        "representativeBadges": [...]
      },
      ...
    ],
    "totalCount": 23
  }
}
```

---

### RANKING-003. 그룹 랭킹 조회

```
GET /rankings/groups/{groupId}?period={period}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "period": "weekly",
    "group": {
      "groupId": "880e8400-e29b-41d4-a716-446655440000",
      "name": "취준생 스터디"
    },
    "myRanking": {
      "rank": 3,
      "studyTime": 1523,
      "rankChange": 1
    },
    "rankings": [...],
    "totalCount": 12
  }
}
```

---

## 13. Missions (미션)

### MISSION-001. 미션 목록 조회

```
GET /missions
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "dailyMissions": {
      "missions": [
        {
          "missionId": "daily_attendance",
          "title": "오늘의 출석",
          "description": "앱에 접속하세요",
          "missionType": "daily",
          "rewardFuel": 0.1,
          "currentProgress": 1,
          "requiredProgress": 1,
          "isCompleted": true,
          "completedAt": "2024-01-15T09:00:00Z",
          "isClaimed": true
        },
        {
          "missionId": "daily_1hour",
          "title": "1시간 집중",
          "description": "오늘 1시간 이상 공부하세요",
          "missionType": "daily",
          "rewardFuel": 0.5,
          "currentProgress": 45,
          "requiredProgress": 60,
          "isCompleted": false,
          "completedAt": null,
          "isClaimed": false
        }
      ],
      "completedCount": 3,
      "totalCount": 5,
      "allCompletedBonus": 1.0,
      "allCompleted": false,
      "bonusClaimed": false,
      "resetsAt": "2024-01-16T00:00:00Z"
    },
    "weeklyMissions": {
      "missions": [...],
      "completedCount": 1,
      "totalCount": 4,
      "resetsAt": "2024-01-22T00:00:00Z"
    },
    "hiddenMissions": {
      "completedCount": 2,
      "hint": "특별한 조건을 달성해보세요..."
    }
  }
}
```

---

### MISSION-002. 미션 보상 수령

```
POST /missions/{missionId}/claim
```

#### Request Body

```json
{
  "periodKey": "2024-01-15"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| periodKey | String | ✓ | 기간 키 (daily: YYYY-MM-DD, weekly: YYYY-Www) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "missionId": "daily_1hour",
    "rewardFuel": 0.5,
    "currentFuel": 24.3
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | MISSION_NOT_COMPLETED | 미션 미완료 |
| 400 | ALREADY_CLAIMED | 이미 보상 수령함 |

---

### MISSION-003. 일일 미션 보너스 수령

```
POST /missions/daily/bonus/claim
```

#### Request Body

```json
{
  "bonusDate": "2024-01-15"
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "bonusFuel": 1.0,
    "currentFuel": 25.3
  }
}
```

#### Error Responses

| HTTP | 코드 | 상황 |
|------|------|------|
| 400 | NOT_ALL_COMPLETED | 모든 일일 미션 미완료 |
| 400 | BONUS_ALREADY_CLAIMED | 이미 보너스 수령함 |

---

## 14. Badges (뱃지)

### BADGE-001. 뱃지 목록 조회

```
GET /badges
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "categoryId": "time",
        "name": "시간 누적",
        "badges": [
          {
            "badgeId": "time_10h",
            "name": "견습 탐험가",
            "description": "총 10시간 공부 달성",
            "imageUrl": "/badges/time_10h.png",
            "rarity": "common",
            "isEarned": true,
            "earnedAt": "2024-01-05T10:00:00Z",
            "conditionDescription": "총 10시간 공부",
            "progress": null
          },
          {
            "badgeId": "time_100h",
            "name": "스타 파일럿",
            "description": "총 100시간 공부 달성",
            "imageUrl": "/badges/time_100h.png",
            "rarity": "rare",
            "isEarned": false,
            "earnedAt": null,
            "conditionDescription": "총 100시간 공부",
            "progress": {
              "current": 76,
              "required": 100,
              "percent": 76.0
            }
          }
        ]
      },
      ...
    ],
    "totalCount": 20,
    "earnedCount": 12
  }
}
```

---

### BADGE-002. 뱃지 상세 조회

```
GET /badges/{badgeId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "badgeId": "time_100h",
    "name": "스타 파일럿",
    "description": "총 100시간 공부를 달성하셨습니다!",
    "imageUrl": "/badges/time_100h.png",
    "rarity": "rare",
    "isEarned": false,
    "earnedAt": null,
    "conditionDescription": "총 100시간 공부",
    "progress": {
      "current": 76,
      "required": 100,
      "percent": 76.0
    },
    "earnedUsersCount": 1523
  }
}
```

---

## 15. Ships (공부선 스킨)

### SHIP-001. 공부선 목록 조회

```
GET /ships
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "ships": [
      {
        "shipId": "ship_basic",
        "name": "기본 공부선",
        "description": "모든 탐험가의 첫 공부선",
        "imageUrl": "/ships/basic.png",
        "animationUrl": null,
        "rarity": "common",
        "shipType": "static",
        "isOwned": true,
        "obtainedAt": "2024-01-01T00:00:00Z",
        "obtainMethod": "기본 제공"
      },
      {
        "shipId": "ship_mars",
        "name": "화성 탐사선",
        "description": "화성 해금 보상",
        "imageUrl": "/ships/mars.png",
        "animationUrl": "/ships/mars.riv",
        "rarity": "epic",
        "shipType": "animated",
        "isOwned": false,
        "obtainedAt": null,
        "obtainMethod": "화성 장소 해금"
      }
    ],
    "totalCount": 15,
    "ownedCount": 5,
    "representativeShipId": "ship_basic"
  }
}
```

---

### SHIP-002. 공부선 상세 조회

```
GET /ships/{shipId}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "shipId": "ship_mars",
    "name": "화성 탐사선",
    "description": "붉은 행성을 탐험하기 위해 설계된 특수 공부선",
    "imageUrl": "/ships/mars.png",
    "animationUrl": "/ships/mars.riv",
    "rarity": "epic",
    "shipType": "animated",
    "isOwned": false,
    "obtainedAt": null,
    "obtainMethod": "화성 장소 해금",
    "ownersCount": 523
  }
}
```

---

## 16. Settings (설정)

### SETTINGS-001. 설정 조회

```
GET /settings
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "notifications": {
      "pushEnabled": true,
      "streakReminder": true,
      "friendRequestNotification": true
    },
    "account": {
      "email": "user@gmail.com",
      "provider": "google",
      "connectedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

---

### SETTINGS-002. 알림 설정 변경

```
PATCH /settings/notifications
```

#### Request Body

```json
{
  "pushEnabled": true,
  "streakReminder": false,
  "friendRequestNotification": true
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "notifications": {
      "pushEnabled": true,
      "streakReminder": false,
      "friendRequestNotification": true
    }
  }
}
```

---

## 17. Notifications (알림)

### NOTIFICATION-001. 알림 목록 조회

```
GET /notifications?page={page}&size={size}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "notificationId": "990e8400-e29b-41d4-a716-446655440000",
        "notificationType": "friend_request",
        "title": "새로운 친구 요청",
        "body": "열공러님이 친구 요청을 보냈습니다.",
        "data": {
          "requestId": "770e8400-e29b-41d4-a716-446655440000",
          "fromUserId": "550e8400-e29b-41d4-a716-446655440000"
        },
        "isRead": false,
        "createdAt": "2024-01-15T09:00:00Z"
      },
      {
        "notificationId": "990e8400-e29b-41d4-a716-446655440001",
        "notificationType": "streak_reminder",
        "title": "스트릭 유지하세요!",
        "body": "오늘 아직 공부 기록이 없어요. 스트릭을 유지하려면 지금 시작하세요!",
        "data": {},
        "isRead": true,
        "createdAt": "2024-01-15T20:00:00Z"
      }
    ],
    "unreadCount": 3,
    "pagination": {
      "totalElements": 50,
      "page": 0,
      "hasNext": true
    }
  }
}
```

---

### NOTIFICATION-002. 알림 읽음 처리

```
POST /notifications/read
```

#### Request Body

```json
{
  "notificationIds": [
    "990e8400-e29b-41d4-a716-446655440000",
    "990e8400-e29b-41d4-a716-446655440001"
  ]
}
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "unreadCount": 1
  }
}
```

---

### NOTIFICATION-003. 전체 읽음 처리

```
POST /notifications/read-all
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "message": "모든 알림을 읽음 처리했습니다."
  }
}
```

---

## 18. Home (홈)

### HOME-001. 홈 데이터 조회

```
GET /home
```

#### Response 200

```json
{
  "success": true,
  "data": {
    "user": {
      "nickname": "우주탐험가",
      "level": 5,
      "levelProgress": 78.5
    },
    "stats": {
      "currentFuel": 23.8,
      "currentStreak": 7,
      "todayStudyTime": 65
    },
    "currentLocation": {
      "locationId": "seoul",
      "name": "서울",
      "imageUrl": "/locations/seoul.png"
    },
    "representativeShip": {
      "shipId": "ship_basic",
      "name": "기본 공부선",
      "imageUrl": "/ships/basic.png",
      "animationUrl": null
    },
    "todayTodos": {
      "totalCount": 5,
      "completedCount": 3
    },
    "activeSession": null,
    "dailyMissionsProgress": {
      "completedCount": 3,
      "totalCount": 5
    },
    "unreadNotificationsCount": 2,
    "pendingFriendRequestsCount": 1
  }
}
```

---

## 19. Statistics (통계)

### STATS-001. 공부 통계 조회

```
GET /statistics?period={period}&startDate={startDate}&endDate={endDate}
```

#### Query Parameters

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| period | String | | `daily` / `weekly` / `monthly` |
| startDate | String | | 시작 날짜 (YYYY-MM-DD) |
| endDate | String | | 종료 날짜 (YYYY-MM-DD) |

#### Response 200

```json
{
  "success": true,
  "data": {
    "period": "weekly",
    "startDate": "2024-01-08",
    "endDate": "2024-01-14",
    "totalStudyTime": 1523,
    "totalSessions": 25,
    "averageSessionTime": 61,
    "dailyData": [
      {
        "date": "2024-01-08",
        "studyTime": 180,
        "sessionCount": 3,
        "todoCompletedCount": 4
      },
      {
        "date": "2024-01-09",
        "studyTime": 240,
        "sessionCount": 4,
        "todoCompletedCount": 5
      },
      ...
    ]
  }
}
```

---

## API 요약

### 엔드포인트 총 개수

| 영역 | P0 | P1 | 합계 |
|------|-----|-----|------|
| Auth | 3 | 0 | 3 |
| Users | 2 | 3 | 5 |
| Profile | 2 | 3 | 5 |
| Todos | 5 | 1 | 6 |
| Timer | 6 | 0 | 6 |
| Fuel | 1 | 1 | 2 |
| Level | 1 | 0 | 1 |
| Locations | 2 | 1 | 3 |
| Friends | 9 | 1 | 10 |
| Groups | 9 | 1 | 10 |
| Rankings | 3 | 0 | 3 |
| Missions | 0 | 3 | 3 |
| Badges | 0 | 2 | 2 |
| Ships | 0 | 2 | 2 |
| Settings | 0 | 2 | 2 |
| Notifications | 0 | 3 | 3 |
| Home | 1 | 0 | 1 |
| Statistics | 0 | 1 | 1 |
| **합계** | **44** | **24** | **68** |

---
