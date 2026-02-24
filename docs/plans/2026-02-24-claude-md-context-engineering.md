# CLAUDE.md Context Engineering - Progressive Disclosure 모듈화

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 매 대화마다 자동 로딩되는 컨텍스트를 1,960줄에서 ~300줄로 축소 (85% 절감)하면서, 모든 정보에 온디맨드 접근 유지

**Architecture:** `~/.claude/` 루트의 SuperClaude 프레임워크 파일들을 하위 디렉토리로 이동 (Progressive Disclosure). 프로젝트 CLAUDE.md는 "라우터" 역할로 슬림화. 상세 정보는 docs/ 모듈에서 필요 시 로드.

**Tech Stack:** Claude Code CLAUDE.md system, Markdown, Shell (mv/mkdir)

---

## 현재 상태 분석 (정량)

```
자동 로딩되는 파일                              줄 수    비율
─────────────────────────────────────────────────────────
~/.claude/BUSINESS_PANEL_EXAMPLES.md           278     14%
~/.claude/BUSINESS_SYMBOLS.md                  211     11%
~/.claude/MODE_Business_Panel.md               334     17%
~/.claude/RULES.md                             257     13%
~/.claude/FLAGS.md                             120      6%
~/.claude/MODE_Task_Management.md              107      5%
~/.claude/MODE_Token_Efficiency.md              74      4%
~/.claude/PRINCIPLES.md                         60      3%
~/.claude/MODE_Orchestration.md                 49      3%
~/.claude/MODE_Brainstorming.md                 43      2%
~/.claude/MODE_Introspection.md                 38      2%
~/.claude/MCP_Context7.md                       29      1%
~/.claude/MCP_Magic.md                          30      2%
~/.claude/MCP_Playwright.md                     31      2%
~/.claude/MCP_Serena.md                         31      2%
~/.claude/CLAUDE.md (global)                    61      3%
프로젝트 CLAUDE.md                              187     10%
MEMORY.md                                       20      1%
─────────────────────────────────────────────────────────
합계                                          1,960    100%
```

**핵심 문제:** SuperClaude 프레임워크 16개 파일 (1,692줄, 87%)이 Flutter 개발과 무관하게 매번 로딩됨.

**원인:** Claude Code는 `~/.claude/` 루트의 모든 `.md` 파일을 자동 로딩. 하위 디렉토리(`commands/`, `agents/`, `plugins/` 등)는 로딩하지 않음.

---

## 목표 상태

```
자동 로딩되는 파일                              줄 수
─────────────────────────────────────────────────────
~/.claude/CLAUDE.md (global, 슬림화)            ~40
프로젝트 CLAUDE.md (슬림화)                     ~120
MEMORY.md                                       ~30
─────────────────────────────────────────────────────
합계                                           ~190  (90% 절감)
```

SuperClaude 프레임워크 파일들은 `~/.claude/reference/superclaude/`로 이동 → 필요 시 스킬/에이전트가 온디맨드 로드.

---

## Phase 1: Global `~/.claude/` Progressive Disclosure (최우선)

### Task 1: reference 디렉토리 생성

**Files:**
- Create: `~/.claude/reference/superclaude/` (디렉토리)

**Step 1: 디렉토리 구조 생성**

```bash
mkdir -p ~/.claude/reference/superclaude
```

**Step 2: 디렉토리 존재 확인**

Run: `ls -la ~/.claude/reference/`
Expected: `superclaude` 디렉토리 존재

---

### Task 2: SuperClaude 프레임워크 파일 이동

**Files:**
- Move: `~/.claude/BUSINESS_PANEL_EXAMPLES.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/BUSINESS_SYMBOLS.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/FLAGS.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/PRINCIPLES.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/RULES.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MODE_Brainstorming.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MODE_Business_Panel.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MODE_Introspection.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MODE_Orchestration.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MODE_Task_Management.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MODE_Token_Efficiency.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MCP_Context7.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MCP_Magic.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MCP_Playwright.md` → `~/.claude/reference/superclaude/`
- Move: `~/.claude/MCP_Serena.md` → `~/.claude/reference/superclaude/`

**Step 1: 모든 SuperClaude 파일 이동**

```bash
mv ~/.claude/BUSINESS_PANEL_EXAMPLES.md ~/.claude/reference/superclaude/
mv ~/.claude/BUSINESS_SYMBOLS.md ~/.claude/reference/superclaude/
mv ~/.claude/FLAGS.md ~/.claude/reference/superclaude/
mv ~/.claude/PRINCIPLES.md ~/.claude/reference/superclaude/
mv ~/.claude/RULES.md ~/.claude/reference/superclaude/
mv ~/.claude/MODE_Brainstorming.md ~/.claude/reference/superclaude/
mv ~/.claude/MODE_Business_Panel.md ~/.claude/reference/superclaude/
mv ~/.claude/MODE_Introspection.md ~/.claude/reference/superclaude/
mv ~/.claude/MODE_Orchestration.md ~/.claude/reference/superclaude/
mv ~/.claude/MODE_Task_Management.md ~/.claude/reference/superclaude/
mv ~/.claude/MODE_Token_Efficiency.md ~/.claude/reference/superclaude/
mv ~/.claude/MCP_Context7.md ~/.claude/reference/superclaude/
mv ~/.claude/MCP_Magic.md ~/.claude/reference/superclaude/
mv ~/.claude/MCP_Playwright.md ~/.claude/reference/superclaude/
mv ~/.claude/MCP_Serena.md ~/.claude/reference/superclaude/
```

**Step 2: 이동 확인**

Run: `ls ~/.claude/reference/superclaude/ | wc -l`
Expected: `15`

Run: `ls ~/.claude/*.md`
Expected: `CLAUDE.md`만 존재 (다른 .md 파일 없음)

---

### Task 3: Global CLAUDE.md 정리

**Files:**
- Modify: `~/.claude/CLAUDE.md`

**Step 1: 현재 내용 백업**

```bash
cp ~/.claude/CLAUDE.md ~/.claude/reference/CLAUDE.md.backup
```

**Step 2: Global CLAUDE.md를 슬림 버전으로 교체**

새 `~/.claude/CLAUDE.md` 내용:

```markdown
# Global Instructions

## Git Conventions
- Co-Authored-By 태그 절대 금지. 커밋 메시지에 추가하지 않는다.

## SuperClaude Reference
SuperClaude 프레임워크 참조 파일은 `~/.claude/reference/superclaude/`에 위치.
필요 시 Read 도구로 개별 파일 로드:
- FLAGS.md — 실행 제어 플래그
- RULES.md — 행동 규칙
- PRINCIPLES.md — 엔지니어링 원칙
- MODE_*.md — 모드별 행동 가이드
- MCP_*.md — MCP 서버 사용 가이드
- BUSINESS_*.md — 비즈니스 패널 분석
```

**Step 3: env secrets 완전 제거 확인**

기존 CLAUDE.md에 있던 backend/.env, frontend/.env.local 정보가 새 버전에 포함되지 않았는지 확인.

Run: `grep -c "SUPABASE\|DATABASE_URL\|ANON_KEY" ~/.claude/CLAUDE.md`
Expected: `0`

---

### Task 4: 이동 후 검증

**Step 1: ~/.claude/ 루트에 자동 로딩될 .md 파일 수 확인**

Run: `ls ~/.claude/*.md`
Expected: `CLAUDE.md`만 출력

**Step 2: reference 디렉토리에 모든 파일 있는지 확인**

Run: `ls ~/.claude/reference/superclaude/ | sort`
Expected:
```
BUSINESS_PANEL_EXAMPLES.md
BUSINESS_SYMBOLS.md
FLAGS.md
MCP_Context7.md
MCP_Magic.md
MCP_Playwright.md
MCP_Serena.md
MODE_Brainstorming.md
MODE_Business_Panel.md
MODE_Introspection.md
MODE_Orchestration.md
MODE_Task_Management.md
MODE_Token_Efficiency.md
PRINCIPLES.md
RULES.md
```

**Step 3: 자동 로딩 줄 수 계산**

Run: `wc -l ~/.claude/CLAUDE.md`
Expected: ~15-20줄 (기존 61줄에서 축소)

---

## Phase 2: 프로젝트 CLAUDE.md 최적화 (선택)

> Phase 1만으로 87% 절감 달성. Phase 2는 추가 최적화.

### Task 5: 디자인 시스템 상수 참조 문서 생성

**Files:**
- Create: `docs/07_DESIGN_SYSTEM_CONSTANTS.md`

**Step 1: 디자인 시스템 상수 레퍼런스 문서 작성**

이 문서에는 현재 CLAUDE.md의 Design System Constants 섹션 전체와 Common Widgets 테이블을 포함. CLAUDE.md에서는 핵심 규칙만 남기고 상세 값은 이 문서로 링크.

```markdown
# Design System Constants Reference

> CLAUDE.md에서 분리된 상세 참조 문서. UI 작업 시 이 파일을 참조하세요.

## AppColors (`core/constants/app_colors.dart`)

```dart
// Primary: primary, primaryLight, primaryDark
// Secondary: secondary, secondaryLight, secondaryDark
// Accent: accentGold/Light/Dark, accentPink/Light/Dark
// Functional: success, warning, error, info
// Background: spaceBackground, spaceSurface, spaceElevated, spaceDivider
// Text: textPrimary(white), textSecondary(70%), textTertiary(50%), textDisabled(30%)
// Semantic: timerRunning/Paused/Completed, fuelFull/Medium/Low/Empty
```

## AppSpacing (`core/constants/spacing_and_radius.dart`)

```dart
SizedBox(height: AppSpacing.s16)
// 사용 가능: s4, s8, s12, s16, s20, s24, s32, s40, s48, s56, s64
// ⚠️ s2, s6, s10, s14 등은 없음 → 하드코딩 허용
```

## AppPadding

```dart
AppPadding.all4 ~ all24              // 전방향
AppPadding.horizontal8 ~ horizontal24  // 좌우
AppPadding.vertical8 ~ vertical24      // 상하
AppPadding.screenPadding       // h20 + v16
AppPadding.cardPadding         // all16
AppPadding.listItemPadding     // h16 + v12
AppPadding.buttonPadding       // h24 + v12
AppPadding.bottomSheetTitlePadding // h20 + v12
```

## AppRadius

```dart
AppRadius.small(4) · medium(8) · large(12) · xlarge(16) · xxlarge(24) · chip(100)
AppRadius.card(12) · button(12) · modal(상단16) · input(8) · snackbar(12)
```

## AppTextStyles (`core/constants/text_styles.dart`)

```dart
// Heading: semibold28, heading_24, heading_20, subHeading_18
// Label: label_16, label16Medium
// Body: paragraph_14, paragraph_14_100, paragraph14Semibold
// Small: tag_12, tag_10, tag10Semibold
// Timer: timer_24, timer_32, timer_48, timer_64
```

## AppGradients (`core/constants/app_gradients.dart`)

- `cardSurface`, `cardSurfaceAccent`, `primaryAccent` 등

## Common Widgets (`lib/core/widgets/`)

**새 위젯 만들기 전에 반드시 확인!**

| 위젯 | 경로 | 용도 |
|------|------|------|
| `AppButton` | `buttons/app_button.dart` | 모든 버튼 |
| `AppTextField` | `inputs/app_text_field.dart` | 텍스트 입력 |
| `AppCard` | `cards/app_card.dart` | 카드 컨테이너 |
| `AppDialog` | `dialogs/app_dialog.dart` | 모달 (`AppDialog.show`, `AppDialog.confirm`) |
| `AppLoading` | `feedback/app_loading.dart` | 로딩 인디케이터 |
| `AppSkeleton` | `feedback/app_skeleton.dart` | Shimmer 로딩 |
| `AppSnackBar` | `feedback/app_snackbar.dart` | 토스트 (`AppSnackBar.success/error/info`) |
| `AppEmptyState` | `states/app_empty_state.dart` | 빈 상태 |
| `SpaceEmptyState` | `states/space_empty_state.dart` | 우주 테마 빈 상태 |
| `SpaceBackground` | `backgrounds/space_background.dart` | **모든 화면 필수** 별 배경 |
| `FadeSlideIn` | `animations/entrance_animations.dart` | 입장 애니메이션 |
| `DragHandle` | `atoms/drag_handle.dart` | 바텀시트 드래그 핸들 |
| `CalendarHeader` | `atoms/calendar_header.dart` | 캘린더 커스텀 헤더 |
| `SpaceStatItem` | `atoms/space_stat_item.dart` | 통계 아이콘+라벨+값 |

**Space 위젯** (`space/`): `TodoItem`, `SpaceshipCard`, `SpaceshipAvatar`, `BadgeCard`, `StreakBadge`, `FuelGauge`, `StatusCard`, `RankingItem`, `BoosterBanner`, `TimerDisplay`
```

**Step 2: 파일 생성 확인**

Run: `wc -l docs/07_DESIGN_SYSTEM_CONSTANTS.md`
Expected: ~80줄

---

### Task 6: 프로젝트 CLAUDE.md 슬림화

**Files:**
- Modify: `CLAUDE.md` (프로젝트 루트)

**Step 1: 백업**

```bash
cp CLAUDE.md CLAUDE.md.backup
```

**Step 2: CLAUDE.md를 라우터 형태로 재작성**

새 `CLAUDE.md` 내용 (~120줄):

```markdown
# CLAUDE.md

## Project Overview

**Space Study Ship (우주공부선)** — 우주 탐험 테마 게이미피케이션 학습 관리 Flutter 앱

**Tech Stack:** Flutter 3.9+ · Riverpod 2.6 (Generator) · Freezed 2.5 · Dio + Retrofit · Firebase Auth · Pretendard Font

---

## Commands

```bash
# 코드 생성 (Freezed, Riverpod, Retrofit 어노테이션 변경 후 필수)
flutter pub run build_runner build --delete-conflicting-outputs

# 정적 분석
flutter analyze
```

---

## Architecture: Clean 3-Layer

**의존성 방향:** `Presentation → Domain → Data` (역방향 금지)

```
features/<feature>/
├── data/           # DataSource, Model(DTO), Repository 구현체
├── domain/         # Entity(Freezed), Repository 인터페이스, UseCase — 순수 Dart만
└── presentation/   # Provider(@riverpod), Screen, Widget
```

**Provider 체인:** `DataSource → Repository → UseCase → Notifier`

**구현된 Feature:**
- `auth/` — Firebase Auth (Google, Apple, Guest) + JWT
- `timer/` — 타이머 + 세션 기록 (data/domain/presentation 완전 구현)
- `todo/` — 할일 CRUD + 카테고리 (data/domain/presentation 완전 구현)
- `home/`, `explore/`, `exploration/`, `profile/`, `social/` — presentation 위주

> 상세: [docs/01_ARCHITECTURE.md](docs/01_ARCHITECTURE.md)

---

## Design System (하드코딩 금지)

**핵심 규칙:** 매칭되는 상수가 있으면 하드코딩 절대 금지.

- **AppColors** → `core/constants/app_colors.dart`
- **AppSpacing** → s4, s8, s12, s16, s20, s24, s32, s40, s48, s56, s64 (⚠️ s2/s6/s10/s14 없음)
- **AppPadding** → all/horizontal/vertical 프리셋 + screenPadding, cardPadding, listItemPadding, buttonPadding
- **AppRadius** → small(4), medium(8), large(12), xlarge(16), xxlarge(24), chip(100)
- **AppTextStyles** → `core/constants/text_styles.dart`

> 전체 값 목록: [docs/07_DESIGN_SYSTEM_CONSTANTS.md](docs/07_DESIGN_SYSTEM_CONSTANTS.md)

---

## Common Widgets

**새 위젯 만들기 전에 반드시 [docs/05_WIDGETS_GUIDE.md](docs/05_WIDGETS_GUIDE.md) 확인!**

핵심: `AppButton`, `AppCard`, `AppDialog`, `AppTextField`, `AppLoading`, `AppSnackBar`, `SpaceBackground`(모든 화면 필수), `FadeSlideIn`

> 전체 위젯 목록: [docs/07_DESIGN_SYSTEM_CONSTANTS.md](docs/07_DESIGN_SYSTEM_CONSTANTS.md)

---

## Screen 필수 패턴

```dart
Scaffold(
  backgroundColor: AppColors.spaceBackground,
  body: Stack(
    children: [
      const Positioned.fill(child: SpaceBackground()),  // 필수
      // 실제 콘텐츠
    ],
  ),
)
```

---

## Git Conventions

```
<type>: <한글 설명>
# type: feat, fix, refactor, style, chore, docs, test
```

**Co-Authored-By 태그 절대 금지.**

---

## Naming Rules

```dart
// 파일: snake_case.dart  |  클래스: PascalCase  |  변수/함수: camelCase
// 상수: lowerCamelCase (NOT UPPER_CASE)  |  Boolean: is/has/can prefix
// Private: _ prefix
```

> 상세: [docs/03_CODE_CONVENTIONS.md](docs/03_CODE_CONVENTIONS.md)

---

## Review Commands

| 커맨드 | 검사 항목 |
|--------|----------|
| `/review-1` | Dead code, runtime safety (stream/timer leak), 불필요한 리빌드 |
| `/review-2` | AppColors/AppSpacing/AppPadding/AppRadius 하드코딩, 공통 위젯 미사용 |
| `/review-3` | 아키텍처 레이어 위반, DRY, 불필요한 구조, Riverpod 패턴, 네이밍 |

---

## Key References

- [docs/05_WIDGETS_GUIDE.md](docs/05_WIDGETS_GUIDE.md) — 위젯 카탈로그 (위젯 생성 전 필독)
- [docs/07_DESIGN_SYSTEM_CONSTANTS.md](docs/07_DESIGN_SYSTEM_CONSTANTS.md) — 디자인 시스템 상수 전체 목록
- [docs/TOSS_UI_UX_DESIGN.md](docs/TOSS_UI_UX_DESIGN.md) — UX 원칙 & 라이팅 가이드
- `lib/core/constants/toss_design_tokens.dart` — 애니메이션 duration, curve, tap scale

---

**Last Updated:** 2026-02-24
**Version:** 4.0.0
```

**Step 3: 줄 수 확인**

Run: `wc -l CLAUDE.md`
Expected: ~120줄 (기존 187줄에서 36% 축소)

---

### Task 7: 백업 파일 정리

**Step 1: 백업 파일 제거**

```bash
rm CLAUDE.md.backup
```

**Step 2: 최종 확인**

Run: `flutter analyze`
Expected: 분석 오류 없음 (CLAUDE.md 변경은 코드에 영향 없음)

---

## Phase 3: 검증

### Task 8: 새 대화 시작하여 컨텍스트 크기 검증

**Step 1: Claude Code 새 세션 시작**

새 대화를 열고 다음을 확인:
- `~/.claude/reference/superclaude/*.md` 파일들이 시스템 프롬프트에 포함되지 않는지 확인
- `~/.claude/CLAUDE.md`만 글로벌 인스트럭션으로 로딩되는지 확인
- 프로젝트 `CLAUDE.md`가 정상 로딩되는지 확인

**Step 2: 온디맨드 접근 테스트**

새 대화에서 다음 요청:
```
~/.claude/reference/superclaude/RULES.md 파일을 읽어줘
```
Expected: 파일을 정상적으로 읽을 수 있음 (자동 로딩은 안 되지만 접근은 가능)

**Step 3: 스킬 정상 동작 확인**

새 대화에서 `/sc:help` 등 SuperClaude 커맨드가 정상 동작하는지 확인.
(스킬/커맨드는 `~/.claude/commands/`, `~/.claude/plugins/`에 있으므로 영향 없어야 함)

---

## 요약

```
                        Before       After        절감
─────────────────────────────────────────────────────
Global ~/.claude/       1,753줄      ~15줄       99%
Project CLAUDE.md         187줄     ~120줄       36%
MEMORY.md                  20줄      ~30줄        -
─────────────────────────────────────────────────────
Total auto-loaded       1,960줄     ~165줄       92%
```

## 롤백 방법

Phase 1 롤백 (SuperClaude 파일 원복):
```bash
mv ~/.claude/reference/superclaude/*.md ~/.claude/
```

Phase 2 롤백 (프로젝트 CLAUDE.md 원복):
```bash
git checkout CLAUDE.md
```

---

## 향후 개선 방향

1. **MEMORY.md 활용 강화**: 세션 간 학습 내용을 MEMORY.md에 축적하여 반복 질문 감소
2. **프로젝트별 reference**: `docs/` 디렉토리를 모듈화하여 feature별 참조 구조화
3. **온디맨드 로딩 스킬 생성**: SuperClaude reference를 자동으로 로딩하는 스킬 작성 (예: `/load-rules`)
