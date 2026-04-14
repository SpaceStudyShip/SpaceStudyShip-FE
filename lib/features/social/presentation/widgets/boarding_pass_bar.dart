import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 하단 탑승권(Boarding Pass) 스타일 상태 바
///
/// 좌우에 원형 컷아웃, 가운데 점선 divider, 우측에 + 친구 버튼.
class BoardingPassBar extends StatelessWidget {
  const BoardingPassBar({
    super.key,
    required this.shipName,
    required this.boardedCount,
    required this.totalSeats,
    this.onAddFriend,
  });

  final String shipName;
  final int boardedCount;
  final int totalSeats;
  final VoidCallback? onAddFriend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            decoration: BoxDecoration(
              color: AppColors.spaceSurface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.spaceDivider),
            ),
            child: Row(
              children: [
                _PassColumn(label: 'BOARDING', value: shipName),
                SizedBox(width: AppSpacing.s12),
                const _PassDivider(),
                SizedBox(width: AppSpacing.s12),
                _PassColumn(
                  label: '탑승',
                  value: '$boardedCount / $totalSeats',
                  valueColor: AppColors.success,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onAddFriend,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.button,
                    ),
                    child: Text(
                      '+ 친구',
                      style: AppTextStyles.tag_12.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: -5.w,
            top: 0,
            bottom: 0,
            child: const Center(child: _Cutout()),
          ),
          Positioned(
            right: -5.w,
            top: 0,
            bottom: 0,
            child: const Center(child: _Cutout()),
          ),
        ],
      ),
    );
  }
}

class _PassColumn extends StatelessWidget {
  const _PassColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.tag_10.copyWith(
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: AppColors.textDisabled,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTextStyles.tag_12.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PassDivider extends StatelessWidget {
  const _PassDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 28.h,
      child: CustomPaint(
        painter: _DottedLinePainter(color: AppColors.spaceDivider),
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

class _Cutout extends StatelessWidget {
  const _Cutout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.spaceBackground,
        border: Border.all(color: AppColors.spaceDivider),
      ),
    );
  }
}
