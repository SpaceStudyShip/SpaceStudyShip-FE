# Stat Chip to Top Bar Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 연료 칩을 상단 바 우측으로 이동, 경험치 칩 제거, 우주선 영역 정리

**Architecture:** `_buildTopBar()`에 연료 칩 추가, `_buildSpaceshipArea()`에서 Positioned 칩 2개 제거. HomeStatChip을 컴팩트하게 조정하여 상단 바에 맞게 배치.

**Tech Stack:** Flutter Row, HomeStatChip

---

## 현재 상태

```
상단 바 (_buildTopBar):
  Row: [ StreakBadge | Spacer | 🔔 알림 ]

우주선 영역 (_buildSpaceshipArea):
  Stack:
    ├─ Center: SpaceshipAvatar(200) + 이름 + 변경하기
    ├─ Positioned(left): HomeStatChip(연료)        ← 제거
    └─ Positioned(right): HomeStatChip(경험치)     ← 제거
```

## 목표 상태

```
상단 바 (_buildTopBar):
  Row: [ StreakBadge | Spacer | HomeStatChip(연료) | SizedBox(8) | 🔔 알림 ]

우주선 영역 (_buildSpaceshipArea):
  Center: SpaceshipAvatar(200) + 이름 + 변경하기
  (Positioned 칩 없음 — 깔끔한 우주선 영역)
```

---

### Task 1: 상단 바에 연료 칩 추가 + 우주선 영역 칩 제거

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

**Step 1: `_buildTopBar()`에 연료 칩 추가**

Spacer 뒤, 알림 아이콘 앞에 연료 칩 삽입:

```dart
// Before:
Widget _buildTopBar() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    child: Row(
      children: [
        if (_streakDays > 0)
          FadeSlideIn(
            child: StreakBadge(...),
          ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.notifications_outlined, ...),
          onPressed: () {},
        ),
      ],
    ),
  );
}

// After:
Widget _buildTopBar() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    child: Row(
      children: [
        if (_streakDays > 0)
          FadeSlideIn(
            child: StreakBadge(...),
          ),
        const Spacer(),
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: HomeStatChip(
            iconData: Icons.local_gas_station_rounded,
            value: _fuel.toStringAsFixed(0),
            label: '연료',
            valueColor: _fuelColor,
          ),
        ),
        SizedBox(width: AppSpacing.s8),
        IconButton(
          icon: Icon(Icons.notifications_outlined, ...),
          onPressed: () {},
        ),
      ],
    ),
  );
}
```

**Step 2: `_buildSpaceshipArea()`에서 Positioned 칩 2개 제거**

연료 칩 Positioned, 경험치 칩 Positioned 블록을 삭제. Stack은 우주선만 남기거나, Stack 자체를 Center로 변경 가능:

```dart
// Before:
Widget _buildSpaceshipArea() {
  return Stack(
    alignment: Alignment.center,
    children: [
      // 우주선 + 이름 + 변경하기
      GestureDetector(...),

      // 연료 칩 (좌측) — 삭제
      Positioned(
        left: 16.w,
        top: 60.h,
        child: FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: HomeStatChip(...연료...),
        ),
      ),

      // 경험치 칩 (우측) — 삭제
      Positioned(
        right: 16.w,
        top: 60.h,
        child: FadeSlideIn(
          delay: const Duration(milliseconds: 300),
          child: HomeStatChip(...경험치...),
        ),
      ),
    ],
  );
}

// After (Stack → Center로 단순화):
Widget _buildSpaceshipArea() {
  return Center(
    child: GestureDetector(
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
  );
}
```

**Step 3: 사용하지 않는 코드 정리**

- `_formattedExperience` getter 삭제 (경험치 칩 제거됨)
- `_experience` 필드 삭제

**Step 4: Verify**

Run: `flutter analyze`

---

### Task 2: 시각적 검증

**Step 1: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 확인 포인트**

앱 실행하여 확인:
- 상단 바: 스트릭 배지(좌) | 연료 칩 + 알림(우) 배치
- 연료 칩이 상단 바 높이에 잘 맞는지
- 우주선 영역이 깔끔하게 우주선+이름만 있는지
- 나중에 재화 칩 추가 시 연료 칩 왼쪽에 넣으면 됨

**조정 가이드 (필요 시):**
- 연료 칩이 상단 바에서 너무 크면: HomeStatChip의 padding/fontSize 조정
- 칩 간격 조정: `SizedBox(width: AppSpacing.s8)` 값 변경

---

### Summary of Changes

| File | Change | Reason |
|------|--------|--------|
| `home_screen.dart` | 연료 칩을 `_buildTopBar()`으로 이동 | 게이미피케이션 패턴 (상단 재화 표시) |
| `home_screen.dart` | 경험치 칩 제거 | 존재하지 않는 기능 |
| `home_screen.dart` | `_buildSpaceshipArea()` Stack→Center 단순화 | 칩 제거로 Stack 불필요 |
| `home_screen.dart` | `_experience`, `_formattedExperience` 삭제 | 사용처 없음 |

**Total: 1 file modified**
