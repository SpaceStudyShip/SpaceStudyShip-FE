import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 티켓 본체와 stub 사이 점선 구분선
///
/// 수평 점선을 그리는 CustomPainter 기반 위젯입니다.
/// dash 길이와 간격을 커스텀할 수 있습니다.
class TicketDashedLine extends StatelessWidget {
  const TicketDashedLine({
    super.key,
    this.color,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
    this.strokeWidth = 1.0,
    this.height = 1.0,
  });

  final Color? color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color ?? AppColors.spaceDivider,
          dashWidth: dashWidth,
          dashGap: dashGap,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      dashWidth != oldDelegate.dashWidth ||
      dashGap != oldDelegate.dashGap ||
      strokeWidth != oldDelegate.strokeWidth;
}
