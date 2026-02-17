import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/calendar_header.dart';
import '../../../todo/domain/entities/todo_entity.dart';

/// 우주 테마 캘린더 위젯
///
/// table_calendar를 CalendarBuilders로 완전 커스텀하여
/// 다크 우주 배경에 어울리는 캘린더를 제공한다.
///
/// [isCompact] true: 주간 스트립 (접힌 시트용, 헤더 없음)
/// [isCompact] false: 월간/주간 토글 (펼친 시트용, 헤더 있음)
class SpaceCalendar extends StatelessWidget {
  const SpaceCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
    this.isCompact = false,
    this.calendarFormat = CalendarFormat.month,
    this.onFormatChanged,
    this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final List<TodoEntity> Function(DateTime day) eventLoader;
  final bool isCompact;
  final CalendarFormat calendarFormat;
  final void Function(CalendarFormat)? onFormatChanged;
  final void Function(DateTime)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 커스텀 헤더 — 타이틀 탭으로 월간/주간 토글 (compact 아닐 때만)
        if (!isCompact)
          CalendarHeader(
            focusedDay: focusedDay,
            calendarFormat: calendarFormat,
            showArrowBackground: true,
            onPreviousMonth: () {
              final prev = DateTime(focusedDay.year, focusedDay.month - 1);
              onPageChanged?.call(prev);
            },
            onNextMonth: () {
              final next = DateTime(focusedDay.year, focusedDay.month + 1);
              onPageChanged?.call(next);
            },
            onToggleFormat: () {
              final next = calendarFormat == CalendarFormat.month
                  ? CalendarFormat.week
                  : CalendarFormat.month;
              onFormatChanged?.call(next);
            },
          ),
        TableCalendar<TodoEntity>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: isCompact ? CalendarFormat.week : calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'ko_KR',
          headerVisible: false,
          daysOfWeekHeight: 20.h,
          rowHeight: isCompact ? 42.h : 48.h,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
          eventLoader: eventLoader,

          // === 요일 헤더 스타일 ===
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary,
            ),
            weekendStyle: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary.withValues(alpha: 0.6),
            ),
          ),

          // === CalendarStyle 기본값 (CalendarBuilders 미적용 셀 대비) ===
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            cellMargin: EdgeInsets.all(2.w),
          ),

          // === CalendarBuilders: 우주 테마 커스텀 셀 렌더링 ===
          calendarBuilders: CalendarBuilders(
            // 기본 날짜 셀 (주말은 투명도 낮춤)
            defaultBuilder: (context, day, focusedDay) {
              final isWeekend =
                  day.weekday == DateTime.saturday ||
                  day.weekday == DateTime.sunday;
              return _buildDayCell(
                day: day,
                textColor: isWeekend
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white,
              );
            },

            // 선택된 날짜 — 글로우 원형
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day: day,
                textColor: Colors.white,
                fontWeight: FontWeight.bold,
                backgroundColor: AppColors.primary,
                showGlow: true,
              );
            },

            // 오늘 날짜 — 테두리 원형 (filled X)
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day: day,
                textColor: AppColors.primary,
                fontWeight: FontWeight.bold,
                borderColor: AppColors.primary,
              );
            },

            // 도트 마커 — 완료 상태에 따라 아이콘 변경
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              final allCompleted = events.every(
                (t) => t.isCompletedForDate(day),
              );
              final markerColor = allCompleted
                  ? AppColors.success
                  : AppColors.primary;
              return Positioned(
                bottom: 2.h,
                child: Icon(
                  allCompleted ? Icons.check_circle : Icons.circle,
                  size: 6.w,
                  color: markerColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 커스텀 날짜 셀 빌더
  Widget _buildDayCell({
    required DateTime day,
    required Color textColor,
    FontWeight fontWeight = FontWeight.normal,
    Color? backgroundColor,
    Color? borderColor,
    bool showGlow = false,
  }) {
    return Center(
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: AppTextStyles.label_16.copyWith(
            color: textColor,
            fontWeight: fontWeight,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
