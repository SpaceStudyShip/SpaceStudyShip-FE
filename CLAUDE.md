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

## Architecture: Clean 3-Layer + DIP

**의존성 방향:** `Presentation → Domain ← Data` (Domain이 중심, 역방향 금지)

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

**파일 패턴:**
```
{name}_entity.dart · {name}_model.dart · {name}_repository.dart
{name}_repository_impl.dart · {name}_remote_datasource.dart · {name}_local_datasource.dart
{verb}_{name}_usecase.dart · {name}_provider.dart · {name}_screen.dart
```

> 상세: [docs/03_CODE_CONVENTIONS.md](docs/03_CODE_CONVENTIONS.md)

---

## Review Commands

| 커맨드 | 검사 항목 |
|--------|----------|
| `/review` | 범용 리뷰 (보안, 성능, 버그, 코드 품질 — 모든 프로젝트) |
| `/review-flutter` | **Flutter 종합 리뷰** — safety/design-system/architecture + 범용 리뷰를 4개 병렬 서브에이전트로 실행 |
| `/review-safety` | Dead code, runtime safety (stream/timer leak), 불필요한 리빌드 |
| `/review-design-system` | AppColors/AppSpacing/AppPadding/AppRadius/AppTextStyles 하드코딩, 공통 위젯 미사용 |
| `/review-architecture` | 아키텍처 레이어 위반, DRY, 불필요한 구조, Riverpod 패턴, 네이밍 |

---

## Key References

- [docs/05_WIDGETS_GUIDE.md](docs/05_WIDGETS_GUIDE.md) — 위젯 카탈로그 (위젯 생성 전 필독)
- [docs/07_DESIGN_SYSTEM_CONSTANTS.md](docs/07_DESIGN_SYSTEM_CONSTANTS.md) — 디자인 시스템 상수 전체 목록
- [docs/TOSS_UI_UX_DESIGN.md](docs/TOSS_UI_UX_DESIGN.md) — UX 원칙 & 라이팅 가이드
- `lib/core/constants/toss_design_tokens.dart` — 애니메이션 duration, curve, tap scale

---

**Last Updated:** 2026-02-24
**Version:** 4.0.0
