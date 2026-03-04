import 'dart:math';

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

    // 3D 그라데이션 구체 — 광원 각도에 따라 하이라이트 위치 회전
    final highlightX = cos(lightAngle) * 0.3;
    final highlightY = sin(lightAngle) * 0.3;
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(highlightX, highlightY),
        radius: 0.9,
        colors: [style.highlightColor, style.baseColor, style.shadowColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, spherePaint);
  }

  @override
  bool shouldRepaint(PlanetPainter oldDelegate) {
    return oldDelegate.showGlow != showGlow ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.style != style ||
        oldDelegate.lightAngle != lightAngle;
  }
}
