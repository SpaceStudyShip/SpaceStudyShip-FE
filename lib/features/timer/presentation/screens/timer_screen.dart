import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/route_paths.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../todo/domain/entities/todo_entity.dart';
import '../providers/timer_provider.dart';
import '../providers/study_stats_provider.dart';
import '../providers/timer_state.dart';
import '../utils/timer_format_utils.dart';
import '../widgets/timer_ring_painter.dart';
import '../widgets/todo_select_bottom_sheet.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerNotifierProvider);
    final isRunning = timerState.status == TimerStatus.running;
    final isPaused = timerState.status == TimerStatus.paused;
    final isIdle = timerState.status == TimerStatus.idle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          '타이머',
          style: AppTextStyles.heading_20.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: Colors.white, size: 24.w),
            onPressed: () => context.push(RoutePaths.timerHistory),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 타이머 링 + 시간 표시
            SizedBox(
              width: 260.w,
              height: 260.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(260.w, 260.w),
                    painter: TimerRingPainter(
                      progress: _calculateProgress(timerState.elapsed),
                      isRunning: isRunning,
                      strokeWidth: 6.w,
                    ),
                  ),
                  Padding(
                    padding: AppPadding.horizontal16,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(timerState.elapsed),
                            style: AppTextStyles.timer_48.copyWith(
                              color: isRunning
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                          SizedBox(height: AppSpacing.s4),
                          _buildStatusText(timerState, isIdle, isRunning),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s48),

            // 컨트롤 버튼
            _buildControls(isIdle, isRunning, isPaused),
            SizedBox(height: AppSpacing.s48),

            // 오늘의 통계 (Consumer 격리: 매초 타이머 리빌드에 영향받지 않음)
            Consumer(
              builder: (context, ref, _) {
                final todayMinutes = ref.watch(todayStudyMinutesProvider);
                final weeklyMinutes = ref.watch(weeklyStudyMinutesProvider);
                final streak = ref.watch(currentStreakProvider);
                return Padding(
                  padding: AppPadding.horizontal20,
                  child: AppCard(
                    style: AppCardStyle.outlined,
                    padding: AppPadding.all20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SpaceStatItem(
                          icon: Icons.today_rounded,
                          label: '오늘',
                          value: formatMinutes(todayMinutes),
                        ),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: AppColors.spaceDivider,
                        ),
                        SpaceStatItem(
                          icon: Icons.date_range_rounded,
                          label: '이번 주',
                          value: formatMinutes(weeklyMinutes),
                        ),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: AppColors.spaceDivider,
                        ),
                        SpaceStatItem(
                          icon: Icons.local_fire_department_rounded,
                          label: '연속',
                          value: '$streak일',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(bool isIdle, bool isRunning, bool isPaused) {
    if (isIdle) {
      return Padding(
        padding: AppPadding.horizontal20,
        child: AppButton(text: '시작하기', onPressed: _onStart),
      );
    }

    return Padding(
      padding: AppPadding.horizontal20,
      child: Row(
        children: [
          if (isRunning)
            Expanded(
              child: AppButton(
                text: '일시정지',
                onPressed: () =>
                    ref.read(timerNotifierProvider.notifier).pause(),
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textSecondary,
                borderColor: AppColors.spaceDivider,
                width: double.infinity,
              ),
            ),
          if (isPaused)
            Expanded(
              child: AppButton(
                text: '계속하기',
                onPressed: () =>
                    ref.read(timerNotifierProvider.notifier).resume(),
                width: double.infinity,
              ),
            ),
          SizedBox(width: AppSpacing.s16),
          Expanded(
            child: AppButton(
              text: '종료',
              onPressed: _onStop,
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.error,
              borderColor: AppColors.error.withValues(alpha: 0.5),
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onStart() async {
    final result = await showTodoSelectBottomSheet(context: context);

    if (!mounted) return;

    // null = dismiss → 타이머 시작하지 않음
    if (result == null) return;

    // true = "연동 없이 시작" → 할일 연동 없이 타이머 시작
    // TodoEntity = 할일 선택 → 해당 할일과 연동하여 타이머 시작
    final todo = result is TodoEntity ? result : null;
    ref
        .read(timerNotifierProvider.notifier)
        .start(todoId: todo?.id, todoTitle: todo?.title);
  }

  Future<void> _onStop() async {
    final result = await ref.read(timerNotifierProvider.notifier).stop();
    if (!mounted || result == null) return;
    _showResultDialog(result);
  }

  void _showResultDialog(
    ({Duration sessionDuration, String? todoTitle, int? totalMinutes}) result,
  ) {
    final sessionText = _formatDuration(result.sessionDuration);

    AppDialog.show(
      context: context,
      title: '수고했어요!',
      emotion: AppDialogEmotion.success,
      customContent: Column(
        children: [
          _buildResultRow('이번 세션', sessionText),
          if (result.todoTitle != null) ...[
            Padding(
              padding: AppPadding.vertical12,
              child: Divider(color: AppColors.spaceDivider, height: 1),
            ),
            _buildResultRow('연동 할 일', result.todoTitle!),
            if (result.totalMinutes != null)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.s8),
                child: _buildResultRow(
                  '누적 시간',
                  formatMinutes(result.totalMinutes!),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.label_16.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText(TimerState timerState, bool isIdle, bool isRunning) {
    // 연동된 할일이 있고 idle이 아닌 경우 → 할일 제목 표시
    if (timerState.linkedTodoTitle != null && !isIdle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link_rounded,
            color: isRunning ? AppColors.primary : AppColors.textSecondary,
            size: 14.w,
          ),
          SizedBox(width: AppSpacing.s4),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 160.w),
            child: Text(
              timerState.linkedTodoTitle!,
              style: AppTextStyles.tag_12.copyWith(
                color: isRunning ? AppColors.primary : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // 연동 없음 → 기존 상태 텍스트
    return Text(
      isIdle
          ? '집중 시간을 측정해보세요'
          : isRunning
          ? '집중 중...'
          : '일시정지',
      style: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// 1시간(3600초)을 한 바퀴로 계산. 넘으면 다시 0부터.
  double _calculateProgress(Duration elapsed) {
    const oneHourSeconds = 3600;
    return (elapsed.inSeconds % oneHourSeconds) / oneHourSeconds;
  }
}
