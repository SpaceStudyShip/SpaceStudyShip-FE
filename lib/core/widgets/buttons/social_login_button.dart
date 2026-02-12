import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_button.dart';

/// Google 소셜 로그인 버튼
///
/// **디자인 스펙**:
/// - 배경색: Colors.white (#FFFFFF)
/// - 텍스트색: Color(0xFF000000)
/// - 아이콘: assets/icons/icon_google.svg (20x20)
/// - 아이콘-텍스트 간격: 8px
///
/// **사용 예시**:
/// ```dart
/// GoogleLoginButton(
///   onPressed: () => handleGoogleLogin(),
///   isLoading: isLoading,
/// )
/// ```
class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  /// 버튼 클릭 핸들러
  final VoidCallback? onPressed;

  /// 로딩 상태
  final bool isLoading;

  /// 버튼 너비 (기본: AppButton 기본값)
  final double? width;

  /// 버튼 높이 (기본: AppButton 기본값)
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Google로 시작하기',
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/icons/icon_google.svg',
        width: 20.w,
        height: 20.h,
      ),
      iconPosition: IconPosition.leading,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF000000),
      showBorder: true,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }
}

/// Apple 소셜 로그인 버튼
///
/// **디자인 스펙**:
/// - 배경색: Color(0xFF000000) (순수 블랙)
/// - 텍스트색: Colors.white (#FFFFFF)
/// - 아이콘: assets/icons/icon_apple.svg (20x20)
/// - 아이콘-텍스트 간격: 8px
///
/// **사용 예시**:
/// ```dart
/// AppleLoginButton(
///   onPressed: () => handleAppleLogin(),
///   isLoading: isLoading,
/// )
/// ```
class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  /// 버튼 클릭 핸들러
  final VoidCallback? onPressed;

  /// 로딩 상태
  final bool isLoading;

  /// 버튼 너비 (기본: AppButton 기본값)
  final double? width;

  /// 버튼 높이 (기본: AppButton 기본값)
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Apple로 시작하기',
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/icons/icon_apple.svg',
        width: 20.w,
        height: 20.h,
      ),
      iconPosition: IconPosition.leading,
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
      showBorder: false,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }
}
