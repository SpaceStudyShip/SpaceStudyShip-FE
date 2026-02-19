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
          rowHeight: isCompact ? 48.h : 56.h,
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

            // 선택된 날짜 — 행성 스타일 (RadialGradient + glow)
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day: day,
                textColor: Colors.white,
                isBold: true,
                isPlanet: true,
              );
            },

            // 오늘 날짜 — 궤도 링 스타일 (cosmic purple 테두리 + subtle gradient)
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day: day,
                textColor: AppColors.secondaryLight,
                isBold: true,
                isOrbit: true,
              );
            },

            // 별 마커 — 미완료: 빈 별, 완료: 금색 별
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              final allCompleted = events.every(
                (t) => t.isCompletedForDate(day),
              );
              return Positioned(
                bottom: 1.h,
                child: Icon(
                  allCompleted
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 18.w,
                  color: allCompleted
                      ? AppColors.accentGold
                      : AppColors.textTertiary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 커스텀 날짜 셀 빌더
  ///
  /// [isPlanet] true: 선택된 날짜 — 행성 스타일 (RadialGradient + glow)
  /// [isOrbit] true: 오늘 날짜 — 궤도 링 스타일 (cosmic purple)
  /// [isBold] true: SemiBold 14sp, false: Medium 14sp
  Widget _buildDayCell({
    required DateTime day,
    required Color textColor,
    bool isBold = false,
    bool isPlanet = false,
    bool isOrbit = false,
  }) {
    final textStyle =
        (isBold
                ? AppTextStyles.paragraph14Semibold
                : AppTextStyles.paragraph_14_100)
            .copyWith(color: textColor);

    // 스타일별 decoration 결정
    final decoration = isPlanet
        ? BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 0.9,
              colors: [
                AppColors.primary.withValues(alpha: 0.6),
                AppColors.primaryDark.withValues(alpha: 0.3),
              ],
            ),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          )
        : isOrbit
        ? BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                AppColors.secondary.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
            border: Border.all(color: AppColors.secondaryLight, width: 1.5),
          )
        : const BoxDecoration(shape: BoxShape.circle);

    return Center(
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text('${day.day}', style: textStyle),
      ),
    );
  }
}
