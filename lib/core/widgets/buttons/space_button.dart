import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 버튼 타입 (폰 레스토프 효과: 색상으로 중요도 구분)
enum SpaceButtonType {
  /// Primary - 주요 액션 (파란색)
  primary,

  /// Secondary - 보조 액션 (테두리만)
  secondary,

  /// Text - 텍스트 전용 (배경 없음)
  text,

  /// Destructive - 위험 액션 (빨간색)
  destructive,
}

/// 버튼 크기
enum SpaceButtonSize {
  /// Small - 40dp 높이
  small,

  /// Medium - 48dp 높이 (기본값)
  medium,

  /// Large - 56dp 높이
  large,
}

/// 아이콘 위치
enum SpaceButtonIconPosition {
  /// 텍스트 왼쪽
  leading,

  /// 텍스트 오른쪽
  trailing,
}

/// 우주공부선 Button
///
/// Toss UX 원칙이 적용된 통합 버튼 위젯입니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 피츠의 법칙: 최소 터치 영역 48dp 보장
/// - 도허티 임계: 0.15초 눌림 애니메이션
/// - 폰 레스토프 효과: 타입별 색상 구분
/// - 심미적 사용성: 둥글둥글한 디자인
///
/// **사용 예시:**
/// ```dart
/// SpaceButton(
///   text: '시작하기',
///   onPressed: () => print('clicked'),
/// )
///
/// SpaceButton(
///   text: '삭제',
///   type: SpaceButtonType.destructive,
///   onPressed: () => deleteItem(),
/// )
/// ```
class SpaceButton extends StatefulWidget {
  /// SpaceButton 생성자
  const SpaceButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = SpaceButtonType.primary,
    this.size = SpaceButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.iconPosition = SpaceButtonIconPosition.leading,
    this.width,
    this.enableHaptic = true,
    this.enablePressAnimation = true,
  });

  /// 버튼 텍스트
  final String text;

  /// 버튼 클릭 콜백 (null이면 비활성)
  final VoidCallback? onPressed;

  /// 버튼 타입
  final SpaceButtonType type;

  /// 버튼 크기
  final SpaceButtonSize size;

  /// 로딩 상태
  final bool isLoading;

  /// 전체 너비 사용 여부
  final bool isFullWidth;

  /// 아이콘 (선택적)
  final IconData? icon;

  /// 아이콘 위치
  final SpaceButtonIconPosition iconPosition;

  /// 커스텀 너비 (isFullWidth가 false일 때 사용)
  final double? width;

  /// 햅틱 피드백 활성화
  final bool enableHaptic;

  /// 눌림 애니메이션 활성화 (도허티 임계)
  final bool enablePressAnimation;

  @override
  State<SpaceButton> createState() => _SpaceButtonState();
}

class _SpaceButtonState extends State<SpaceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  double get _height {
    switch (widget.size) {
      case SpaceButtonSize.small:
        return 40.h;
      case SpaceButtonSize.medium:
        return 48.h;
      case SpaceButtonSize.large:
        return 56.h;
    }
  }

  Color get _backgroundColor {
    if (!_isEnabled) {
      return AppColors.primary.withValues(alpha: 0.3);
    }

    switch (widget.type) {
      case SpaceButtonType.primary:
        return AppColors.primary;
      case SpaceButtonType.secondary:
        return Colors.transparent;
      case SpaceButtonType.text:
        return Colors.transparent;
      case SpaceButtonType.destructive:
        return AppColors.error;
    }
  }

  Color get _foregroundColor {
    if (!_isEnabled) {
      return AppColors.textDisabled;
    }

    switch (widget.type) {
      case SpaceButtonType.primary:
        return AppColors.textOnPrimary;
      case SpaceButtonType.secondary:
        return AppColors.primary;
      case SpaceButtonType.text:
        return AppColors.primary;
      case SpaceButtonType.destructive:
        return AppColors.textOnPrimary;
    }
  }

  BorderSide? get _borderSide {
    if (widget.type == SpaceButtonType.secondary) {
      return BorderSide(
        color: _isEnabled ? AppColors.primary : AppColors.textDisabled,
        width: 1.5,
      );
    }
    return null;
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    if (widget.enablePressAnimation) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    if (widget.enablePressAnimation) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    if (widget.enablePressAnimation) {
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (!_isEnabled) return;
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enablePressAnimation ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: _height,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: AppRadius.button,
            border: _borderSide != null
                ? Border.fromBorderSide(_borderSide!)
                : null,
            boxShadow: widget.type == SpaceButtonType.primary && _isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: _buildContent(),
        ),
      ),
    );

    return button;
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
          ),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: AppTextStyles.body1.semiBold().copyWith(color: _foregroundColor),
    );

    if (widget.icon == null) {
      return Center(child: textWidget);
    }

    final iconWidget = Icon(
      widget.icon,
      color: _foregroundColor,
      size: 20.w,
    );

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.iconPosition == SpaceButtonIconPosition.leading
            ? [
                iconWidget,
                SizedBox(width: 8.w),
                textWidget,
              ]
            : [
                textWidget,
                SizedBox(width: 8.w),
                iconWidget,
              ],
      ),
    );
  }
}

/// 기존 코드 호환을 위한 deprecated alias
///
/// [SpaceButton]을 사용하세요.
@Deprecated('Use SpaceButton instead. Migration: SpaceButton(text: ..., onPressed: ...)')
class SpacePrimaryButton extends StatelessWidget {
  const SpacePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SpaceButton(
      text: text,
      onPressed: onPressed,
      type: SpaceButtonType.primary,
      isLoading: isLoading,
      isFullWidth: width == null,
      width: width,
    );
  }
}
