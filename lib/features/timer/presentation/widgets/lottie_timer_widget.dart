import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../providers/timer_animation_provider.dart';
import '../utils/timer_format_utils.dart';
import 'timer_animation_selector.dart';
import 'timer_ring_painter.dart';

/// 타이머 비주얼 위젯
///
/// Provider의 선택 값에 따라 기본 타이머(링+숫자) 또는 Lottie 애니메이션을 표시.
/// 탭 시 스타일 선택 바텀시트 호출.
class TimerVisualWidget extends ConsumerWidget {
  const TimerVisualWidget({
    super.key,
    required this.isRunning,
    required this.elapsed,
    this.lottieSize = 400,
    this.basicSize = 260,
  });

  final bool isRunning;
  final Duration elapsed;
  final double lottieSize;
  final double basicSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsset = ref.watch(timerAnimationNotifierProvider);
    final isBasic = currentAsset == basicTimerAsset;

    return GestureDetector(
      onTap: () => _onTap(context, ref, currentAsset),
      child: isBasic
          ? _buildBasicTimer(context)
          : _buildLottieTimer(currentAsset),
    );
  }

  /// 기본 타이머: 원형 프로그레스 링 + 중앙 시간 표시
  Widget _buildBasicTimer(BuildContext context) {
    final size = basicSize.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: TimerRingPainter(
              progress: _calculateProgress(elapsed),
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
                    formatDuration(elapsed),
                    style: AppTextStyles.timer_48.copyWith(
                      color: isRunning ? AppColors.primary : Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s4),
                  Text(
                    isRunning ? '집중 중...' : '준비',
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
    );
  }

  /// Lottie 애니메이션 타이머
  Widget _buildLottieTimer(String asset) {
    final size = lottieSize.w;

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        asset,
        fit: BoxFit.contain,
        animate: isRunning,
        repeat: true,
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    String currentAsset,
  ) async {
    final selected = await showTimerAnimationSelector(
      context: context,
      currentAsset: currentAsset,
    );

    if (selected != null && selected != currentAsset) {
      ref.read(timerAnimationNotifierProvider.notifier).select(selected);
    }
  }

  /// 1시간(3600초)을 한 바퀴로 계산. 넘으면 다시 0부터.
  double _calculateProgress(Duration elapsed) {
    const oneHourSeconds = 3600;
    return (elapsed.inSeconds % oneHourSeconds) / oneHourSeconds;
  }
}
