# 궤도 타이머 3D 입체감 강화 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 항성-행성 공전 시스템의 pseudo-3D 효과를 강화하여 시작 직후부터 입체감이 느껴지도록 개선한다.

**Architecture:** PlanetPainter에 lightAngle 파라미터를 추가하여 광원 회전을 구현하고, OrbitTimerPainter에 항성 그림자를 추가한다. OrbitTimerWidget에서 tilt 최소값을 설정하고 lightAngle을 공전 각도 기반으로 계산하여 전달한다.

**Tech Stack:** Flutter CustomPaint · dart:math

**Design Doc:** `docs/plans/2026-03-03-orbit-3d-enhancement-design.md`

---

### Task 1: 초기 tilt 최소값 설정

**Files:**
- Modify: `lib/features/timer/presentation/widgets/orbit_timer_widget.dart:128-136`

**Step 1: _tilt getter 수정**

기존:
```dart
  /// pseudo-3D 기울기: 30분 1사이클, 0°→45°→0°
  double get _tilt {
    const thirtyMinSeconds = 1800;
    final cycleProgress =
        (widget.elapsed.inSeconds % thirtyMinSeconds) / thirtyMinSeconds;
    // sin(0→2π)로 0→1→0→-1→0 → abs로 0→1→0→1→0
    // 하지만 디자인: 0분=0°, 15분=45°, 30분=0° → sin(progress * pi) 사용
    return (pi / 4) * sin(cycleProgress * pi);
  }
```

변경:
```dart
  /// pseudo-3D 기울기: 30분 1사이클, 15°→45°→15°
  double get _tilt {
    const thirtyMinSeconds = 1800;
    final cycleProgress =
        (widget.elapsed.inSeconds % thirtyMinSeconds) / thirtyMinSeconds;
    // 최소 15°(π/12) ~ 최대 45°(π/4): 시작부터 타원 궤도 보장
    return (pi / 12) + (pi / 6) * sin(cycleProgress * pi);
  }
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/widgets/orbit_timer_widget.dart
git commit -m "feat : 궤도 tilt 최소값 15° 설정 (즉시 3D 효과) #46"
```

---

### Task 2: PlanetPainter 광원 회전 하이라이트

**Files:**
- Modify: `lib/features/timer/presentation/widgets/planet_painter.dart`

**Step 1: lightAngle 파라미터 추가 및 RadialGradient center 계산**

기존:
```dart
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
```

변경:
```dart
class PlanetPainter extends CustomPainter {
  PlanetPainter({
    required this.style,
    this.showGlow = false,
    this.glowIntensity = 0.2,
    this.lightAngle = -0.8,
  });

  /// 구체 색상 스타일
  final PlanetStyle style;

  /// 외곽 글로우 표시 여부
  final bool showGlow;

  /// 글로우 강도 (0.0 ~ 1.0)
  final double glowIntensity;

  /// 광원 각도 (라디안). 공전 위치에 따라 하이라이트 방향 회전.
  final double lightAngle;
```

기존 (paint 메서드 내 그라데이션):
```dart
    // 3D 그라데이션 구체
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3), // 좌상단 하이라이트
        radius: 0.9,
```

변경:
```dart
    // 3D 그라데이션 구체 — 광원 각도에 따라 하이라이트 위치 회전
    final highlightX = cos(lightAngle) * 0.3;
    final highlightY = sin(lightAngle) * 0.3;
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(highlightX, highlightY),
        radius: 0.9,
```

기존 (shouldRepaint):
```dart
  @override
  bool shouldRepaint(PlanetPainter oldDelegate) {
    return oldDelegate.showGlow != showGlow ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.style != style;
  }
```

변경:
```dart
  @override
  bool shouldRepaint(PlanetPainter oldDelegate) {
    return oldDelegate.showGlow != showGlow ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.style != style ||
        oldDelegate.lightAngle != lightAngle;
  }
```

`dart:math` import 추가:
```dart
import 'dart:math';

import 'package:flutter/material.dart';
```

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 커밋**

```bash
git add lib/features/timer/presentation/widgets/planet_painter.dart
git commit -m "feat : PlanetPainter 광원 회전 하이라이트 추가 #46"
```

---

### Task 3: OrbitTimerWidget에서 행성 lightAngle 전달

**Files:**
- Modify: `lib/features/timer/presentation/widgets/orbit_timer_widget.dart`

**Step 1: _planetLightAngle getter 추가**

`_planetInFront` getter 뒤에 추가:

```dart
  /// 행성 광원 각도 — 공전 위치에 따라 하이라이트 방향 회전
  double get _planetLightAngle {
    final angle = -pi / 2 + 2 * pi * _orbitProgress;
    // 앞에 올 때: -0.8 (좌상단 하이라이트)
    // 뒤로 갈 때: 2.3 (후면, 어둡게)
    return -0.8 + (angle + pi / 2);
  }
```

**Step 2: _buildPlanet에 lightAngle 전달**

기존 `_buildPlanet` 시그니처:
```dart
  Widget _buildPlanet(
    Offset position,
    double size,
    double opacity,
  ) {
```

변경:
```dart
  Widget _buildPlanet(
    Offset position,
    double size,
    double opacity,
    double lightAngle,
  ) {
```

기존 `_buildPlanet` 내부 PlanetPainter:
```dart
          child: CustomPaint(
            painter: PlanetPainter(
              style: widget.planetStyle,
              showGlow: widget.isRunning,
              glowIntensity: widget.isRunning ? 0.15 : 0,
            ),
          ),
```

변경:
```dart
          child: CustomPaint(
            painter: PlanetPainter(
              style: widget.planetStyle,
              showGlow: widget.isRunning,
              glowIntensity: widget.isRunning ? 0.15 : 0,
              lightAngle: lightAngle,
            ),
          ),
```

**Step 3: build 메서드에서 호출부 수정**

builder 내부에 lightAngle 계산 추가:
```dart
            final scaledPlanetSize = basePlanetSize * planetScale;
            final planetLightAngle = _planetLightAngle;
```

`_buildPlanet` 호출 2곳 모두 lightAngle 인자 추가:
```dart
                // 행성 (뒤쪽)
                if (!planetInFront)
                  _buildPlanet(
                    planetPos,
                    scaledPlanetSize,
                    effectivePlanetOpacity,
                    planetLightAngle,
                  ),
```
```dart
                // 행성 (앞쪽)
                if (planetInFront)
                  _buildPlanet(
                    planetPos,
                    scaledPlanetSize,
                    effectivePlanetOpacity,
                    planetLightAngle,
                  ),
```

**Step 4: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 5: 커밋**

```bash
git add lib/features/timer/presentation/widgets/orbit_timer_widget.dart
git commit -m "feat : 행성 공전 위치 기반 광원 회전 적용 #46"
```

---

### Task 4: 항성 아래 타원 그림자

**Files:**
- Modify: `lib/features/timer/presentation/widgets/orbit_timer_painter.dart`

**Step 1: OrbitTimerPainter에 starSize 파라미터 추가**

기존 생성자:
```dart
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
```

변경:
```dart
  OrbitTimerPainter({
    required this.progress,
    required this.tilt,
    this.isRunning = false,
    this.isPaused = false,
    this.orbitStrokeWidth = 1.5,
    this.starSize = 60,
  });

  final double progress;
  final double tilt;
  final bool isRunning;
  final bool isPaused;
  final double orbitStrokeWidth;
  final double starSize;
```

**Step 2: _drawStarShadow 메서드 추가**

`_drawTail` 메서드 뒤에 추가:

```dart
  /// 항성 아래 타원형 그림자 — 부유감 표현
  void _drawStarShadow(Canvas canvas, Offset center) {
    final shadowCenter = Offset(center.dx, center.dy + starSize * 0.3);
    final shadowWidth = starSize * 0.7;
    // tilt에 비례하여 그림자가 납작해짐
    final shadowHeight = starSize * 0.15 * (1 + sin(tilt) * 0.5);

    final shadowRect = Rect.fromCenter(
      center: shadowCenter,
      width: shadowWidth,
      height: shadowHeight,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(shadowRect, shadowPaint);
  }
```

**Step 3: paint 메서드에서 그림자 호출**

기존:
```dart
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2 * 0.85;
    final radiusY = radiusX * cos(tilt); // Y축 압축 = 타원 효과

    _drawOrbitPath(canvas, center, radiusX, radiusY);
```

변경:
```dart
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2 * 0.85;
    final radiusY = radiusX * cos(tilt); // Y축 압축 = 타원 효과

    _drawStarShadow(canvas, center);
    _drawOrbitPath(canvas, center, radiusX, radiusY);
```

**Step 4: OrbitTimerWidget에서 starSize 전달**

`orbit_timer_widget.dart`의 OrbitTimerPainter 생성 부분:

기존:
```dart
                    painter: OrbitTimerPainter(
                      progress: _orbitProgress,
                      tilt: _tilt,
                      isRunning: widget.isRunning,
                      isPaused: widget.isPaused,
                    ),
```

변경:
```dart
                    painter: OrbitTimerPainter(
                      progress: _orbitProgress,
                      tilt: _tilt,
                      isRunning: widget.isRunning,
                      isPaused: widget.isPaused,
                      starSize: starSize,
                    ),
```

**Step 5: shouldRepaint에 starSize 추가**

기존:
```dart
  @override
  bool shouldRepaint(OrbitTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tilt != tilt ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.isPaused != isPaused;
  }
```

변경:
```dart
  @override
  bool shouldRepaint(OrbitTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tilt != tilt ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.isPaused != isPaused ||
        oldDelegate.starSize != starSize;
  }
```

**Step 6: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 7: 커밋**

```bash
git add lib/features/timer/presentation/widgets/orbit_timer_painter.dart lib/features/timer/presentation/widgets/orbit_timer_widget.dart
git commit -m "feat : 항성 아래 타원 그림자 추가 (부유감) #46"
```

---

### Task 5: 시각 검증

**Step 1: 시뮬레이터에서 시각 검증**

Run: `flutter run`

확인 항목:
1. **Idle 상태**: 궤도가 타원(15° tilt)으로 보이는지
2. **Running 상태**: 행성이 앞에 올 때 하이라이트가 정면, 뒤로 갈 때 어두워지는지
3. **항성 그림자**: 항성 아래에 납작한 타원 그림자가 보이는지
4. **tilt 변화**: 시간 경과에 따라 궤도가 15°→45°→15° 변화하는지
5. **성능**: 애니메이션 프레임 드랍 없이 부드러운지

**Step 2: 최종 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 필요시 미세 조정 커밋**

레이아웃이나 크기 미세 조정이 필요한 경우:
```bash
git add -u
git commit -m "fix : 3D 효과 시각 미세 조정 #46"
```
