# CLAUDE.md

**Space Study Ship (우주공부선)** — 우주 탐험 테마 게이미피케이션 학습 Flutter 앱
**Stack:** Flutter 3.9+ · Riverpod 2.6 · Freezed 2.5 · Dio + Retrofit · Firebase Auth · Pretendard

---

## 절대 규칙

- **하드코딩 금지** — `AppColors`/`AppSpacing`/`AppPadding`/`AppRadius`/`AppTextStyles` 상수 필수 사용
- **SpaceBackground 필수** — 모든 Screen은 `Scaffold(backgroundColor: AppColors.spaceBackground, body: Stack([Positioned.fill(SpaceBackground()), ...]))`
- **의존성 방향** — `Presentation → Domain ← Data` (Domain 역방향 금지)
- **새 위젯 만들기 전** — `.claude/rules/05_WIDGETS_GUIDE.md` 먼저 확인
- **UI 작업 전** — `DESIGN.md` + `.claude/rules/07_DESIGN_SYSTEM_CONSTANTS.md` 로드
- **이모지 전면 금지** — 🚀✅❌⭐ 등 모든 이모지 사용 불가. 아이콘은 `font_awesome_flutter` (`FaIcon(FontAwesomeIcons.xxx)`) 또는 Material `Icons.xxx` 사용
- **커밋 메시지에 Claude 태그 절대 금지** — `Co-Authored-By: Claude`, `🤖 Generated with Claude Code`, `Claude Sonnet` 등 AI 관련 메타 태그·푸터 전면 금지

---

## Commands

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
```

---

## Rules Index (`.claude/rules/`)

| 파일 | 언제 로드 |
|------|----------|
| `00_QUICK_REFERENCE.md` | 전체 개요 |
| `01_ARCHITECTURE.md` | Clean Architecture·Provider 체인 |
| `02_FOLDER_STRUCTURE.md` | 새 feature 추가 |
| `03_CODE_CONVENTIONS.md` | 네이밍·파일 패턴 |
| `04_CODE_GENERATION_GUIDE.md` | build_runner 어노테이션 |
| `05_WIDGETS_GUIDE.md` | **위젯 생성 전 필독** |
| `06_CICD_GUIDE.md` | CI/CD 수정 |
| `07_DESIGN_SYSTEM_CONSTANTS.md` | **UI 작업 전 필독** — 상수 값 |
| `08_TIMER_ARCHITECTURE.md` | 타이머 수정 |

**기타:** `DESIGN.md` (디자인 철학·voice) · `docs/TOSS_UI_UX_DESIGN.md` (UX 라이팅) · `lib/core/constants/toss_design_tokens.dart` (애니메이션)

---

## Review Commands

`/review-flutter` (종합) · `/review-design-system` · `/review-architecture` · `/review-safety`

---

**Version:** 5.0.0 · **Updated:** 2026-04-13
</content>
</invoke>