# 우주선 아바타 정리 및 바텀시트 개선 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 홈 화면 우주선 크기를 키우고, 원형 배경/글로우를 제거하여 콘텐츠(Lottie/아이콘)만 표시하며, 우주선 선택 바텀시트를 외부 탭으로 닫을 수 있게 한다.

**Architecture:** SpaceshipAvatar를 StatelessWidget으로 단순화하고 glow/circle 렌더링을 제거한다. showSpaceshipSelector에서 DraggableScrollableSheet 래핑을 제거하여 showModalBottomSheet의 기본 barrier dismiss가 작동하도록 한다.

**Tech Stack:** Flutter, Lottie, 기존 SpaceshipAvatar/SpaceshipSelector 위젯

---

## Task 1: SpaceshipAvatar 단순화 (글로우/원형 제거 + 크기 키우기)

**Files:**
- Modify: `lib/core/widgets/space/spaceship_avatar.dart` (전면 재작성)
- Modify: `lib/features/home/presentation/screens/home_screen.dart:252-256` (size 변경)

**Step 1: SpaceshipAvatar를 StatelessWidget으로 단순화**

`lib/core/widgets/space/spaceship_avatar.dart` 전체를 다음으로 교체:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../constants/space_icons.dart';

/// 우주선 아바타 위젯
///
/// lottieAsset이 제공되면 Lottie 애니메이션, 아니면 아이콘만 표시.
/// 원형 배경/글로우 없이 콘텐츠만 렌더링.
class SpaceshipAvatar extends StatelessWidget {
  const SpaceshipAvatar({
    super.key,
    required this.icon,
    this.size = 120,
    this.lottieAsset,
  });

  /// 우주선 이모지/아이콘 키
  final String icon;

  /// 전체 크기 (기본 120)
  final double size;

  /// Lottie 에셋 경로 (null이면 아이콘 표시)
  final String? lottieAsset;

  @override
  Widget build(BuildContext context) {
    if (lottieAsset != null) {
      return SizedBox(
        width: size.w,
        height: size.w,
        child: Lottie.asset(
          lottieAsset!,
          fit: BoxFit.contain,
        ),
      );
    }

    // Lottie 없을 때: 아이콘만 표시 (원형 배경 없이)
    final gradient = SpaceIcons.gradientOf(icon);
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ).createShader(bounds),
          child: Icon(
            SpaceIcons.resolve(icon),
            size: (size * 0.6).sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

**핵심 변경점:**
- `StatefulWidget` → `StatelessWidget` (AnimationController 불필요)
- `showGlow` 파라미터 제거
- glow Container/AnimatedBuilder 전부 제거
- `GradientCircleIcon` import/사용 제거 → ShaderMask + Icon으로 직접 렌더링
- Lottie 경로: SizedBox + Lottie.asset()만
- 아이콘 경로: SizedBox + ShaderMask + Icon만 (원형 배경 없음)

**Step 2: HomeScreen에서 size 200 → 280으로 변경**

`home_screen.dart` 252-256번 줄:

```dart
// Before:
SpaceshipAvatar(
  icon: _selectedSpaceshipIcon,
  size: 200,
  lottieAsset: _selectedLottieAsset,
),

// After:
SpaceshipAvatar(
  icon: _selectedSpaceshipIcon,
  size: 280,
  lottieAsset: _selectedLottieAsset,
),
```

**Step 3: flutter analyze 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/space_study_ship && flutter analyze`
Expected: `No issues found!`

**Step 4: Commit**

```bash
git add lib/core/widgets/space/spaceship_avatar.dart lib/features/home/presentation/screens/home_screen.dart
git commit -m "refactor: SpaceshipAvatar 단순화 - 글로우/원형 제거, 크기 280으로 확대"
```

---

## Task 2: 우주선 선택 바텀시트 외부 탭 닫기

**Files:**
- Modify: `lib/features/home/presentation/widgets/spaceship_selector.dart:142-166` (showSpaceshipSelector 함수)

**Step 1: showSpaceshipSelector에서 DraggableScrollableSheet 제거**

현재 `showModalBottomSheet` 안에 `DraggableScrollableSheet`를 중첩 사용하고 있어 barrier 영역의 탭 이벤트가 차단될 수 있다. `DraggableScrollableSheet`를 제거하고 `SpaceshipSelector`를 직접 렌더링한다.

```dart
/// 우주선 선택 바텀시트 표시 헬퍼
Future<void> showSpaceshipSelector({
  required BuildContext context,
  required List<SpaceshipData> spaceships,
  required String selectedId,
  required ValueChanged<String> onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => SpaceshipSelector(
      spaceships: spaceships,
      selectedId: selectedId,
      onSelect: onSelect,
    ),
  );
}
```

**핵심 변경점:**
- `DraggableScrollableSheet` 래핑 제거 → `SpaceshipSelector` 직접 반환
- `isDismissible: true` 명시적 추가
- `enableDrag: true` 명시적 추가
- `SpaceshipSelector`는 이미 `Column(mainAxisSize: MainAxisSize.min)` + `Flexible`로 자체 크기 조절

**Step 2: flutter analyze 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/space_study_ship && flutter analyze`
Expected: `No issues found!`

**Step 3: Commit**

```bash
git add lib/features/home/presentation/widgets/spaceship_selector.dart
git commit -m "fix: 우주선 선택 바텀시트 외부 탭으로 닫기 가능하도록 수정"
```

---

## 영향 범위 요약

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `spaceship_avatar.dart` | 전면 재작성 | StatelessWidget으로 단순화, 글로우/원형 제거 |
| `home_screen.dart` | 1줄 수정 | size 200 → 280 |
| `spaceship_selector.dart` | 함수 수정 | DraggableScrollableSheet 제거 |

**변경 파일 수:** 3개
**위험도:** 낮음 (UI 변경만, 로직 불변)

**주의:** `SpaceshipAvatar`의 `showGlow` 파라미터가 제거된다. 다른 파일에서 `showGlow`를 사용하는 곳이 없는지 확인 필요. (현재 HomeScreen에서만 사용하며, `showGlow`를 명시적으로 전달하는 곳 없음 — 기본값만 사용)
