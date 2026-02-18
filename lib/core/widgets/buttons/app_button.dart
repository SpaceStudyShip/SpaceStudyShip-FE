import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';

/// 아이콘 위치를 정의하는 Enum
///
/// 버튼 내에서 아이콘이 텍스트의 왼쪽에 위치할지 오른쪽에 위치할지 결정합니다.
enum IconPosition {
  /// 텍스트 왼쪽에 아이콘 배치
  leading,

  /// 텍스트 오른쪽에 아이콘 배치
  trailing,
}

/// 앱 전역에서 사용하는 공용 버튼 컴포넌트 - 토스 스타일 우주 테마
///
/// **기본 스펙**:
/// - 크기: 353x56 (반응형)
/// - 모서리: 16px 라운드
/// - 텍스트: AppTextStyles.label_16
/// - 테두리: 기본 1px (showBorder로 제어 가능)
///
/// **토스 스타일 애니메이션**:
/// - 탭 시 스케일: 0.97 (3% 축소)
/// - Duration: 150ms (즉각적 피드백)
/// - Curve: easeOutBack (스프링 느낌)
///
/// **우주 테마 색상**:
/// - 활성화: 배경 primary (Deep Space Blue), 텍스트 white
/// - 비활성화: 배경 spaceSurface, 텍스트 textDisabled
/// - 테두리: primaryDark (활성) / transparent (비활성)
///
/// **사용 예시**:
/// ```dart
/// // 기본 Primary 버튼
/// AppButton(
///   text: '시작하기',
///   onPressed: () {},
/// )
///
/// // Secondary 버튼 (보조 액션)
/// AppButton(
///   text: '건너뛰기',
///   onPressed: () {},
///   backgroundColor: AppColors.secondary,
/// )
///
/// // 아이콘 포함 버튼
/// AppButton(
///   text: '설정',
///   onPressed: () {},
///   icon: Icon(Icons.settings, size: 20.w),
///   iconPosition: IconPosition.leading,
/// )
///
/// // 로딩 중 버튼
/// AppButton(
///   text: '로그인 중...',
///   onPressed: () {},
///   isLoading: true,
/// )
/// ```
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.showBorder = true,
    this.borderWidth = 1.0,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.subtitle,
    this.subtitleColor,
    this.contentAlignment,
  });

  /// 버튼 텍스트 (필수)
  final String text;

  /// 버튼 클릭 핸들러 (필수, null이면 비활성화)
  final VoidCallback? onPressed;

  /// 활성화 상태 배경색 (기본: AppColors.primary - Deep Space Blue)
  final Color? backgroundColor;

  /// 활성화 상태 텍스트/아이콘 색상 (기본: AppColors.textOnPrimary - white)
  final Color? foregroundColor;

  /// 비활성화 상태 배경색 (기본: AppColors.spaceSurface)
  final Color? disabledBackgroundColor;

  /// 비활성화 상태 텍스트/아이콘 색상 (기본: AppColors.textDisabled)
  final Color? disabledForegroundColor;

  /// 테두리 표시 여부 (기본: true)
  final bool showBorder;

  /// 테두리 두께 (기본: 1.0px)
  final double borderWidth;

  /// 활성화 상태 테두리 색상 (기본: AppColors.primaryDark)
  final Color? borderColor;

  /// 버튼 너비 (기본: 353.w)
  final double? width;

  /// 버튼 높이 (기본: 56.h)
  final double? height;

  /// 모서리 반경 (기본: 16.r)
  final BorderRadius? borderRadius;

  /// 아이콘 위젯 (선택 사항)
  final Widget? icon;

  /// 아이콘 위치 (기본: leading - 텍스트 왼쪽)
  final IconPosition iconPosition;

  /// 로딩 상태 (true면 CircularProgressIndicator 표시)
  final bool isLoading;

  /// 서브 텍스트 (선택 사항, 메인 텍스트 아래 작은 글씨)
  final String? subtitle;

  /// 서브 텍스트 색상 (기본: foregroundColor)
  final Color? subtitleColor;

  /// 버튼 내용 정렬 (기본: center, spaceBetween으로 좌우 정렬 가능)
  final MainAxisAlignment? contentAlignment;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  /// 버튼이 눌린 상태인지 추적
  bool _isPressed = false;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 활성 상태 배경색
  Color get _effectiveBackgroundColor {
    if (widget.isLoading || widget.onPressed == null) {
      return widget.disabledBackgroundColor ?? AppColors.spaceSurface;
    }
    return widget.backgroundColor ?? AppColors.primary;
  }

  /// 활성 상태 텍스트/아이콘 색상
  Color get _effectiveForegroundColor {
    if (widget.isLoading || widget.onPressed == null) {
      return widget.disabledForegroundColor ?? AppColors.textDisabled;
    }
    return widget.foregroundColor ?? Colors.white;
  }

  /// 활성 상태 테두리 색상 (비활성화 시 투명)
  Color get _effectiveBorderColor {
    if (widget.isLoading || widget.onPressed == null) {
      return Colors.transparent; // 비활성화 시 테두리 없음
    }
    return widget.borderColor ?? AppColors.primaryDark; // 활성화 시 primaryDark
  }

  /// 기본 너비 (353px)
  double get _effectiveWidth => widget.width ?? 353.w;

  /// 기본 높이 (56px)
  double get _effectiveHeight => widget.height ?? 56.h;

  /// 기본 모서리 반경 (16px)
  BorderRadius get _effectiveBorderRadius {
    return widget.borderRadius ?? AppRadius.xlarge;
  }

  /// 기본 정렬 방식 (center)
  MainAxisAlignment get _effectiveContentAlignment {
    return widget.contentAlignment ?? MainAxisAlignment.center;
  }

  /// 서브텍스트 색상 (기본: 메인 텍스트 색상과 동일)
  Color get _effectiveSubtitleColor {
    return widget.subtitleColor ?? _effectiveForegroundColor;
  }

  // ============================================
  // Widget Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            }
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? TossDesignTokens.buttonTapScale : 1.0,
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.springCurve,
        child: AnimatedContainer(
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.smoothCurve,
          width: _effectiveWidth,
          height: _effectiveHeight,
          decoration: BoxDecoration(
            color: _effectiveBackgroundColor,
            borderRadius: _effectiveBorderRadius,
            border: widget.showBorder
                ? Border.all(
                    color: _effectiveBorderColor,
                    width: widget.borderWidth,
                  )
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? _buildLoadingIndicator()
                : _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20.w,
      height: 20.h,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(_effectiveForegroundColor),
      ),
    );
  }

  /// 버튼 내용 (텍스트 + 아이콘)
  Widget _buildButtonContent() {
    // 텍스트 위젯 구성 (단일 or 2줄)
    Widget textWidget;
    if (widget.subtitle == null) {
      // 기존: 단일 텍스트
      textWidget = Text(
        widget.text,
        style: AppTextStyles.label_16.copyWith(
          color: _effectiveForegroundColor,
        ),
      );
    } else {
      // 새로운: 2줄 텍스트 (Column)
      textWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
        children: [
          Text(
            widget.text,
            style: AppTextStyles.label_16.copyWith(
              color: _effectiveForegroundColor,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          Text(
            widget.subtitle!,
            style: AppTextStyles.tag_12.copyWith(
              color: _effectiveSubtitleColor,
            ),
          ),
        ],
      );
    }

    if (widget.icon == null) {
      return textWidget;
    }

    // 아이콘 + 텍스트
    final iconWidget = widget.icon!;
    final isSpaceBetween =
        _effectiveContentAlignment == MainAxisAlignment.spaceBetween;

    return Row(
      mainAxisAlignment: _effectiveContentAlignment,
      mainAxisSize: MainAxisSize.max, // 전체 너비 사용
      children: widget.iconPosition == IconPosition.trailing
          ? [
              textWidget,
              if (!isSpaceBetween) SizedBox(width: AppSpacing.s8),
              iconWidget,
            ]
          : [
              iconWidget,
              if (!isSpaceBetween) SizedBox(width: AppSpacing.s8),
              textWidget,
            ],
    );
  }
}
