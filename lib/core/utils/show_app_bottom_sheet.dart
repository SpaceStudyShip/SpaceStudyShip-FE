import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/spacing_and_radius.dart';

/// 앱 공통 바텀시트 헬퍼
///
/// 플로팅 네비게이션 높이를 자동으로 반영한 하단 패딩을 제공한다.
/// 모든 바텀시트는 이 함수를 통해 열어야 플로팅 네비에 가려지지 않는다.
///
/// [bottomPadding]을 통해 플로팅 네비 높이를 포함한 하단 여백을 자동 계산한다.
/// 바텀시트 콘텐츠 내부에서 직접 SafeArea 하단 패딩을 추가할 필요 없다.
///
/// ```dart
/// showAppBottomSheet<String>(
///   context: context,
///   builder: (context, bottomPadding) => MySheet(bottomPadding: bottomPadding),
/// );
/// ```
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, double bottomPadding) builder,
  Color? barrierColor,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final safeAreaBottom = MediaQuery.of(context).padding.bottom;
  final bottomPadding =
      safeAreaBottom + FloatingNavMetrics.totalHeight + AppSpacing.s12;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ?? AppColors.barrier,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) => builder(context, bottomPadding),
  );
}
