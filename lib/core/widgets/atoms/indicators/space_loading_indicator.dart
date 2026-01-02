import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/text_styles.dart';

/// 우주공부선 Loading Indicator
///
/// CircularProgressIndicator 기반의 로딩 인디케이터입니다.
/// 우주 테마의 Primary 색상을 사용하며,
/// 선택적으로 로딩 메시지를 표시할 수 있습니다.
///
/// **기본 사용**:
/// ```dart
/// SpaceLoadingIndicator()
/// ```
///
/// **메시지와 함께**:
/// ```dart
/// SpaceLoadingIndicator(
///   message: '데이터를 불러오는 중...',
/// )
/// ```
///
/// **크기 지정**:
/// ```dart
/// SpaceLoadingIndicator(
///   size: 60,
///   strokeWidth: 4,
/// )
/// ```
class SpaceLoadingIndicator extends StatelessWidget {
  /// Loading Indicator 생성자
  const SpaceLoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
  });

  /// 로딩 메시지 (선택적)
  final String? message;

  /// 인디케이터 크기
  final double size;

  /// 인디케이터 선 두께
  final double strokeWidth;

  /// 인디케이터 색상 (미지정 시 primary)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size.w,
            height: size.w,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth.w,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: AppTextStyles.body2.regular().copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
