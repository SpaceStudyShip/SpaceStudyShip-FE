import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../constants/space_icons.dart';

/// 우주선 아바타 위젯
///
/// lottieAsset이 제공되면 Lottie 애니메이션, 아니면 아이콘만 표시.
/// 원형 배경/글로우 없이 콘텐츠만 렌더링.
class SpaceshipAvatar extends StatelessWidget {
  const SpaceshipAvatar({
    super.key,
    required this.icon,
    this.size = 120,
    this.lottieAsset,
  });

  /// 우주선 이모지/아이콘 키
  final String icon;

  /// 전체 크기 (기본 120)
  final double size;

  /// Lottie 에셋 경로 (null이면 아이콘 표시)
  final String? lottieAsset;

  @override
  Widget build(BuildContext context) {
    if (lottieAsset != null) {
      return SizedBox(
        width: size.w,
        height: size.w,
        child: Lottie.asset(lottieAsset!, fit: BoxFit.contain),
      );
    }

    // Lottie 없을 때: 아이콘만 표시 (원형 배경 없이)
    final gradient = SpaceIcons.gradientOf(icon);
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ).createShader(bounds),
          child: Icon(
            SpaceIcons.resolve(icon),
            size: (size * 0.6).sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
