# Home UI Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 홈 화면을 듀오링고 스타일로 재설계 — 우주선을 화면 중앙에 크게 배치하고, 연료/경험치 칩을 주변에 떠있게 하고, 할 일/활동 카드는 하단 시트로 이동

**Architecture:** SliverAppBar + CustomScrollView 구조를 제거하고, Stack 기반 레이아웃으로 전환. SpaceshipAvatar(200)를 중앙에 배치, HomeStatChip을 Positioned로 주변에 떠있게 배치. 하단에 DraggableScrollableSheet로 할 일/활동 카드 제공.

**Tech Stack:** Flutter Stack, Positioned, DraggableScrollableSheet, SpaceshipAvatar

---

## 현재 구조

```
Scaffold
  └─ CustomScrollView
       ├─ SliverAppBar (320.h) + SpaceshipHeader
       │    ├─ cosmicHeader 그라데이션 배경
       │    ├─ StreakBadge
       │    ├─ SpaceshipAvatar(120) + 이름 + "변경하기"
       │    └─ HomeStatChip x2 (연료, 경험치)
       ├─ 오늘의 할 일 카드
       └─ 최근 활동 카드
```

## 목표 구조

```
Scaffold
  └─ Stack
       ├─ SafeArea + Column (메인 콘텐츠)
       │    ├─ 상단 바: 스트릭 배지 + 알림 아이콘
       │    ├─ Expanded (우주선 영역)
       │    │    └─ Stack
       │    │         ├─ Center: SpaceshipAvatar(200) + 이름 + "변경하기"
       │    │         ├─ Positioned: 연료 칩 (좌측)
       │    │         └─ Positioned: 경험치 칩 (우측)
       │    └─ 바텀 여백
       └─ DraggableScrollableSheet
            └─ 할 일 + 활동 카드
```

---

### Task 1: home_screen.dart 레이아웃 전환 (SliverAppBar → Stack)

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: build() 메서드 전체 교체**

기존 CustomScrollView + SliverAppBar 구조를 Stack 기반으로 교체:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    extendBody: true,
    body: Stack(
      children: [
        // 메인 콘텐츠
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 상단 바
              _buildTopBar(),

              // 우주선 영역 (화면 중앙)
              Expanded(
                child: _buildSpaceshipArea(),
              ),

              // 하단 시트 위 여백
              SizedBox(height: 80.h),
            ],
          ),
        ),

        // 하단 시트
        _buildBottomSheet(),
      ],
    ),
  );
}
```

**Step 2: _buildTopBar() 작성**

스트릭 배지 (좌) + 알림 아이콘 (우):

```dart
Widget _buildTopBar() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    child: Row(
      children: [
        if (_streakDays > 0)
          FadeSlideIn(
            child: StreakBadge(
              days: _streakDays,
              isActive: _isStreakActive,
              showLabel: true,
              size: StreakBadgeSize.medium,
            ),
          ),
        const Spacer(),
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24.w,
          ),
          onPressed: () {
            // TODO: 알림 화면
          },
        ),
      ],
    ),
  );
}
```

**Step 3: _buildSpaceshipArea() 작성**

우주선 중앙 + 연료/경험치 칩 주변 떠있는 배치:

```dart
Widget _buildSpaceshipArea() {
  return Stack(
    alignment: Alignment.center,
    children: [
      // 우주선 + 이름 + 변경하기 (중앙)
      GestureDetector(
        onTapDown: (_) => setState(() => _isSpaceshipPressed = true),
        onTapUp: (_) {
          setState(() => _isSpaceshipPressed = false);
          _showSpaceshipSelector();
        },
        onTapCancel: () => setState(() => _isSpaceshipPressed = false),
        child: AnimatedScale(
          scale: _isSpaceshipPressed
              ? TossDesignTokens.buttonTapScale
              : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: FadeSlideIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpaceshipAvatar(
                  icon: _selectedSpaceshipIcon,
                  size: 200,
                ),
                SizedBox(height: AppSpacing.s16),
                Text(
                  _selectedSpaceshipName,
                  style: AppTextStyles.heading_20.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.s4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '변경하기',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.chevron_right,
                      size: 14.w,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // 연료 칩 (좌측)
      Positioned(
        left: 16.w,
        top: 60.h,
        child: FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: HomeStatChip(
            iconData: Icons.local_gas_station_rounded,
            value: _fuel.toStringAsFixed(0),
            label: '연료',
            valueColor: _fuelColor,
          ),
        ),
      ),

      // 경험치 칩 (우측)
      Positioned(
        right: 16.w,
        top: 60.h,
        child: FadeSlideIn(
          delay: const Duration(milliseconds: 300),
          child: HomeStatChip(
            iconData: Icons.star_rounded,
            value: _formattedExperience,
            label: '경험치',
            valueColor: AppColors.accentGold,
          ),
        ),
      ),
    ],
  );
}
```

**Step 4: _buildBottomSheet() 작성**

DraggableScrollableSheet으로 하단 시트:

```dart
Widget _buildBottomSheet() {
  return DraggableScrollableSheet(
    initialChildSize: 0.12,
    minChildSize: 0.12,
    maxChildSize: 0.6,
    snap: true,
    snapSizes: const [0.12, 0.4, 0.6],
    builder: (context, scrollController) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.spaceSurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            // 드래그 핸들
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // 섹션 제목
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
              child: _buildSectionTitle('오늘의 할 일'),
            ),
            Padding(
              padding: AppPadding.horizontal20,
              child: _buildEmptyTodoCard(),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
              child: _buildSectionTitle('최근 활동'),
            ),
            Padding(
              padding: AppPadding.horizontal20,
              child: _buildEmptyActivityCard(),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      );
    },
  );
}
```

**Step 5: 불필요한 코드 정리**

- `_buildCollapsedTitle()` 메서드 삭제 (SliverAppBar 없으므로)
- `_isSpaceshipPressed` 상태 변수 추가
- `_fuelColor`, `_formattedExperience` getter는 기존 spaceship_header.dart에서 이동
- import 정리: `SpaceshipHeader` 제거, 필요한 import 추가

**Step 6: Verify**

Run: `flutter analyze`

---

### Task 2: spaceship_header.dart의 로직을 home_screen.dart로 이동

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: home_screen.dart에 필요한 import 및 상태 추가**

spaceship_header.dart에서 사용하던 것들을 home_screen.dart로 이동:

```dart
// 추가 import
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/widgets/space/spaceship_avatar.dart';
import '../../../../core/widgets/space/streak_badge.dart';
import '../widgets/home_stat_chip.dart';

// State에 추가
bool _isSpaceshipPressed = false;

Color get _fuelColor {
  if (_fuel >= 75) return AppColors.fuelFull;
  if (_fuel >= 50) return AppColors.fuelMedium;
  if (_fuel >= 25) return AppColors.fuelLow;
  return AppColors.fuelEmpty;
}

String get _formattedExperience {
  if (_experience >= 1000) {
    final thousands = _experience ~/ 1000;
    final remainder = _experience % 1000;
    return '$thousands,${remainder.toString().padLeft(3, '0')}';
  }
  return _experience.toString();
}
```

**Step 2: 사용하지 않는 import 제거**

```dart
// 제거
import '../widgets/spaceship_header.dart';
```

**Step 3: Verify**

Run: `flutter analyze`

---

### Task 3: 시각적 검증 및 미세 조정

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 위치 조정 가이드**

앱 실행하여 확인할 사항:
- SpaceshipAvatar(200)가 화면 중앙에 적절한 크기인지
- 연료/경험치 칩이 우주선과 겹치지 않는지
- 하단 시트 초기 상태(12%)가 자연스러운지
- 하단 시트 드래그가 부드러운지
- SpaceBackground 별이 우주선 뒤에 잘 보이는지

Positioned 값 조정이 필요할 수 있음:
- 칩 위치: `left/right: 16.w`, `top: 60.h` — 기기별로 확인
- 하단 시트 snapSizes — 콘텐츠 양에 따라 조정

---

### Summary of Changes

| File | Change | Reason |
|------|--------|--------|
| `home_screen.dart` | SliverAppBar+CustomScrollView → Stack 기반 레이아웃 | 우주선 중앙 배치 |
| `home_screen.dart` | SpaceshipAvatar 120 → 200 | 크기 확대 |
| `home_screen.dart` | HomeStatChip을 Positioned로 우주선 주변 배치 | 떠있는 우주 느낌 |
| `home_screen.dart` | DraggableScrollableSheet 추가 | 할 일/활동 하단 시트 |
| `home_screen.dart` | SpaceshipHeader 로직 인라인 이동 | 헤더 위젯 의존성 제거 |
| `spaceship_header.dart` | 변경 없음 (다른 곳에서 사용 가능) | 재사용 가능하게 유지 |

**Total: 1 file modified**
**spaceship_header.dart는 삭제하지 않음 — 다른 곳에서 재사용 가능성 유지**
