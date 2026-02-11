# 우주선 선택기 리디자인 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** SpaceshipCard에서 체크 아이콘 제거, 세로가 긴 직사각형 카드로 변경, 바텀시트 탑바 통일.

**Architecture:** SpaceshipCard의 레이아웃을 세로 직사각형으로 변경하고 선택 표시를 border만으로 처리. SpaceshipSelector의 Wrap을 균등 그리드로 변경. 바텀시트 탑바는 dragHandle + 제목 텍스트(아이콘 없이) 패턴으로 통일.

**Tech Stack:** Flutter, 기존 SpaceshipCard/SpaceshipSelector 위젯

---

## Task 1: SpaceshipCard 리디자인 (체크 제거 + 세로 직사각형)

**Files:**
- Modify: `lib/core/widgets/space/spaceship_card.dart:108-219`

**Step 1: 체크 아이콘 제거**

`build()` 메서드에서 lines 208-212 삭제:

```dart
// 삭제할 부분:
// 선택 체크 표시
if (widget.isSelected) ...[
  SizedBox(height: AppSpacing.s4),
  Icon(Icons.check_circle, size: 16.w, color: AppColors.primary),
],
```

선택 상태는 기존 border 색상/두께로 이미 표현되므로 체크가 불필요.

**Step 2: 카드를 세로 직사각형으로 변경**

Container의 레이아웃을 변경:

```dart
child: Container(
  width: 80.w,
  height: 110.h,
  padding: AppPadding.all12,
  decoration: BoxDecoration(
    color: AppColors.spaceSurface,
    borderRadius: AppRadius.large,
    border: Border.all(
      color: _borderColor,
      width: widget.isSelected ? 2.5 : 1.5,
    ),
    boxShadow:
        widget.isUnlocked && widget.rarity == SpaceshipRarity.legendary
        ? [
            BoxShadow(
              color: AppColors.accentGold.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
        : null,
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // 우주선 아이콘 + 애니메이션 마크
      Stack(
        alignment: Alignment.center,
        children: [
          widget.isUnlocked
              ? SpaceIcons.buildIcon(widget.icon, size: 32.w)
              : Icon(
                  SpaceIcons.resolve(widget.icon),
                  size: 32.w,
                  color: AppColors.textTertiary,
                ),
          if (!widget.isUnlocked)
            Icon(
              Icons.lock_rounded,
              size: 20.w,
              color: AppColors.textTertiary,
            ),
          if (widget.isAnimated && widget.isUnlocked)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.auto_awesome,
                size: 12.w,
                color: AppColors.accentGold,
              ),
            ),
        ],
      ),
      SizedBox(height: AppSpacing.s8),

      // 이름 + 희귀도 배지
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isUnlocked &&
              widget.rarity != SpaceshipRarity.normal)
            Container(
              width: 6.w,
              height: 6.w,
              margin: EdgeInsets.only(right: 4.w),
              decoration: BoxDecoration(
                color: _rarityBadgeColor,
                shape: BoxShape.circle,
              ),
            ),
          Flexible(
            child: Text(
              widget.isUnlocked ? widget.name : '???',
              style: AppTextStyles.tag_12.copyWith(
                color: widget.isUnlocked
                    ? Colors.white
                    : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ],
  ),
),
```

**핵심 변경점:**
- `height: 110.h` 추가 → 세로가 긴 직사각형
- `mainAxisSize: MainAxisSize.min` → `mainAxisAlignment: MainAxisAlignment.center`
- 체크 아이콘 섹션 전체 삭제

**Step 3: flutter analyze 실행**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/core/widgets/space/spaceship_card.dart
git commit -m "refactor: SpaceshipCard 세로 직사각형으로 변경 및 체크 아이콘 제거"
```

---

## Task 2: 바텀시트 탑바 통일

**Files:**
- Modify: `lib/features/home/presentation/widgets/spaceship_selector.dart:62-103` (SpaceshipSelector.build)

**Step 1: 우주선 선택기 탑바를 홈 시트와 동일한 패턴으로 변경**

현재 두 시트의 탑바 차이:

| 요소 | 오늘의 할일 시트 | 우주선 선택기 |
|------|-----------------|-------------|
| dragHandle margin | top:12, bottom:8 | top:12, bottom:0 |
| 아이콘 | 없음 | 로켓 아이콘 |
| 제목 스타일 | subHeading_18, w700 | heading_20 |
| Divider | 없음 | 있음 |

통일 방향: **오늘의 할일 시트 패턴으로 맞춤** (심플, 아이콘 없이)

SpaceshipSelector의 build 메서드에서 dragHandle + 제목 부분을 변경:

```dart
child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    // 드래그 핸들 (홈 시트와 동일)
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

    // 제목 (아이콘 없이, 홈 시트와 동일 스타일)
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Text(
            '우주선 선택',
            style: AppTextStyles.subHeading_18.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),

    // 우주선 그리드 (기존 유지)
    Flexible(
      child: SingleChildScrollView(
        ...
```

**핵심 변경점:**
- dragHandle: `margin top:12` → `margin top:12, bottom:8` (홈 시트와 동일)
- dragHandle 색상: `AppColors.spaceDivider` → `AppColors.textTertiary.withValues(alpha: 0.4)` (홈 시트와 동일)
- 제목: 로켓 아이콘 제거, `heading_20` → `subHeading_18 w700`
- 제목 패딩: `all20` → `horizontal:20, vertical:12` (홈 시트와 동일)
- `Divider` 제거

**Step 2: flutter analyze 실행**

Run: `flutter analyze`
Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/home/presentation/widgets/spaceship_selector.dart
git commit -m "style: 바텀시트 탑바 스타일 통일 (우주선 선택기 → 할일 시트 패턴)"
```

---

## 영향 범위 요약

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `spaceship_card.dart` | Modify | 체크 제거 + height 추가 + mainAxis center |
| `spaceship_selector.dart` | Modify | 탑바 dragHandle/제목/Divider 통일 |

**변경 파일 수:** 2개
**위험도:** 낮음 (UI 변경만)
