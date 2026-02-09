import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 그라데이션 원형 아이콘
///
/// RadialGradient 배경 + border + glow shadow + ShaderMask 아이콘.
/// 스플래시, 로그인, 온보딩, 우주선 헤더에서 공통 사용.
class GradientCircleIcon extends StatelessWidget {
  const GradientCircleIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 80,
    this.iconSize,
    this.gradientColors,
  });

  /// 아이콘
  final IconData icon;

  /// 기본 색상 (그라데이션/테두리/그림자에 사용)
  final Color color;

  /// 원형 컨테이너 크기 (기본 80)
  final double size;

  /// 아이콘 크기 (기본: size * 0.45)
  final double? iconSize;

  /// ShaderMask용 그라데이션 색상 (기본: [color, color.withValues(alpha: 0.7)])
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? (size * 0.45).sp;
    final effectiveGradient =
        gradientColors ?? [color, color.withValues(alpha: 0.7)];

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: effectiveGradient,
          ).createShader(bounds),
          child: Icon(icon, size: effectiveIconSize, color: Colors.white),
        ),
      ),
    );
  }
}
