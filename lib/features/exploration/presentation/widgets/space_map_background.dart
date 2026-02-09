import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 우주 맵 별 배경 위젯
///
/// 랜덤 배치된 별들이 반짝이는 우주 배경을 표현합니다.
/// 일부 별에 컬러 틴트를 적용하고 서틀 네뷸라 오버레이를 추가합니다.
/// RepaintBoundary로 감싸서 성능을 보호합니다.
class SpaceMapBackground extends StatefulWidget {
  const SpaceMapBackground({super.key, required this.height});

  /// 맵 전체 높이
  final double height;

  @override
  State<SpaceMapBackground> createState() => _SpaceMapBackgroundState();
}

class _SpaceMapBackgroundState extends State<SpaceMapBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  /// 별 색상 틴트 팔레트
  static const _starTintColors = [
    Color(0xFF64B5F6), // blue
    Color(0xFFBA68C8), // purple
    Color(0xFFFFD740), // gold
    Color(0xFFF06292), // pink
    Color(0xFF4DD0E1), // cyan
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final random = Random(42); // 고정 시드로 일관된 별 배치
    _stars = List.generate(50, (i) {
      // 약 20% 별에 컬러 틴트 적용
      final hasTint = i % 5 == 0;
      final tintColor = hasTint
          ? _starTintColors[random.nextInt(_starTintColors.length)]
          : null;

      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.0 + 0.5,
        twinkle: i < 8, // 처음 8개만 반짝임
        twinkleOffset: random.nextDouble(),
        tintColor: tintColor,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // TickerMode가 false면 탭이 비활성 → 애니메이션 정지
    if (TickerMode.of(context)) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Layer 1: 네뷸라 오버레이
          Positioned.fill(
            child: CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: _NebulaPainter(),
            ),
          ),

          // Layer 2: 별 필드
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(double.infinity, widget.height),
                painter: _StarPainter(
                  stars: _stars,
                  twinkleValue: _controller.value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkle,
    required this.twinkleOffset,
    this.tintColor,
  });

  final double x;
  final double y;
  final double size;
  final bool twinkle;
  final double twinkleOffset;
  final Color? tintColor;
}

/// 서틀 네뷸라 RadialGradient 오버레이 페인터
class _NebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 상단 좌측 보라색 네뷸라
    final nebula1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.3),
        radius: 0.8,
        colors: [
          AppColors.secondary.withValues(alpha: 0.04),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula1);

    // 하단 우측 파란색 네뷸라
    final nebula2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 0.6),
        radius: 0.7,
        colors: [
          AppColors.primary.withValues(alpha: 0.03),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula2);

    // 중앙 핑크 네뷸라 (아주 미세)
    final nebula3 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 0.5,
        colors: [
          AppColors.accentPink.withValues(alpha: 0.02),
          AppColors.accentPink.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula3);
  }

  @override
  bool shouldRepaint(_NebulaPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.stars, required this.twinkleValue});

  final List<_Star> stars;
  final double twinkleValue;

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      double opacity;
      if (star.twinkle) {
        // 각 별마다 오프셋을 줘서 다른 타이밍에 반짝임
        final phase = (twinkleValue + star.twinkleOffset) % 1.0;
        opacity = 0.3 + 0.7 * (0.5 + 0.5 * sin(phase * pi * 2));
      } else {
        opacity = 0.4 + star.size * 0.15;
      }

      final baseColor = star.tintColor ?? Colors.white;
      final center = Offset(star.x * size.width, star.y * size.height);

      // 틴트된 별은 미세한 glow 추가
      if (star.tintColor != null && star.size > 1.0) {
        final glowPaint = Paint()
          ..color = star.tintColor!.withValues(alpha: opacity * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(center, star.size * 2.5, glowPaint);
      }

      final paint = Paint()
        ..color = baseColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) {
    return oldDelegate.twinkleValue != twinkleValue;
  }
}
