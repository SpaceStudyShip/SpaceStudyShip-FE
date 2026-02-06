import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 부스터 배너 위젯 - 우주 테마
///
/// **사용 예시**:
/// ```dart
/// BoosterBanner(
///   multiplier: 1.5,
///   remainingMinutes: 45,
///   isActive: true,
/// )
/// ```
class BoosterBanner extends StatelessWidget {
  const BoosterBanner({
    super.key,
    required this.multiplier,
    required this.remainingMinutes,
    this.isActive = true,
    this.onTap,
  });

  /// 부스터 배율 (예: 1.5, 2.0)
  final double multiplier;

  /// 남은 시간 (분)
  final int remainingMinutes;

  /// 활성화 상태
  final bool isActive;

  /// 탭 콜백
  final VoidCallback? onTap;

  String get _multiplierText => '$multiplier배';

  String get _remainingText {
    if (remainingMinutes >= 60) {
      final hours = remainingMinutes ~/ 60;
      final mins = remainingMinutes % 60;
      return mins > 0 ? '$hours시간 $mins분' : '$hours시간';
    }
    return '$remainingMinutes분';
  }

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.15),
          borderRadius: AppRadius.large,
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 로켓 아이콘
            Text('🚀', style: TextStyle(fontSize: 20.w)),
            SizedBox(width: 8.w),

            // 메시지
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: _multiplierText,
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' 부스터 활성화 중!'),
                  ],
                ),
              ),
            ),

            // 남은 시간
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: AppRadius.small,
              ),
              child: Text(
                '남은 시간: $_remainingText',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.accentGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
