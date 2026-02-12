import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/exploration_progress_entity.dart';

/// 탐험 진행도 바 위젯
///
/// 행성/지역의 클리어 진행 상태를 수평 프로그레스 바로 표시합니다.
class ExplorationProgressBar extends StatelessWidget {
  const ExplorationProgressBar({
    super.key,
    required this.progress,
    this.showLabel = true,
    this.height,
  });

  /// 진행도 데이터
  final ExplorationProgressEntity progress;

  /// 라벨(n/n) 표시 여부
  final bool showLabel;

  /// 바 높이 (기본 6.h)
  final double? height;

  Color get _progressColor {
    if (progress.isCompleted) return AppColors.success;
    if (progress.progressRatio >= 0.5) return AppColors.primary;
    return AppColors.accentGold;
  }

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? 6.h;

    return Row(
      children: [
        // 프로그레스 바
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(barHeight / 2),
            child: SizedBox(
              height: barHeight,
              child: Stack(
                children: [
                  // 배경
                  Container(
                    color: AppColors.spaceDivider.withValues(alpha: 0.5),
                  ),
                  // 진행
                  FractionallySizedBox(
                    widthFactor: progress.progressRatio.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _progressColor,
                            _progressColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 라벨
        if (showLabel) ...[
          SizedBox(width: AppSpacing.s8),
          Text(
            '${progress.clearedChildren}/${progress.totalChildren}',
            style: AppTextStyles.tag_12.copyWith(
              color: progress.isCompleted
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
