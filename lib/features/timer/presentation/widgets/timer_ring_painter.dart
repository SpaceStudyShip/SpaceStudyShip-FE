import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 원형 프로그레스 링 CustomPainter
///
/// 타이머 진행률을 원형 링으로 표시합니다.
///
/// **사용 예시**:
/// ```dart
/// CustomPaint(
///   size: Size(200, 200),
///   painter: TimerRingPainter(
///     progress: 0.75,
///     isRunning: true,
///   ),
/// )
/// ```
class TimerRingPainter extends CustomPainter {
  TimerRingPainter({
    required this.progress,
    this.isRunning = false,
    this.strokeWidth = 6.0,
    this.backgroundColor,
    this.progressColor,
  });

  /// 진행률 (0.0 ~ 1.0)
  final double progress;

  /// 실행 중 여부 (glow 효과)
  final bool isRunning;

  /// 링 두께
  final double strokeWidth;

  /// 배경 링 색상
  final Color? backgroundColor;

  /// 진행 링 색상
  final Color? progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 배경 링
    final bgPaint = Paint()
      ..color = backgroundColor ?? AppColors.spaceDivider.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // 진행 링 그라데이션
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          progressColor ?? AppColors.primary,
          (progressColor ?? AppColors.primary).withValues(alpha: 0.6),
          progressColor ?? AppColors.primary,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    // Glow 효과 (실행 중일 때)
    if (isRunning) {
      final glowPaint = Paint()
        ..color = (progressColor ?? AppColors.primary).withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 3
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, glowPaint);
    }

    // 진행 아크
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRunning != isRunning;
  }
}
