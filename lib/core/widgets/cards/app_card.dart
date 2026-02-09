import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_gradients.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/toss_design_tokens.dart';

/// 카드 스타일 타입
enum AppCardStyle {
  /// 그림자가 있는 카드 (기본)
  elevated,

  /// 테두리만 있는 카드
  outlined,

  /// 배경색만 있는 카드
  filled,
}

/// 앱 전역에서 사용하는 공용 카드 컴포넌트 - 토스 스타일
///
/// **기본 스펙**:
/// - 모서리: 16px 라운드
/// - 배경: spaceSurface
/// - 패딩: 16px
///
/// **토스 스타일**:
/// - 탭 시 0.98 스케일 (살짝 눌림)
/// - 부드러운 스프링 애니메이션
/// - 선택 시 primary 테두리
///
/// **사용 예시**:
/// ```dart
/// // 기본 카드
/// AppCard(
///   padding: AppPadding.all16,
///   child: Text('카드 내용'),
/// )
///
/// // 클릭 가능한 카드
/// AppCard(
///   style: AppCardStyle.outlined,
///   onTap: () => navigateToDetail(),
///   child: ListTile(title: Text('클릭 가능')),
/// )
///
/// // 선택 상태
/// AppCard(
///   isSelected: true,
///   child: Text('선택됨'),
/// )
/// ```
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.style = AppCardStyle.elevated,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.enabled = true,
    this.gradient,
  });

  /// 카드 내용 (필수)
  final Widget child;

  /// 카드 스타일 (기본: elevated)
  final AppCardStyle style;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 롱프레스 콜백
  final VoidCallback? onLongPress;

  /// 선택 상태 (true면 primary 테두리)
  final bool isSelected;

  /// 내부 패딩 (기본: 16px)
  final EdgeInsetsGeometry? padding;

  /// 외부 마진
  final EdgeInsetsGeometry? margin;

  /// 카드 너비
  final double? width;

  /// 카드 높이
  final double? height;

  /// 배경색 (기본: spaceSurface)
  final Color? backgroundColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 모서리 반경 (기본: 16px)
  final BorderRadius? borderRadius;

  /// 그림자 높이 (elevated 스타일에서만 적용)
  final double? elevation;

  /// 활성화 여부
  final bool enabled;

  /// 그라데이션 배경 (null이면 단색 배경)
  final Gradient? gradient;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  // ============================================
  // 스타일 Getter
  // ============================================

  Color get _backgroundColor {
    if (!widget.enabled) return AppColors.spaceBackground;
    return widget.backgroundColor ?? AppColors.spaceSurface;
  }

  Color get _borderColor {
    if (widget.isSelected) return AppColors.primary;
    if (widget.borderColor != null) return widget.borderColor!;

    switch (widget.style) {
      case AppCardStyle.elevated:
        return Colors.transparent;
      case AppCardStyle.outlined:
        return AppColors.spaceDivider;
      case AppCardStyle.filled:
        return Colors.transparent;
    }
  }

  double get _borderWidth {
    if (widget.isSelected) return 2.0;
    return widget.style == AppCardStyle.outlined ? 1.0 : 0.0;
  }

  List<BoxShadow> get _boxShadow {
    if (widget.style != AppCardStyle.elevated) return [];
    if (!widget.enabled) return [];

    final elevation = widget.elevation ?? 4.0;
    return [
      // Outer shadow - depth
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
      // Inner glow - subtle primary tint
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.04),
        blurRadius: elevation * 3,
        spreadRadius: -2,
      ),
    ];
  }

  BorderRadius get _borderRadius {
    return widget.borderRadius ?? AppRadius.xlarge;
  }

  EdgeInsetsGeometry get _padding {
    return widget.padding ?? AppPadding.all16;
  }

  // ============================================
  // UI 빌드
  // ============================================

  @override
  Widget build(BuildContext context) {
    final isInteractive =
        widget.enabled && (widget.onTap != null || widget.onLongPress != null);

    Widget card = AnimatedScale(
      scale: _isPressed ? TossDesignTokens.cardTapScale : 1.0,
      duration: TossDesignTokens.animationFast,
      curve: TossDesignTokens.springCurve,
      child: AnimatedContainer(
        duration: TossDesignTokens.animationFast,
        curve: TossDesignTokens.smoothCurve,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        padding: _padding,
        decoration: BoxDecoration(
          color: widget.gradient == null ? _backgroundColor : null,
          gradient: widget.gradient ?? (widget.style == AppCardStyle.elevated ? AppGradients.cardSurface : null),
          borderRadius: _borderRadius,
          border: _borderWidth > 0
              ? Border.all(color: _borderColor, width: _borderWidth)
              : null,
          boxShadow: _boxShadow,
        ),
        child: widget.child,
      ),
    );

    if (!isInteractive) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: card,
    );
  }
}
