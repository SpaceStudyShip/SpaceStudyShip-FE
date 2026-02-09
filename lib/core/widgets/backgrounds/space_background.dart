import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// 우주 별 배경 위젯 (화면 전체용)
///
/// 랜덤 배치된 별들이 반짝이는 우주 배경을 표현합니다.
/// ExploreScreen의 SpaceMapBackground와 동일한 비주얼이지만
/// 일반 화면 크기에 최적화되어 별 수가 적습니다 (30개).
/// RepaintBoundary + TickerMode 기반 성능 보호.
class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

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
    _stars = List.generate(30, (i) {
      final hasTint = i % 5 == 0;
      final tintColor = hasTint
          ? _starTintColors[random.nextInt(_starTintColors.length)]
          : null;

      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.0 + 0.5,
        twinkle: i < 5, // 처음 5개만 반짝임
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
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Layer 1: 네뷸라 오버레이
            Positioned.fill(
              child: CustomPaint(
                painter: _NebulaPainter(),
              ),
            ),

            // Layer 2: 별 필드
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _StarPainter(
                      stars: _stars,
                      twinkleValue: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 상단 좌측 보라색 네뷸라
    final nebula1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.3),
        radius: 0.8,
        colors: [
          AppColors.secondary.withValues(alpha: 0.04),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, nebula1);

    // 하단 우측 파란색 네뷸라
    final nebula2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 0.6),
        radius: 0.7,
        colors: [
          AppColors.primary.withValues(alpha: 0.03),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, nebula2);

    // 중앙 핑크 네뷸라 (아주 미세)
    final nebula3 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 0.5,
        colors: [
          AppColors.accentPink.withValues(alpha: 0.02),
          AppColors.accentPink.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, nebula3);
  }

  @override
  bool shouldRepaint(_NebulaPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.stars,
    required this.twinkleValue,
  });

  final List<_Star> stars;
  final double twinkleValue;

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      double opacity;
      if (star.twinkle) {
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
