# 타이머 Lottie 애니메이션 전환 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CustomPaint 궤도 시스템을 Lottie 애니메이션으로 교체하고, 사용자가 탭하여 애니메이션을 변경할 수 있게 한다.

**Architecture:** LottieTimerWidget이 AnimationController를 관리하고, 선택 상태는 SharedPreferences에 저장. TimerScreen에서 교체.

**Tech Stack:** Flutter · Lottie · SharedPreferences

**Design Doc:** `docs/plans/2026-03-04-lottie-timer-design.md`

---

### Task 1: LottieTimerWidget 생성

**Files:**
- Create: `lib/features/timer/presentation/widgets/lottie_timer_widget.dart`

**Step 1: 위젯 구현**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'timer_animation_selector.dart';

/// 타이머 Lottie 애니메이션 위젯
///
/// running: 애니메이션 반복 재생
/// paused: 현재 프레임 정지
/// idle: 첫 프레임 고정
/// 탭 시 애니메이션 선택 바텀시트 호출
class LottieTimerWidget extends StatefulWidget {
  const LottieTimerWidget({
    super.key,
    required this.isRunning,
    required this.isPaused,
    this.size = 260,
  });

  final bool isRunning;
  final bool isPaused;
  final double size;

  @override
  State<LottieTimerWidget> createState() => _LottieTimerWidgetState();
}

class _LottieTimerWidgetState extends State<LottieTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentAsset = TimerAnimationData.defaultAsset;

  static const _prefKey = 'timer_lottie_asset';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadSavedAsset();
  }

  Future<void> _loadSavedAsset() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && TimerAnimationData.isValidAsset(saved)) {
      setState(() => _currentAsset = saved);
    }
  }

  @override
  void didUpdateWidget(LottieTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning ||
        oldWidget.isPaused != widget.isPaused) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isRunning) {
      _controller.repeat();
    } else if (widget.isPaused) {
      _controller.stop();
    } else {
      // idle
      _controller.reset();
    }
  }

  Future<void> _onTap() async {
    final selected = await showTimerAnimationSelector(
      context: context,
      currentAsset: _currentAsset,
    );

    if (selected != null && selected != _currentAsset) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, selected);
      setState(() => _currentAsset = selected);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = widget.size.w;

    return GestureDetector(
      onTap: _onTap,
      child: SizedBox(
        width: canvasSize,
        height: canvasSize,
        child: Lottie.asset(
          _currentAsset,
          controller: _controller,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _updateAnimation();
          },
        ),
      ),
    );
  }
}
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found (timer_animation_selector.dart 미존재로 에러 가능 — Task 2에서 해결)

---

### Task 2: TimerAnimationSelector 바텀시트 생성

**Files:**
- Create: `lib/features/timer/presentation/widgets/timer_animation_selector.dart`

**Step 1: 데이터 모델 + 바텀시트 구현**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 타이머 애니메이션 데이터
class TimerAnimationData {
  const TimerAnimationData({
    required this.asset,
    required this.name,
  });

  final String asset;
  final String name;

  static const defaultAsset = 'assets/lotties/Earth_and_Connections.json';

  static const List<TimerAnimationData> animations = [
    TimerAnimationData(
      asset: 'assets/lotties/Earth_and_Connections.json',
      name: '지구와 연결',
    ),
    TimerAnimationData(
      asset: 'assets/lotties/Planet_earth_and rocket.json',
      name: '지구와 로켓',
    ),
  ];

  static bool isValidAsset(String asset) {
    return animations.any((a) => a.asset == asset);
  }
}

/// 타이머 애니메이션 선택 바텀시트
class TimerAnimationSelector extends StatelessWidget {
  const TimerAnimationSelector({
    super.key,
    required this.currentAsset,
  });

  final String currentAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // 제목
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Text(
              '타이머 애니메이션',
              style:
                  AppTextStyles.subHeading_18.copyWith(color: Colors.white),
            ),
          ),

          // 애니메이션 목록
          ...TimerAnimationData.animations.map((anim) {
            final isSelected = anim.asset == currentAsset;
            return _buildAnimationItem(context, anim, isSelected);
          }),

          // 안전 영역 여백
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
        ],
      ),
    );
  }

  Widget _buildAnimationItem(
    BuildContext context,
    TimerAnimationData anim,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(anim.asset),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        padding: AppPadding.all16,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.spaceCardDark,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(
                  color: AppColors.spaceDivider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Lottie 미리보기
            SizedBox(
              width: 64.w,
              height: 64.w,
              child: Lottie.asset(anim.asset, fit: BoxFit.contain),
            ),
            SizedBox(width: AppSpacing.s16),
            // 이름
            Expanded(
              child: Text(
                anim.name,
                style: AppTextStyles.label_16.copyWith(
                  color: isSelected ? AppColors.primary : Colors.white,
                ),
              ),
            ),
            // 선택 표시
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 24.w),
          ],
        ),
      ),
    );
  }
}

/// 타이머 애니메이션 선택 바텀시트 표시 헬퍼
Future<String?> showTimerAnimationSelector({
  required BuildContext context,
  required String currentAsset,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => TimerAnimationSelector(currentAsset: currentAsset),
  );
}
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

---

### Task 3: TimerScreen 교체

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart`

**Step 1: import 교체**

기존:
```dart
import '../widgets/orbit_timer_widget.dart';
```

변경:
```dart
import '../widgets/lottie_timer_widget.dart';
```

**Step 2: 위젯 교체**

기존:
```dart
            // 항성-행성 공전 타이머
            OrbitTimerWidget(
              elapsed: timerState.elapsed,
              isRunning: isRunning,
              isPaused: isPaused,
            ),
```

변경:
```dart
            // 타이머 Lottie 애니메이션
            LottieTimerWidget(
              isRunning: isRunning,
              isPaused: isPaused,
            ),
```

**Step 3: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

---

### Task 4: 사용하지 않는 파일 삭제

**Files:**
- Delete: `lib/features/timer/presentation/widgets/orbit_timer_widget.dart`
- Delete: `lib/features/timer/presentation/widgets/orbit_timer_painter.dart`
- Delete: `lib/features/timer/presentation/widgets/planet_painter.dart`
- Delete: `lib/features/timer/presentation/models/planet_style.dart`
- Delete: `docs/plans/2026-03-03-orbit-3d-enhancement-design.md`
- Delete: `docs/plans/2026-03-03-orbit-3d-enhancement-impl.md`

**Step 1: 삭제 전 참조 확인**

삭제 대상 파일들이 다른 곳에서 import되고 있지 않은지 확인:

Run:
```bash
grep -r "orbit_timer_widget\|orbit_timer_painter\|planet_painter\|planet_style" lib/ --include="*.dart" -l
```

Expected: timer_screen.dart만 참조 (Task 3에서 이미 교체됨), 또는 참조 없음

**Step 2: 파일 삭제**

Run:
```bash
git rm lib/features/timer/presentation/widgets/orbit_timer_widget.dart
git rm lib/features/timer/presentation/widgets/orbit_timer_painter.dart
git rm lib/features/timer/presentation/widgets/planet_painter.dart
git rm lib/features/timer/presentation/models/planet_style.dart
git rm docs/plans/2026-03-03-orbit-3d-enhancement-design.md
git rm docs/plans/2026-03-03-orbit-3d-enhancement-impl.md
```

**Step 3: models 디렉토리 정리**

Run:
```bash
rmdir lib/features/timer/presentation/models 2>/dev/null || true
```

**Step 4: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

---

### Task 5: 최종 검증

**Step 1: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 시뮬레이터 시각 검증**

확인 항목:
1. **Idle 상태**: Lottie 첫 프레임 표시
2. **Running 상태**: Lottie 애니메이션 반복 재생
3. **Paused 상태**: 현재 프레임에서 정지
4. **탭**: 바텀시트 열림, 2종 애니메이션 목록 표시
5. **선택 변경**: 다른 애니메이션으로 변경되고 앱 재시작 후에도 유지
6. **AppBar 시간**: 기존대로 정상 표시
