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
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/space/spaceship_avatar.dart';
import '../../../../core/widgets/space/streak_badge.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../../../routes/route_paths.dart';
import '../../../todo/domain/entities/todo_entity.dart';
import '../../../todo/presentation/providers/todo_provider.dart';
import '../../../todo/presentation/widgets/dismissible_todo_item.dart';
import '../../../todo/presentation/widgets/todo_add_bottom_sheet.dart';
import '../widgets/space_calendar.dart';
import '../widgets/spaceship_selector.dart';

/// 홈 스크린
///
/// 우주선을 화면 중앙에 크게 배치하고,
/// 상단 바에 연료 등 재화 칩을 표시합니다.
/// 할 일/활동은 하단 시트로 제공합니다.
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
  final int _streakDays = 5;
  final bool _isStreakActive = true;
  bool _isSpaceshipPressed = false;
  bool _isSheetExpanded = false;

  // 캘린더 상태
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // 샘플 우주선 데이터 (SpaceshipData.sampleList 공유)
  final List<SpaceshipData> _spaceships = SpaceshipData.sampleList;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    final expanded = _sheetController.size > 0.4;
    if (expanded != _isSheetExpanded) {
      setState(() {
        _isSheetExpanded = expanded;
        // 시트 접힘 → 월간 포맷으로 리셋 (다음 펼침 시 월간부터 시작)
        if (!expanded) {
          _calendarFormat = CalendarFormat.month;
        }
      });
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _streakDays > 0
            ? FadeSlideIn(
                child: StreakBadge(
                  days: _streakDays,
                  isActive: _isStreakActive,
                  showLabel: true,
                  size: StreakBadgeSize.large,
                ),
              )
            : null,
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
          SizedBox(width: 2.w),
        ],
      ),
      body: Stack(
        children: [
          // 메인 콘텐츠
          GestureDetector(
            onTap: () {
              _sheetController.animateTo(
                0.25,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),
                Expanded(child: _buildSpaceshipArea()),
                SizedBox(height: 80.h),
              ],
            ),
          ),

          // 하단 시트
          _buildBottomSheet(),
        ],
      ),
    );
  }

  /// 우주선 영역: 중앙보다 살짝 위
  Widget _buildSpaceshipArea() {
    return Align(
      alignment: const Alignment(0, -0.3),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isSpaceshipPressed = true),
        onTapUp: (_) {
          setState(() => _isSpaceshipPressed = false);
          if (_isSheetExpanded) {
            _sheetController.animateTo(
              0.25,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _showSpaceshipSelector();
          }
        },
        onTapCancel: () => setState(() => _isSpaceshipPressed = false),
        child: AnimatedScale(
          scale: _isSpaceshipPressed ? TossDesignTokens.buttonTapScale : 1.0,
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.springCurve,
          child: FadeSlideIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpaceshipAvatar(
                  icon: _selectedSpaceshipIcon,
                  size: 320,
                  lottieAsset: _selectedLottieAsset,
                ),
                // 바텀시트와 우주선 간 여백 확보
                SizedBox(height: 58.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 시트: 할 일 + 활동 카드
  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.25, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.spaceSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _isSheetExpanded
              ? _buildExpandedSheet(scrollController)
              : _buildCollapsedSheet(scrollController),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  /// 접힌 상태: 주간 캘린더 스트립 + 할일 카운트
  Widget _buildCollapsedSheet(ScrollController scrollController) {
    final todosByDate = ref.watch(todosByDateMapProvider);
    final todayKey = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayTodoCount =
        todosByDate[todayKey]
            ?.where((t) => !t.isCompletedForDate(todayKey))
            .length ??
        0;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildDragHandle(),

        // 주간 캘린더 스트립 (컴팩트 모드)
        Padding(
          padding: AppPadding.horizontal20,
          child: SpaceCalendar(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            isCompact: true,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _sheetController.animateTo(
                0.85,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return todosByDate[key] ?? [];
            },
          ),
        ),

        // 오늘의 할일 카운트 + 펼치기 안내
        GestureDetector(
          onTap: () {
            _sheetController.animateTo(
              0.85,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                Text(
                  '오늘의 할 일',
                  style: AppTextStyles.label_16.copyWith(color: Colors.white),
                ),
                SizedBox(width: AppSpacing.s8),
                Text(
                  '$todayTodoCount개',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.textTertiary,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 펼친 상태: 월간 캘린더 + 날짜별 할일 목록
  Widget _buildExpandedSheet(ScrollController scrollController) {
    final selectedKey = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final todosForSelected = ref.watch(todosForDateProvider(selectedKey));
    final unscheduled = ref.watch(unscheduledTodosProvider);
    final todosByDate = ref.watch(todosByDateMapProvider);
    final dateLabel = DateFormat('M/d', 'ko_KR').format(_selectedDay);

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildDragHandle(),

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
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return todosByDate[key] ?? [];
            },
          ),
        ),

        SizedBox(height: AppSpacing.s16),

        // ── 선택된 날짜의 할일 섹션 ──
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
          child: Row(
            children: [
              _buildSectionTitle('$dateLabel 할일'),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final result = await showTodoAddBottomSheet(
                    context: context,
                    initialScheduledDates: [_selectedDay],
                  );
                  if (result != null && mounted) {
                    ref
                        .read(todoListNotifierProvider.notifier)
                        .addTodo(
                          title: result['title'] as String,
                          categoryId: result['categoryId'] as String?,
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

        if (todosForSelected.isEmpty)
          Padding(
            padding: AppPadding.horizontal20,
            child: _buildEmptyTodoCard(),
          )
        else
          ...todosForSelected.map(
            (todo) => _buildTodoRow(todo, contextDate: _selectedDay),
          ),

        // ── 카테고리 관리 버튼 ──
        Padding(
          padding: AppPadding.horizontal20,
          child: TextButton(
            onPressed: () => context.push(RoutePaths.todoList),
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

        // ── 날짜 미지정 할일 섹션 ──
        if (unscheduled.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
            child: _buildSectionTitle('날짜 미지정'),
          ),
          SizedBox(height: AppSpacing.s8),
          ...unscheduled.map((todo) => _buildTodoRow(todo)),
        ],

        SizedBox(height: AppSpacing.s40),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
    );
  }

  Widget _buildTodoRow(TodoEntity todo, {DateTime? contextDate}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
      child: DismissibleTodoItem(todo: todo, contextDate: contextDate),
    );
  }

  Widget _buildEmptyTodoCard() {
    return AppCard(
      style: AppCardStyle.outlined,
      padding: AppPadding.all24,
      child: SpaceEmptyState(
        icon: Icons.edit_note_rounded,
        title: '할 일이 없어요',
        subtitle: '+ 버튼을 눌러 추가해보세요',
        iconSize: 40,
        animated: false,
      ),
    );
  }
}
