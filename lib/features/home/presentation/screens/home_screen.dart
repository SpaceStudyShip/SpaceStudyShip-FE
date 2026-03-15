import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';
import '../../../../core/utils/show_app_bottom_sheet.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/space/spaceship_avatar.dart';
import '../../../../core/widgets/space/streak_badge.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/route_paths.dart';
import '../../../timer/presentation/providers/study_stats_provider.dart';
import '../../../todo/domain/entities/todo_entity.dart';
import '../../../todo/presentation/providers/todo_provider.dart';
import '../../../../core/widgets/space/todo_item.dart';
import '../../../todo/presentation/widgets/dismissible_todo_item.dart';
import '../../../todo/presentation/widgets/todo_add_bottom_sheet.dart';
import '../widgets/space_calendar.dart';
import '../../../../routes/navigation_providers.dart';
import '../widgets/spaceship_selector.dart';

/// 홈 스크린
///
/// 우주선을 화면 중앙에 크게 배치하고,
/// 상단 바에 연료 등 재화 칩을 표시합니다.
/// 우주선 하단에 컴팩트 카드를 배치하고, 탭하면 캘린더+할일 모달을 엽니다.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 임시 상태 (나중에 Riverpod Provider로 이동)
  String _selectedSpaceshipId = 'default';
  String _selectedSpaceshipIcon = '🚀';
  String? _selectedLottieAsset = 'assets/lotties/default_rocket.json';
  bool _isSpaceshipPressed = false;

  // 캘린더 상태 (모달에서 사용)
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // 샘플 우주선 데이터 (SpaceshipData.sampleList 공유)
  final List<SpaceshipData> _spaceships = SpaceshipData.sampleList;

  void _showSpaceshipSelector() {
    showSpaceshipSelector(
      context: context,
      spaceships: _spaceships,
      selectedId: _selectedSpaceshipId,
      onSelect: (id) {
        final selected = _spaceships.firstWhere((s) => s.id == id);
        setState(() {
          _selectedSpaceshipId = id;
          _selectedSpaceshipIcon = selected.icon;
          _selectedLottieAsset = selected.lottieAsset;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 홈 탭 재탭 → 열려있는 모달 닫기
    ref.listen(homeReTapProvider, (prev, next) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.s20,
        title: Consumer(
          builder: (context, ref, _) {
            final streakDays = ref.watch(currentStreakProvider);
            if (streakDays <= 0) return const SizedBox.shrink();
            return FadeSlideIn(
              child: StreakBadge(
                days: streakDays,
                isActive: true,
                showLabel: true,
                size: StreakBadgeSize.large,
              ),
            );
          },
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24.w,
            ),
            onPressed: () {
              // TODO: 알림 화면
            },
          ),
          SizedBox(width: AppSpacing.s4),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          Expanded(child: _buildSpaceshipArea()),
          _buildCompactCard(),
          // 플로팅 네비 + 안전 영역 여백
          SizedBox(
            height:
                MediaQuery.of(context).padding.bottom +
                FloatingNavMetrics.totalHeight +
                AppSpacing.s12,
          ),
        ],
      ),
    );
  }

  /// 우주선 영역: 중앙보다 살짝 위
  Widget _buildSpaceshipArea() {
    return Align(
      alignment: const Alignment(0, -0.2),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isSpaceshipPressed = true),
        onTapUp: (_) {
          setState(() => _isSpaceshipPressed = false);
          _showSpaceshipSelector();
        },
        onTapCancel: () => setState(() => _isSpaceshipPressed = false),
        child: AnimatedScale(
          scale: _isSpaceshipPressed ? TossDesignTokens.buttonTapScale : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: FadeSlideIn(
            child: SpaceshipAvatar(
              icon: _selectedSpaceshipIcon,
              size: 320,
              lottieAsset: _selectedLottieAsset,
            ),
          ),
        ),
      ),
    );
  }

  /// 컴팩트 카드: 오늘의 할일 요약 + 진행률 바
  Widget _buildCompactCard() {
    final todayKey = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final stats = ref.watch(todoCompletionStatsForDateProvider(todayKey));
    final hasAnyTodo = stats.total > 0;
    final progress = hasAnyTodo ? stats.completed / stats.total : 0.0;

    return GestureDetector(
      onTap: _openTodoCalendarModal,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: AppPadding.horizontal20,
        child: AppCard(
          style: AppCardStyle.outlined,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀 행
              Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                  SizedBox(width: AppSpacing.s8),
                  Text(
                    '오늘의 할 일',
                    style: AppTextStyles.label_16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (hasAnyTodo)
                    Text(
                      '${stats.completed}/${stats.total} 완료',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    )
                  else
                    Text(
                      '할 일을 추가해보세요',
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),

              // 진행률 바 (할일이 있을 때만)
              if (hasAnyTodo) ...[
                SizedBox(height: AppSpacing.s12),
                ClipRRect(
                  borderRadius: AppRadius.small,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.h,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 캘린더 + 할일 목록 모달 바텀시트 열기
  void _openTodoCalendarModal() {
    showAppBottomSheet(
      context: context,
      builder: (context, bottomPadding) {
        return _TodoCalendarModal(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          calendarFormat: _calendarFormat,
          bottomPadding: bottomPadding,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
        );
      },
    );
  }
}

/// 캘린더 + 할일 목록 모달 바텀시트
class _TodoCalendarModal extends ConsumerStatefulWidget {
  const _TodoCalendarModal({
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.bottomPadding,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final double bottomPadding;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onPageChanged;

  @override
  ConsumerState<_TodoCalendarModal> createState() => _TodoCalendarModalState();
}

class _TodoCalendarModalState extends ConsumerState<_TodoCalendarModal> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _selectedDay = widget.selectedDay;
    _calendarFormat = widget.calendarFormat;
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final todosForSelected = ref.watch(todosForDateProvider(selectedKey));
    final bankTodos = ref.watch(todosNotForDateProvider(selectedKey));
    final unscheduled = ref.watch(unscheduledTodosProvider);
    final todosByDate = ref.watch(todosByDateMapProvider);
    final dateLabel = DateFormat('M/d', 'ko_KR').format(_selectedDay);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          const DragHandle(),

          // 월간/주간 토글 캘린더
          Padding(
            padding: AppPadding.horizontal20,
            child: SpaceCalendar(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              isCompact: false,
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDaySelected(selectedDay, focusedDay);
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
                widget.onFormatChanged(format);
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
                widget.onPageChanged(focusedDay);
              },
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return todosByDate[key] ?? [];
              },
            ),
          ),

          SizedBox(height: AppSpacing.s16),

          // 선택된 날짜의 할일 섹션
          Padding(
            padding: AppPadding.horizontal20,
            child: Row(
              children: [
                Text(
                  '$dateLabel 할 일',
                  style: AppTextStyles.subHeading_18.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final result = await showTodoAddBottomSheet(
                      context: context,
                      initialScheduledDates: [_selectedDay],
                    );
                    if (result != null && context.mounted) {
                      ref
                          .read(todoListNotifierProvider.notifier)
                          .addTodo(
                            title: result['title'] as String,
                            categoryIds:
                                (result['categoryIds'] as List<String>?) ?? [],
                            scheduledDates:
                                result['scheduledDates'] as List<DateTime>?,
                          );
                    }
                  },
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s8),

          if (todosForSelected.isEmpty && bankTodos.isEmpty)
            Padding(
              padding: AppPadding.horizontal20,
              child: AppCard(
                style: AppCardStyle.outlined,
                padding: AppPadding.all24,
                child: SpaceEmptyState(
                  icon: Icons.edit_note_rounded,
                  title: '할 일이 없어요',
                  subtitle: '+ 버튼을 눌러 추가해보세요',
                  iconSize: 40,
                  animated: false,
                ),
              ),
            )
          else if (todosForSelected.isNotEmpty)
            ...todosForSelected.map(
              (todo) => Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                child: DismissibleTodoItem(
                  todo: todo,
                  contextDate: _selectedDay,
                ),
              ),
            ),

          // 할 일 추가 (todo bank)
          _buildTodoBankSection(selectedKey, bankTodos),

          // 카테고리 관리 버튼
          Padding(
            padding: AppPadding.horizontal20,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // GoRouter push는 모달 닫힌 뒤 실행
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) context.push(RoutePaths.todoList);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '카테고리 관리',
                    style: AppTextStyles.label_16.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.w,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // 날짜 미지정 할일 섹션
          if (unscheduled.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: Text(
                '날짜 미지정',
                style: AppTextStyles.subHeading_18.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s8),
            ...unscheduled.map(
              (todo) => Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                child: DismissibleTodoItem(todo: todo),
              ),
            ),
          ],

          SizedBox(height: widget.bottomPadding),
        ],
      ),
    );
  }

  Widget _buildTodoBankSection(
    DateTime selectedDate,
    List<TodoEntity> bankTodos,
  ) {
    if (bankTodos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSpacing.s16),
        Padding(
          padding: AppPadding.horizontal20,
          child: Text(
            '할 일 추가',
            style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: AppSpacing.s8),
        ...bankTodos.map(
          (todo) => Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, AppSpacing.s8),
            child: TodoItem(
              title: todo.title,
              subtitle: todo.studyTimeLabel,
              isCompleted: false,
              leading: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 24.w,
              ),
              onToggle: () => ref
                  .read(todoListNotifierProvider.notifier)
                  .addDateToTodo(todo, selectedDate),
              onTap: () => ref
                  .read(todoListNotifierProvider.notifier)
                  .addDateToTodo(todo, selectedDate),
            ),
          ),
        ),
      ],
    );
  }
}
