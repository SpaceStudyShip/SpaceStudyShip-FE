# 게스트 모드 + 온보딩 설계

**작성일:** 2026-02-12
**상태:** 승인됨

---

## 개요

로그인 없이 앱을 사용할 수 있는 게스트 모드를 추가합니다.
- 게스트 = 체험판. 데이터 저장 없음. 앱 종료 시 데이터 소멸.
- 로그인 = 전체 기능 + 데이터 서버 저장.
- 소셜 탭은 게스트 접근 불가.

---

## 전체 흐름

```
[첫 실행]
Splash → Login Screen
         ├─ Google/Apple 로그인 → Home (기존 흐름)
         └─ "게스트로 시작하기" 탭
              → 스낵바: "게스트 모드에서는 정보가 저장되지 않습니다"
              → 온보딩 (SharedPreferences로 1회만)
              → Home (게스트 모드)

[게스트 → 로그인 전환]
프로필 탭 "로그인하기" 버튼
  → Login Screen으로 이동
  → Google/Apple 로그인 성공
  → NicknameSetupScreen (닉네임 입력 + 중복확인 API)
  → 확인 완료 → Home (로그인 상태)

[재실행]
Splash → 상태 확인
         ├─ 게스트 저장됨 (SharedPreferences) → Home (게스트 모드)
         ├─ JWT 토큰 있음 → Home (로그인 상태)
         └─ 없음 → Login Screen
```

---

## AuthState 변경

```dart
enum AuthStatus { unauthenticated, guest, authenticated }
```

- `unauthenticated`: JWT 없고 게스트도 아님 → /login
- `guest`: SharedPreferences에 is_guest=true → Home 허용, 소셜 차단
- `authenticated`: JWT 토큰 보유 → 전체 접근

### RouterNotifier 변경
- `guest` 상태에서 메인 Shell 접근 허용
- `/social` 경로는 게스트일 때 로그인 유도 화면으로 대체

---

## Login Screen 변경

기존 Google/Apple 로그인 버튼 아래에 추가:

```
  ┌─────────────────────┐
  │  G  Google로 시작하기 │
  └─────────────────────┘
  ┌─────────────────────┐
  │  🍎 Apple로 시작하기  │
  └─────────────────────┘

     게스트로 시작하기        ← TextButton + underline, 작은 폰트
```

- 탭 시 스낵바로 "게스트 모드에서는 정보가 저장되지 않습니다" 안내
- `AuthNotifier.signInAsGuest()` 호출
- 첫 게스트 → 온보딩, 이후 게스트 → 바로 Home

---

## 온보딩 화면

3페이지 PageView, SpaceBackground 배경.

**페이지 1:**
> **당신의 우주선이 준비됐어요**
> 공부를 연료 삼아, 우주를 항해해볼까요?

**페이지 2:**
> **할 일을 끝내면 연료가 채워져요**
> 매일 조금씩, 더 멀리 갈 수 있어요

**페이지 3:**
> **어떤 행성을 발견하게 될까요?**
> 지금 바로 첫 항해를 시작하세요

버튼: **"탐험 시작하기"**

### 공통 요소
- 하단 dot indicator (3개)
- 좌우 스와이프 (PageView)
- 마지막 페이지에서만 "탐험 시작하기" 버튼 활성화
- SharedPreferences에 `has_seen_onboarding: true` 저장
- 앱 삭제/재설치 시 초기화

---

## 게스트 모드 제한사항

### 소셜 탭 차단
- 게스트가 소셜 탭 누르면 로그인 유도 화면 표시
- "친구와 함께 공부하려면 로그인이 필요해요" + "로그인하기" 버튼

### 프로필 탭 변경
- 게스트: 상단에 "로그인하기" 버튼 배치
- 닉네임 영역: "게스트" 표시
- 로그아웃 버튼 숨김

### 데이터 미저장
- 앱 종료 시 모든 인메모리 데이터 소멸
- 서버 API 호출 없음

---

## 닉네임 설정 화면 (NicknameSetupScreen)

게스트 → 로그인 전환 시 표시.

```
┌─────────────────────────────┐
│  ← 뒤로                     │
│                             │
│  닉네임을 설정해주세요         │
│                             │
│  ┌──────────────┐ ┌──────┐  │
│  │ 닉네임 입력    │ │중복확인│ │
│  └──────────────┘ └──────┘  │
│                             │
│  ✅ 사용 가능한 닉네임이에요   │
│  ❌ 이미 사용 중인 닉네임이에요 │
│                             │
│  ┌─────────────────────┐    │
│  │     완료하기          │    │
│  └─────────────────────┘    │
└─────────────────────────────┘
```

- AppTextField + AppButton 조합
- 중복확인 API: `GET /api/v1/users/check-nickname?nickname=xxx`
- "완료하기" 버튼은 중복확인 통과 후에만 활성화
- SpaceBackground 배경 적용

---

## UI 가이드라인

- 불필요한 그라데이션 사용 금지
- 기존 spacing_and_radius.dart 상수 사용 필수
- SpaceBackground 모든 화면 적용
- 기존 common widgets (AppButton, AppTextField 등) 재사용

---

## 변경/추가 파일

### 변경할 파일 (5개)
| 파일 | 변경 내용 |
|------|----------|
| `auth_provider.dart` | AuthStatus에 `guest` 추가, `signInAsGuest()` 메서드 |
| `login_screen.dart` | "게스트로 시작하기" 언더라인 텍스트 + 탭 시 안내 스낵바 |
| `app_router.dart` | 게스트 라우팅 허용, 소셜 탭 차단, 닉네임/온보딩 라우트 추가 |
| `profile_screen.dart` | 게스트일 때 "로그인하기" 버튼 표시, 로그아웃 숨김 |
| `social_screen.dart` | 게스트일 때 로그인 유도 화면 표시 |

### 새로 만들 파일 (3개)
| 파일 | 설명 |
|------|------|
| `onboarding_screen.dart` | 3페이지 PageView 온보딩 |
| `nickname_setup_screen.dart` | 닉네임 입력 + 중복확인 화면 |
| `guest_login_prompt.dart` | 소셜 탭용 로그인 유도 위젯 |

### 의존성
- SharedPreferences (이미 설치됨)
