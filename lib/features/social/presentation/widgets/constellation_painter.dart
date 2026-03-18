import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/friend_entity.dart';
import 'constellation_patterns.dart';

class ConstellationPainter extends CustomPainter {
  const ConstellationPainter({required this.friends});

  final List<FriendEntity> friends;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.spaceDivider
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    Offset toPixel(Offset ratio) =>
        Offset(ratio.dx * size.width, ratio.dy * size.height);

    final polarisPos = toPixel(ConstellationPatterns.polaris);
    final slotPositions =
        ConstellationPatterns.bigDipperSlots.map(toPixel).toList();

    for (final (from, to) in ConstellationPatterns.connections) {
      final fromPos = from == -1 ? polarisPos : slotPositions[from];
      final toPos = to == -1 ? polarisPos : slotPositions[to];
      canvas.drawLine(fromPos, toPos, linePaint);
    }
  }

  @override
  bool shouldRepaint(ConstellationPainter oldDelegate) =>
      oldDelegate.friends != friends;
}
