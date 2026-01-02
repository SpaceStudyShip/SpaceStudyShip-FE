import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';

/// 우주공부선 SnackBar 유틸리티
///
/// 우주 테마에 맞는 일관된 SnackBar를 제공합니다.
/// Success, Error, Info, Warning 4가지 타입을 지원합니다.
///
/// **사용 예시**:
/// ```dart
/// // 성공 메시지
/// SpaceSnackBar.success(context, '저장되었습니다!');
///
/// // 에러 메시지
/// SpaceSnackBar.error(context, '저장에 실패했습니다.');
///
/// // 정보 메시지
/// SpaceSnackBar.info(context, '새로운 업데이트가 있습니다.');
///
/// // 경고 메시지
/// SpaceSnackBar.warning(context, '입력값을 확인해주세요.');
/// ```
class SpaceSnackBar {
  // Private 생성자 - 인스턴스화 방지
  SpaceSnackBar._();

  /// SnackBar 기본 표시 시간 (5초)
  static const Duration _defaultDuration = Duration(seconds: 5);

  /// 베이스 SnackBar 생성 (내부 헬퍼 메서드)
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = _defaultDuration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textOnPrimary,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body2.medium().copyWith(
                      color: AppColors.textOnPrimary,
                    ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.snackbar,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        duration: duration,
        elevation: 4,
      ),
    );
  }

  /// 성공 메시지 표시
  ///
  /// **사용 예시**:
  /// ```dart
  /// SpaceSnackBar.success(context, '저장되었습니다!');
  /// ```
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
      duration: duration ?? _defaultDuration,
    );
  }

  /// 에러 메시지 표시
  ///
  /// **사용 예시**:
  /// ```dart
  /// SpaceSnackBar.error(context, '저장에 실패했습니다.');
  /// ```
  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error,
      duration: duration ?? _defaultDuration,
    );
  }

  /// 정보 메시지 표시
  ///
  /// **사용 예시**:
  /// ```dart
  /// SpaceSnackBar.info(context, '새로운 업데이트가 있습니다.');
  /// ```
  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.primary,
      icon: Icons.info,
      duration: duration ?? _defaultDuration,
    );
  }

  /// 경고 메시지 표시
  ///
  /// **사용 예시**:
  /// ```dart
  /// SpaceSnackBar.warning(context, '입력값을 확인해주세요.');
  /// ```
  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning,
      duration: duration ?? _defaultDuration,
    );
  }
}
