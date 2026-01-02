import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/spacing_and_radius.dart';
import '../../../constants/text_styles.dart';

/// 우주공부선 Primary Button
///
/// Material 3 ElevatedButton 기반의 주요 액션 버튼입니다.
/// 우주 테마의 Deep Space Blue 색상을 사용하며,
/// 전역 테마 설정을 따릅니다.
///
/// **사용 예시**:
/// ```dart
/// SpacePrimaryButton(
///   text: '시작하기',
///   onPressed: () {
///     // 액션 처리
///   },
/// )
/// ```
///
/// **비활성 상태**:
/// ```dart
/// SpacePrimaryButton(
///   text: '로딩 중...',
///   onPressed: null, // null이면 비활성
/// )
/// ```
class SpacePrimaryButton extends StatelessWidget {
  /// Primary Button 생성자
  const SpacePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  /// 버튼 텍스트
  final String text;

  /// 버튼 클릭 시 실행될 콜백
  /// null이면 버튼이 비활성 상태가 됩니다
  final VoidCallback? onPressed;

  /// 로딩 상태 여부
  /// true일 경우 CircularProgressIndicator 표시
  final bool isLoading;

  /// 버튼 너비 (미지정 시 부모 너비에 맞춤)
  final double? width;

  /// 버튼 높이 (미지정 시 테마 기본값 사용)
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: AppPadding.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.textOnPrimary,
                  ),
                ),
              )
            : Text(
                text,
                style: AppTextStyles.body1.semiBold(),
              ),
      ),
    );
  }
}
