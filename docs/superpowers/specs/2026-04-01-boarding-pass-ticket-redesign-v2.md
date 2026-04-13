# Boarding Pass Ticket Redesign v2

## Context

Issue #65 — 지역 상세 화면 2x2 정보 그리드 개선.
v1에서 탑승권 티켓 UI로 교체했으나 정보가 2x2 그리드에 분산되어 실제 항공권과 거리가 있었음. 실제 항공권 레이아웃을 참고하여 재구성.

## Design

### Layout (위→아래 순서)

```
BOARDING PASS                [COMPLETED]
────────────────────────────────────────
FROM                              TO
지구            ✈ ─ ─ →        🇯🇵 일본
벚꽃과 기술의 나라

PROGRESS ━━━━━━━━━━━━━░░░░░░  2 / 12

FUEL          DIFFICULTY        DATE
  1             쉬움         2026.03.29
────────────────────────────────────────
#3547
- - - - - - - - - - - - - - - - - - - -
        [stub: 바코드 / 찢기 / 스탬프]
```

### 1. Header

- 좌측: "BOARDING PASS" 라벨 (tag_10, letterSpacing 2.0, bold)
- 우측: 상태 배지 (LOCKED / BOARDED / COMPLETED) — 기존 그대로 유지

### 2. FROM → TO (메인 영역)

- FROM/TO 라벨: tag_10, textTertiary
- **이름: heading_24 크기로 크게 표시** (기존 label_16에서 업그레이드)
- 중앙: 로켓/화살표 아이콘 + 점선 경로
- TO 우측에 RegionFlagIcon 유지
- FROM 이름 아래에 description 텍스트 (tag_12, textSecondary) — 기존 footer에서 이동

### 3. Progress (해금 시만 표시)

- FROM/TO 아래에 배치
- 좌측: "PROGRESS" 라벨
- 우측: "cleared / total" 텍스트
- 아래: LinearProgressIndicator (기존과 동일)

### 4. 하단 정보 행

- 3개 항목 한 줄 나열: **FUEL | DIFFICULTY | DATE**
- 각 항목: 라벨(tag_10) + 값(paragraph14Semibold)
- 아이콘 없음 (텍스트만)
- Expanded로 균등 분할
- STATUS 제외 (헤더 배지와 중복)
- PROGRESS 제외 (별도 섹션)

### 5. Footer

- 좌측: 티켓 번호 (#XXXX)
- description은 FROM/TO 영역으로 이동했으므로 footer에서 제거

### 6. 점선 구분선 + Stub

- 기존 TicketDashedLine 유지
- 기존 TicketTearInteraction 유지 (변경 없음)

## 변경 범위

- `boarding_pass_ticket.dart` — `_buildTicketBody`, `_buildRoute`, `_buildInfoGrid` → `_buildInfoRow`, `_buildFooter` 수정
- 다른 파일 변경 없음

## 변경하지 않는 것

- TicketTearInteraction (stub 찢기 인터랙션)
- TicketDashedLine (점선 구분선)
- TicketPunchClipper (펀치 자국)
- LocationDetailScreen (화면 레이아웃)
- 히어로 섹션 (행성 아이콘, 국기, 원형 진행도)
