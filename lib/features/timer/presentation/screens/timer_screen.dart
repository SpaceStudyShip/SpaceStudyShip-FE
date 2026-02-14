import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../providers/timer_provider.dart';
import '../providers/timer_state.dart';
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
            onPressed: () {
              // TODO: 타이머 기록 화면 (향후 구현)
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 연동된 할일 표시
            if (timerState.linkedTodoTitle != null) ...[
              FadeSlideIn(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        color: AppColors.primary,
                        size: 16.w,
                      ),
                      SizedBox(width: AppSpacing.s8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200.w),
                        child: Text(
                          timerState.linkedTodoTitle!,
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s24),
            ],

            // 타이머 링 + 시간 표시
            FadeSlideIn(
              child: SizedBox(
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
                            Text(
                              isIdle
                                  ? '집중 시간을 측정해보세요'
                                  : isRunning
                                  ? '집중 중...'
                                  : '일시정지',
                              style: AppTextStyles.tag_12.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s48),

            // 컨트롤 버튼
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: _buildControls(isIdle, isRunning, isPaused),
            ),
            SizedBox(height: AppSpacing.s48),

            // 오늘의 통계 (하드코딩 유지 -- 향후 구현)
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Padding(
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
                        value: '0시간 0분',
                      ),
                      Container(
                        width: 1,
                        height: 40.h,
                        color: AppColors.spaceDivider,
                      ),
                      SpaceStatItem(
                        icon: Icons.date_range_rounded,
                        label: '이번 주',
                        value: '0시간 0분',
                      ),
                      Container(
                        width: 1,
                        height: 40.h,
                        color: AppColors.spaceDivider,
                      ),
                      SpaceStatItem(
                        icon: Icons.local_fire_department_rounded,
                        label: '연속',
                        value: '0일',
                      ),
                    ],
                  ),
                ),
              ),
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
              onPressed: () => ref.read(timerNotifierProvider.notifier).stop(),
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
    final selectedTodo = await showTodoSelectBottomSheet(context: context);

    if (!mounted) return;

    ref
        .read(timerNotifierProvider.notifier)
        .start(todoId: selectedTodo?.id, todoTitle: selectedTodo?.title);
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
