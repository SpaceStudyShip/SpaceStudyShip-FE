import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';

/// 카드 스타일 (심미적 사용성)
enum SpaceCardStyle {
  /// Elevated - 그림자가 있는 부유 카드
  elevated,

  /// Outlined - 테두리만 있는 카드
  outlined,

  /// Filled - 배경색만 있는 카드
  filled,
}

/// 우주공부선 Card
///
/// Toss UX 원칙이 적용된 카드 컴포넌트입니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 심미적 사용성 효과: 캐주얼하고 둥글둥글한 디자인
/// - 피츠의 법칙: 클릭 가능 시 전체 영역 터치 가능
/// - 도허티 임계: 눌림 시 즉각적 피드백 (scale 애니메이션)
/// - 제이콥의 법칙: 익숙한 카드 패턴 유지
///
/// **사용 예시:**
/// ```dart
/// SpaceCard(
///   child: Text('카드 내용'),
/// )
///
/// SpaceCard(
///   style: SpaceCardStyle.outlined,
///   onTap: () => navigateToDetail(),
///   child: ListTile(title: Text('클릭 가능한 카드')),
/// )
/// ```
class SpaceCard extends StatefulWidget {
  /// SpaceCard 생성자
  const SpaceCard({
    super.key,
    required this.child,
    this.style = SpaceCardStyle.elevated,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.enablePressAnimation = true,
    this.width,
    this.height,
  });

  /// 카드 내부 콘텐츠
  final Widget child;

  /// 카드 스타일
  final SpaceCardStyle style;

  /// 카드 내부 패딩
  final EdgeInsetsGeometry? padding;

  /// 카드 외부 마진
  final EdgeInsetsGeometry? margin;

  /// 카드 모서리 반경
  final BorderRadius? borderRadius;

  /// 카드 탭 콜백
  final VoidCallback? onTap;

  /// 카드 롱프레스 콜백
  final VoidCallback? onLongPress;

  /// 선택 상태 (폰 레스토프 효과)
  final bool isSelected;

  /// 눌림 애니메이션 활성화 (도허티 임계)
  final bool enablePressAnimation;

  /// 카드 너비
  final double? width;

  /// 카드 높이
  final double? height;

  @override
  State<SpaceCard> createState() => _SpaceCardState();
}

class _SpaceCardState extends State<SpaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.style) {
      case SpaceCardStyle.elevated:
        return AppColors.spaceSurface;
      case SpaceCardStyle.outlined:
        return Colors.transparent;
      case SpaceCardStyle.filled:
        return AppColors.spaceElevated;
    }
  }

  BoxBorder? get _border {
    if (widget.isSelected) {
      return Border.all(color: AppColors.primary, width: 2);
    }

    switch (widget.style) {
      case SpaceCardStyle.outlined:
        return Border.all(color: AppColors.spaceDivider, width: 1);
      default:
        return null;
    }
  }

  List<BoxShadow>? get _boxShadow {
    if (widget.style != SpaceCardStyle.elevated) return null;

    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isInteractive || !widget.enablePressAnimation) return;
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isInteractive || !widget.enablePressAnimation) return;
    _animationController.reverse();
  }

  void _handleTapCancel() {
    if (!_isInteractive || !widget.enablePressAnimation) return;
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.onLongPress == null) return;
    HapticFeedback.mediumImpact();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? AppRadius.card;

    Widget card = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enablePressAnimation ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: borderRadius,
          border: _border,
          boxShadow: _boxShadow,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.transparent,
            child: _isInteractive
                ? InkWell(
                    onTap: _handleTap,
                    onLongPress: _handleLongPress,
                    borderRadius: borderRadius,
                    splashColor: AppColors.primary.withValues(alpha: 0.1),
                    highlightColor: AppColors.primary.withValues(alpha: 0.05),
                    child: _buildContent(),
                  )
                : _buildContent(),
          ),
        ),
      ),
    );

    if (_isInteractive) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: card,
      );
    }

    return card;
  }

  Widget _buildContent() {
    if (widget.padding != null) {
      return Padding(padding: widget.padding!, child: widget.child);
    }
    return widget.child;
  }
}
