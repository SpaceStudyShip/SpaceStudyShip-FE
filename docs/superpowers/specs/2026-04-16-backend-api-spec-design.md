# Backend API Specification

> **Space Study Ship** 백엔드 API 명세서
> **Version:** 1.0.0
> **Base URL:** `https://api.spacestudyship.com`
> **Date:** 2026-04-16

---

## 공통 사항

### 인증

| 항목 | 값 |
|------|-----|
| 인증 방식 | JWT Bearer Token |
| 헤더 | `Authorization: Bearer {accessToken}` |
| 공개 API (토큰 불필요) | `POST /api/auth/login`, `POST /api/auth/reissue` |

### 공통 에러 응답

```json
{
  "code": "ERROR_CODE",
  "message": "사람이 읽을 수 있는 메시지"
}
```

| HTTP Status | code | 설명 |
|-------------|------|------|
| 400 | `BAD_REQUEST` | 요청 파라미터 오류 |
| 401 | `UNAUTHORIZED` | 토큰 없음 또는 만료 |
| 403 | `FORBIDDEN` | 권한 없음 |
| 404 | `NOT_FOUND` | 리소스 없음 |
| 409 | `CONFLICT` | 중복 (닉네임, 친구 요청 등) |
| 500 | `INTERNAL_ERROR` | 서버 내부 오류 |

### 공통 규칙

- 날짜/시간 형식: **ISO 8601** (`2026-04-16T09:30:00Z`), 날짜만 필요한 경우 `YYYY-MM-DD` (`2026-04-16`)
- ID 타입: 서버 생성 = `Long`, 클라이언트 생성 = `String (UUID)`
- 페이지네이션: `?page=0&size=20` (0-indexed)
- Duration: **분 단위 정수** (`durationMinutes: 90`)
- 연료 충전: 별도 API 없음. 타이머 세션 저장(`POST /api/timer-sessions`) 시 서버에서 자동 충전

---

## 1. Auth (인증 + 프로필)

> Base Path: `/api/auth`

### 1.1 소셜 로그인

`POST /api/auth/login`

**Description:** Firebase ID Token으로 로그인/회원가입. 신규 유저는 자동 생성.

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `socialPlatform` | String | O | `GOOGLE` 또는 `APPLE` |
| `idToken` | String | O | Firebase ID Token |
| `fcmToken` | String | O | FCM 디바이스 토큰 |
| `deviceType` | String | O | `IOS` 또는 `ANDROID` |
| `deviceId` | String | O | 고유 디바이스 ID |

**Response (200 - 기존 회원 / 201 - 신규 가입):**

```json
{
  "userId": 1,
  "nickname": "민첩한괴도5308",
  "tokens": {
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG..."
  },
  "isNewUser": false
}
```

---

### 1.2 로그아웃

`POST /api/auth/logout`

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `refreshToken` | String | O | Refresh Token |

**Response:** `204 No Content`

---

### 1.3 토큰 재발급

`POST /api/auth/reissue`

> 인증 불필요 (공개 API)

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `refreshToken` | String | O | Refresh Token |

**Response (200):**

```json
{
  "tokens": {
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG..."
  }
}
```

**Error:**

| Status | code | 상황 |
|--------|------|------|
| 401 | `INVALID_REFRESH_TOKEN` | Refresh Token 만료 또는 유효하지 않음 |

---

### 1.4 회원 탈퇴

`DELETE /api/auth/withdraw`

**Description:** 계정 및 모든 관련 데이터 삭제. 되돌릴 수 없음.

**Response:** `204 No Content`

---

### 1.5 닉네임 중복 확인

`GET /api/auth/check-nickname`

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `nickname` | String | O | 확인할 닉네임 (2~10자) |

**Response (200):**

```json
{
  "available": true
}
```

---

### 1.6 닉네임 변경

`PATCH /api/auth/nickname`

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `nickname` | String | O | 새 닉네임 (2~10자) |

**Response (200):**

```json
{
  "nickname": "새닉네임"
}
```

**Error:**

| Status | code | 상황 |
|--------|------|------|
| 409 | `NICKNAME_DUPLICATED` | 이미 사용 중인 닉네임 |

---

## 2. Todo (할 일)

> Base Path: `/api/todos`

### 2.1 Todo 목록 조회

`GET /api/todos`

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `date` | String | X | 특정 날짜 필터 (`2026-04-16`) |
| `categoryId` | String | X | 카테고리 필터 |

**Response (200):**

```json
[
  {
    "id": "uuid-1234",
    "title": "수학 문제 풀기",
    "scheduledDates": ["2026-04-16", "2026-04-17"],
    "completedDates": ["2026-04-16"],
    "categoryIds": ["cat-1"],
    "estimatedMinutes": 60,
    "actualMinutes": 45,
    "createdAt": "2026-04-15T10:00:00Z",
    "updatedAt": "2026-04-16T09:30:00Z"
  }
]
```

---

### 2.2 Todo 생성

`POST /api/todos`

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `title` | String | O | 제목 (1~100자) |
| `categoryIds` | String[] | X | 카테고리 ID 목록 (기본: `[]`) |
| `estimatedMinutes` | Integer | X | 예상 소요 시간 (분) |
| `scheduledDates` | String[] | X | 예정 날짜 목록 (`["2026-04-16"]`) |

**Response (201):**

```json
{
  "id": "uuid-1234",
  "title": "수학 문제 풀기",
  "scheduledDates": ["2026-04-16"],
  "completedDates": [],
  "categoryIds": ["cat-1"],
  "estimatedMinutes": 60,
  "actualMinutes": null,
  "createdAt": "2026-04-16T10:00:00Z",
  "updatedAt": "2026-04-16T10:00:00Z"
}
```

---

### 2.3 Todo 수정

`PATCH /api/todos/{todoId}`

**Path Parameters:**

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `todoId` | String | Todo ID |

**Request Body (변경할 필드만 전송):**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `title` | String | X | 제목 |
| `scheduledDates` | String[] | X | 예정 날짜 목록 (`YYYY-MM-DD`) |
| `completedDates` | String[] | X | 완료 날짜 목록 (`YYYY-MM-DD`) |
| `categoryIds` | String[] | X | 카테고리 ID 목록 |
| `estimatedMinutes` | Integer | X | 예상 소요 시간 |
| `actualMinutes` | Integer | X | 실제 소요 시간 |

**Response (200):** 수정된 Todo 객체 (2.2 응답과 동일 형식)

---

### 2.4 Todo 삭제

`DELETE /api/todos/{todoId}`

**Response:** `204 No Content`

---

### 2.5 카테고리 목록 조회

`GET /api/todo-categories`

**Response (200):**

```json
[
  {
    "id": "cat-1",
    "name": "수학",
    "iconId": "math_icon",
    "positionX": 0.3,
    "positionY": 0.5,
    "createdAt": "2026-04-01T00:00:00Z",
    "updatedAt": null
  }
]
```

---

### 2.6 카테고리 생성

`POST /api/todo-categories`

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `name` | String | O | 카테고리 이름 (1~20자) |
| `iconId` | String | X | 아이콘 ID |
| `positionX` | Double | X | 맵 가로 위치 (0.0~1.0) |
| `positionY` | Double | X | 맵 세로 위치 (0.0~1.0) |

**Response (201):** 생성된 카테고리 객체

---

### 2.7 카테고리 수정

`PATCH /api/todo-categories/{categoryId}`

**Request Body (변경할 필드만 전송):**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `name` | String | X | 카테고리 이름 |
| `iconId` | String | X | 아이콘 ID |
| `positionX` | Double | X | 맵 가로 위치 (0.0~1.0) |
| `positionY` | Double | X | 맵 세로 위치 (0.0~1.0) |

**Response (200):** 수정된 카테고리 객체

---

### 2.8 카테고리 삭제

`DELETE /api/todo-categories/{categoryId}`

**Description:** 카테고리 삭제 시 해당 카테고리에 속한 Todo의 `categoryIds`에서 자동 제거.

**Response:** `204 No Content`

---

## 3. Timer (공부 타이머)

> Base Path: `/api/timer-sessions`

### 3.1 세션 목록 조회

`GET /api/timer-sessions`

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `startDate` | String | X | 시작일 필터 (`2026-04-01`) |
| `endDate` | String | X | 종료일 필터 (`2026-04-16`) |
| `page` | Integer | X | 페이지 (기본: 0) |
| `size` | Integer | X | 페이지 크기 (기본: 20) |

**Response (200):**

```json
{
  "content": [
    {
      "id": "session-uuid",
      "todoId": "todo-uuid",
      "todoTitle": "수학 문제 풀기",
      "startedAt": "2026-04-16T09:00:00Z",
      "endedAt": "2026-04-16T10:30:00Z",
      "durationMinutes": 90
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 45,
  "totalPages": 3
}
```

---

### 3.2 세션 기록 저장

`POST /api/timer-sessions`

**Description:** 타이머 종료 시 세션 기록 저장. 서버에서 시간 유효성 검증 후 연료 자동 충전.

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `todoId` | String | X | 연결된 Todo ID |
| `todoTitle` | String | X | Todo 제목 (스냅샷) |
| `startedAt` | String | O | 시작 시각 (ISO 8601) |
| `endedAt` | String | O | 종료 시각 (ISO 8601) |
| `durationMinutes` | Integer | O | 공부 시간 (분) |

**Response (201):**

```json
{
  "session": {
    "id": "server-generated-uuid",
    "todoId": "todo-uuid",
    "todoTitle": "수학 문제 풀기",
    "startedAt": "2026-04-16T09:00:00Z",
    "endedAt": "2026-04-16T10:30:00Z",
    "durationMinutes": 90
  },
  "fuelCharged": 90
}
```

> `fuelCharged`: 서버에서 검증 후 실제 충전된 연료량. 클라이언트 `durationMinutes`와 다를 수 있음 (조작 방지).

**Error:**

| Status | code | 상황 |
|--------|------|------|
| 400 | `INVALID_SESSION` | startedAt > endedAt, durationMinutes 불일치 등 |

---

### 3.3 오늘 공부 통계

`GET /api/timer-sessions/today-stats`

**Response (200):**

```json
{
  "totalMinutes": 180,
  "sessionCount": 3,
  "streak": 7
}
```

---

## 4. Fuel (연료)

> Base Path: `/api/fuel`

### 4.1 연료 잔량 조회

`GET /api/fuel`

**Response (200):**

```json
{
  "currentFuel": 350,
  "totalCharged": 1200,
  "totalConsumed": 850,
  "pendingMinutes": 0,
  "lastUpdatedAt": "2026-04-16T10:30:00Z"
}
```

---

### 4.2 연료 거래 내역 조회

`GET /api/fuel/transactions`

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `type` | String | X | `charge` 또는 `consume` |
| `page` | Integer | X | 페이지 (기본: 0) |
| `size` | Integer | X | 페이지 크기 (기본: 20) |

**Response (200):**

```json
{
  "content": [
    {
      "id": "tx-uuid",
      "type": "charge",
      "amount": 90,
      "reason": "STUDY_SESSION",
      "referenceId": "session-uuid",
      "balanceAfter": 350,
      "createdAt": "2026-04-16T10:30:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 120,
  "totalPages": 6
}
```

---

## 5. Exploration (탐험)

> Base Path: `/api/explorations`

### 5.1 행성 목록 조회

`GET /api/explorations/planets`

**Description:** 전체 행성 목록 + 사용자의 해금/클리어 상태 반영.

**Response (200):**

```json
[
  {
    "id": "earth",
    "name": "지구",
    "nodeType": "planet",
    "depth": 2,
    "icon": "earth",
    "parentId": null,
    "requiredFuel": 0,
    "isUnlocked": true,
    "isCleared": false,
    "sortOrder": 0,
    "description": "모든 여정의 시작점",
    "mapX": 0.5,
    "mapY": 0.3,
    "unlockedAt": "2026-04-01T00:00:00Z",
    "progress": {
      "clearedChildren": 3,
      "totalChildren": 5,
      "progressRatio": 0.6
    }
  }
]
```

---

### 5.2 행성 하위 지역 목록 조회

`GET /api/explorations/planets/{planetId}/regions`

**Response (200):**

```json
[
  {
    "id": "region-kr",
    "name": "대한민국",
    "nodeType": "region",
    "depth": 3,
    "icon": "KR",
    "parentId": "earth",
    "requiredFuel": 100,
    "isUnlocked": true,
    "isCleared": true,
    "sortOrder": 0,
    "description": "한반도의 남쪽",
    "mapX": 0.7,
    "mapY": 0.4,
    "unlockedAt": "2026-04-05T15:30:00Z"
  }
]
```

---

### 5.3 지역 해금

`POST /api/explorations/regions/{regionId}/unlock`

**Description:** 연료를 소비하여 지역 해금. 서버에서 연료 잔량 확인 + 차감 + 해금 상태 변경을 원자적으로 처리. 별도의 fuel consume API 호출 불필요. 해당 행성의 모든 지역이 해금되면 행성도 자동 클리어.

**Response (200):**

```json
{
  "region": {
    "id": "region-jp",
    "name": "일본",
    "isUnlocked": true,
    "isCleared": true,
    "unlockedAt": "2026-04-16T11:00:00Z"
  },
  "fuelConsumed": 100,
  "currentFuel": 250,
  "planetCleared": false
}
```

**Error:**

| Status | code | 상황 |
|--------|------|------|
| 400 | `INSUFFICIENT_FUEL` | 연료 부족 |
| 400 | `ALREADY_UNLOCKED` | 이미 해금된 지역 |

---

### 5.4 행성 해금

`POST /api/explorations/planets/{planetId}/unlock`

**Description:** 연료를 소비하여 행성 해금 (행성 진입 가능 상태로 변경). 서버에서 연료 잔량 확인 + 차감 + 해금을 원자적으로 처리. 별도의 fuel consume API 호출 불필요.

**Response (200):**

```json
{
  "planet": {
    "id": "mars",
    "name": "화성",
    "isUnlocked": true,
    "isCleared": false,
    "unlockedAt": "2026-04-16T11:30:00Z"
  },
  "fuelConsumed": 200,
  "currentFuel": 50
}
```

**Error:**

| Status | code | 상황 |
|--------|------|------|
| 400 | `INSUFFICIENT_FUEL` | 연료 부족 |
| 400 | `ALREADY_UNLOCKED` | 이미 해금된 행성 |

---

## 6. Badge (배지)

> Base Path: `/api/badges`

### 6.1 배지 목록 조회

`GET /api/badges`

**Description:** 전체 배지 목록 + 사용자의 해금 상태 반영.

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `category` | String | X | 필터: `STUDY_TIME`, `STREAK`, `SESSION`, `EXPLORATION`, `FUEL`, `HIDDEN` |
| `unlockedOnly` | Boolean | X | `true`: 해금된 배지만 |

**Response (200):**

```json
[
  {
    "id": "badge-first-hour",
    "name": "첫 번째 시간",
    "icon": "clock_1h",
    "description": "누적 공부 시간 1시간 달성",
    "category": "STUDY_TIME",
    "rarity": "NORMAL",
    "requiredValue": 60,
    "isUnlocked": true,
    "unlockedAt": "2026-04-05T10:00:00Z"
  },
  {
    "id": "badge-streak-7",
    "name": "일주일 연속",
    "icon": "flame_7d",
    "description": "7일 연속 공부 달성",
    "category": "STREAK",
    "rarity": "RARE",
    "requiredValue": 7,
    "isUnlocked": false,
    "unlockedAt": null
  }
]
```

---

### 6.2 배지 해금 확인 (서버 트리거)

`POST /api/badges/check`

**Description:** 서버에서 현재 사용자의 통계를 기반으로 해금 가능한 배지를 확인하고 자동 해금. 타이머 종료, 탐험 해금 등의 이벤트 후 클라이언트가 호출.

**Response (200):**

```json
{
  "newlyUnlocked": [
    {
      "id": "badge-streak-7",
      "name": "일주일 연속",
      "rarity": "RARE",
      "unlockedAt": "2026-04-16T10:30:00Z"
    }
  ]
}
```

> `newlyUnlocked`가 빈 배열이면 새로 해금된 배지 없음.

---

## 7. Social (친구 + 랭킹)

> Base Path: `/api/friends`

### 7.1 친구 목록 조회

`GET /api/friends`

**Description:** 친구 목록 + 실시간 상태 (공부 중/대기/오프라인).

**Response (200):**

```json
[
  {
    "userId": 10,
    "nickname": "김우주",
    "status": "STUDYING",
    "studyDurationMinutes": 155,
    "currentSubject": "수학",
    "weeklyStudyDurationMinutes": 980
  },
  {
    "userId": 11,
    "nickname": "최성운",
    "status": "IDLE",
    "studyDurationMinutes": null,
    "currentSubject": null,
    "weeklyStudyDurationMinutes": 330
  }
]
```

**Status 값:**

| 값 | 설명 |
|----|------|
| `STUDYING` | 현재 타이머 실행 중 |
| `IDLE` | 앱 열려 있지만 타이머 미실행 |
| `OFFLINE` | 앱 미사용 |

---

### 7.2 친구 요청 보내기

`POST /api/friends/request`

**Request Body:**

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `targetNickname` | String | O | 친구 추가할 닉네임 |

**Response (201):**

```json
{
  "requestId": 1,
  "targetUserId": 42,
  "targetNickname": "김우주",
  "status": "PENDING",
  "createdAt": "2026-04-16T11:00:00Z"
}
```

**Error:**

| Status | code | 상황 |
|--------|------|------|
| 404 | `USER_NOT_FOUND` | 닉네임에 해당하는 유저 없음 |
| 409 | `ALREADY_FRIENDS` | 이미 친구 |
| 409 | `REQUEST_ALREADY_SENT` | 이미 요청 보냄 |

---

### 7.3 받은 친구 요청 목록

`GET /api/friends/requests/received`

**Response (200):**

```json
[
  {
    "requestId": 1,
    "fromUserId": 10,
    "fromNickname": "박탐험",
    "status": "PENDING",
    "createdAt": "2026-04-15T20:00:00Z"
  }
]
```

---

### 7.4 친구 요청 수락

`POST /api/friends/requests/{requestId}/accept`

**Path Parameters:**

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `requestId` | Long | 친구 요청 ID |

**Response (200):**

```json
{
  "friendUserId": 10,
  "friendNickname": "박탐험"
}
```

---

### 7.5 친구 요청 거절

`POST /api/friends/requests/{requestId}/reject`

**Path Parameters:**

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `requestId` | Long | 친구 요청 ID |

**Response:** `204 No Content`

---

### 7.6 친구 삭제

`DELETE /api/friends/{friendUserId}`

**Response:** `204 No Content`

---

### 7.7 친구 랭킹 조회

`GET /api/friends/ranking`

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `period` | String | X | `DAILY` (기본), `WEEKLY`, `MONTHLY` |

**Description:** 나 + 친구들의 공부 시간 랭킹. 정렬: 공부 시간 내림차순.

**Response (200):**

```json
{
  "period": "WEEKLY",
  "myRank": 4,
  "rankings": [
    {
      "rank": 1,
      "userId": 10,
      "nickname": "김우주",
      "studyDurationMinutes": 5670,
      "isCurrentUser": false
    },
    {
      "rank": 4,
      "userId": 1,
      "nickname": "나",
      "studyDurationMinutes": 3300,
      "isCurrentUser": true
    }
  ]
}
```

---

## 데이터 동기화 전략 요약

| API | Tier | 전략 | 설명 |
|-----|------|------|------|
| Todo CRUD | Tier 1 | Optimistic | 로컬 먼저 저장, 백그라운드 동기화 |
| Timer 세션 저장 | Tier 2 | Server-Validated | 서버에서 시간 검증 후 연료 충전 |
| Fuel 소비 | Tier 2 | Server-Validated | 서버에서 잔량 확인 후 차감 |
| Exploration 해금 | Tier 2 | Server-Validated | Fuel 소비 + 해금 상태 변경 원자적 처리 |
| Badge 해금 | Tier 2 | Server-Validated | 서버에서 통계 기반 해금 조건 확인 |
| 친구 목록/랭킹 | Tier 3 | Server-Only | 항상 서버 조회, 로컬 캐시는 읽기 전용 |

---

## 엔드포인트 총 정리

| # | Method | Path | 설명 |
|---|--------|------|------|
| | | **Auth** | |
| 1 | POST | `/api/auth/login` | 소셜 로그인 |
| 2 | POST | `/api/auth/logout` | 로그아웃 |
| 3 | POST | `/api/auth/reissue` | 토큰 재발급 |
| 4 | DELETE | `/api/auth/withdraw` | 회원 탈퇴 |
| 5 | GET | `/api/auth/check-nickname` | 닉네임 중복 확인 |
| 6 | PATCH | `/api/auth/nickname` | 닉네임 변경 |
| | | **Todo** | |
| 7 | GET | `/api/todos` | Todo 목록 조회 |
| 8 | POST | `/api/todos` | Todo 생성 |
| 9 | PATCH | `/api/todos/{todoId}` | Todo 수정 |
| 10 | DELETE | `/api/todos/{todoId}` | Todo 삭제 |
| 11 | GET | `/api/todo-categories` | 카테고리 목록 |
| 12 | POST | `/api/todo-categories` | 카테고리 생성 |
| 13 | PATCH | `/api/todo-categories/{categoryId}` | 카테고리 수정 |
| 14 | DELETE | `/api/todo-categories/{categoryId}` | 카테고리 삭제 |
| | | **Timer** | |
| 15 | GET | `/api/timer-sessions` | 세션 목록 조회 |
| 16 | POST | `/api/timer-sessions` | 세션 기록 저장 |
| 17 | GET | `/api/timer-sessions/today-stats` | 오늘 통계 |
| | | **Fuel** | |
| 18 | GET | `/api/fuel` | 연료 잔량 조회 |
| 19 | GET | `/api/fuel/transactions` | 거래 내역 조회 |
| | | **Exploration** | |
| 20 | GET | `/api/explorations/planets` | 행성 목록 |
| 21 | GET | `/api/explorations/planets/{planetId}/regions` | 지역 목록 |
| 22 | POST | `/api/explorations/regions/{regionId}/unlock` | 지역 해금 (연료 자동 차감) |
| 23 | POST | `/api/explorations/planets/{planetId}/unlock` | 행성 해금 (연료 자동 차감) |
| | | **Badge** | |
| 24 | GET | `/api/badges` | 배지 목록 |
| 25 | POST | `/api/badges/check` | 배지 해금 확인 |
| | | **Social** | |
| 26 | GET | `/api/friends` | 친구 목록 |
| 27 | POST | `/api/friends/request` | 친구 요청 |
| 28 | GET | `/api/friends/requests/received` | 받은 요청 목록 |
| 29 | POST | `/api/friends/requests/{requestId}/accept` | 요청 수락 |
| 30 | POST | `/api/friends/requests/{requestId}/reject` | 요청 거절 |
| 31 | DELETE | `/api/friends/{friendUserId}` | 친구 삭제 |
| 32 | GET | `/api/friends/ranking` | 친구 랭킹 |
