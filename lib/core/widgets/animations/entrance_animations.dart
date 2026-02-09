import 'package:flutter/material.dart';

/// Fade + Slide Up 진입 애니메이션
///
/// **사용 예시**:
/// ```dart
/// FadeSlideIn(
///   delay: Duration(milliseconds: 100),
///   child: Text('안녕하세요'),
/// )
/// ```
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.offsetY = 20.0,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slideOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = CurvedAnimation(parent: _controller, curve: widget.curve);

    // SlideTransition은 부모 크기 비율 기반이므로 직접 Offset 애니메이션 사용
    _slideOffset = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideOffset,
      child: FadeTransition(opacity: _opacity, child: widget.child),
      builder: (context, child) {
        return Transform.translate(offset: _slideOffset.value, child: child);
      },
    );
  }
}

/// 시차(Staggered) 리스트 애니메이션
///
/// 자식들이 순서대로 지연되며 나타납니다.
///
/// **사용 예시**:
/// ```dart
/// StaggeredList(
///   children: [
///     Text('첫번째'),
///     Text('두번째'),
///     Text('세번째'),
///   ],
/// )
/// ```
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.staggerInterval = const Duration(milliseconds: 60),
    this.initialDelay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final Duration staggerInterval;
  final Duration initialDelay;
  final Duration duration;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: initialDelay + staggerInterval * i,
            duration: duration,
            child: children[i],
          ),
      ],
    );
  }
}

/// Spring Scale 진입 애니메이션
///
/// **사용 예시**:
/// ```dart
/// ScaleIn(
///   delay: Duration(milliseconds: 200),
///   child: Icon(Icons.star),
/// )
/// ```
class ScaleIn extends StatefulWidget {
  const ScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.elasticOut,
    this.beginScale = 0.0,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginScale;

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scale = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
