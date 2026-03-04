# 항성-행성 공전 타이머 UI 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 타이머 화면의 원형 프로그레스 링을 항성-행성 공전 시스템으로 교체하여 우주 테마 시각적 몰입감을 극대화한다.

**Architecture:** CustomPaint 기반 렌더링. `PlanetPainter`가 그라데이션 구체를 그리고, `OrbitTimerPainter`가 궤도 경로·글로우·꼬리를 그린다. `OrbitTimerWidget`이 이들을 조합하고 AnimationController 2개(행성 공전, 항성 pulse)로 상태별 애니메이션을 관리한다. 기존 `timer_screen.dart`의 260×260 TimerRingPainter 영역만 교체하며 버튼·통계 카드·AppBar는 변경 없음.

**Tech Stack:** Flutter CustomPaint · AnimationController · flutter_screenutil · Riverpod (기존 TimerNotifier 재사용)

**Design Doc:** `docs/plans/2026-03-03-orbit-timer-design.md`

---

### Task 1: PlanetStyle 데이터 클래스

**Files:**
- Create: `lib/features/timer/presentation/models/planet_style.dart`

**Step 1: PlanetStyle 클래스 생성**

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 행성/항성의 시각적 스타일 정의
///
/// 향후 탐험 시스템에서 해금한 행성별 커스텀 스타일 매핑에 사용.
class PlanetStyle {
  const PlanetStyle({
    required this.baseColor,
    required this.highlightColor,
    required this.shadowColor,
    this.glowColor,
  });

  /// 구체의 기본 색상 (그라데이션 중간)
  final Color baseColor;

  /// 하이라이트 색상 (좌상단 광원 반사)
  final Color highlightColor;

  /// 그림자 색상 (우하단 어둠)
  final Color shadowColor;

  /// 외곽 글로우 색상 (null이면 baseColor 20% opacity 사용)
  final Color? glowColor;

  /// 기본 항성 스타일 (태양 — 골드 계열)
  static const star = PlanetStyle(
    baseColor: AppColors.accentGold,
    highlightColor: AppColors.accentGoldLight,
    shadowColor: AppColors.accentGoldDark,
  );

  /// 기본 행성 스타일 (파란 행성 — primary 계열)
  static const planet = PlanetStyle(
    baseColor: AppColors.primary,
    highlightColor: AppColors.primaryLight,
    shadowColor: AppColors.primaryDark,
  );
}
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/models/planet_style.dart
git commit -m "feat: PlanetStyle 데이터 클래스 추가 #46"
```

---

### Task 2: PlanetPainter — 그라데이션 구체 렌더링

**Files:**
- Create: `lib/features/timer/presentation/widgets/planet_painter.dart`

**Ref:** 디자인 문서 "렌더링: CustomPaint 그라데이션 구체" 섹션

**Step 1: PlanetPainter 구현**

RadialGradient로 3D 느낌의 구체를 그리는 CustomPainter. 외곽 글로우(blur filter) 옵션 포함.

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/planet_style.dart';

/// 그라데이션 구체를 렌더링하는 CustomPainter
///
/// [PlanetStyle]의 3색 그라데이션으로 3D 구체 효과를 표현.
/// 좌상단 하이라이트 + 우하단 그림자로 광원 방향을 시뮬레이션.
class PlanetPainter extends CustomPainter {
  PlanetPainter({
    required this.style,
    this.showGlow = false,
    this.glowIntensity = 0.2,
  });

  /// 구체 색상 스타일
  final PlanetStyle style;

  /// 외곽 글로우 표시 여부
  final bool showGlow;

  /// 글로우 강도 (0.0 ~ 1.0)
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 외곽 글로우 (항성 pulse 등에 사용)
    if (showGlow && glowIntensity > 0) {
      final glowColor = style.glowColor ?? style.baseColor;
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: glowIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6);
      canvas.drawCircle(center, radius * 1.3, glowPaint);
    }

    // 3D 그라데이션 구체
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3), // 좌상단 하이라이트
        radius: 0.9,
        colors: [
          style.highlightColor,
          style.baseColor,
          style.shadowColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, spherePaint);
  }

  @override
  bool shouldRepaint(PlanetPainter oldDelegate) {
    return oldDelegate.showGlow != showGlow ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.style != style;
  }
}
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/widgets/planet_painter.dart
git commit -m "feat: PlanetPainter 그라데이션 구체 렌더링 추가 #46"
```

---

### Task 3: OrbitTimerPainter — 궤도 경로 + 진행 글로우 + 꼬리

**Files:**
- Create: `lib/features/timer/presentation/widgets/orbit_timer_painter.dart`

**Ref:** 디자인 문서 "pseudo-3D 궤도 시스템", "상태별 시각 변화" 섹션

**Step 1: OrbitTimerPainter 구현**

궤도 경로(타원/원)와 진행 구간 글로우, 행성 꼬리를 그리는 CustomPainter.

```dart
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 궤도 경로 + 진행 글로우 + 꼬리를 그리는 CustomPainter
///
/// [tilt]: 궤도 기울기 (0 = 완전한 원, pi/4 = 최대 타원)
/// [progress]: 행성 공전 진행률 (0.0 ~ 1.0, 30분 = 1.0)
/// [isRunning]: 실행 중 여부 (글로우 + 꼬리 표시)
/// [isPaused]: 일시정지 여부 (주황색 궤도)
class OrbitTimerPainter extends CustomPainter {
  OrbitTimerPainter({
    required this.progress,
    required this.tilt,
    this.isRunning = false,
    this.isPaused = false,
    this.orbitStrokeWidth = 1.5,
  });

  final double progress;
  final double tilt;
  final bool isRunning;
  final bool isPaused;
  final double orbitStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2 * 0.85;
    final radiusY = radiusX * cos(tilt); // Y축 압축 = 타원 효과

    _drawOrbitPath(canvas, center, radiusX, radiusY);

    if (isRunning && progress > 0) {
      _drawProgressGlow(canvas, center, radiusX, radiusY);
      _drawTail(canvas, center, radiusX, radiusY);
    }
  }

  /// 궤도 경로 (점선/실선)
  void _drawOrbitPath(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
  ) {
    final Color orbitColor;
    if (isRunning) {
      orbitColor = AppColors.primary;
    } else if (isPaused) {
      orbitColor = AppColors.timerPaused;
    } else {
      orbitColor = AppColors.spaceDivider;
    }

    final paint = Paint()
      ..color = orbitColor.withValues(alpha: isRunning ? 0.6 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = orbitStrokeWidth;

    // 타원 경로
    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    if (!isRunning && !isPaused) {
      // idle: 점선 효과 — 짧은 arc 여러 개
      const segments = 36;
      const gapRatio = 0.4;
      final segmentAngle = 2 * pi / segments;
      for (var i = 0; i < segments; i++) {
        final startAngle = i * segmentAngle;
        final sweepAngle = segmentAngle * (1 - gapRatio);
        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      }
    } else {
      // running/paused: 실선
      canvas.drawOval(rect, paint);
    }
  }

  /// 진행 구간 글로우 (running 상태)
  void _drawProgressGlow(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
  ) {
    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = orbitStrokeWidth * 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // 12시 방향(-pi/2)부터 진행률만큼
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, glowPaint);

    // 진행 arc (밝은 선)
    final progressPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = orbitStrokeWidth * 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  /// 행성 뒤 꼬리 (~20° 그라데이션 arc)
  void _drawTail(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
  ) {
    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    // 행성 현재 각도
    final angle = -pi / 2 + 2 * pi * progress;
    // 꼬리: 행성 뒤 20°
    const tailSweep = 20 * pi / 180;
    final tailStart = angle - tailSweep;

    // 3단계 그라데이션 꼬리 (진한 → 투명)
    for (var i = 0; i < 3; i++) {
      final alpha = 0.3 - i * 0.1;
      final width = orbitStrokeWidth * (3 - i);
      final tailPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: alpha.clamp(0.05, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, tailStart, tailSweep, false, tailPaint);
    }
  }

  @override
  bool shouldRepaint(OrbitTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tilt != tilt ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.isPaused != isPaused;
  }
}
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/widgets/orbit_timer_painter.dart
git commit -m "feat: OrbitTimerPainter 궤도 경로·글로우·꼬리 렌더링 추가 #46"
```

---

### Task 4: OrbitTimerWidget — 전체 조합 위젯

**Files:**
- Create: `lib/features/timer/presentation/widgets/orbit_timer_widget.dart`

**Ref:** 디자인 문서 "pseudo-3D 궤도 시스템", "상태별 시각 변화", "성능 고려" 섹션

이 위젯이 핵심. 항성 + 행성 + 궤도 + 시간 텍스트 + 상태 텍스트를 조합하고, AnimationController 2개로 애니메이션 관리.

**Step 1: OrbitTimerWidget 구현**

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../models/planet_style.dart';
import 'orbit_timer_painter.dart';
import 'planet_painter.dart';

/// 항성-행성 공전 타이머 위젯
///
/// 중앙 항성 + 궤도 + 공전 행성 + 시간 텍스트로 구성.
/// AnimationController 2개:
/// - [_orbitController]: 행성 공전 (UI 틱 기반, 연속 회전)
/// - [_pulseController]: 항성 글로우 pulse (3초 주기)
///
/// **공전 주기:** 30분 = 1바퀴 (연료 시스템과 동기화)
/// **pseudo-3D:** 30분 1사이클로 tilt가 0°→45°→0° 변화
class OrbitTimerWidget extends StatefulWidget {
  const OrbitTimerWidget({
    super.key,
    required this.elapsed,
    required this.isRunning,
    required this.isPaused,
    required this.timeText,
    required this.statusWidget,
    this.size = 260,
    this.starStyle = PlanetStyle.star,
    this.planetStyle = PlanetStyle.planet,
  });

  /// 경과 시간
  final Duration elapsed;

  /// 실행 중 여부
  final bool isRunning;

  /// 일시정지 여부
  final bool isPaused;

  /// HH:MM:SS 텍스트
  final String timeText;

  /// 상태 텍스트 위젯 (연동 할일 or "집중 중...")
  final Widget statusWidget;

  /// 위젯 크기 (정사각형, ScreenUtil 적용 전)
  final double size;

  /// 항성 스타일
  final PlanetStyle starStyle;

  /// 행성 스타일
  final PlanetStyle planetStyle;

  @override
  State<OrbitTimerWidget> createState() => _OrbitTimerWidgetState();
}

class _OrbitTimerWidgetState extends State<OrbitTimerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

  /// 행성 깜박임 (paused 상태)
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();

    // 행성 공전 애니메이션 — 60초 주기로 연속 회전
    // 실제 위치는 elapsed 기반 계산이므로 이 컨트롤러는 repaint 트리거 용도
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );

    // 항성 pulse 글로우 (3초 주기)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 행성 깜박임 (1초 주기, paused 상태)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _updateAnimations();
  }

  @override
  void didUpdateWidget(OrbitTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning ||
        oldWidget.isPaused != widget.isPaused) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isRunning) {
      _orbitController.repeat();
      _pulseController.repeat(reverse: true);
      _blinkController.stop();
      _blinkController.value = 1.0;
    } else if (widget.isPaused) {
      _orbitController.stop();
      _pulseController.stop();
      _blinkController.repeat(reverse: true);
    } else {
      // idle
      _orbitController.stop();
      _pulseController.stop();
      _blinkController.stop();
      _blinkController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  /// 30분 = 1바퀴 공전 진행률
  double get _orbitProgress {
    const thirtyMinSeconds = 1800;
    return (widget.elapsed.inSeconds % thirtyMinSeconds) / thirtyMinSeconds;
  }

  /// pseudo-3D 기울기: 30분 1사이클, 0°→45°→0°
  double get _tilt {
    const thirtyMinSeconds = 1800;
    final cycleProgress =
        (widget.elapsed.inSeconds % thirtyMinSeconds) / thirtyMinSeconds;
    // sin(0→2π)로 0→1→0→-1→0 → abs로 0→1→0→1→0
    // 하지만 디자인: 0분=0°, 15분=45°, 30분=0° → sin(progress * pi) 사용
    return (pi / 4) * sin(cycleProgress * pi);
  }

  /// 행성 위치 계산 (타원 궤도 위의 x, y 좌표)
  Offset _planetPosition(double canvasSize) {
    final angle = -pi / 2 + 2 * pi * _orbitProgress; // 12시 방향 시작
    final orbitRadius = canvasSize / 2 * 0.85;
    final radiusY = orbitRadius * cos(_tilt);

    final x = canvasSize / 2 + orbitRadius * cos(angle);
    final y = canvasSize / 2 + radiusY * sin(angle);
    return Offset(x, y);
  }

  /// 행성 원근 스케일 (앞=크게, 뒤=작게)
  double get _planetScale {
    final angle = -pi / 2 + 2 * pi * _orbitProgress;
    final depthFactor = sin(angle); // -1(뒤) ~ +1(앞)
    return 1.0 + 0.2 * depthFactor * sin(_tilt);
  }

  /// 행성 원근 투명도
  double get _planetOpacity {
    final angle = -pi / 2 + 2 * pi * _orbitProgress;
    final depthFactor = sin(angle);
    return 0.7 + 0.3 * (depthFactor + 1) / 2;
  }

  /// 행성이 항성 앞에 있는지 (Z-order)
  bool get _planetInFront {
    final angle = -pi / 2 + 2 * pi * _orbitProgress;
    return sin(angle) > 0;
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = widget.size.w;
    final starSize = 60.w;
    final basePlanetSize = 20.w;

    return RepaintBoundary(
      child: SizedBox(
        width: canvasSize,
        height: canvasSize,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _orbitController,
            _pulseController,
            _blinkController,
          ]),
          builder: (context, child) {
            final planetPos = _planetPosition(canvasSize);
            final planetScale = _planetScale;
            final planetOpacity = _planetOpacity;
            final planetInFront = _planetInFront;
            final scaledPlanetSize = basePlanetSize * planetScale;

            // 항성 글로우 강도 (running: 0.15~0.25 pulse, idle: 0.15 고정)
            final glowIntensity = widget.isRunning
                ? 0.15 + 0.1 * _pulseController.value
                : 0.15;

            // 행성 불투명도 (paused: 깜박임)
            final effectivePlanetOpacity = widget.isPaused
                ? 0.3 + 0.7 * _blinkController.value
                : planetOpacity;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 궤도 경로
                Positioned.fill(
                  child: CustomPaint(
                    painter: OrbitTimerPainter(
                      progress: _orbitProgress,
                      tilt: _tilt,
                      isRunning: widget.isRunning,
                      isPaused: widget.isPaused,
                    ),
                  ),
                ),

                // 행성 (뒤쪽 — 항성 뒤에 그려짐)
                if (!planetInFront)
                  _buildPlanet(
                    planetPos,
                    scaledPlanetSize,
                    effectivePlanetOpacity,
                  ),

                // 항성 (중앙)
                Positioned(
                  left: (canvasSize - starSize) / 2,
                  top: (canvasSize - starSize) / 2,
                  child: SizedBox(
                    width: starSize,
                    height: starSize,
                    child: CustomPaint(
                      painter: PlanetPainter(
                        style: widget.starStyle,
                        showGlow: true,
                        glowIntensity: glowIntensity,
                      ),
                    ),
                  ),
                ),

                // 행성 (앞쪽 — 항성 앞에 그려짐)
                if (planetInFront)
                  _buildPlanet(
                    planetPos,
                    scaledPlanetSize,
                    effectivePlanetOpacity,
                  ),

                // 시간 텍스트 + 상태 텍스트 (항성 아래)
                child!,
              ],
            );
          },
          child: _buildTextOverlay(canvasSize, starSize),
        ),
      ),
    );
  }

  Widget _buildPlanet(
    Offset position,
    double size,
    double opacity,
  ) {
    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: PlanetPainter(
              style: widget.planetStyle,
              showGlow: widget.isRunning,
              glowIntensity: widget.isRunning ? 0.15 : 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextOverlay(double canvasSize, double starSize) {
    // 텍스트를 항성 바로 아래에 배치
    final textTop = (canvasSize + starSize) / 2 + AppSpacing.s4;

    return Positioned(
      left: 0,
      right: 0,
      top: textTop,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.timeText,
              style: AppTextStyles.timer_48.copyWith(
                color:
                    widget.isRunning ? AppColors.primary : Colors.white,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          widget.statusWidget,
        ],
      ),
    );
  }
}
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/widgets/orbit_timer_widget.dart
git commit -m "feat: OrbitTimerWidget 항성-행성 공전 조합 위젯 추가 #46"
```

---

### Task 5: TimerScreen 통합 — TimerRingPainter → OrbitTimerWidget 교체

**Files:**
- Modify: `lib/features/timer/presentation/screens/timer_screen.dart`

**Ref:** 디자인 문서 "레이아웃" 섹션, `timer_screen.dart` 전체

**핵심:** 기존 `SizedBox(260×260)` 영역의 `Stack(TimerRingPainter + Text)` 블록을 `OrbitTimerWidget`으로 교체. 버튼·통계 카드·AppBar 코드는 변경 없음.

**Step 1: import 교체**

기존 `timer_ring_painter.dart` import를 `orbit_timer_widget.dart`로 교체:

```dart
// 제거:
// import '../widgets/timer_ring_painter.dart';

// 추가:
import '../widgets/orbit_timer_widget.dart';
```

**Step 2: 타이머 영역 교체**

기존 코드 (line 63~101):
```dart
            // 타이머 링 + 시간 표시
            SizedBox(
              width: 260.w,
              height: 260.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(260.w, 260.w),
                    painter: TimerRingPainter(
                      progress: _calculateProgress(timerState.elapsed),
                      isRunning: isRunning,
                      strokeWidth: 6.w,
                    ),
                  ),
                  Padding(
                    padding: AppPadding.horizontal16,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(timerState.elapsed),
                            style: AppTextStyles.timer_48.copyWith(
                              color: isRunning
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                          SizedBox(height: AppSpacing.s4),
                          _buildStatusText(timerState, isIdle, isRunning),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
```

교체 후:
```dart
            // 항성-행성 공전 타이머
            OrbitTimerWidget(
              elapsed: timerState.elapsed,
              isRunning: isRunning,
              isPaused: isPaused,
              timeText: _formatDuration(timerState.elapsed),
              statusWidget: _buildStatusText(timerState, isIdle, isRunning),
            ),
```

**Step 3: `_calculateProgress` 메서드 제거**

기존 (line 349~352):
```dart
  /// 1시간(3600초)을 한 바퀴로 계산. 넘으면 다시 0부터.
  double _calculateProgress(Duration elapsed) {
    const oneHourSeconds = 3600;
    return (elapsed.inSeconds % oneHourSeconds) / oneHourSeconds;
  }
```

이 메서드는 `OrbitTimerWidget` 내부에서 30분 기준으로 자체 계산하므로 제거.

**Step 4: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 5: 커밋**

```bash
git add lib/features/timer/presentation/screens/timer_screen.dart
git commit -m "feat: 타이머 화면에 OrbitTimerWidget 적용 (TimerRingPainter 교체) #46"
```

---

### Task 6: 시각 검증 + 최종 확인

**Step 1: 시뮬레이터에서 시각 검증**

Run: `flutter run`

확인 항목:
1. **Idle 상태**: 항성 중앙 + 행성 12시 방향 고정 + 점선 궤도 + 흰색 `00:00:00`
2. **Running 상태**: 행성 공전 + 항성 pulse 글로우 + 실선 궤도 + 꼬리 + 파란색 시간 텍스트
3. **Paused 상태**: 행성 현재 위치 고정 + 깜박임 + 주황색 궤도 + 흰색 시간 텍스트
4. **시간 텍스트**: 항성 바로 아래, 가독성 확인
5. **pseudo-3D**: 시간 경과에 따라 궤도가 원→타원→원 변화
6. **Z-order**: 행성이 항성 앞/뒤로 올바르게 전환
7. **통계 카드/버튼**: 기존과 동일하게 표시

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 최종 확인 후 필요시 미세 조정 커밋**

레이아웃이나 크기 미세 조정이 필요한 경우:
```bash
git add -u
git commit -m "fix: OrbitTimerWidget 시각 미세 조정 #46"
```
