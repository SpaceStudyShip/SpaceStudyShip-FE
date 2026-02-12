import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/atoms/space_stat_item.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../widgets/timer_ring_painter.dart';

/// 타이머 스크린
///
/// 공부 시간 측정 및 연료 획득 화면입니다.
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // TODO: 타이머 기록 화면
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 타이머 링 + 시간 표시
            FadeSlideIn(
              child: SizedBox(
                width: 260.w,
                height: 260.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 원형 프로그레스 링
                    CustomPaint(
                      size: Size(260.w, 260.w),
                      painter: TimerRingPainter(
                        progress: 0.0,
                        isRunning: false,
                        strokeWidth: 6.w,
                      ),
                    ),
                    // 시간 텍스트
                    Padding(
                      padding: AppPadding.horizontal16,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '00:00:00',
                              style: AppTextStyles.timer_48.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s4),
                            Text(
                              '집중 시간을 측정해보세요',
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

            // 시작 버튼
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: AppButton(
                text: '시작하기',
                onPressed: () {
                  // TODO: 타이머 시작
                },
              ),
            ),
            SizedBox(height: AppSpacing.s48),

            // 오늘의 통계
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
}
