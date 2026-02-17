import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 앱 전역에서 사용하는 SnackBar 유틸리티 - 토스 스타일
///
/// **기본 스펙**:
/// - floating 스타일
/// - 아이콘 + 메시지
/// - 2초 자동 닫힘
/// - 12px 라운드
///
/// **사용 예시**:
/// ```dart
/// // 성공
/// AppSnackBar.success(context, '저장했어요');
///
/// // 에러
/// AppSnackBar.error(context, '저장에 실패했어요');
///
/// // 정보
/// AppSnackBar.info(context, '새로운 업데이트가 있어요');
///
/// // 경고
/// AppSnackBar.warning(context, '입력값을 확인해 주세요');
///
/// // 실행 취소 지원
/// AppSnackBar.showWithUndo(
///   context: context,
///   message: '삭제했어요',
///   onUndo: () => restoreItem(),
/// );
/// ```
class AppSnackBar {
  // Private 생성자 - 인스턴스화 방지
  AppSnackBar._();

  /// 기본 표시 시간 (2초)
  static const Duration _defaultDuration = Duration(seconds: 2);

  /// Undo 표시 시간 (4초)
  static const Duration _undoDuration = Duration(seconds: 4);

  // ============================================
  // 타입별 SnackBar
  // ============================================

  /// 성공 스낵바 (초록색)
  static void success(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: Icons.check_circle,
      iconColor: AppColors.success,
    );
  }

  /// 에러 스낵바 (빨간색)
  static void error(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: Icons.error,
      iconColor: AppColors.error,
    );
  }

  /// 정보 스낵바 (파란색)
  static void info(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: Icons.info,
      iconColor: AppColors.info,
    );
  }

  /// 경고 스낵바 (주황색)
  static void warning(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: Icons.warning,
      iconColor: AppColors.warning,
    );
  }

  /// 실행 취소 가능한 스낵바
  static void showWithUndo({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
  }) {
    _show(
      context: context,
      message: message,
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      duration: _undoDuration,
      action: SnackBarAction(
        label: '실행 취소',
        textColor: AppColors.primary,
        onPressed: onUndo,
      ),
    );
  }

  /// 커스텀 스낵바
  static void custom({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? iconColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context: context,
      message: message,
      icon: icon,
      iconColor: iconColor,
      duration: duration,
      action: action,
    );
  }

  // ============================================
  // 내부 구현
  // ============================================

  static void _show({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? iconColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    // 기존 스낵바 닫기
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.w, color: iconColor ?? Colors.white),
            SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.paragraph_14.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      duration: duration ?? _defaultDuration,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: AppColors.spaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.snackbar),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      action: action,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 현재 표시 중인 스낵바 닫기
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// 모든 스낵바 닫기
  static void hideAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
