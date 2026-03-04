import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';

/// 타이머 애니메이션 데이터
class TimerAnimationData {
  const TimerAnimationData({required this.asset, required this.name});

  final String asset;
  final String name;

  static const defaultAsset = 'assets/lotties/Earth_and_Connections.json';

  static const List<TimerAnimationData> animations = [
    TimerAnimationData(
      asset: 'assets/lotties/Earth_and_Connections.json',
      name: '지구와 연결',
    ),
    TimerAnimationData(
      asset: 'assets/lotties/Travel_the_World.json',
      name: '세계 여행',
    ),
  ];

  static bool isValidAsset(String asset) {
    return animations.any((a) => a.asset == asset);
  }
}

/// 타이머 애니메이션 선택 바텀시트
class TimerAnimationSelector extends StatelessWidget {
  const TimerAnimationSelector({super.key, required this.currentAsset});

  final String currentAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: AppRadius.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandle(),

          // 제목
          Padding(
            padding: AppPadding.bottomSheetTitlePadding,
            child: Text(
              '타이머 애니메이션',
              style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
            ),
          ),

          // 애니메이션 목록
          ...TimerAnimationData.animations.map((anim) {
            final isSelected = anim.asset == currentAsset;
            return _buildAnimationItem(context, anim, isSelected);
          }),

          // 안전 영역 여백
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
        ],
      ),
    );
  }

  Widget _buildAnimationItem(
    BuildContext context,
    TimerAnimationData anim,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(anim.asset),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        padding: AppPadding.all16,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.spaceElevated,
          borderRadius: AppRadius.large,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(
                  color: AppColors.spaceDivider.withValues(alpha: 0.3),
                ),
        ),
        child: Row(
          children: [
            // Lottie 미리보기
            SizedBox(
              width: 64.w,
              height: 64.w,
              child: Lottie.asset(anim.asset, fit: BoxFit.contain),
            ),
            SizedBox(width: AppSpacing.s16),
            // 이름
            Expanded(
              child: Text(
                anim.name,
                style: AppTextStyles.label_16.copyWith(
                  color: isSelected ? AppColors.primary : Colors.white,
                ),
              ),
            ),
            // 선택 표시
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }
}

/// 타이머 애니메이션 선택 바텀시트 표시 헬퍼
Future<String?> showTimerAnimationSelector({
  required BuildContext context,
  required String currentAsset,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => TimerAnimationSelector(currentAsset: currentAsset),
  );
}
