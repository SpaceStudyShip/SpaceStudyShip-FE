import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/show_app_bottom_sheet.dart';
import '../../../../core/widgets/space/spaceship_card.dart';
import '../models/spaceship_data.dart';

export '../models/spaceship_data.dart';

/// 우주선 선택 바텀시트
///
/// 사용 가능한 우주선 목록을 그리드로 표시합니다.
///
/// **사용 예시**:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => SpaceshipSelector(
///     spaceships: mySpaceships,
///     selectedId: currentSpaceshipId,
///     onSelect: (id) => selectSpaceship(id),
///   ),
/// );
/// ```
class SpaceshipSelector extends StatelessWidget {
  const SpaceshipSelector({
    super.key,
    required this.spaceships,
    required this.selectedId,
    required this.onSelect,
    required this.bottomPadding,
  });

  /// 우주선 목록
  final List<SpaceshipData> spaceships;

  /// 현재 선택된 우주선 ID
  final String selectedId;

  /// 선택 콜백
  final ValueChanged<String> onSelect;

  /// 플로팅 네비 반영 하단 패딩
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들 (홈 시트와 동일)
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // 제목 (홈 시트와 동일 스타일)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Text(
              '우주선 선택',
              style: AppTextStyles.subHeading_18.copyWith(color: Colors.white),
            ),
          ),

          // 우주선 그리드
          Flexible(
            child: SingleChildScrollView(
              padding: AppPadding.all20,
              child: Wrap(
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s12,
                alignment: WrapAlignment.center,
                children: spaceships.map((spaceship) {
                  return SpaceshipCard(
                    icon: spaceship.icon,
                    name: spaceship.name,
                    isUnlocked: spaceship.isUnlocked,
                    isAnimated: spaceship.isAnimated,
                    isSelected: spaceship.id == selectedId,
                    rarity: spaceship.rarity,
                    onTap: spaceship.isUnlocked
                        ? () {
                            onSelect(spaceship.id);
                            Navigator.of(context).pop();
                          }
                        : null,
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

/// 우주선 선택 바텀시트 표시 헬퍼
Future<void> showSpaceshipSelector({
  required BuildContext context,
  required List<SpaceshipData> spaceships,
  required String selectedId,
  required ValueChanged<String> onSelect,
}) {
  return showAppBottomSheet(
    context: context,
    builder: (context, bottomPadding) => SpaceshipSelector(
      spaceships: spaceships,
      selectedId: selectedId,
      onSelect: onSelect,
      bottomPadding: bottomPadding,
    ),
  );
}
