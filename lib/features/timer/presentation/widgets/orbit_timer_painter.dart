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
    this.starSize = 60,
  });

  final double progress;
  final double tilt;
  final bool isRunning;
  final bool isPaused;
  final double orbitStrokeWidth;
  final double starSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2 * 0.85;
    final radiusY = radiusX * cos(tilt); // Y축 압축 = 타원 효과

    _drawStarShadow(canvas, center);
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
  void _drawTail(Canvas canvas, Offset center, double radiusX, double radiusY) {
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

  @override
  bool shouldRepaint(OrbitTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tilt != tilt ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.isPaused != isPaused ||
        oldDelegate.starSize != starSize;
  }
}
