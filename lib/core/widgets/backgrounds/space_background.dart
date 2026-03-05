import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';

/// 우주 별 배경 위젯 (화면 전체용 + 맵용)
///
/// 랜덤 배치된 별들이 반짝이는 우주 배경을 표현합니다.
/// [height]가 null이면 SizedBox.expand으로 화면 전체를 채우고,
/// 값이 있으면 해당 높이로 렌더링합니다 (ExploreScreen 스크롤 맵용).
/// Settings의 starTwinkleEnabled에 따라 반짝임을 on/off합니다.
class SpaceBackground extends ConsumerStatefulWidget {
  const SpaceBackground({super.key, this.height});

  /// 맵 전체 높이 (null이면 SizedBox.expand)
  final double? height;

  @override
  ConsumerState<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends ConsumerState<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  static const _starTintColors = [
    AppColors.primaryLight, // blue
    AppColors.secondaryLight, // purple
    AppColors.accentGoldLight, // gold
    AppColors.accentPinkLight, // pink
    Color(0xFF4DD0E1), // cyan - no AppColors match
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final random = Random(42); // 고정 시드로 일관된 별 배치

    // Jittered grid: 화면을 구역으로 나눠 골고루 분포시킴
    const cols = 7;
    const rows = 8;
    const totalStars = 50;

    _stars = List.generate(totalStars, (i) {
      final double x;
      final double y;

      if (i < cols * rows) {
        // 그리드 기반 jittered 배치 (균일 분포)
        final col = i % cols;
        final row = i ~/ cols;
        x = (col + 0.15 + random.nextDouble() * 0.7) / cols;
        y = (row + 0.15 + random.nextDouble() * 0.7) / rows;
      } else {
        // 나머지는 순수 랜덤 (자연스러운 불규칙성)
        x = random.nextDouble();
        y = random.nextDouble();
      }

      // 크기: 지수 분포 → 작은 별이 많고 큰 별은 드물게 (실제 밤하늘)
      final sizeRoll = random.nextDouble();
      final size = sizeRoll < 0.6
          ? 0.3 +
                random.nextDouble() *
                    0.5 // 60%: 아주 작은 별 (0.3~0.8)
          : sizeRoll < 0.85
          ? 0.8 +
                random.nextDouble() *
                    0.8 // 25%: 중간 별 (0.8~1.6)
          : 1.6 + random.nextDouble() * 1.0; // 15%: 큰 별 (1.6~2.6)

      // 틴트: 큰 별일수록 색상 가질 확률 높음
      final hasTint = size > 1.0 && random.nextDouble() < 0.4;
      final tintColor = hasTint
          ? _starTintColors[random.nextInt(_starTintColors.length)]
          : null;

      // 반짝임: 큰 별 + 일부 중간 별 (총 ~12개)
      final twinkle = size > 1.4 || (size > 0.8 && random.nextDouble() < 0.15);

      return _Star(
        x: x.clamp(0.0, 1.0),
        y: y.clamp(0.0, 1.0),
        size: size,
        twinkle: twinkle,
        twinkleOffset: random.nextDouble(),
        baseOpacity: 0.3 + random.nextDouble() * 0.4, // 별마다 기본 밝기 다르게
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
    final twinkleEnabled = ref.watch(starTwinkleEnabledProvider);

    // 반짝임 설정에 따라 애니메이션 제어
    if (twinkleEnabled && TickerMode.of(context)) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else if (!twinkleEnabled) {
      _controller.stop();
    }

    final content = Stack(
      children: [
        // Layer 1: 네뷸라 오버레이
        Positioned.fill(
          child: CustomPaint(
            size: widget.height != null
                ? Size(double.infinity, widget.height!)
                : Size.zero,
            painter: _NebulaPainter(),
          ),
        ),

        // Layer 2: 별 필드
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: widget.height != null
                    ? Size(double.infinity, widget.height!)
                    : Size.zero,
                painter: _StarPainter(
                  stars: _stars,
                  twinkleValue: twinkleEnabled ? _controller.value : 0.0,
                  twinkleEnabled: twinkleEnabled,
                ),
              );
            },
          ),
        ),
      ],
    );

    return RepaintBoundary(
      child: widget.height != null
          ? SizedBox(
              width: double.infinity,
              height: widget.height,
              child: content,
            )
          : SizedBox.expand(child: content),
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
    required this.baseOpacity,
    this.tintColor,
  });

  final double x;
  final double y;
  final double size;
  final bool twinkle;
  final double twinkleOffset;
  final double baseOpacity;
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
    required this.twinkleEnabled,
  });

  final List<_Star> stars;
  final double twinkleValue;
  final bool twinkleEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      double opacity;
      if (star.twinkle && twinkleEnabled) {
        final phase = (twinkleValue + star.twinkleOffset) % 1.0;
        opacity =
            star.baseOpacity +
            (1.0 - star.baseOpacity) * (0.5 + 0.5 * sin(phase * pi * 2));
      } else {
        opacity = star.baseOpacity;
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
    return oldDelegate.twinkleValue != twinkleValue ||
        oldDelegate.twinkleEnabled != twinkleEnabled;
  }
}
