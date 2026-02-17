# Calendar Planet Style Design

**Goal:** 캘린더 날짜 셀에 행성 테마 적용 + 체크박스 마커 크기 증가

## Design Decisions

### 선택된 날짜 = 미니 행성
- `RadialGradient` (center: -0.3, -0.3) — 좌상단 하이라이트로 3D 구체감
- Primary blue 기반 gradient: `[primary.withOpacity(0.6), primaryDark.withOpacity(0.3)]`
- 테두리: `primaryLight.withOpacity(0.5)`, width 1.5
- BoxShadow glow: `primary.withOpacity(0.4)`, blur 12, spread 3
- 텍스트: 흰색 bold

### 오늘 날짜 = 궤도 링
- 배경: subtle gradient `[secondary.withOpacity(0.15), transparent]`
- 테두리: `secondaryLight` (Stellar Purple), width 1.5
- 텍스트: `secondaryLight` bold
- glow 없음 (선택과 차별화)

### 일반 날짜 = 변경 없음
- 심플한 흰색/반투명 텍스트 유지

### 체크박스 마커
- 14px → 18px 증가
- 아이콘/색상 로직은 현재 그대로 유지

## 변경 파일
- `lib/features/home/presentation/widgets/space_calendar.dart` (1개 파일)
