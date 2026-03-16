import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 원형 진행률 표시 위젯 - 우주 테마
///
/// **사용 예시**:
/// ```dart
/// SpaceCircularProgress(
///   progress: 0.75,
///   size: 48,
/// )
/// ```
class SpaceCircularProgress extends StatelessWidget {
  const SpaceCircularProgress({
    super.key,
    required this.progress,
    this.size = 48,
    this.color,
  });

  /// 진행률 (0.0 ~ 1.0)
  final double progress;

  /// 위젯 크기 (논리 픽셀, .w 적용됨)
  final double size;

  /// 진행률 아크 색상 (null이면 primary, 100%이면 success)
  final Color? color;

  Color get _progressColor {
    if (color != null) return color!;
    return progress >= 1.0 ? AppColors.success : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).round();
    final widgetSize = size.w;

    return SizedBox(
      width: widgetSize,
      height: widgetSize,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: clampedProgress,
          progressColor: _progressColor,
          trackColor: AppColors.spaceDivider.withValues(alpha: 0.3),
          strokeWidth: 4.w,
        ),
        child: Center(
          child: Text(
            '$percentage%',
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 트랙
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 진행률 아크
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      const startAngle = -pi / 2; // 12시 방향부터 시작

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
