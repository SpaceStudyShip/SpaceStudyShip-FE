import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// SnackBar 타입 (폰 레스토프 효과)
enum SpaceSnackBarType {
  /// 성공 (초록색)
  success,

  /// 에러 (빨간색)
  error,

  /// 경고 (주황색)
  warning,

  /// 정보 (파란색)
  info,

  /// 중립 (회색)
  neutral,
}

/// 우주공부선 SnackBar 유틸리티
///
/// Toss UX 원칙이 적용된 일관된 SnackBar를 제공합니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 폰 레스토프 효과: 타입별 색상/아이콘 차별화
/// - 도허티 임계: 즉각적인 피드백 (0ms 딜레이)
/// - 피크엔드 법칙: 성공 시 긍정적 경험
/// - 피츠의 법칙: 액션 버튼 터치 영역 최적화
///
/// **사용 예시:**
/// ```dart
/// // 성공 메시지
/// SpaceSnackBar.success(context, '저장했어요');
///
/// // 에러 메시지
/// SpaceSnackBar.error(context, '저장에 실패했어요');
///
/// // 실행 취소 지원
/// SpaceSnackBar.showWithUndo(
///   context: context,
///   message: '삭제했어요',
///   onUndo: () => restoreItem(),
/// );
/// ```
class SpaceSnackBar {
  // Private 생성자 - 인스턴스화 방지
  SpaceSnackBar._();

  /// SnackBar 기본 표시 시간 (4초)
  static const Duration _defaultDuration = Duration(seconds: 4);

  /// 실행 취소 기본 시간 (5초)
  static const Duration _defaultUndoWindow = Duration(seconds: 5);

  /// 타입별 색상 매핑
  static Color _getBackgroundColor(SpaceSnackBarType type) {
    switch (type) {
      case SpaceSnackBarType.success:
        return AppColors.success;
      case SpaceSnackBarType.error:
        return AppColors.error;
      case SpaceSnackBarType.warning:
        return AppColors.warning;
      case SpaceSnackBarType.info:
        return AppColors.primary;
      case SpaceSnackBarType.neutral:
        return AppColors.spaceElevated;
    }
  }

  /// 타입별 아이콘 매핑
  static IconData _getIcon(SpaceSnackBarType type) {
    switch (type) {
      case SpaceSnackBarType.success:
        return Icons.check_circle;
      case SpaceSnackBarType.error:
        return Icons.error;
      case SpaceSnackBarType.warning:
        return Icons.warning;
      case SpaceSnackBarType.info:
        return Icons.info;
      case SpaceSnackBarType.neutral:
        return Icons.notifications;
    }
  }

  /// 기본 SnackBar 표시
  static void show({
    required BuildContext context,
    required String message,
    SpaceSnackBarType type = SpaceSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
    bool enableHaptic = true,
  }) {
    // 햅틱 피드백 (도허티 임계)
    if (enableHaptic) {
      switch (type) {
        case SpaceSnackBarType.success:
          HapticFeedback.lightImpact();
        case SpaceSnackBarType.error:
          HapticFeedback.heavyImpact();
        case SpaceSnackBarType.warning:
          HapticFeedback.mediumImpact();
        default:
          HapticFeedback.selectionClick();
      }
    }

    final backgroundColor = _getBackgroundColor(type);
    final icon = _getIcon(type);
    final textColor = type == SpaceSnackBarType.neutral
        ? AppColors.textPrimary
        : AppColors.textOnPrimary;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body2.medium().copyWith(color: textColor),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(width: 8.w),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  minimumSize: Size(48.w, 36.h), // 피츠의 법칙
                ),
                child: Text(
                  actionLabel,
                  style: AppTextStyles.body2.semiBold().copyWith(
                    color: textColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.snackbar),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        duration: duration,
        elevation: 4,
      ),
    );
  }

  /// 성공 메시지 표시
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SpaceSnackBarType.success,
      duration: duration ?? _defaultDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 에러 메시지 표시
  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SpaceSnackBarType.error,
      duration: duration ?? _defaultDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 정보 메시지 표시
  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SpaceSnackBarType.info,
      duration: duration ?? _defaultDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 경고 메시지 표시
  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SpaceSnackBarType.warning,
      duration: duration ?? _defaultDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 실행 취소 지원 SnackBar (테슬러 법칙)
  ///
  /// 사용자가 실수로 삭제한 경우 복구할 수 있는 기회 제공
  static void showWithUndo({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    Duration undoWindow = _defaultUndoWindow,
    SpaceSnackBarType type = SpaceSnackBarType.info,
  }) {
    show(
      context: context,
      message: message,
      type: type,
      actionLabel: '취소',
      onAction: onUndo,
      duration: undoWindow,
    );
  }

  /// 현재 SnackBar 즉시 닫기
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// 모든 SnackBar 즉시 닫기
  static void hideAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
