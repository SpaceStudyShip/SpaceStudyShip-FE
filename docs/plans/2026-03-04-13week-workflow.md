# 우주공부선 — 13주 개발 워크플로우

## 프로젝트 개요

**프로젝트명:** Space Study Ship (우주공부선)
**목표:** 우주 탐험 테마 게이미피케이션 학습 관리 앱
**기술 스택:** Flutter + Spring Boot + Firebase + MySQL

---

## 1주차 — 프로젝트 정의 및 환경 구축

### 프로젝트 배경

대학생의 학습 시간 관리에서 기존 Todo·타이머 앱은 기록과 측정에 치중되어 있어, 장기적 동기부여 요소가 부족하다. 이에 학습 시간을 시각적 보상과 성취 경험으로 전환하는 서비스를 기획했다. 공부 시간을 '연료'로 변환해 탐험 구조로 확장하는 방식으로, 학습 과정 자체를 도전 과제화하여 지속적 사용을 유도한다.

### 기대 효과

- 기획·설계·개발 전 과정을 직접 경험하는 실무 중심 학습
- 프론트엔드·백엔드 유기적 연동 구조 설계·구현 역량
- 게이미피케이션 기반 UX 설계 (행동 변화·지속성 고려)
- 팀 협업 개발 경험 (역할 분담, 일정 관리, 문제 해결)

### 환경 구축

| 항목        | 내용                                                             |
| ----------- | ---------------------------------------------------------------- |
| CI/CD       | GitHub Actions + Playstore/TestFlight 자동화 빌드                |
| 패키지 정의 | Flutter 3.9, Riverpod 2.6, Freezed 2.5, Dio + Retrofit, Firebase |
| 아키텍처    | Clean 3-Layer + DIP (Presentation → Domain ← Data)              |
| 코드 생성   | build_runner (Freezed, Riverpod Generator, Retrofit Generator)   |

**산출물:** 프로젝트 구조 확정, CI/CD 파이프라인 동작 확인

---

## 2주차 — 디자인 시스템 구축

| 항목         | 내용                                                                      |
| ------------ | ------------------------------------------------------------------------- |
| 색상 체계    | AppColors — 우주 테마 다크 팔레트                                         |
| 간격/반경    | AppSpacing (s4~s64), AppPadding 프리셋, AppRadius                         |
| 타이포그래피 | AppTextStyles — Pretendard 폰트 기반                                      |
| 공통 위젯    | AppButton, AppCard, AppDialog, AppTextField, SpaceBackground, FadeSlideIn |
| 디자인 토큰  | 애니메이션 duration, curve, tap scale (토스 UX 참고)                      |

**산출물:** 디자인 상수 체계 완성, 공통 위젯 라이브러리

---

## 3주차 — 핵심 기능 (1): 타이머 + 할일

### 타이머 기능

- 포모도로 타이머 (시작/일시정지/종료)
- 세션 기록 로컬 저장 (SharedPreferences)
- 타이머 이력 화면
- 항성-행성 공전 애니메이션 (CustomPaint 기반 pseudo-3D)

### 할일 기능

- Todo CRUD (생성/조회/수정/삭제)
- 카테고리 분류
- 캘린더 연동 (table_calendar)
- 타이머 연동 (할일 선택 후 집중 시간 측정)

**산출물:** Timer + Todo 기능 완전 구현 (게스트 모드)

---

## 4주차 — 핵심 기능 (2): 배지 + 연료 + 탐험

### 배지 시스템

- 해금 조건 (누적 학습 시간, 연속 출석, 세션 수)
- 배지 컬렉션 UI + 해금 축하 다이얼로그
- 시드 데이터 기반 배지 목록

### 연료 시스템

- 학습 시간 → 연료 변환 (pendingMinutes → fuel)
- currentFuel / totalCharged / totalConsumed 추적

### 탐험 시스템

- 행성/지역 해금 (연료 소비)
- 진행률 추적
- 우주 지도 CustomPaint 렌더링

**산출물:** Badge + Fuel + Exploration 기능 완전 구현 (게스트 모드)

---

## 5주차 — 인증 및 알림

### Firebase Auth

- Google / Apple / Guest 소셜 로그인
- Firebase IdToken 기반 로그인 플로우 완성
- IdToken → 백엔드 JWT 발급 구조 설계 (7주차 연동 대비)
- Auth Interceptor 클라이언트 인프라 구축 (토큰 저장, 자동 주입 틀)

### FCM 푸시 알림

- Firebase Cloud Messaging 연동
- 포그라운드/백그라운드 메시지 처리
- 로컬 알림 표시

### 추가 인프라

- Firebase Crashlytics (크래시 리포팅)
- Firebase Analytics (이벤트 추적)

**산출물:** 인증 플로우 완성, 푸시 알림 동작 확인

---

## 6주차 — Spring Boot 백엔드 기반 구축

| 항목            | 내용                                                               |
| --------------- | ------------------------------------------------------------------ |
| 프로젝트 초기화 | Spring Boot 3.x + Gradle + Java/Kotlin                             |
| DB 설계         | MySQL 스키마 (User, Timer Session, Todo, Badge, Fuel, Exploration) |
| API 명세        | Swagger/OpenAPI 문서화                                             |
| 공통 모듈       | 예외 처리, 응답 포맷, 로깅                                         |
| 배포 환경       | Docker + AWS/GCP 기본 세팅                                         |

**산출물:** Spring Boot 프로젝트 구조, DB 스키마, API 명세서

---

## 7주차 — Auth API 연동

| 항목             | 내용                                               |
| ---------------- | -------------------------------------------------- |
| 로그인 API       | POST /api/auth/login (Firebase IdToken → JWT 발급) |
| 로그아웃 API     | POST /api/auth/logout (Refresh Token 무효화)       |
| 토큰 갱신 API    | POST /api/auth/reissue (Refresh Token → 새 JWT)    |
| 회원 탈퇴 API    | POST /api/auth/withdraw                            |
| 닉네임 중복 확인 | POST /api/auth/check-nickname                      |
| Flutter 연동     | 기존 Auth Interceptor + Retrofit 클라이언트 연결   |

**산출물:** 인증 API 완성, Flutter 로그인 플로우 백엔드 연동

---

## 8주차 — Timer + Todo API 연동

### Timer API

- 세션 시작/종료 기록 API
- 세션 이력 조회 (페이지네이션)
- 일간/주간/월간 통계 집계 API

### Todo API

- CRUD REST API
- 카테고리별 조회
- 타이머 연동 세션과 할일 매핑

### Flutter 연동

- 로컬 DataSource → Remote DataSource 전환
- Repository에서 게스트/인증 모드 분기 처리

**산출물:** Timer + Todo 백엔드 동기화 완성

---

## 9주차 — Badge + Fuel API 연동

### Badge API

- 배지 목록 조회 + 해금 상태 동기화
- 서버 사이드 해금 조건 검증
- 해금 이벤트 푸시 알림 연동

### Fuel API

- 연료 잔량/충전/소비 API
- 학습 세션 종료 시 자동 연료 충전

### Flutter 연동

- Badge + Fuel Repository 원격 데이터소스 연결

**산출물:** Badge + Fuel 백엔드 동기화 완성

---

## 10주차 — Exploration + Social API

### Exploration API

- 탐험 진행 상태 동기화
- 행성/지역 해금 API (연료 차감)
- 탐험 랭킹 조회

### Social API

- 친구 목록 / 추가 / 삭제
- 학습 현황 공유 (랭킹, 뱃지)
- 소셜 피드 기능

### Flutter 연동

- Exploration + Social 화면 실데이터 연결

**산출물:** Exploration + Social 기능 백엔드 연동 완성

---

## 11주차 — Home + Profile 실데이터 연동

### Home 화면

- 대시보드 실데이터 (오늘 학습 시간, 연속 출석, 연료 현황)
- 우주선 커스터마이징 (탐험 해금 연동)
- 캘린더 학습 기록 히트맵

### Profile 화면

- 사용자 프로필 정보 (닉네임, 프로필 이미지)
- 누적 통계 (총 학습 시간, 배지 수, 탐험 진행률)
- 설정 (알림, 테마, 계정 관리)

**산출물:** 모든 화면 실데이터 연동 완성

---

## 12주차 — 테스트 + 최적화

| 항목          | 내용                                               |
| ------------- | -------------------------------------------------- |
| 통합 테스트   | 주요 시나리오 E2E 테스트                           |
| 성능 최적화   | 네트워크 캐싱, 이미지 최적화, 불필요한 리빌드 제거 |
| 보안 점검     | API 인증/인가 검증, 입력값 검증, HTTPS 적용        |
| 오프라인 지원 | 로컬-원격 데이터 동기화 전략 (충돌 해결)           |

**산출물:** 안정화된 앱 + 보안 점검 완료

---

## 13주차 — 최종 QA + 배포 + 발표

| 항목            | 내용                                                |
| --------------- | --------------------------------------------------- |
| 시나리오 테스트 | 전체 사용자 플로우 검증 (가입 → 학습 → 탐험 → 소셜) |
| 스토어 배포     | TestFlight (iOS) + Play Store 내부 테스트 (Android) |
| 문서 정리       | API 문서, 아키텍처 다이어그램, README               |
| 발표 자료       | 프로젝트 소개, 기술 스택, 데모 시연, 회고           |

**산출물:** 최종 배포 + 발표 자료 완성

---

## 진행 현황 요약

```
■■■■■□□□□□□□□  5/13주 완료 (38%)
```

| 구분            | 주차      | 상태    |
| --------------- | --------- | ------- |
| 프론트엔드 기반 | 1~5주차   | ✅ 완료 |
| 백엔드 구축     | 6주차     | 🔜 예정 |
| API 연동        | 7~11주차  | 🔜 예정 |
| 테스트 + 배포   | 12~13주차 | 🔜 예정 |
