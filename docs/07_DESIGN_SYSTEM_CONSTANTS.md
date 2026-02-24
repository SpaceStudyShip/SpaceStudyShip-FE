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
