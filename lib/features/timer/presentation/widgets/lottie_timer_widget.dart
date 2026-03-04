import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../providers/timer_animation_provider.dart';
import 'timer_animation_selector.dart';

/// 타이머 Lottie 애니메이션 위젯
///
/// isRunning일 때만 재생. 탭 시 애니메이션 선택 바텀시트 호출.
class LottieTimerWidget extends ConsumerWidget {
  const LottieTimerWidget({
    super.key,
    required this.isRunning,
    this.size = 400,
  });

  final bool isRunning;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsset = ref.watch(timerAnimationNotifierProvider);
    final canvasSize = size.w;

    return GestureDetector(
      onTap: () => _onTap(context, ref, currentAsset),
      child: SizedBox(
        width: canvasSize,
        height: canvasSize,
        child: Lottie.asset(
          currentAsset,
          fit: BoxFit.contain,
          animate: isRunning,
          repeat: true,
        ),
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
}
