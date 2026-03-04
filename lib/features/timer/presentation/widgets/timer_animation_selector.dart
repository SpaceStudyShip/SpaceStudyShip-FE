import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/atoms/drag_handle.dart';
import 'timer_ring_painter.dart';

/// 타이머 모드 식별 상수
const basicTimerAsset = 'basic';

/// 타이머 애니메이션 데이터
class TimerAnimationData {
  const TimerAnimationData({required this.asset, required this.name});

  final String asset;
  final String name;

  /// 기본값: 기본 타이머 (원형 링 + 숫자)
  static const defaultAsset = basicTimerAsset;

  static const List<TimerAnimationData> animations = [
    TimerAnimationData(asset: basicTimerAsset, name: '기본 타이머'),
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

  /// Lottie 애니메이션인지 여부
  bool get isLottie => asset != basicTimerAsset;
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
              '타이머 스타일',
              style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
            ),
          ),

          // 애니메이션 목록
          ...TimerAnimationData.animations.map((anim) {
            final isSelected = anim.asset == currentAsset;
            return _buildAnimationItem(context, anim, isSelected);
          }),

          // 안전 영역 여백
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.s20),
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
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
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
            // 미리보기
            SizedBox(
              width: 64.w,
              height: 64.w,
              child: anim.isLottie
                  ? Lottie.asset(anim.asset, fit: BoxFit.contain)
                  : _buildBasicTimerPreview(),
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

  /// 기본 타이머 미리보기: 작은 원형 링 + 시간 텍스트
  Widget _buildBasicTimerPreview() {
    return CustomPaint(
      painter: TimerRingPainter(
        progress: 0.65,
        isRunning: true,
        strokeWidth: 3.w,
      ),
      child: Center(
        child: Text(
          '00:00',
          style: AppTextStyles.tag10Semibold.copyWith(color: AppColors.textPrimary),
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
    barrierColor: AppColors.barrier,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => TimerAnimationSelector(currentAsset: currentAsset),
  );
}
