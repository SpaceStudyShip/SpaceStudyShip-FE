import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 행성 롱프레스 시 표시되는 컨텍스트 메뉴 결과
enum PlanetMenuAction { edit, move, delete }

/// 행성 롱프레스 컨텍스트 메뉴 표시
///
/// [position]은 LongPressStartDetails.globalPosition에서 가져옴.
/// 반환: 선택된 액션 또는 null(취소)
Future<PlanetMenuAction?> showPlanetContextMenu({
  required BuildContext context,
  required Offset position,
}) {
  return showMenu<PlanetMenuAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    color: AppColors.spaceSurface,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.large,
      side: BorderSide(color: AppColors.spaceDivider),
    ),
    items: [
      PopupMenuItem(
        value: PlanetMenuAction.edit,
        child: Row(
          children: [
            Icon(Icons.edit_rounded, size: 18.w, color: Colors.white),
            SizedBox(width: AppSpacing.s8),
            Text(
              '수정',
              style: AppTextStyles.label_16.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: PlanetMenuAction.move,
        child: Row(
          children: [
            Icon(Icons.open_with_rounded, size: 18.w, color: Colors.white),
            SizedBox(width: AppSpacing.s8),
            Text(
              '위치 이동',
              style: AppTextStyles.label_16.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: PlanetMenuAction.delete,
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 18.w, color: AppColors.error),
            SizedBox(width: AppSpacing.s8),
            Text(
              '삭제',
              style: AppTextStyles.label_16.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    ],
  );
}
