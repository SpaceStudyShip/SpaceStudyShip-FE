# 친구 상세 화면 — D2 (원형 프로그레스) 개선 스펙

**Date:** 2026-04-14
**Branch:** `20260412_#67_소셜_화면_UI_UX_구체화_탑승권_테마_레이아웃_설계`
**Target:** `lib/features/social/presentation/screens/friend_detail_screen.dart`
**Status:** Approved for planning

---

## 1. 목표

기존 친구 상세 화면(아바타 + 이름 + 과목 카드 + 통계 2개)을 **원형 프로그레스로 실시간 세션을 강조**하는 D2 디자인으로 교체. 친구가 지금 얼마나 집중 중인지를 즉각 시각적으로 전달.

### 해결하려는 문제
- 현재 디자인이 너무 평범 — "지금 공부 중"이라는 핵심 상태가 약함
- 과목 카드/통계 카드가 단순 텍스트 박스라 시각적 중심이 없음
- 응원 등 인터랙션 부재
- 이름 위 인라인 `TextStyle(fontSize: 26.sp, ...)` — `text_styles.dart` 미사용 위반

---

## 2. 최종 디자인 (D2)

### 2.1 전체 레이아웃 (위→아래)

```
┌─────────────────────────────────┐
│  ‹                          ⋯   │  ← AppBar (back / more)
├─────────────────────────────────┤
│  [김]  김우주                    │  ← 헤더 행 (아바타 + 이름 + 상태)
│        ● 지금 공부 중 · 수학       │
│                                 │
│       ┌─────────────┐            │
│       │   ╱── ──╲    │            │  ← 원형 프로그레스 (200dp)
│       │  /  LIVE  \  │            │     중앙: LIVE / 02:35 / 서브
│       │ │   02:35  │ │            │
│       │  \ 2시간  /  │            │
│       │   ╲─────╱   │            │
│       └─────────────┘            │
│                                 │
│  ┌──────────┐ ┌──────────┐      │  ← 통계 2개 grid
│  │ 16h 20m  │ │   5일    │      │
│  │ 이번 주   │ │ 연속 학습 │      │
│  └──────────┘ └──────────┘      │
│                                 │
│  ┌────────────────────────┐    │
│  │   ⭐ 응원 보내기         │    │  ← 응원 버튼 (gold)
│  └────────────────────────┘    │
└─────────────────────────────────┘
```

### 2.2 AppBar
- 변경 없음 (back leading + more action 그대로)
- more → 친구 삭제 액션 시트 (기존 로직 유지)

### 2.3 헤더 행
- **아바타** (원형, `_FriendAvatar`)
  - 56dp, `spaceElevated` 배경
  - 테두리 2px, 색상은 상태에 따름:
    - studying → `success`
    - idle/offline → `spaceDivider`
  - 중앙: 이름 첫 글자 (`AppTextStyles.heading_24`, 흰색)
- **이름** (`AppTextStyles.heading_20`, `textPrimary`)
- **상태 텍스트**
  - studying: `● 지금 공부 중 · {currentSubject}` (`tag_12`, `success`)
  - idle: `● 대기 중` (`tag_12`, `textTertiary`)
  - offline: `● 오프라인` (`tag_12`, `textTertiary`)
  - dot: 5dp, blink 애니메이션 (studying만)

### 2.4 원형 프로그레스 (메인)

**진행률 계산:**
- 1시간 = 한 바퀴 (`(studyDuration.inSeconds % 3600) / 3600`)
- 1시간 단위로 link 한 바퀴씩 회전 → 시간 흐름 직관

**스타일:**
- 크기: `200.w × 200.w`
- 트랙 stroke: 8dp, `spaceElevated` (또는 `spaceDivider.withValues(alpha: 0.3)`)
- 진행 stroke: 8dp, `success` 색, round cap
- glow: `BoxShadow` 또는 `dropShadow(rgba(76,175,80,0.5), blur 6)`

**중앙 콘텐츠 (Column, mainAxisSize: min):**
- 라벨 "LIVE" — `tag10Semibold`, `textTertiary` (idle/offline일 땐 "OFFLINE", error 색)
- 시간 값 `02:35` 또는 `47:12` — `AppTextStyles.timer_32`, `success` 색, tabular nums
  - 1시간 미만: `MM:SS`
  - 1시간 이상: `HH:MM`
- 서브 "2시간 35분째" — `tag_12`, `textSecondary`

**상태별 분기:**
- studying: 위 풀 디자인, 진행률 애니메이션
- idle/offline: 트랙 회색 + 진행률 0, 가운데 "OFFLINE" + `--:--`

### 2.5 통계 2개 (Grid 2열)

- 좌: `이번 주` (`weeklyStudyDuration` → `_formatDuration`)
- 우: `연속 학습` (현재는 더미 5일 — friend_entity에 필드 없으므로 mock)

각 셀은 `AppCard` 또는 `Container` (border + padding):
- 값 (`AppTextStyles.subHeading_18`, `textPrimary`)
- 라벨 (`tag_12`, `textTertiary`)
- 가운데 정렬

`SpaceStatItem` 사용 가능 (`valueFirst: true` 모드).

### 2.6 응원 버튼

- `AppButton` 사용 (이미 있는 공통)
- 라벨: "응원 보내기"
- 색상: `accentGold` 배경, 검정 텍스트
- 풀 너비 (좌우 20dp 마진)
- 탭 시: `AppSnackBar.success("{name}님에게 응원을 보냈어요")` (mock)
- 비활성: idle/offline일 때

---

## 3. 컴포넌트 분해

### 3.1 새로 만들 위젯

| 위젯 | 위치 | 사용처 | 분리 이유 |
|------|------|--------|----------|
| `LiveSessionRing` | `lib/features/social/presentation/widgets/live_session_ring.dart` | friend_detail (1) | 1번 사용이지만 80~120 line CustomPaint + Stack 조합 → file 분리 가독성 |
| `_FriendAvatar` | friend_detail_screen 내부 private | friend_detail 헤더 (1) | private (1번만 사용) |
| `_StatusLine` | friend_detail_screen 내부 private | friend_detail 헤더 (1) | private |

> "2번 이상 사용 시 위젯 분리" 원칙 적용. `LiveSessionRing`은 1번 사용이지만 코드 길이 때문에 파일 분리. 나머지는 private.

### 3.2 확장할 기존 위젯

| 위젯 | 변경 |
|------|------|
| `SpaceCircularProgress` | **사용 안 함** — 가운데 텍스트 `${%}` 고정이라 D2 요구사항(`02:35` + 라벨 + 서브)과 불일치. 새 `LiveSessionRing` 만듬. 단, painter 로직(start angle, sweep, stroke cap)은 참고 |

### 3.3 재사용할 기존 위젯

| 위젯 | 사용처 |
|------|--------|
| `SpaceBackground` | 배경 (이미 사용 중) |
| `SpaceStatItem` (`valueFirst: true`) | 통계 2개 셀 (Container border로 감싸기) |
| `AppButton` | 응원 보내기 버튼 |
| `AppSnackBar.success()` | 응원/삭제 피드백 |
| `AppDialog.confirm()` | 친구 삭제 확인 (기존 그대로) |

### 3.4 제거할 기존 코드

기존 `friend_detail_screen.dart`에서:
- `_StatusBadge` private 클래스 → `_StatusLine`으로 교체
- `_SubjectCard` private 클래스 → 삭제 (LiveSessionRing 안에 통합)
- `_StatCard` private 클래스 → 삭제 (`SpaceStatItem` + `Container` border 사용)
- 인라인 `TextStyle(fontSize: 26.sp)` → `AppTextStyles.heading_24` 사용

---

## 4. 데이터 바인딩

`FriendEntity`에서 사용하는 필드:
- `name` → 헤더 + 아바타 이니셜
- `status` → studying/idle/offline 분기
- `currentSubject` → 헤더 상태 텍스트 (studying일 때만)
- `studyDuration` → 원형 진행률 + 중앙 시간
- `weeklyStudyDuration` → "이번 주" 통계

**없는 필드 (mock):**
- `streak` (연속 학습 일수) → 일단 하드코딩 `5` (TODO 주석 추가)
- `cheerCount` → 응원 버튼은 mock으로 처리

---

## 5. 인터랙션

| 액션 | 결과 |
|------|------|
| back arrow | `Navigator.pop` |
| more (`...`) | 액션 시트 → 친구 삭제 (기존 로직 그대로) |
| 응원 버튼 (studying일 때) | `AppSnackBar.success("{name}님에게 응원을 보냈어요")` |
| 응원 버튼 (idle/offline) | 비활성, 회색 표시 |

---

## 6. AppColors / AppTextStyles 매핑

**색상:**
- 진행 링 / studying 테두리 / 상태 dot / 시간 텍스트 = `AppColors.success`
- 트랙 = `AppColors.spaceDivider.withValues(alpha: 0.3)`
- 응원 버튼 배경 = `AppColors.accentGold`
- idle/offline 표시 = `AppColors.textTertiary`
- 배경 = `AppColors.spaceBackground`
- 카드 = `AppColors.spaceSurface` + `spaceDivider` border

**텍스트 스타일 (text_styles.dart 강제, fontSize override 금지):**
- 이름: `heading_20`
- 아바타 이니셜: `heading_24`
- 시간 (LIVE 값): `timer_32`
- 라벨 ("LIVE", "OFFLINE"): `tag10Semibold`
- 서브 ("2시간 35분째"): `tag_12`
- 상태 텍스트: `tag_12`
- 통계 값: `subHeading_18` (SpaceStatItem 기본)
- 통계 라벨: `tag_12` (SpaceStatItem 기본)

---

## 7. 엣지 케이스

| 상황 | 처리 |
|------|------|
| `studyDuration == null` | `--:--` 표시, 진행률 0 |
| `currentSubject == null` (studying) | 상태 텍스트 "지금 공부 중" (과목 부분 생략) |
| `weeklyStudyDuration == null` | "0분" 표시 |
| 1시간 미만 | `MM:SS` |
| 1시간 이상 | `HH:MM` (초는 생략 — 상세 화면은 분 단위로도 충분) |
| 빈 이름 | "?" 이니셜 |

---

## 8. 구현 범위

### In Scope
- [ ] `LiveSessionRing` 새 위젯 (CustomPaint)
- [ ] `friend_detail_screen.dart` body 전면 교체
- [ ] private `_FriendAvatar` / `_StatusLine` 추출
- [ ] `_SubjectCard` / `_StatCard` / `_StatusBadge` 제거
- [ ] 응원 버튼 + mock 핸들러
- [ ] 인라인 `TextStyle(fontSize:)` 제거 → `AppTextStyles` 사용
- [ ] `flutter analyze` 통과

### Out of Scope
- 실시간 1초 카운트업 애니메이션 (정적 표시만, 화면 진입 시점 기준)
- streak / cheer 실제 데이터 (백엔드 API 명세 후)
- 응원 send API 호출
- friend_entity에 streak 필드 추가

---

## 9. 위젯 분리 원칙 적용

- **2번 이상 사용 시 분리**: 현재 친구 상세 1곳에서만 쓰는 부속 위젯들은 private 유지
- **코드 가독성을 위한 예외**: `LiveSessionRing`은 CustomPaint + 중앙 Stack으로 80+ line이라 파일 분리
- **이미 있는 공통 위젯 우선**: `SpaceStatItem`, `AppButton`, `AppSnackBar`, `AppDialog`, `SpaceBackground` 모두 활용
