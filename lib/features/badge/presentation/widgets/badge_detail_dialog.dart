import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/space_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../domain/entities/badge_entity.dart';

/// 배지 상세 다이얼로그 (공통)
///
/// [isUnlockCelebration] 이 true 이면 해금 축하 팝업으로 표시합니다.
Future<void> showBadgeDetailDialog(
  BuildContext context,
  BadgeEntity badge, {
  bool isUnlockCelebration = false,
}) {
  final showRealIcon = badge.isUnlocked || isUnlockCelebration;
  final hiddenAndLocked =
      !showRealIcon && badge.category == BadgeCategory.hidden;
  final iconId = hiddenAndLocked ? SpaceIcons.lock : badge.icon;
  final iconColor = showRealIcon ? Colors.white : AppColors.textTertiary;

  return AppDialog.show(
    context: context,
    title: isUnlockCelebration
        ? '배지 획득!'
        : badge.isUnlocked
        ? badge.name
        : badge.category == BadgeCategory.hidden
        ? '???'
        : badge.name,
    customContent: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          SpaceIcons.resolve(iconId),
          size: 48.sp,
          color: iconColor,
        ),
        SizedBox(height: AppSpacing.s12),
        if (isUnlockCelebration) ...[
          Text(
            badge.name,
            style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
          ),
          SizedBox(height: AppSpacing.s8),
        ],
        Text(
          showRealIcon
              ? badge.description
              : badge.category == BadgeCategory.hidden
              ? '아직 해금되지 않은 배지예요'
              : '해금 조건: ${badge.unlockConditionText}',
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
