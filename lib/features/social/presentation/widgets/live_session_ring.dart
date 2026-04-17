import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 친구 상세 화면용 원형 라이브 세션 링
///
/// CustomPaint로 트랙(회색) + 진행 아크(상태 색)를 그리고,
/// 중앙에 라벨 / 시간 / 서브 텍스트를 Stack으로 올린다.
///
/// 진행률은 1시간(3600초)을 한 바퀴로 환산:
/// `(duration.inSeconds % 3600) / 3600`
///
/// 상태별:
/// - active=true → success 색 + 진행률 표시 + LIVE 라벨
/// - active=false → spaceDivider 색 + 진행률 0 + OFFLINE 라벨 + --:--
class LiveSessionRing extends StatelessWidget {
  const LiveSessionRing({
    super.key,
    required this.duration,
    required this.active,
    this.size = 200,
  });

  final Duration duration;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.spaceDivider;
    final progress = active ? (duration.inSeconds % 3600) / 3600 : 0.0;
    final widgetSize = size.w;

    return SizedBox(
      width: widgetSize,
      height: widgetSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widgetSize, widgetSize),
            painter: _RingPainter(
              progress: progress,
              progressColor: color,
              trackColor: AppColors.spaceDivider.withValues(alpha: 0.3),
              strokeWidth: 8.w,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                active ? 'LIVE' : 'OFFLINE',
                style: AppTextStyles.tag10Semibold.copyWith(
                  color: active
                      ? AppColors.textTertiary
                      : AppColors.textDisabled,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              Text(
                _formatTime(duration, active),
                style: AppTextStyles.timer_32.copyWith(color: color),
              ),
              SizedBox(height: AppSpacing.s4),
              Text(
                _formatSub(duration, active),
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d, bool active) {
    if (!active) return '--:--';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatSub(Duration d, bool active) {
    if (!active) return '집중 중이 아니에요';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h시간 $m분째 집중 중';
    return '$m분째 집중 중';
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
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

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweep = 2 * pi * progress;
      const start = -pi / 2; // 12시 방향부터
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
