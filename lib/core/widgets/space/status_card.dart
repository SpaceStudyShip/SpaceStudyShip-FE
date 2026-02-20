import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../cards/app_card.dart';
import 'fuel_gauge.dart';
import 'streak_badge.dart';

/// 상태 카드 위젯 - 메인 홈용
///
/// 현재 위치, 연료, 스트릭 정보를 통합 표시
///
/// **사용 예시**:
/// ```dart
/// StatusCard(
///   location: '서울',
///   locationFlag: '🇰🇷',
///   fuel: 3,
///   streakDays: 5,
/// )
/// ```
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.location,
    this.locationFlag,
    required this.fuel,
    required this.streakDays,
    this.isStreakActive = true,
    this.onTap,
  });

  /// 현재 위치 이름
  final String location;

  /// 위치 국기 이모지 (예: 🇰🇷)
  final String? locationFlag;

  /// 현재 연료
  final int fuel;

  /// 스트릭 일수
  final int streakDays;

  /// 스트릭 활성화 상태
  final bool isStreakActive;

  /// 탭 콜백
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: AppCardStyle.outlined,
      onTap: onTap,
      padding: AppPadding.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 현재 위치
          Row(
            children: [
              Icon(Icons.public_rounded, size: 18.w, color: AppColors.primary),
              SizedBox(width: AppSpacing.s8),
              Text(
                '현재 위치: ',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (locationFlag != null) ...[
                Text(locationFlag!, style: AppTextStyles.label_16),
                SizedBox(width: AppSpacing.s4),
              ],
              Text(
                location,
                style: AppTextStyles.label_16.copyWith(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12),

          // 연료
          FuelGauge(
            currentFuel: fuel,
            showLabel: true,
            showIcon: true,
            size: FuelGaugeSize.medium,
          ),
          SizedBox(height: AppSpacing.s12),

          // 스트릭
          StreakBadge(
            days: streakDays,
            isActive: isStreakActive,
            showLabel: true,
            size: StreakBadgeSize.medium,
          ),
        ],
      ),
    );
  }
}
