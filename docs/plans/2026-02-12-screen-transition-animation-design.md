# Screen Transition Animation Design

## Overview

스플래시 → 로그인, 로그아웃 → 로그인 화면 전환 시 커스텀 애니메이션 적용.
현재 GoRouter 기본 전환(플랫폼 슬라이드)을 우주 테마에 맞는 전환으로 교체한다.

## Design Decisions

| 전환 | 애니메이션 | 시간 | Curve | Hero |
|---|---|---|---|---|
| Splash → Login | Fade through | 500ms | easeInOut | 로켓 아이콘 (96px → 80px) |
| Logout → Login | Simple fade | 300ms | easeInOut | 없음 |

## Splash → Login: Fade Through + Hero

### 동작 상세
1. 스플래시 콘텐츠(타이틀, 서브타이틀, 로딩 인디케이터)가 **fade out** (~200ms)
2. 로그인 콘텐츠(환영 텍스트, 로그인 버튼들)가 **fade in** (~300ms)
3. **로켓 아이콘(GradientCircleIcon)**은 Hero 애니메이션으로 연결
   - 스플래시: size 96, iconSize 44
   - 로그인: size 80, iconSize 36
   - 크기 축소 + 위치 이동이 자연스럽게 보간됨
4. SpaceBackground는 양쪽 모두 존재하므로 배경 끊김 없음

### 구현 방식
- Splash GoRoute: `pageBuilder`에서 `CustomTransitionPage` + fade out 트랜지션
- Login GoRoute: `pageBuilder`에서 `CustomTransitionPage` + fade in 트랜지션
- 양쪽 GradientCircleIcon을 `Hero(tag: 'rocket-icon')` 위젯으로 감싸기

## Logout → Login: Simple Fade

### 동작 상세
1. 현재 화면(프로필, 홈 등)이 **fade out**
2. 로그인 화면이 **fade in**
3. Hero 없음 — 로그아웃 시점 화면이 다양하므로 연결 불가

### 구현 방식
- Login GoRoute의 `pageBuilder`에 fade 전환 적용
- Splash에서 오는 경우: Hero가 위젯 레벨에서 같은 tag로 자동 동작
- 그 외(로그아웃 등): Hero 매칭 없으므로 순수 fade만 동작

## 수정 대상 파일

1. `lib/routes/app_router.dart` — splash, login 라우트에 `pageBuilder` + `CustomTransitionPage` 적용
2. `lib/features/auth/presentation/screens/splash_screen.dart` — GradientCircleIcon을 Hero로 감싸기
3. `lib/features/auth/presentation/screens/login_screen.dart` — GradientCircleIcon을 Hero로 감싸기

## Design Rationale

- **스플래시 → 로그인을 특별하게**: 앱 첫인상이므로 몰입감 있는 전환
- **로그아웃 → 로그인은 심플하게**: 사용자 의도적 행위이므로 빠르고 깔끔하게
- **Hero로 연속성 부여**: 로켓 아이콘이 "같은 우주선"이라는 느낌 유지
- **Fade through 선택 이유**: 양쪽 화면이 SpaceBackground를 공유하므로 "같은 공간에서 장면 전환"
