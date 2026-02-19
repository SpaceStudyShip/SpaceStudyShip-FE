import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 캘린더 커스텀 헤더 위젯
///
/// [showArrowBackground] true이면 화살표에 원형 배경 (SpaceCalendar 스타일)
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onToggleFormat,
    this.titleStyle,
    this.showArrowBackground = false,
    this.verticalPadding,
  });

  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback? onToggleFormat;
  final TextStyle? titleStyle;
  final bool showArrowBackground;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding ?? AppSpacing.s8),
      child: Row(
        children: [
          _buildArrowButton(icon: Icons.chevron_left, onTap: onPreviousMonth),
          Expanded(
            child: GestureDetector(
              onTap: onToggleFormat,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('yyyy년 M월', 'ko_KR').format(focusedDay),
                    style:
                        titleStyle ??
                        AppTextStyles.subHeading_18.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  SizedBox(width: AppSpacing.s4),
                  Icon(
                    calendarFormat == CalendarFormat.month
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 16.w,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          _buildArrowButton(icon: Icons.chevron_right, onTap: onNextMonth),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    if (showArrowBackground) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: AppPadding.all4,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.w),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: AppPadding.all8,
        child: Icon(icon, color: AppColors.primary, size: 20.w),
      ),
    );
  }
}
