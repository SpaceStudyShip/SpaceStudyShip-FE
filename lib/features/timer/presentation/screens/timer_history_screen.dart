import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../providers/study_stats_provider.dart';
import '../providers/timer_session_provider.dart';
import '../utils/timer_format_utils.dart';

const _pageSize = 7; // 한 페이지 = 7일치 날짜 그룹으로

class TimerHistoryScreen extends ConsumerStatefulWidget {
  const TimerHistoryScreen({super.key});

  @override
  ConsumerState<TimerHistoryScreen> createState() => _TimerHistoryScreenState();
}

class _TimerHistoryScreenState extends ConsumerState<TimerHistoryScreen> {
  late final PagingController<int, DateGroup> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, DateGroup>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        final loaded = state.items?.length ?? 0;
        final allGroups = ref.read(sortedDateGroupsProvider);
        return loaded >= allGroups.length ? null : loaded;
      },
      fetchPage: (pageKey) {
        final allGroups = ref.read(sortedDateGroupsProvider);
        final end = (pageKey + _pageSize).clamp(0, allGroups.length);
        return allGroups.sublist(pageKey, end);
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 세션 목록이 변경되면 PagingController 리프레시
    ref.listen(timerSessionListNotifierProvider, (_, _) {
      _pagingController.refresh();
    });

    final isEmpty = ref.watch(
      sortedDateGroupsProvider.select((g) => g.isEmpty),
    );
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          if (isEmpty)
            const Center(
              child: SpaceEmptyState(
                icon: Icons.history_rounded,
                title: '기록이 없어요',
                subtitle: '타이머를 사용하면 여기에 기록됩니다',
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 고정 타이틀
                  Padding(
                    padding: EdgeInsets.only(
                      top: 36.h,
                      left: 20.w,
                      right: 20.w,
                    ),
                    child: Text(
                      '기록',
                      style: AppTextStyles.heading_20.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s20),
                  // 요약 통계
                  Consumer(
                    builder: (context, ref, _) {
                      final totalMinutes = ref.watch(totalStudyMinutesProvider);
                      final monthlyMinutes = ref.watch(
                        monthlyStudyMinutesProvider,
                      );
                      final sessionCount = ref.watch(totalSessionCountProvider);
                      return Padding(
                        padding: AppPadding.horizontal20,
                        child: AppCard(
                          style: AppCardStyle.outlined,
                          padding: AppPadding.all16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SpaceStatItem(
                                icon: Icons.school_rounded,
                                label: '전체',
                                value: formatMinutes(totalMinutes),
                              ),
                              Container(
                                width: 1,
                                height: 32.h,
                                color: AppColors.spaceDivider,
                              ),
                              SpaceStatItem(
                                icon: Icons.calendar_month_rounded,
                                label: '이번 달',
                                value: formatMinutes(monthlyMinutes),
                              ),
                              Container(
                                width: 1,
                                height: 32.h,
                                color: AppColors.spaceDivider,
                              ),
                              SpaceStatItem(
                                icon: Icons.timer_outlined,
                                label: '세션',
                                value: '$sessionCount회',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.s16),
                  // 스크롤 영역
                  Expanded(child: _buildPagedList()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPagedList() {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, DateGroup>(
        state: state,
        fetchNextPage: fetchNextPage,
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
        builderDelegate: PagedChildBuilderDelegate<DateGroup>(
          itemBuilder: (context, dateGroup, index) =>
              _buildDateGroup(dateGroup),
          noItemsFoundIndicatorBuilder: (_) => const SizedBox.shrink(),
          newPageProgressIndicatorBuilder: (_) => Padding(
            padding: AppPadding.all16,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateGroup(DateGroup dateGroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 헤더 + 총 시간
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDateHeader(dateGroup.date),
              style: AppTextStyles.label_16.copyWith(color: Colors.white),
            ),
            Text(
              formatMinutes(dateGroup.totalMinutes),
              style: AppTextStyles.label_16.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s8),
        // 세션 목록
        ...dateGroup.sessions.map(
          (session) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s8),
            child: _buildSessionTile(session),
          ),
        ),
        SizedBox(height: AppSpacing.s16),
      ],
    );
  }

  Widget _buildSessionTile(TimerSessionEntity session) {
    final timeRange =
        '${DateFormat('HH:mm').format(session.startedAt)} – ${DateFormat('HH:mm').format(session.endedAt)}';

    return Container(
      padding: AppPadding.listItemPadding,
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.spaceDivider),
      ),
      child: Row(
        children: [
          // 좌측: 시간 범위 + 할일 제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeRange,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (session.todoTitle != null) ...[
                  SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 12.w,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Text(
                          session.todoTitle!,
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 우측: 소요 시간
          Text(
            formatMinutes(session.durationMinutes),
            style: AppTextStyles.label_16.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return '오늘';
    if (date == yesterday) return '어제';
    return DateFormat('M월 d일 (E)', 'ko_KR').format(date);
  }
}
