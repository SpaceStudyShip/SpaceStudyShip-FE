import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../models/seat_slot.dart';
import 'seat_widget.dart';

/// 3행 × (2 + 통로 + 2) 좌석 그리드
///
/// 항상 12개 슬롯을 받아야 한다.
/// 가운데 통로는 24dp 폭의 점선 vertical divider로 표시한다.
class SeatGrid extends StatelessWidget {
  const SeatGrid({
    super.key,
    required this.slots,
    this.onSeatTap,
    this.muteOthers = _muteOthersNone,
  }) : assert(slots.length == 12, 'SeatGrid는 정확히 12개 슬롯을 받아야 합니다.');

  final List<SeatSlot> slots;
  final ValueChanged<SeatSlot>? onSeatTap;

  /// 필터 탭에서 비매칭 좌석을 흐리게 처리할 때 사용
  final bool Function(SeatSlot slot) muteOthers;

  static bool _muteOthersNone(SeatSlot _) => false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < 2 ? AppSpacing.s8 : 0,
          ),
          child: _buildRow(rowIndex),
        );
      }),
    );
  }

  Widget _buildRow(int rowIndex) {
    final start = rowIndex * 4;
    final rowSlots = slots.sublist(start, start + 4);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _seat(rowSlots[0])),
          SizedBox(width: AppSpacing.s8),
          Expanded(child: _seat(rowSlots[1])),
          const _Aisle(),
          Expanded(child: _seat(rowSlots[2])),
          SizedBox(width: AppSpacing.s8),
          Expanded(child: _seat(rowSlots[3])),
        ],
      ),
    );
  }

  Widget _seat(SeatSlot slot) {
    return SeatWidget(
      slot: slot,
      muted: muteOthers(slot),
      onTap: () => onSeatTap?.call(slot),
    );
  }
}

class _Aisle extends StatelessWidget {
  const _Aisle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.w,
      child: Center(
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: CustomPaint(
            painter: _DottedLinePainter(color: AppColors.spaceDivider),
            child: const SizedBox(width: 1),
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashHeight = 3.0;
    const gap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
