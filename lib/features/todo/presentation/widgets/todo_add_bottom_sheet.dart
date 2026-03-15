import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/calendar_header.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import '../../../../core/utils/show_app_bottom_sheet.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';

class TodoAddBottomSheet extends ConsumerStatefulWidget {
  const TodoAddBottomSheet({
    super.key,
    this.initialCategoryIds,
    this.initialScheduledDates,
    this.initialTodo,
    required this.bottomPadding,
  });

  final List<String>? initialCategoryIds;
  final List<DateTime>? initialScheduledDates;
  final TodoEntity? initialTodo;
  final double bottomPadding;

  @override
  ConsumerState<TodoAddBottomSheet> createState() => _TodoAddBottomSheetState();
}

class _TodoAddBottomSheetState extends ConsumerState<TodoAddBottomSheet> {
  final _titleController = TextEditingController();
  List<String> _selectedCategoryIds = [];
  List<DateTime> _selectedScheduledDates = [];
  bool _showCalendar = false;
  DateTime _calendarFocusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  bool get _isEditMode => widget.initialTodo != null;

  @override
  void initState() {
    super.initState();
    final todo = widget.initialTodo;
    if (todo != null) {
      // 수정 모드: 기존 값으로 초기화
      _titleController.text = todo.title;
      _selectedCategoryIds = List<String>.from(todo.categoryIds);
      _selectedScheduledDates = todo.scheduledDates
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList();
      if (_selectedScheduledDates.isNotEmpty) {
        _calendarFocusedDay = _selectedScheduledDates.first;
      }
    } else {
      // 생성 모드: 기존 로직
      _selectedCategoryIds = widget.initialCategoryIds != null
          ? List<String>.from(widget.initialCategoryIds!)
          : [];
      if (widget.initialScheduledDates != null &&
          widget.initialScheduledDates!.isNotEmpty) {
        _selectedScheduledDates = widget.initialScheduledDates!
            .map((d) => DateTime(d.year, d.month, d.day))
            .toList();
      } else {
        final now = DateTime.now();
        _selectedScheduledDates = [DateTime(now.year, now.month, now.day)];
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop({
      'title': title,
      'categoryIds': List<String>.from(_selectedCategoryIds),
      'scheduledDates': _selectedScheduledDates,
      if (widget.initialTodo != null) 'id': widget.initialTodo!.id,
    });
  }

  void _toggleDate(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    setState(() {
      final index = _selectedScheduledDates.indexWhere((d) => d == normalized);
      if (index >= 0) {
        _selectedScheduledDates.removeAt(index);
      } else {
        _selectedScheduledDates.add(normalized);
      }
    });
  }

  bool _isDateSelected(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _selectedScheduledDates.any((d) => d == normalized);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 드래그 핸들
                const DragHandle(),

                // 제목
                Padding(
                  padding: AppPadding.bottomSheetTitlePadding,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isEditMode ? '할 일 수정' : '할 일 추가',
                      style: AppTextStyles.subHeading_18.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 제목 입력 필드
                Padding(
                  padding: AppPadding.horizontal20,
                  child: AppTextField(
                    controller: _titleController,
                    hintText: '할 일을 입력하세요',
                    onSubmitted: (_) => _submit(),
                    autofocus: !_isEditMode,
                    showBorder: false,
                  ),
                ),
                SizedBox(height: AppSpacing.s16),

                // 카테고리 칩 선택
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: AppPadding.horizontal20,
                          child: Text(
                            '카테고리',
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s8),
                        SizedBox(
                          height: 36.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: AppPadding.horizontal20,
                            children: [
                              _CategoryChip(
                                label: '미분류',
                                isSelected: _selectedCategoryIds.isEmpty,
                                onTap: () => setState(
                                  () => _selectedCategoryIds.clear(),
                                ),
                              ),
                              SizedBox(width: AppSpacing.s8),
                              ...categories.map(
                                (cat) => Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: _CategoryChip(
                                    iconId: cat.iconId,
                                    label: cat.name,
                                    isSelected: _selectedCategoryIds.contains(
                                      cat.id,
                                    ),
                                    onTap: () => setState(() {
                                      if (_selectedCategoryIds.contains(
                                        cat.id,
                                      )) {
                                        _selectedCategoryIds.remove(cat.id);
                                      } else {
                                        _selectedCategoryIds.add(cat.id);
                                      }
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.s4),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                SizedBox(height: AppSpacing.s16),

                // 날짜 선택 섹션
                Padding(
                  padding: AppPadding.horizontal20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '예정일',
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showCalendar = !_showCalendar),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showCalendar
                                      ? Icons.keyboard_arrow_up
                                      : Icons.calendar_today,
                                  size: 16.w,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: AppSpacing.s4),
                                Text(
                                  _showCalendar ? '접기' : '캘린더',
                                  style: AppTextStyles.tag_12.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.s8),

                      // 선택된 날짜 칩들
                      if (_selectedScheduledDates.isNotEmpty)
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: _selectedScheduledDates.map((date) {
                            return _DateChip(
                              date: date,
                              onRemove: () => _toggleDate(date),
                            );
                          }).toList(),
                        )
                      else
                        GestureDetector(
                          onTap: () => setState(() => _showCalendar = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.chip,
                              border: Border.all(color: AppColors.spaceDivider),
                            ),
                            child: Text(
                              '날짜 미지정',
                              style: AppTextStyles.tag_12.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),

                      // 인라인 캘린더
                      if (_showCalendar) ...[
                        SizedBox(height: AppSpacing.s12),
                        _buildInlineCalendar(),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.s16),

                // 추가 버튼
                Padding(
                  padding: AppPadding.horizontal20,
                  child: ListenableBuilder(
                    listenable: _titleController,
                    builder: (context, _) => AppButton(
                      text: _isEditMode ? '수정하기' : '추가하기',
                      onPressed: _titleController.text.trim().isEmpty
                          ? null
                          : _submit,
                      width: double.infinity,
                    ),
                  ),
                ),

                SizedBox(height: widget.bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineCalendar() {
    return Column(
      children: [
        // 커스텀 헤더 — 타이틀 탭으로 월간/주간 토글
        CalendarHeader(
          focusedDay: _calendarFocusedDay,
          calendarFormat: _calendarFormat,
          onPreviousMonth: () {
            setState(() {
              _calendarFocusedDay = DateTime(
                _calendarFocusedDay.year,
                _calendarFocusedDay.month - 1,
              );
            });
          },
          onNextMonth: () {
            setState(() {
              _calendarFocusedDay = DateTime(
                _calendarFocusedDay.year,
                _calendarFocusedDay.month + 1,
              );
            });
          },
          onToggleFormat: () {
            setState(() {
              _calendarFormat = _calendarFormat == CalendarFormat.month
                  ? CalendarFormat.week
                  : CalendarFormat.month;
            });
          },
          titleStyle: AppTextStyles.label_16.copyWith(color: Colors.white),
          verticalPadding: 4.h,
        ),
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _calendarFocusedDay,
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'ko_KR',
          headerVisible: false,
          daysOfWeekHeight: 20.h,
          rowHeight: 40.h,
          selectedDayPredicate: (day) => _isDateSelected(day),
          onDaySelected: (selectedDay, focusedDay) {
            _toggleDate(selectedDay);
            _calendarFocusedDay = focusedDay;
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            setState(() => _calendarFocusedDay = focusedDay);
          },
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary,
            ),
            weekendStyle: AppTextStyles.tag_12.copyWith(
              color: AppColors.textTertiary.withValues(alpha: 0.6),
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            cellMargin: EdgeInsets.all(2.w),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: AppTextStyles.tag_12.copyWith(
              color: Colors.white,
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            todayTextStyle: AppTextStyles.tag_12.copyWith(
              color: AppColors.primary,
            ),
            defaultTextStyle: AppTextStyles.tag_12.copyWith(
              color: Colors.white,
            ),
            weekendTextStyle: AppTextStyles.tag_12.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date, required this.onRemove});

  final DateTime date;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('M/d (E)', 'ko_KR').format(date),
            style: AppTextStyles.tag_12.copyWith(color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.s4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14.w, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconId,
  });

  final String? iconId;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.spaceDivider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconId != null) ...[
              CategoryIcons.buildIcon(iconId, size: 14.w),
              SizedBox(width: AppSpacing.s4),
            ],
            Text(
              label,
              style: AppTextStyles.tag_12.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 할일 추가 바텀시트를 표시하는 헬퍼 함수
Future<Map<String, dynamic>?> showTodoAddBottomSheet({
  required BuildContext context,
  List<String>? initialCategoryIds,
  List<DateTime>? initialScheduledDates,
  TodoEntity? initialTodo,
}) {
  return showAppBottomSheet<Map<String, dynamic>>(
    context: context,
    builder: (context, bottomPadding) => TodoAddBottomSheet(
      initialCategoryIds: initialCategoryIds,
      initialScheduledDates: initialScheduledDates,
      initialTodo: initialTodo,
      bottomPadding: bottomPadding,
    ),
  );
}
