import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/planet_style.dart';
import 'orbit_timer_painter.dart';
import 'planet_painter.dart';

/// 항성-행성 공전 타이머 위젯
///
/// 중앙 항성 + 궤도 + 공전 행성으로 구성. 순수 비주얼 위젯.
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

  /// 고정 3D 시점 각도 (30° — 위에서 비스듬히 내려다보는 태양계 시점)
  static const double _tilt = pi / 6;

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

  /// 행성 광원 각도 — 공전 위치에 따라 하이라이트 방향 회전
  double get _planetLightAngle {
    final angle = -pi / 2 + 2 * pi * _orbitProgress;
    // 앞에 올 때: -0.8 (좌상단 하이라이트)
    // 뒤로 갈 때: 2.3 (후면, 어둡게)
    return -0.8 + (angle + pi / 2);
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
            final planetLightAngle = _planetLightAngle;

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
                      starSize: starSize,
                    ),
                  ),
                ),

                // 행성 (뒤쪽 — 항성 뒤에 그려짐)
                if (!planetInFront)
                  _buildPlanet(
                    planetPos,
                    scaledPlanetSize,
                    effectivePlanetOpacity,
                    planetLightAngle,
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
                    planetLightAngle,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlanet(
    Offset position,
    double size,
    double opacity,
    double lightAngle,
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
              lightAngle: lightAngle,
            ),
          ),
        ),
      ),
    );
  }
}
