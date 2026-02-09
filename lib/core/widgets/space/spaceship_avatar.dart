import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/space_icons.dart';
import '../atoms/gradient_circle_icon.dart';

/// 우주선 아바타 위젯
///
/// 현재: GradientCircleIcon 기반 정적 아이콘 + pulse glow
/// 미래: Rive 애니메이션으로 교체 예정 (이 위젯 내부만 수정)
class SpaceshipAvatar extends StatefulWidget {
  const SpaceshipAvatar({
    super.key,
    required this.icon,
    this.size = 120,
    this.showGlow = true,
  });

  /// 우주선 이모지/아이콘 키
  final String icon;

  /// 전체 크기 (기본 120)
  final double size;

  /// glow 애니메이션 표시 여부
  final bool showGlow;

  @override
  State<SpaceshipAvatar> createState() => _SpaceshipAvatarState();
}

class _SpaceshipAvatarState extends State<SpaceshipAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = SpaceIcons.colorOf(widget.icon);
    final gradient = SpaceIcons.gradientOf(widget.icon);

    // TODO: Rive 에셋으로 교체 시 이 위젯 내부만 수정
    // return SizedBox(
    //   width: widget.size.w,
    //   height: widget.size.w,
    //   child: RiveAnimation(
    //     'assets/animations/spaceship.riv',
    //     artboard: widget.icon,
    //     fit: BoxFit.contain,
    //   ),
    // );

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = 0.15 + _glowController.value * 0.15;
        final glowSpread = 4.0 + _glowController.value * 8.0;
        final glowBlur = 24.0 + _glowController.value * 16.0;

        return Container(
          width: widget.size.w,
          height: widget.size.w,
          decoration: widget.showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withValues(alpha: glowOpacity),
                      blurRadius: glowBlur,
                      spreadRadius: glowSpread,
                    ),
                  ],
                )
              : null,
          child: child,
        );
      },
      child: GradientCircleIcon(
        icon: SpaceIcons.resolve(widget.icon),
        color: baseColor,
        size: widget.size,
        iconSize: widget.size * 0.42,
        gradientColors: gradient,
      ),
    );
  }
}
