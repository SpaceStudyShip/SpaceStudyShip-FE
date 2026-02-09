import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 행성 간 경로를 그리는 CustomPainter
///
/// sortOrder 순서대로 행성들을 곡선 점선으로 연결합니다.
/// 해금된 경로는 그라데이션 + glow, 잠금 경로는 어둡게 표시합니다.
class SpaceMapPainter extends CustomPainter {
  SpaceMapPainter({required this.planetPositions, required this.unlockedIds});

  final List<MapEntry<String, Offset>> planetPositions;
  final Set<String> unlockedIds;

  @override
  void paint(Canvas canvas, Size size) {
    if (planetPositions.length < 2) return;

    for (int i = 0; i < planetPositions.length - 1; i++) {
      final from = planetPositions[i];
      final to = planetPositions[i + 1];

      final isUnlockedPath =
          unlockedIds.contains(from.key) && unlockedIds.contains(to.key);

      // 곡선 경로 생성
      final path = Path();
      path.moveTo(from.value.dx, from.value.dy);

      final midY = (from.value.dy + to.value.dy) / 2;
      final controlX1 = from.value.dx;
      final controlX2 = to.value.dx;

      path.cubicTo(controlX1, midY, controlX2, midY, to.value.dx, to.value.dy);

      if (isUnlockedPath) {
        // Glow pass (해금 경로)
        final glowPaint = Paint()
          ..color = AppColors.primary.withValues(alpha: 0.15)
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawPath(path, glowPaint);

        // 그라데이션 실선
        final paint = Paint()
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(from.value, to.value, [
            AppColors.primary.withValues(alpha: 0.7),
            AppColors.primaryLight.withValues(alpha: 0.5),
          ]);

        canvas.drawPath(path, paint);
      } else {
        // 잠금 경로: 점선
        final paint = Paint()
          ..color = AppColors.spaceDivider.withValues(alpha: 0.3)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        _drawDashedPath(canvas, path, paint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(SpaceMapPainter oldDelegate) {
    return oldDelegate.planetPositions != planetPositions ||
        oldDelegate.unlockedIds != unlockedIds;
  }
}
