# 소셜 화면 — 우주선 좌석 배치 UI 개선

**Date:** 2026-04-14
**Branch:** `20260412_#67_소셜_화면_UI_UX_구체화_탑승권_테마_레이아웃_설계`
**Status:** Approved for planning

---

## 1. 목표

기존 "궤도(전속력/이륙 중) + 충전 중" 구조의 `SocialSpaceView`를 **버스/비행기 좌석 배치도** 형태로 전면 교체한다. 친구가 우주선에 탑승해 있는 좌석 그리드를 한눈에 보고, 색상만으로 상태(선장/공부 중/충전 중/빈 자리)를 구분할 수 있게 한다.

### 해결하려는 문제

- 기존 레이아웃의 전속력/이륙 중 구분이 단순 가로 나열이라 "궤도" 느낌이 전혀 없다
- 친구가 적을 때 빈 공간이 어색하다
- `ShipNode`에 과목 정보 등 정보 밀도가 낮다
- 하단 상태바의 정보가 본문과 중복된다
- 소셜 화면 고유의 아이덴티티가 약하다 (우주 테마인데 탐험 맵 화면과 차별화 안 됨)

---

## 2. 최종 디자인

### 2.1 전체 구조

```
┌────────────────────────────────┐
│  소셜                       [+] │  ← 헤더 (타이틀 + 서브 + 추가 버튼)
│  우주선 1호 · 4명 탑승 중        │
├────────────────────────────────┤
│  ■ 선장  ■ 공부 중  □ 충전 중    │  ← 상태 범례
├────────────────────────────────┤
│  ( 공부 중 )( 충전 중 )( 전체 ) │  ← 필터 탭
├────────────────────────────────┤
│                                │
│  [1A][1B]  │  [1C][1D]         │  ← 좌석 행 1
│  [2A][2B]  │  [2C][2D]         │  ← 좌석 행 2
│  [3A][3B]  │  [3C][3D]         │  ← 좌석 행 3
│                                │
├────────────────────────────────┤
│ BOARDING   │  탑승        [+친구]│  ← 탑승권 바
│ 우주선 1호 │  4 / 12              │
└────────────────────────────────┘
```

### 2.2 좌석 그리드 사양

- **총 좌석 수:** 12 (4 × 3행)
- **한 행 구조:** `[좌석 A][좌석 B] | 통로 (24dp) | [좌석 C][좌석 D]`
- **좌석 번호:** `1A 1B 1C 1D / 2A 2B 2C 2D / 3A 3B 3C 3D`
- **좌석 종횡비:** `1:1` (정사각 기반, 윗부분이 둥근 실루엣)
- **행간 간격:** `AppSpacing.s8` (8dp)
- **좌석간 간격(행 내부):** `AppSpacing.s8` (통로 외)
- **통로 폭:** `AppSpacing.s24` (24dp) — 점선 vertical divider
- **좌우 패딩:** `AppSpacing.s20` (화면 좌우)

### 2.3 좌석 위젯 사양 (C 변형 — 좌석 실루엣)

**모양:**
- `border-radius: 16 16 8 8` (top-left, top-right, bottom-right, bottom-left) → 등받이 느낌
- 외곽 테두리: `1.5px solid`
- 이너 보더: `inset 4px`, `border-radius: 13 13 5 5`, `1px solid 30%` (이중 테두리)
- 발판 언더라인: 좌석 하단 바깥 2px 컬러 바 (상태 색상)

**내용물 (세로 중앙 정렬):**
1. 좌상단: 좌석 번호 (`AppTextStyles.tag_10`, font-size 6sp, letter-spacing 0.3, 상태 색상)
2. 아바타: `24×24` 원형, 상태 색상 배경, 흰색 이니셜 (font-size 11sp, weight 800)
3. 이름: font-size 9sp, weight 800, `textPrimary`
4. 시간: font-size 8sp, weight 800, 상태 색상

**pulse 애니메이션:**
- 아바타 `::after` 오버레이 원형 보더
- `inset: -3px`, `1px solid 40% 상태 색`
- `scale 1 → 1.4 + opacity 1 → 0`, `2.2s ease-out infinite`
- 적용: 나(선장), 공부 중 친구만

### 2.4 상태별 스타일

| 상태 | 테두리 | 배경 | 발판 | 아바타 | pulse |
|------|-------|------|------|-------|-------|
| **나(선장)** | `primary #2196F3` 1.5px | `primary.withOpacity(0.10)` | `primary` | `primary` | O |
| **공부 중** | `success #4CAF50` 1.5px | `success.withOpacity(0.08)` | `success` | `success` | O |
| **충전 중** | `spaceDivider` 1.5px | `spaceSurface` | — | `spaceElevated` + `textTertiary` | X |
| **빈 자리** | `spaceDivider.withOpacity(0.45)` dashed | transparent | — | — | X |

- **충전 중** 좌석은 추가로 `opacity: 0.5` + `ColorFilter.matrix(grayscale 0.8)` 적용
- **빈 자리** 좌석 내부는 `24×24` 대시 원형 + `+` 아이콘 (`textDisabled`)

### 2.5 상태 범례 (Legend)

- 헤더 아래 한 줄
- 3개 항목: `선장` / `공부 중` / `충전 중`
- 각 항목: `8×8` 둥근 사각(각 상태 색상) + 라벨 (`AppTextStyles.tag_12` 9sp)
- `AppSpacing.s12` 간격

### 2.6 필터 탭

- 3개 탭: `공부 중` / `충전 중` / `전체`
- pill 스타일: 높이 24dp, `AppRadius.chip`, padding `5×12`
- 선택 상태: `primary` 배경 + 흰 텍스트
- 비선택: `spaceSurface` 배경 + `textTertiary` 텍스트 + `spaceDivider` 테두리
- 탭 변경 시: 매칭되지 않는 좌석은 기본 `spaceSurface + divider`로 표시 (여전히 좌석은 채워져 있음)

### 2.7 탑승권 바 (Boarding Pass Bar)

- 하단 고정 (`FloatingNavMetrics.totalHeight` 위에 여백)
- 외곽: `spaceSurface` 배경, `spaceDivider` 1px 테두리, `AppRadius.card` (12dp)
- 좌우에 원형 컷아웃 (`bg` 색 원 + `divider` 1px 테두리, 반경 4dp, 좌우 `-5px` 위치)
- 좌측: `BOARDING` 라벨 + `우주선 1호` 값
- 중간: 점선 세로 divider
- 우측: `탑승` 라벨 + `4 / 12` 값 (`success` 색)
- 우측 끝: `+ 친구` 버튼 (`primary` 배경, 흰 텍스트)

### 2.8 헤더

- 타이틀 `소셜` — `AppTextStyles.heading_20`
- 서브 `우주선 1호 · {N}명 탑승 중` — `AppTextStyles.tag_10` `textTertiary`
- 우측: `30×30` 아이콘 버튼 (`+` 추가), `spaceSurface` 배경

### 2.9 배경

- 기본: `SpaceBackground` 유지 (기존 별 배경)
- 이번 작업에서는 추가 배경 레이어 없음 (캐빈 인테리어 라인 등은 범위 외)

---

## 3. 컴포넌트 분해

### 3.1 새로 만들 위젯

| 위젯 | 파일 | 역할 |
|------|------|------|
| `SocialSeatView` | `presentation/widgets/social_seat_view.dart` | 최상위 스크린 본문. 헤더 + 범례 + 탭 + 좌석 그리드 + 탑승권 바 조립 |
| `SeatWidget` | `presentation/widgets/seat_widget.dart` | 단일 좌석 렌더링. 상태(me/studying/idle/empty)에 따라 스타일 분기 |
| `SeatGrid` | `presentation/widgets/seat_grid.dart` | 12좌석 배치. 행·통로 레이아웃 + 친구 리스트 → 좌석 매핑 |
| `BoardingPassBar` | `presentation/widgets/boarding_pass_bar.dart` | 하단 탑승권 바 (원형 컷아웃 포함) |
| `SeatLegend` | `presentation/widgets/seat_legend.dart` | 상태 범례 한 줄 |

### 3.2 제거할 위젯

- `social_space_view.dart` → `social_seat_view.dart`로 전면 교체
- `ship_node.dart` → `SeatWidget`에 흡수
- `docked_ship_node.dart` → `SeatWidget`에 흡수
- `social_radar_view.dart` (legacy, 이미 미사용) → 이번 작업과 함께 제거 검토

### 3.3 Provider 변경

- `friendsProvider` — 유지 (그대로 사용)
- `studyingCountProvider` — 유지
- `highOrbitFriendsProvider` / `lowOrbitFriendsProvider` — **삭제** (구분 폐기)
- `dockedFriendsProvider` — 유지
- `innerRingFriendsProvider` / `outerRingFriendsProvider` — **삭제** (legacy)
- 추가: `seatFilterProvider` (`SeatFilter.studying | idle | all`) — 탭 상태 관리
- 추가: `seatAssignmentProvider` — 친구 리스트 + 나 → 12 좌석 슬롯 매핑

---

## 4. 데이터 바인딩

### 4.1 좌석 할당 로직

1. 나(`_me` FriendEntity)는 **항상 1A**에 배치
2. `FriendStatus.studying` 친구들을 공부 시간 내림차순으로 정렬 → `1B, 1C, 1D, 2A, 2B, ...` 순서 채움
3. `FriendStatus.idle` + `FriendStatus.offline` 친구들을 이어서 채움
4. 남은 슬롯은 `empty` 상태로 표시
5. 12명 초과 시: 좌석은 고정, 초과 친구는 현재는 **숨김** (추후 2페이지 확장 가능)

### 4.2 FriendEntity 필드 → 좌석 UI 매핑

| FriendEntity 필드 | 좌석 UI 요소 |
|-------------------|------------|
| `name[0]` | 아바타 이니셜 |
| `name` | 좌석 하단 이름 (font 9sp) |
| `studyDuration` | 시간 표기 (`2h 35m` / `47m`) |
| `status == studying` | 초록 테두리 + 배경 + pulse |
| `status == idle` | 회색 + grayscale + opacity |
| `status == offline` | 회색 + grayscale + opacity (idle과 동일 처리. 이름 옆 "오프" 레이블) |
| `currentSubject` | (이번 단계는 미표시 — 정보 너무 많으면 답답해짐. Detail 화면에서만 노출) |

### 4.3 탭 필터 동작

- **공부 중:** `studying` 좌석만 원래 스타일, 나머지는 선택 불가 상태(회색 + 0.3 opacity)
- **충전 중:** `idle/offline` 좌석만 원래 스타일, 나머지는 회색
- **전체:** 모든 좌석 원래 스타일

탭 전환은 단순 시각 필터. 좌석 배치 순서는 변하지 않는다.

---

## 5. 인터랙션

- **좌석 탭:** 해당 친구의 `FriendDetailScreen`으로 이동 (기존 라우팅 재사용)
- **나(1A) 탭:** 아무것도 하지 않음 (기존 `ShipNode`와 동일)
- **빈 자리 탭:** 친구 추가 플로우 트리거 (기존 `+ 친구` 버튼과 동일 콜백)
- **헤더 `+` 버튼 / 탑승권 바 `+ 친구` 버튼:** 동일 — 친구 추가 (TODO #67 이슈에서 연결 예정)
- **탭 전환:** `setState` 혹은 Riverpod `StateProvider` 변경만

---

## 6. 엣지 케이스

| 상황 | 처리 |
|------|------|
| 친구 0명 | 1A에 나, 나머지 11석 모두 `empty` |
| 공부 중 친구 0명 | 나만 초록 배경 없음 (나는 항상 파랑), 나머지 친구는 회색 |
| 12명 초과 | 이번 릴리스에서는 초과분 숨김. 상단 서브텍스트에 `+{초과 수}명` 표시 (예: "우주선 1호 · 12명 탑승 중 +3명") |
| 친구 이름 5자 초과 | ellipsis 처리 (`TextOverflow.ellipsis` + `maxLines: 1`) |
| studyDuration null | "공부 중" 상태면 `—` 표시, idle이면 `대기`/`오프` |

---

## 7. AppColors 매핑

- **primary** = `#2196F3` → 나(선장) 테두리/배경/발판/아바타
- **success** = `#4CAF50` → 공부 중 테두리/배경/발판/아바타/pulse
- **spaceBackground** = `#0A0E27` → 전체 배경 (`SpaceBackground` 위에 올림)
- **spaceSurface** = `#1A1F3A` → 충전 중 좌석 배경, 헤더 아이콘 버튼, 탑승권 바 배경
- **spaceElevated** = `#252B47` → 충전 중 아바타 배경
- **spaceDivider** = `#2D3555` → 모든 비활성 테두리, 통로 점선
- **textPrimary / textSecondary / textTertiary / textDisabled** → 기존 opacity 계층 그대로

**하드코딩 컬러 금지** — 모두 `AppColors` 상수 사용.

---

## 8. 접근성 / 반응형

- 모든 좌석은 `Semantics` 라벨 포함 (예: "1B 김우주 2시간 35분 공부 중")
- `ScreenUtil`의 `.w/.h/.sp`로 모든 크기 표기
- 좌석 터치 영역은 최소 48dp 보장 — 좌석 자체가 48dp 이상이므로 OK
- 작은 화면(`< 360dp`)에서도 4열 유지. 통로 폭만 축소

---

## 9. 구현 범위 (In Scope)

- [ ] `SocialSeatView` 신규 작성 및 `SocialScreen`에서 교체
- [ ] `SeatWidget` / `SeatGrid` / `BoardingPassBar` / `SeatLegend` 신규 작성
- [ ] 좌석 할당 로직 Provider (`seatFilterProvider`, `seatAssignmentProvider`)
- [ ] 기존 `SocialSpaceView`, `ShipNode`, `DockedShipNode` 삭제
- [ ] Legacy provider 정리 (`highOrbit*`, `lowOrbit*`, `innerRing*`, `outerRing*`)
- [ ] `SocialSpaceView` 관련 기존 테스트 갱신/삭제
- [ ] 신규 위젯 테스트 작성 (TDD)
- [ ] DESIGN.md 규칙 준수 (하드코딩 금지, 이모지 금지 등)

---

## 9.A API 연결 준비

현재 `friendsProvider`는 하드코딩 더미 데이터다. 이번 작업에서는 **UI만 교체**하지만, 추후 API 연결이 매끄럽게 되도록 아래 원칙을 지킨다.

- **위젯은 `List<FriendEntity>`만 소비** — Provider 내부가 동기 더미든 비동기 Future든 신경 쓰지 않도록 한다
- **좌석 할당 로직은 순수 함수로 분리** — `SeatAssignment.from(me, friends)` 같은 순수 함수 하나로 빼서, 소스가 무엇이든 입력만 같으면 동일 결과를 반환
- **`seatAssignmentProvider`는 `friendsProvider`만 watch** — Repository/UseCase가 나중에 `friendsProvider`에 들어올 때 좌석 Provider는 수정 불필요
- **비동기 상태(로딩/에러) 대비:** `SocialSeatView`는 `AsyncValue<List<FriendEntity>>`도 받을 수 있도록 `.when` 분기 준비. 현재 더미는 `AsyncValue.data`로 감싸서 전달
- **좌석 할당 결정론:** 같은 친구 리스트 입력 시 항상 같은 좌석 번호가 나와야 한다 → 정렬 키 명시 (공부 시간 내림차순 → idle/offline은 이름 오름차순)
- **게스트 모드는 고려 불필요** — `SocialScreen`에서 `isGuestProvider`로 이미 분기 처리되어 `SocialSeatView`에 진입하지 않음

## 10. 범위 외 (Out of Scope)

- 친구 추가 실제 기능 (TODO #67 후속 이슈)
- 12명 초과 페이지네이션
- 좌석별 드래그/재배치
- 좌석 장식 애니메이션 (예: 우주선 움직임, 창문 밖 별)
- 과목/태그 필터
- Rive/Lottie 애니메이션

---

## 11. 참고 목업

- `.superpowers/brainstorm/77947-1776147602/content/social-seats-variants.html` — A/B/C/D 변형 비교 (선택: **C**)
- `.superpowers/brainstorm/77947-1776147602/content/social-seats-bus.html` — 버스 좌석 구조 기준선
