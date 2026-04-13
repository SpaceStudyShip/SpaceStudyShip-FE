# Spec — Space Study Ship Design System Rules

**Date:** 2026-04-13
**Status:** Approved
**Owner:** Luca

---

## Problem

프로젝트에 디자인 시스템 상수 (`AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles`) 는 존재하지만, **언제·어떻게·왜** 쓰는지에 대한 규칙과 voice·철학이 문서화되어 있지 않다.

결과적으로:
- Claude 가 UI 를 작성할 때마다 판단이 달라져 일관성 드리프트 발생
- Material 위젯과 커스텀 위젯이 혼재
- 이모지가 UI·문서·이슈 템플릿에 산재
- aerospace 영문 레이블 voice (BoardingPass 에서 시작된 패턴) 가 확산되지 못하고 고립

## Goal

`DESIGN.md` 를 프로젝트 루트에 생성하여 **Claude / AI 에이전트 / 개발자** 모두가 UI 작업 전 참조하는 단일 규칙 문서로 만든다. 기존 `07_DESIGN_SYSTEM_CONSTANTS.md` (값 레퍼런스) 와 역할을 분리 — DESIGN.md 는 "철학·규칙·voice", 07 파일은 "값".

## Non-Goals

- 기존 `AppColors` / `AppSpacing` / `AppRadius` / `AppTextStyles` 상수 값을 바꾸지 않는다 (문서화만)
- 새 공통 위젯을 만들지 않는다 (기존 위젯의 사용 규칙만 정의)
- 타이포 토큰을 새로 만들지 않는다

---

## Design Decisions

### 1. 배치 (Placement)

- **`DESIGN.md` 를 프로젝트 루트에 배치**
- `CLAUDE.md` 에 "UI 작업 전 DESIGN.md 로드" 규칙 추가
- getdesign.md (awesome-design-md 생태계) 표준 컨벤션 준수

**Rejected:**
- `docs/08_DESIGN_SYSTEM.md` 네이밍 — 기존 07 파일과 역할이 모호해질 우려
- `.agents/skills/design-system/SKILL.md` — 스킬로는 "자동 적용성" 이 떨어짐

### 2. 범위 (Scope)

- **문서화 중심** (철학·규칙·voice)
- 값은 `.claude/rules/07_DESIGN_SYSTEM_CONSTANTS.md` 에 위임
- 두 파일은 서로 링크로 연결

**Rejected:**
- 통합 (07 파일 흡수) — 07 파일이 "빠른 값 참조" 용도로 특화되어 있어 분리 유지
- 2-파트 분할 (DESIGN.md + DESIGN_COMPONENTS.md) — 파일 수 증가, 관리 부담

### 3. Voice 전략

- **Dual Voice** — 한글 본문 + aerospace 영문 레이블
- aerospace 영문은 `tag_10` / `tag_12` 스타일에만 허용
- 사전(dictionary)을 Section 7 에 고정해 즉흥적 레이블 확산 방지

**Rejected:**
- 전면 aerospace voice (SpaceX 스타일) — 학습앱 친근감 훼손
- Voice 규칙 없음 — 일관성 관리 실패

### 4. 구조 (Structure)

- **getdesign.md 9섹션 모델** 채택
- Section 1~9: Visual Theme / Color / Typography & Voice / Component / Layout / Depth / Aerospace Dictionary / Do's & Don'ts / Agent Prompt Guide

**Rejected:**
- 4섹션 슬림 모델 — 프로젝트 복잡도 대비 얕음
- 2-파트 분할 — 관리 부담

### 5. 엘리베이션 철학

- **그림자 없음. 배경 루미넌스 스태킹으로 고도 표현**
- Linear 의 다크 UI 철학 차용
- `spaceBackground → spaceSurface → spaceElevated → spaceDivider → barrier` 5레이어

**Rejected:**
- Material elevation (BoxShadow) — 다크 캔버스에서 식별 불가, 우주 은유 훼손

### 6. 이모지 정책

- **전면 금지** — UI·코드·문서·커밋·이슈 어디에도 사용 불가
- 아이콘은 `font_awesome_flutter` 의 `FaIcon` 또는 Material `Icon` 사용
- 기존 이모지 (이슈 템플릿·코드) 는 후속 작업으로 마이그레이션

---

## Deliverables

### 1차 (이 스펙의 범위)

1. **`DESIGN.md`** — 프로젝트 루트에 9섹션 문서 작성
2. **`CLAUDE.md` 업데이트** — DESIGN.md 참조 추가, 이모지 금지 규칙 추가, 경로를 `.claude/rules/` 로 수정
3. **본 스펙 파일** — `docs/superpowers/specs/2026-04-13-design-system-rules-design.md`

### 후속 작업 (별도 이슈·플랜)

1. **font_awesome_flutter 패키지 설치** — `flutter pub add font_awesome_flutter`
2. **이모지 전역 마이그레이션** — 기존 코드·문서·이슈 템플릿 전체 스캔 후 제거 또는 아이콘 전환
3. **`/review-design-system` 커맨드 보강** — DESIGN.md 규칙 (BoxShadow 금지·이모지 금지·aerospace 사전 검증) 을 자동 검증하도록 확장
4. **기존 Screen 리팩터링** — `social_screen.dart` 등 빈 상태 화면부터 DESIGN.md 기준으로 재정비 (이슈 `social-boarding-ui-design` 와 연계)

---

## Section Summary (DESIGN.md 9 Sections)

| # | 섹션 | 핵심 내용 |
|---|------|----------|
| 1 | Visual Theme & Atmosphere | 우주 탐험 + 탑승 여정 은유, Deep Space 캔버스, 3-tier 서피스 |
| 2 | Color Palette & Roles | AppColors 역할 정의, Gold 보호, 새 색상 금지 규칙 |
| 3 | Typography & Voice | Pretendard 계층, Dual Voice 원칙, 이모지 0개 |
| 4 | Component Stylings | AppButton/Card/Dialog/TextField/SnackBar, BoardingPassTicket 사용 규칙 |
| 5 | Layout Principles | Scaffold 템플릿, Spacing Rhythm, Whitespace 철학 |
| 6 | Depth & Elevation | 그림자 금지, 5-Layer Luminance Stack |
| 7 | Voice & Labels — Aerospace Dictionary | Status/Resource/Journey/Metadata/Document 레이블 사전 |
| 8 | Do's and Don'ts | 빠른 체크리스트 |
| 9 | Agent Prompt Guide | 작업 전 로드·작성 중 점검·제출 전 검증·샘플 선언 |

---

## Success Criteria

- [ ] `DESIGN.md` 가 프로젝트 루트에 커밋됨
- [ ] `CLAUDE.md` 가 54줄 이하, DESIGN.md 참조 포함
- [ ] Claude 가 UI 작업 시작 시 DESIGN.md 를 자동 Read 함
- [ ] 신규 UI 코드에 `Color(0xFF...)` / `TextStyle(...)` 인라인 / `BoxShadow` / 이모지가 등장하지 않음
- [ ] aerospace 레이블 사전 외 새 영문 레이블 즉흥 생성이 사라짐

## Risks

- **문서 드리프트** — 코드는 바뀌는데 DESIGN.md 가 업데이트되지 않으면 문서가 거짓말을 하게 됨
  - 완화: Section 9.E "개선 루프" 명시, 리뷰 커맨드에서 DESIGN.md 변경 유무 체크
- **과도한 제약** — 이모지·BoxShadow 등 전면 금지가 실무에서 예외 상황을 못 다룰 수 있음
  - 완화: 예외가 반복되면 규칙 자체를 수정, 일회성 예외는 인라인 주석으로 사유 명시

## Open Questions

없음 (모든 결정사항이 브레인스토밍 중 확정됨).
