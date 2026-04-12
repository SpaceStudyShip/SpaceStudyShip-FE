# DESIGN.md — Space Study Ship Design System

> **읽기 대상:** 이 프로젝트에서 UI 작업을 수행하는 Claude / AI 에이전트 / 개발자
> **역할:** 철학·규칙·voice 를 정의한다. 상수 값은 `.claude/rules/07_DESIGN_SYSTEM_CONSTANTS.md` 참조.
> **Last Updated:** 2026-04-13
> **Version:** 1.0.0

---

## 1. Visual Theme & Atmosphere

Space Study Ship 은 학습 관리를 **우주 탐험 + 탑승 여정** 으로 재구성한 게이미피케이션 Flutter 앱이다. 사용자는 단순한 "학습자" 가 아니라 "탑승객" 이며, 할일·타이머·진행도는 각각 연료·비행시간·탑승권 상태로 번역된다. UI 의 모든 결정은 이 은유를 강화해야 한다.

시각적 기반은 **Deep Space** — `#0A0E27` 의 가장 깊은 우주 배경 위에 별이 반짝이는 `SpaceBackground` 가 모든 화면에 상시 존재한다. 콘텐츠는 우주선 내부 서피스인 `spaceSurface (#1A1F3A)` 와 `spaceElevated (#252B47)` 로 루미넌스를 쌓아 올리는 방식으로 계층화된다. 그림자로 깊이를 만들지 않고, **배경 밝기 스텝** 으로 고도를 표현한다.

감정선은 **Deep Space Blue** (신뢰·깊이), **Stellar Purple** (신비·프리미엄), **Cosmic Gold** (성취·보상) 세 기둥으로 구성되며, 이 외의 색상은 system/status 용 외에는 도입하지 않는다.

**핵심 특징:**
- Deep Space 다크 캔버스 (`#0A0E27`) 에 `SpaceBackground` 상시 오버레이
- 3-tier 서피스 루미넌스 스태킹: `spaceBackground → spaceSurface → spaceElevated`
- 그림자 없음 — 고도는 배경 밝기로만 표현
- Pretendard 한글 본문 + aerospace 영문 레이블 (`FUEL` / `PROGRESS` / `BOARDED`) 이중 voice
- 게이미피케이션 어휘: 탑승권·연료·행성·지역·미션
- 이모지 0개 — 모든 아이콘은 `FaIcon` 또는 `Icon`

---

## 2. Color Palette & Roles

### 절대 규칙 (Hard Constraint)

**모든 색상은 `lib/core/constants/app_colors.dart` 에 정의된 `AppColors.*` 상수만 사용한다.**

- `Color(0xFF...)` 리터럴 **금지**
- `Colors.blue`, `Colors.white70` 등 Material 색상 **금지** (`Colors.white` / `Colors.black` / `Colors.transparent` 는 `AppColors` 내부에서만 허용)
- `.withValues(alpha: 0.x)` 는 **opacity 조정 한정**으로만 허용. 새 색상을 만드는 용도로 사용 금지
- `LinearGradient` 등 그라디언트에 쓰는 색도 `AppColors.*` 로만 구성
- 새 색상이 필요하면 `app_colors.dart` 에 추가 후 커밋에 사유 명시 — 인라인 하드코딩 절대 금지
- 이 규칙은 `/review-design-system` 명령으로 자동 검증된다

### Primary — Deep Space Blue (`AppColors.primary`)
주요 액션·타이머 실행·현재 위치 표시. "지금 이 앱에서 가장 중요한 것" 에만 사용. 남발 금지.

### Secondary — Stellar Purple (`AppColors.secondary`)
뱃지·그룹·특별 카테고리. Primary 와 동등한 강조가 아닌 **보조 강조**. 서로 경쟁시키지 않는다.

### Accent Gold — Cosmic Gold (`AppColors.accentGold`)
오직 **성취 / 보상 / 연료** 만. 버튼 배경이나 일반 텍스트 강조에 금색 사용 금지. 금색은 "획득한 것" 의 신호.

### Accent Pink — Nebula Pink (`AppColors.accentPink`)
특별 이벤트·프로모션 한정. 일상 UI 에 등장하지 않음.

### Functional — Success / Warning / Error / Info
상태 전용. 디자인 강조용 색 팔레트로 쓰지 않는다. "에러색이 예뻐서" 빨강 버튼 만들기 금지.

### Surfaces — Luminance Stack
- `spaceBackground (#0A0E27)` — 화면 루트. 이것보다 어두운 배경을 만들지 않는다.
- `spaceSurface (#1A1F3A)` — 카드·다이얼로그·바텀시트
- `spaceElevated (#252B47)` — FAB·선택된 카드·호버 상태
- `spaceDivider (#2D3555)` — 경계선

고도가 올라갈수록 배경이 **밝아진다**. 새 서피스 색상을 임의 도입하지 않고 4단계 안에서 해결.

### Text — Opacity Tier (not new colors)
텍스트 계층은 새 회색을 만들지 않고 `Colors.white` 의 opacity 로만 표현:
- `textPrimary` (100%) — 제목·주요 정보
- `textSecondary` (70%) — 본문·설명
- `textTertiary` (50%) — 메타·라벨·캡션
- `textDisabled` (30%) — 비활성

### Semantic Colors — Fuel / Timer / Status
`fuelFull/Medium/Low/Empty`, `timerRunning/Paused/Completed`, `online/away/offline` 는 상태 전용 네이밍이 존재한다. 이 시맨틱 이름이 있는 상황에서 직접 `success`/`warning` 을 쓰지 않는다.

---

## 3. Typography & Voice

폰트는 **Pretendard** 단일 패밀리. weight 는 `Pretendard-SemiBold` / `Pretendard-Medium` 두 가지만 사용. 값은 `AppTextStyles` 에서 가져오고 새 `TextStyle` 을 인라인으로 만들지 않는다.

### 계층 (크기 기준)

| 역할 | 스타일 | 용도 |
|------|--------|------|
| Display | `semibold28` | 초대 코드·특수 하이라이트 |
| Heading 1 | `heading_24` | 메인 타이틀 (화면당 1개) |
| Heading 2 | `heading_20` | AppBar 제목·섹션 제목 |
| Sub Heading | `subHeading_18` | 카드 제목 |
| Label | `label_16` / `label16Medium` | 버튼·리스트 항목 라벨 |
| Paragraph | `paragraph_14` / `paragraph14Semibold` | 본문 |
| Tag | `tag_12` / `tag_10` | 캡션·메타·aerospace 레이블 |
| Timer | `timer_24/32/48/64` | 타이머 숫자 전용 |

### Voice 규칙 — Dual Voice System

**한글 voice — "친근한 탐험 동료"**

헤딩·본문·버튼·내비·다이얼로그·스낵바·에러 메시지는 전부 한글. 친근하지만 유치하지 않게. `docs/TOSS_UI_UX_DESIGN.md` 기준.

- ○ "탐험을 시작해볼까요?"
- ○ "연료가 부족해요"
- × "탐험 시작" (너무 건조)
- × "탐험 ㄱㄱ!" (유치)

**영문 aerospace voice — "미션 브리핑 레이블"**

`tag_10` / `tag_12` 스타일에만 허용. 항공우주 계기판 느낌. **Uppercase + letter-spacing 1.0~2.0px** 로 렌더링.

- 허용: `FUEL`, `PROGRESS`, `LOCKED`, `BOARDED`, `COMPLETED`, `FROM`, `TO`, `DIFFICULTY`, `DATE`, `MISSION`, `LEVEL`
- 적용 위치: 탑승권 티켓 레이블·카드 헤더 캡션·상태 뱃지·바코드 라벨
- 전체 사전은 Section 7 참조

**혼용 금지:** 같은 요소에 한글 + 영문 레이블을 동시에 쓰지 않는다. (`FUEL 연료` ×)

### 이모지 0개 원칙

UI 텍스트·코드 주석·문서·커밋 메시지·이슈 템플릿 어디에도 이모지 (🚀 ✅ ❌ ⭐ 🎨 🙋‍♂️ 등) 사용 금지. 아이콘이 필요하면 `FaIcon(FontAwesomeIcons.xxx)` 또는 `Icon(Icons.xxx)` 만 사용. 감정·상태 표현은 아이콘 + 색상으로 해결.

### 금지 사항
- ALL CAPS 한글 스페이싱 (`탐 험`)
- 3개 이상 weight 혼용 — SemiBold / Medium 두 축 고수
- `TextStyle(...)` 인라인 정의 — 무조건 `AppTextStyles` 사용
- 이모지 사용

---

## 4. Component Stylings

모든 UI 는 기존 공통 위젯으로 시작한다. 새 위젯을 만들기 전 `.claude/rules/05_WIDGETS_GUIDE.md` 를 반드시 확인하고, 공통 위젯에 없는 패턴만 신규 생성.

### AppButton — `core/widgets/buttons/app_button.dart`
- 모든 CTA·액션 버튼의 단일 진입점. `ElevatedButton` / `TextButton` / `InkWell` 직접 사용 금지.
- 변형은 `AppButton` 파라미터로만 표현. 자체 `Container + GestureDetector` 로 버튼 재구현 금지.

### AppCard
- 배경: `AppColors.spaceSurface`
- Radius: `AppRadius.card` (12px)
- Padding: `AppPadding.cardPadding` (all16)
- 그림자 없음. 고도 표현은 배경을 `spaceElevated` 로 올려서 처리.

### AppDialog / AppBottomSheet
- 다이얼로그 라운드: `AppRadius.xlarge`
- 바텀시트 라운드: `AppRadius.modal` (상단만 16px)
- Barrier: `AppColors.barrier` (54% 블랙)
- 타이틀: `heading_20`, 본문: `paragraph_14`, CTA: `AppButton`

### AppTextField
- 배경: `spaceSurface`, 테두리: `spaceDivider`, 포커스: `primary`
- Radius: `AppRadius.input` (8px)
- 라벨 텍스트: `tag_12` 컬러 `textTertiary`

### AppSnackBar
- `AppSnackBar.info / success / warning / error` 만 사용. `ScaffoldMessenger.showSnackBar(SnackBar(...))` 직접 호출 금지.
- 메시지는 한글 단문, 마침표 없음, 이모지 없음.

### SpaceBackground — 화면의 필수 하위 요소
- 모든 `Scaffold` 의 `body` 는 `Stack` 첫 자식으로 `Positioned.fill(child: SpaceBackground())` 를 반드시 포함.
- 예외 없음. 특수 상황에서도 배경을 제거하지 않고, 필요하면 오버레이를 위에 쌓는다.

### FadeSlideIn / ScaleIn — 진입 애니메이션
- 화면·카드·리스트 아이템 진입은 이 위젯으로 래핑. `AnimatedOpacity` 인라인 구현 금지.
- Duration / curve 는 `TossDesignTokens` 사용.

### BoardingPassTicket / PlanetNode — 특수 게임화 컴포넌트
- 탐험(`exploration`) 피처 전용이지만 재사용 가능. 내부 구조 (펀치클리퍼·점선·찢기 인터랙션) 수정 금지.
- 외부에서 새 "탑승권 스타일 카드" 가 필요하면 파라미터화하거나 래핑. 복제 구현 금지.

### 금지 사항
- `ElevatedButton` · `OutlinedButton` · `TextButton` 직접 사용
- Material `Card` 위젯 사용 — `AppCard` 로 대체
- `showDialog` 원시 호출 — `AppDialog` 헬퍼 사용
- 인라인 `BoxDecoration` 으로 그림자 추가 — 고도는 배경 루미넌스로만
- 위젯 내부에서 `TextStyle(...)` 신규 정의

---

## 5. Layout Principles

### Scaffold 템플릿 (필수 패턴)

모든 Screen 은 아래 구조로 시작한다. 예외 없음.

```dart
Scaffold(
  backgroundColor: AppColors.spaceBackground,
  extendBodyBehindAppBar: true,
  extendBody: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleSpacing: AppSpacing.s20,
    title: Text('제목', style: AppTextStyles.heading_20.copyWith(color: Colors.white)),
  ),
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),
      // 콘텐츠
    ],
  ),
)
```

- `AppBar` 는 투명·탄성 없음 — `SpaceBackground` 가 상단까지 이어진다
- 하단 플로팅 내비가 있는 화면은 `MediaQuery.padding.bottom + FloatingNavMetrics.totalHeight` 를 bottom inset 으로 계산

### Spacing Rhythm

`AppSpacing` 은 Flutter ScreenUtil 기반 반응형 값. **12 단계만** 존재 — s4 / s8 / s12 / s16 / s20 / s24 / s32 / s40 / s48 / s56 / s64. 사이 값(s10/s14 등) 없음.

**주요 리듬:**
- **s4** — 텍스트 라인 간·작은 제약 간격
- **s8** — 관련 요소 묶음 간격 (아이콘 ↔ 텍스트)
- **s12** — 리스트 아이템 내부 수직 간격
- **s16** — 카드 내부·섹션 내부 기본 간격
- **s20** — 화면 가로 패딩 (`screenPadding`)
- **s24** — 섹션 간 분리
- **s32~s64** — 큰 블록 간 여백·Empty State·히어로 영역

### AppPadding 프리셋 우선 사용
`AppPadding.screenPadding` / `cardPadding` / `listItemPadding` / `buttonPadding` / `bottomSheetTitlePadding` 이 있으면 그것부터 사용. `EdgeInsets.symmetric(...)` 인라인 생성은 프리셋에 없을 때만.

### AppRadius 스케일

| 레벨 | 값 | 용도 |
|------|-----|------|
| `small` | 4 | 작은 뱃지·인라인 태그 |
| `medium` | 8 | 입력 필드·소형 카드 |
| `large` / `button` / `card` | 12 | 기본 카드·버튼 |
| `xlarge` | 16 | 바텀시트 상단·큰 다이얼로그 |
| `xxlarge` | 24 | 티켓·히어로 카드 |
| `chip` | 100 | 칩·필 상태 뱃지 |
| `floatingNav` | 28 | 플로팅 내비게이션 바 전용 |

새 라디우스 값 추가 금지. 위 7개로 모든 UI 해결.

### Grid & Container
- 최대 가로폭 제약 없음 (모바일 전용)
- 리스트는 `ListView.separated` + `SizedBox(height: AppSpacing.s12)` 구분자 기본
- 그리드는 `SliverGridDelegateWithFixedCrossAxisCount` + `AppSpacing.s12` 간격
- `Row` / `Column` 의 `mainAxisAlignment.spaceBetween` 은 **2개 요소일 때만**. 3개 이상은 `Spacer` 또는 명시적 간격.

### Whitespace 철학
우주 배경이 곧 여백이다. 흰색 여백이 아니라 **별이 반짝이는 Deep Space** 가 콘텐츠 사이를 채운다. 카드와 카드 사이, 섹션과 섹션 사이의 큰 간격은 "비어 있음" 이 아니라 "우주가 드러나는 창".

실용적 결과:
- 섹션 구분을 위해 `Divider` 를 남발하지 않는다 — 간격만으로 충분
- 카드 사이에 `spaceDivider` 색 수평선 넣지 않는다 — `SizedBox` 간격으로 대체
- 여백이 넓어 보인다고 요소를 채워 넣지 않는다

---

## 6. Depth & Elevation

**그림자 없음. 고도는 배경 루미넌스로 표현한다.**

전통적인 Material Design 은 `elevation` 값으로 `BoxShadow` 를 투하한다. 이 프로젝트는 이 방식을 **쓰지 않는다**. 이유:

1. **다크 캔버스에서 그림자는 보이지 않음** — `#0A0E27` 위의 반투명 그림자는 거의 식별 불가능
2. **우주의 은유** — 우주 공간에는 대기가 없어 빛이 산란하지 않는다. 퍼지는 그림자를 넣는 순간 "우주" 느낌이 깨진다
3. **실용성** — 다크 서피스에서는 서피스 자체의 밝기를 올리는 것이 유일하게 작동하는 엘리베이션 방식

### 5-Layer Luminance Stack

| 레벨 | 배경 | 용도 | 엘리베이션 표현 |
|------|------|------|-----------------|
| **L0 — Deep Space** | `spaceBackground` (`#0A0E27`) | 화면 루트. `SpaceBackground` 별 배경이 위에 깔림 | 모든 것의 기반 |
| **L1 — Surface** | `spaceSurface` (`#1A1F3A`) | 카드·다이얼로그·바텀시트·입력 필드 | L0 대비 밝기 상승 |
| **L2 — Elevated** | `spaceElevated` (`#252B47`) | FAB·선택된 카드·호버·활성 리스트 | L1 대비 한 단계 상승 |
| **L3 — Divider** | `spaceDivider` (`#2D3555`) | 경계선·테두리·세퍼레이터 | 면이 아닌 선으로만 |
| **L4 — Barrier** | `barrier` (`0x8A000000`) | 모달·바텀시트 아래 딤 | L0~L2 를 덮어 초점 격리 |

### 사용 규칙
- 같은 화면에서 최대 **3단계** 까지만 쌓는다 (L0 → L1 → L2). L2 위에 또 카드를 얹지 않는다 — 필요하면 구조를 평탄화
- **호버 = 한 단계 상승** — 카드 호버 시 `spaceSurface` → `spaceElevated` 로 배경만 전환
- **선택 상태 = 한 단계 상승 + primary 테두리** — 배경을 `spaceElevated` 로, 테두리를 `AppColors.primary` 1px. 채우기 색으로 primary 사용 금지
- **비활성 = 하강 없이 opacity** — 비활성 카드는 레벨을 낮추지 않고 전체 opacity 0.5 로 처리

### Border 처리
- 기본 카드: 테두리 없음 (배경 밝기만으로 분리)
- 상태 강조: 1px solid, 색상은 의미에 맞게 (`primary` / `success` / `error`)
- 테두리 두께는 1px 고정. 굵은 테두리로 강조를 만들지 않는다.

### 엘리베이션 금지 사항
- `BoxShadow` 사용 (`elevation`, `shadowColor`)
- `Material(elevation: N)` 래퍼
- 그라디언트로 "떠오른 느낌" 시뮬레이션
- Blur (`ImageFilter.blur`) 를 엘리베이션 용도로 사용 (연출 오버레이는 허용)
- `BoxDecoration` 의 `boxShadow: [BoxShadow(...)]` 인라인 정의

---

## 7. Voice & Labels — Aerospace Dictionary

Section 3 에서 dual voice 원칙을 정의했다. 여기서는 **실제 어떤 영문 레이블을 어디에 쓰는지** 를 사전 형태로 고정한다. 아래 목록에 없는 새 영문 레이블을 즉흥 생성하지 않는다. 필요하면 이 사전에 추가 후 팀과 공유.

### 렌더링 규칙
- 스타일: `AppTextStyles.tag_10` 또는 `tag_12`
- 변환: `.toUpperCase()` 로 항상 대문자
- Letter-spacing: 1.0 (tag_12) / 2.0 (tag_10)
- 색상: `AppColors.textTertiary` 기본, 상태 강조 시에만 semantic 컬러

### Label Dictionary

**Status (상태)**
`LOCKED` · `UNLOCKED` · `BOARDED` · `IN PROGRESS` · `COMPLETED` · `CLEARED` · `FAILED` · `EXPIRED`

**Resource (자원)**
`FUEL` · `LEVEL` · `EXP` · `POINTS`

**Journey (여정)**
`FROM` · `TO` · `ROUTE` · `MISSION` · `DESTINATION` · `DEPARTURE` · `ARRIVAL`

**Metadata (메타)**
`DATE` · `TIME` · `DURATION` · `DIFFICULTY` · `PROGRESS` · `PRIORITY` · `CATEGORY`

**Document (문서)**
`BOARDING PASS` · `SPACE PASS` · `TICKET` · `PASS` · `CODE`

### 내비게이션은 한글 원칙
내비게이션 탭 라벨은 **한글** (`홈`, `탐험`, `타이머`, `할일`, `프로필`). 영문 레이블은 탭 내부 콘텐츠의 하위 카테고리에만 사용.

### 난이도·값 표현
- 난이도 **레이블** 은 영문 (`DIFFICULTY`), **값** 은 한글 (`쉬움` · `보통` · `어려움`)
- 시간: `HH:mm:ss` (타이머), `yyyy.MM.dd` (날짜) — 마침표 구분자
- 숫자: 천단위 콤마 (`1,200`)
- 단위: 한글 병기 (`3통`, `120분`, `500포인트`)

### 금지
- 사전에 없는 영문 레이블 즉흥 생성 (`JOURNEY`, `RANK`, `SCORE` 등)
- 한글 + 영문 동시 표기 (`FUEL 연료`)
- 소문자 aerospace 레이블 (`fuel`)
- 축약어 (`PROG`, `DIFF`) — 가독성 우선

---

## 8. Do's and Don'ts

### Do

**색상**
- `AppColors.*` 상수만 사용
- 색의 "역할" 로 선택 — primary 는 주요 액션, gold 는 성취, pink 는 특별 이벤트
- 텍스트 계층은 opacity tier 로 표현
- 고도는 배경 밝기로 표현
- 새 색상이 필요하면 `app_colors.dart` 에 추가 후 커밋 사유 명시

**타이포**
- `AppTextStyles.*` 만 사용
- weight 는 `SemiBold` / `Medium` 두 가지만
- 본문·버튼·메시지는 한글, 작은 레이블만 aerospace 영문
- 영문 레이블은 Section 7 사전 내에서만 선택

**레이아웃**
- 모든 Screen 은 `Scaffold(backgroundColor: spaceBackground, body: Stack([Positioned.fill(SpaceBackground()), ...]))` 패턴
- `AppPadding` 프리셋 우선
- 간격은 `AppSpacing.s4~s64` 12단계 안에서 해결
- 라디우스는 `AppRadius` 7종 안에서 해결

**컴포넌트**
- `AppButton`, `AppCard`, `AppDialog`, `AppTextField`, `AppSnackBar` 공통 위젯으로 시작
- 새 위젯 만들기 전 `.claude/rules/05_WIDGETS_GUIDE.md` 먼저 확인
- 진입 애니메이션은 `FadeSlideIn` / `ScaleIn` 래퍼 사용
- 애니메이션 값은 `TossDesignTokens` 에서

**아이콘**
- `FaIcon(FontAwesomeIcons.xxx)` 또는 `Icon(Icons.xxx)` 사용
- 크기는 `.w` (ScreenUtil) 기반 반응형

**Voice**
- 친근하지만 유치하지 않게
- 짧은 단문, 스낵바·토스트 마침표 생략
- 상태 변화는 아이콘 + 색상 + 한글 + aerospace 레이블 조합

### Don't

**색상**
- `Color(0xFF...)` 리터럴 사용
- `Colors.blue/red/grey` 등 Material 색상 참조
- `.withValues(alpha:)` 로 새로운 색상 생성 (opacity 조정 한정 허용)
- gold 를 일반 강조에 사용

**타이포**
- `TextStyle(...)` 인라인 정의
- Pretendard 외 폰트 도입
- 한글 ALL CAPS 스페이싱
- 같은 요소에 한글 + 영문 동시 표기
- aerospace 레이블 소문자 또는 축약

**레이아웃**
- `SpaceBackground` 생략
- `AppSpacing` 에 없는 간격 값 (`SizedBox(height: 10)`)
- 새 라디우스 값 도입
- `Divider` 로 섹션 분리
- `Row.spaceBetween` 3개 이상 요소에 사용

**컴포넌트**
- `ElevatedButton` / `OutlinedButton` / `TextButton` 직접 사용
- Material `Card` 위젯 사용
- `showDialog` / `showModalBottomSheet` 원시 호출
- `ScaffoldMessenger.showSnackBar(SnackBar(...))` 직접 호출
- `BoxShadow` · `elevation` · `Material(elevation:)` 로 그림자 만들기
- `Container + GestureDetector` 로 버튼 재구현
- `BoardingPassTicket` / `PlanetNode` 내부 구조 복제

**이모지**
- UI 텍스트에 이모지 사용 — **전면 금지**
- 코드 주석·커밋 메시지·이슈·PR 본문·문서에도 이모지 금지
- 상태 표현은 아이콘 + 색상으로만

**Voice**
- 건조한 명령형 ("탐험 시작") — 제안형 ("탐험을 시작해볼까요?") 으로
- 유치한 어미 ("ㄱㄱ!", "!!!")
- 딱딱한 에러 문구 ("Error: fuel insufficient") — 한글 단문 ("연료가 부족해요")
- 기능명을 영어로 표기 ("Todo 추가") — ("할 일 추가")

---

## 9. Agent Prompt Guide

### A. 작업 시작 전 — 로드 체크리스트

UI 관련 작업 (Screen · Widget · Component 생성/수정) 시작 전 다음 파일을 Read 로 로드:

1. `DESIGN.md` (이 파일) — 철학·규칙·voice
2. `.claude/rules/07_DESIGN_SYSTEM_CONSTANTS.md` — 상수 값 레퍼런스
3. `.claude/rules/05_WIDGETS_GUIDE.md` — 공통 위젯 카탈로그
4. `docs/TOSS_UI_UX_DESIGN.md` — UX 라이팅 가이드 (카피 작성 시)
5. 작업 중인 feature 의 기존 Screen · Widget (패턴 파악)

**스킵 조건:** 순수 비즈니스 로직 (UseCase · Repository · Provider 내부) 수정만 하는 경우.

### B. 작성 중 — 실시간 점검

**색상을 쓸 때:**
- [ ] `AppColors.*` 에서 온 것인가?
- [ ] Hex 리터럴이나 `Colors.blue` 같은 걸 쓰지 않았는가?
- [ ] 이 색의 "역할" 이 맞는가?

**간격·라디우스를 쓸 때:**
- [ ] `AppSpacing.sN` / `AppPadding.*` / `AppRadius.*` 에서 가져왔는가?
- [ ] 리터럴이 섞여있지 않은가?

**텍스트를 쓸 때:**
- [ ] `AppTextStyles.*` 를 썼는가?
- [ ] `TextStyle(...)` 인라인이 없는가?
- [ ] 한글 본문인가? 영문 레이블이면 Section 7 사전에 있는가?

**컴포넌트를 만들 때:**
- [ ] `.claude/rules/05_WIDGETS_GUIDE.md` 의 공통 위젯으로 대체 가능한가?
- [ ] `AppButton` 대신 `ElevatedButton` 을 쓰고 있진 않은가?

**화면을 만들 때:**
- [ ] `Scaffold` 의 `backgroundColor` 가 `spaceBackground` 인가?
- [ ] `Stack` 첫 자식이 `Positioned.fill(SpaceBackground())` 인가?
- [ ] `AppBar` 가 투명·플랫 세팅인가?

**엘리베이션:**
- [ ] `BoxShadow` 를 쓰고 있진 않은가?
- [ ] 배경 밝기로 표현했는가?

**아이콘·텍스트 출력:**
- [ ] 이모지가 포함되어 있지 않은가?
- [ ] 아이콘은 `FaIcon(FontAwesomeIcons.xxx)` 또는 `Icon(Icons.xxx)` 인가?

### C. 제출 전 — 최종 검증

1. **grep 셀프체크** — 파일에서 다음 패턴 확인:
   - `Color(0xFF` → `AppColors` 로 교체
   - `TextStyle(` → `AppTextStyles` 로 교체
   - `EdgeInsets.all(` 숫자 리터럴 → `AppPadding` 프리셋 또는 `AppSpacing`
   - `BoxShadow(` → 제거, 루미넌스 스태킹으로 전환
   - `ElevatedButton` · `OutlinedButton` · `Card(` → 공통 위젯
   - 이모지 문자 → 제거
2. **`/review-design-system`** — 자동 검증
3. **`flutter analyze`** — 정적 분석 통과
4. **시각 확인** — 가능하면 실제 렌더 확인

### D. 샘플 선언 프롬프트

사용자가 UI 작업을 요청했을 때 Claude 는 코드 작성 전 다음을 선언:

```
1. DESIGN.md · 07_DESIGN_SYSTEM_CONSTANTS · 05_WIDGETS_GUIDE 로드
2. 기존 [feature]/presentation/screens/ 패턴 확인
3. 필요한 공통 위젯 목록: AppButton, AppCard, ...
4. 신규 생성이 필요한 부분: (있으면 명시)
5. Voice 결정: 한글 본문 + [FUEL, PROGRESS, ...] aerospace 레이블
6. 엘리베이션: L0 → L1 → L2 스택
```

### E. 개선 루프

DESIGN.md 는 살아있는 문서다. 다음 상황에서 업데이트:
- 기존 규칙으로 표현 불가능한 새 UI 패턴이 필요할 때
- Section 7 사전에 없는 새 영문 레이블이 필요할 때
- 새 공통 위젯·상수가 추가될 때

업데이트 시 상단 `Last Updated` 와 `Version` 함께 수정.

---

**End of DESIGN.md**
</content>
</invoke>