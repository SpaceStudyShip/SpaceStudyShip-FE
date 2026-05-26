import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/states/space_empty_state.dart';
import '../../domain/entities/timer_session_entity.dart';
import '../../domain/entities/timer_session_page.dart';
import '../providers/timer_session_provider.dart';
import '../utils/timer_format_utils.dart';

class TimerHistoryScreen extends ConsumerStatefulWidget {
  const TimerHistoryScreen({super.key});

  @override
  ConsumerState<TimerHistoryScreen> createState() => _TimerHistoryScreenState();
}

class _TimerHistoryScreenState extends ConsumerState<TimerHistoryScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // 세션이 추가·삭제되면 현재 페이지 데이터 무효화 (서버 재요청).
    ref.listen(timerSessionListNotifierProvider, (_, _) {
      ref.invalidate(timerHistoryPageProvider(_currentPage));
    });

    final pageAsync = ref.watch(timerHistoryPageProvider(_currentPage));
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
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: pageAsync.when(
              loading: () => const Center(child: AppLoading()),
              error: (e, _) => Center(
                child: Text(
                  '기록을 불러오지 못했어요',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              data: (page) => _buildContent(page),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TimerSessionPage page) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 36.h, left: 20.w, right: 20.w),
          child: Text(
            '기록',
            style: AppTextStyles.heading_20.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: AppSpacing.s20),
        Expanded(
          child: page.items.isEmpty
              ? const Center(
                  child: SpaceEmptyState(
                    icon: Icons.history_rounded,
                    title: '기록이 없어요',
                    subtitle: '타이머를 사용하면 여기에 기록됩니다',
                  ),
                )
              : ListView(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    bottom: AppSpacing.s24,
                  ),
                  children: _groupByDate(
                    page.items,
                  ).map(_buildDateGroup).toList(),
                ),
        ),
        if (page.totalPages > 1)
          _PageNumberBar(
            currentPage: page.page,
            totalPages: page.totalPages,
            onTap: (next) {
              setState(() => _currentPage = next);
            },
          ),
      ],
    );
  }

  List<_DateGroup> _groupByDate(List<TimerSessionEntity> sessions) {
    final grouped = <DateTime, List<TimerSessionEntity>>{};
    for (final session in sessions) {
      final date = normalizeDate(session.startedAt);
      grouped.putIfAbsent(date, () => []).add(session);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys
        .map((date) => _DateGroup(date: date, sessions: grouped[date]!))
        .toList();
  }

  Widget _buildDateGroup(_DateGroup dateGroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

class _DateGroup {
  final DateTime date;
  final List<TimerSessionEntity> sessions;
  final int totalMinutes;

  _DateGroup({required this.date, required this.sessions})
    : totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
}

/// 하단 페이지 번호 바 (`< 1 2 [3] 4 5 >` 형태).
/// 현재 페이지 기준 최대 5개 윈도우를 노출.
class _PageNumberBar extends StatelessWidget {
  const _PageNumberBar({
    required this.currentPage,
    required this.totalPages,
    required this.onTap,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onTap;

  static const int _windowSize = 5;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final canPrev = currentPage > 0;
    final canNext = currentPage < totalPages - 1;

    final half = _windowSize ~/ 2;
    int start = (currentPage - half).clamp(0, totalPages - 1);
    int end = (start + _windowSize - 1).clamp(0, totalPages - 1);
    if (end - start + 1 < _windowSize) {
      start = (end - _windowSize + 1).clamp(0, totalPages - 1);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s12,
        right: AppSpacing.s12,
        top: AppSpacing.s12,
        bottom: AppSpacing.s12 + bottomInset,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: () => onTap(currentPage - 1),
          ),
          for (int i = start; i <= end; i++)
            _PageDot(
              page: i,
              isCurrent: i == currentPage,
              onTap: () => onTap(i),
            ),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: () => onTap(currentPage + 1),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      color: Colors.white,
      disabledColor: AppColors.textDisabled,
      iconSize: 24,
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({
    required this.page,
    required this.isCurrent,
    required this.onTap,
  });

  final int page;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isCurrent ? null : onTap,
      borderRadius: AppRadius.chip,
      child: Container(
        constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: isCurrent ? AppColors.primary : AppColors.spaceDivider,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${page + 1}',
          style: AppTextStyles.paragraph_14.copyWith(
            color: isCurrent ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
