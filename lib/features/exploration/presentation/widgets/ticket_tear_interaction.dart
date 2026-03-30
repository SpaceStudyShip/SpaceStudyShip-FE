import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/toss_design_tokens.dart';

/// 티켓 하단 stub 찢기 인터랙션 위젯
///
/// 하단 stub을 좌우로 스와이프하면 티켓이 찢어지며 해금됩니다.
/// stub 전체가 옆으로 밀려나면서 기울어지고, 임계값을 넘으면 날아갑니다.
///
/// [onTear]는 `Future<bool>`을 반환합니다.
/// - `true`: 해금 성공 → stub 날아감 → torn stub fade-in
/// - `false`: 취소/실패 → stub 원상 복구
class TicketTearInteraction extends StatefulWidget {
  const TicketTearInteraction({
    super.key,
    required this.isLocked,
    required this.isCleared,
    required this.hasEnoughFuel,
    required this.onTear,
    this.tearThreshold = 0.7,
  });

  final bool isLocked;
  final bool isCleared;
  final bool hasEnoughFuel;
  final Future<bool> Function() onTear;
  final double tearThreshold;

  @override
  State<TicketTearInteraction> createState() => _TicketTearInteractionState();
}

class _TicketTearInteractionState extends State<TicketTearInteraction>
    with TickerProviderStateMixin {
  // ─── 찢기 물리 상수 ───
  /// stub이 화면 너비의 몇 %까지 밀려나는지
  static const _maxSlideRatio = 0.6;

  /// 드래그 시 최대 회전 각도 (라디안, ~8도)
  static const _maxDragRotation = 0.14;

  /// fly-away 시 추가 회전 (라디안, ~17도)
  static const _flyAwayExtraRotation = 0.3;

  /// fly-away 시 화면 밖 목표 비율
  static const _flyAwayTargetRatio = 1.2;

  /// fly-away 시 아래로 처지는 픽셀
  static const _flyAwayDropPx = 20.0;

  /// 드래그 시 최소 불투명도
  static const _minDragOpacity = 0.4;

  double _dragProgress = 0.0;
  bool _isTearing = false;
  double _dragDirection = 1.0;

  // 해금 성공 후 전환 애니메이션 상태
  bool _showFlyAway = false;
  bool _showTornEntry = false;

  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  late final AnimationController _shimmerController;
  late final AnimationController _glowController;

  // 해금 후: stub 날아감
  late final AnimationController _flyAwayController;
  // 해금 후: torn stub 등장
  late final AnimationController _tornEntryController;
  late final CurvedAnimation _tornEntryAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: TossDesignTokens.animationNormal,
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _flyAwayController = AnimationController(
      vsync: this,
      duration: TossDesignTokens.entranceFast,
    );

    _tornEntryController = AnimationController(
      vsync: this,
      duration: TossDesignTokens.entranceNormal,
    );
    _tornEntryAnimation = CurvedAnimation(
      parent: _tornEntryController,
      curve: TossDesignTokens.springCurve,
    );

    if (widget.isLocked && widget.hasEnoughFuel) {
      _shimmerController.repeat();
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TicketTearInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부 상태 변경으로 잠김→해금 전환 시 (이미 fly-away 중이 아니면)
    if (!widget.isLocked && oldWidget.isLocked && !_showFlyAway) {
      _playTornEntry();
    }
    if (widget.isLocked && widget.hasEnoughFuel) {
      if (!_shimmerController.isAnimating) {
        _shimmerController.repeat();
        _glowController.repeat(reverse: true);
      }
    } else {
      _shimmerController.stop();
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _tornEntryAnimation.dispose();
    _resetController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    _flyAwayController.dispose();
    _tornEntryController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.isLocked || !widget.hasEnoughFuel || _isTearing) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;
    final delta = details.delta.dx / width;

    if (delta != 0) {
      _dragDirection = delta > 0 ? 1.0 : -1.0;
    }

    setState(() {
      _dragProgress = (_dragProgress + delta.abs()).clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (!widget.isLocked || !widget.hasEnoughFuel || _isTearing) return;

    if (_dragProgress >= widget.tearThreshold) {
      setState(() => _isTearing = true);
      _shimmerController.stop();
      _glowController.stop();

      final success = await widget.onTear();

      if (mounted) {
        if (success) {
          _playFlyAwayThenTorn();
        } else {
          setState(() => _isTearing = false);
          _shimmerController.repeat();
          _glowController.repeat(reverse: true);
          _animateReset();
        }
      }
    } else {
      _animateReset();
    }
  }

  /// 해금 성공: stub 날아감 → torn stub 등장
  void _playFlyAwayThenTorn() {
    setState(() => _showFlyAway = true);

    _flyAwayController.forward(from: 0.0).then((_) {
      if (mounted) {
        _playTornEntry();
      }
    });
  }

  void _playTornEntry() {
    setState(() {
      _showFlyAway = false;
      _showTornEntry = true;
    });
    _tornEntryController.forward(from: 0.0);
  }

  void _animateReset() {
    _resetAnimation =
        Tween<double>(begin: _dragProgress, end: 0.0).animate(
          CurvedAnimation(
            parent: _resetController,
            curve: TossDesignTokens.smoothCurve,
          ),
        )..addListener(() {
          setState(() => _dragProgress = _resetAnimation.value);
        });
    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    // 1) 날아가는 중
    if (_showFlyAway) {
      return _buildFlyingAwayStub();
    }

    // 2) torn stub 등장 애니메이션
    if (_showTornEntry) {
      return _buildTornStubEntry();
    }

    // 3) 이미 해금됨 (첫 빌드부터 해금 상태)
    if (!widget.isLocked) {
      return _buildTornStub();
    }

    // 4) 연료 부족
    if (!widget.hasEnoughFuel) {
      return _buildDisabledStub();
    }

    // 5) 스와이프 가능
    return _buildSwipeableStub();
  }

  /// stub이 화면 밖으로 날아가는 애니메이션
  Widget _buildFlyingAwayStub() {
    return AnimatedBuilder(
      animation: _flyAwayController,
      builder: (context, child) {
        final t = _flyAwayController.value;
        final screenWidth = MediaQuery.of(context).size.width;
        // 현재 위치에서 화면 밖까지 날아감
        final startX =
            _dragProgress * screenWidth * _maxSlideRatio * _dragDirection;
        final endX = screenWidth * _flyAwayTargetRatio * _dragDirection;
        final slideX = startX + (endX - startX) * t;
        final rotation =
            (_maxDragRotation + t * _flyAwayExtraRotation) * _dragDirection;
        final opacity = (1.0 - t).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(slideX, t * _flyAwayDropPx),
          child: Transform.rotate(
            angle: rotation,
            alignment: _dragDirection > 0
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            child: Opacity(opacity: opacity, child: _buildBarcodeContainer()),
          ),
        );
      },
    );
  }

  /// torn stub이 fade-in + slide-up + scale-in으로 등장
  Widget _buildTornStubEntry() {
    return AnimatedBuilder(
      animation: _tornEntryAnimation,
      builder: (context, _) {
        final t = _tornEntryAnimation.value;

        return Transform.translate(
          offset: Offset(0, 10.h * (1 - t)),
          child: Opacity(
            opacity: t,
            child: _buildTornStub(stampScale: 0.5 + t * 0.5),
          ),
        );
      },
    );
  }

  Widget _buildSwipeableStub() {
    final maxSlide = MediaQuery.of(context).size.width * _maxSlideRatio;
    final slideX = _dragProgress * maxSlide * _dragDirection;
    final rotation = _dragProgress * _maxDragRotation * _dragDirection;
    final opacity = (1.0 - _dragProgress * _maxSlideRatio).clamp(
      _minDragOpacity,
      1.0,
    );
    final isDragging = _dragProgress > 0;

    return GestureDetector(
      // PageView 수평 스크롤과의 충돌 방지: stub 영역 터치 우선 처리
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Transform.translate(
        offset: Offset(slideX, 0),
        child: Transform.rotate(
          angle: rotation,
          alignment: _dragDirection > 0
              ? Alignment.bottomLeft
              : Alignment.bottomRight,
          child: Opacity(
            opacity: opacity,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glowOpacity = isDragging
                    ? 0.0
                    : (_glowController.value * 0.6).clamp(0.0, 0.6);

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.spaceSurface,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: glowOpacity),
                      width: 1.5,
                    ),
                    boxShadow: isDragging
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                alpha: glowOpacity * 0.4,
                              ),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: _buildBarcodeWithShimmer(isDragging),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarcodeWithShimmer(bool isDragging) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            if (isDragging) {
              return const LinearGradient(
                colors: [Colors.white, Colors.white],
              ).createShader(bounds);
            }

            final shimmerPosition = _shimmerController.value * 2 - 0.5;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [Colors.white, Colors.white70, Colors.white],
              stops: [
                (shimmerPosition - 0.2).clamp(0.0, 1.0),
                shimmerPosition.clamp(0.0, 1.0),
                (shimmerPosition + 0.2).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.modulate,
          child: child!,
        );
      },
      child: _buildBarcodeSvg(AppColors.textTertiary.withValues(alpha: 0.5)),
    );
  }

  Widget _buildDisabledStub() {
    return Opacity(
      opacity: 0.3,
      child: AbsorbPointer(child: _buildBarcodeContainer()),
    );
  }

  Widget _buildTornStub({double stampScale = 1.0}) {
    final isCleared = widget.isCleared;
    final stampColor = isCleared ? AppColors.accentGold : AppColors.success;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Column(
        children: [
          CustomPaint(
            size: Size(double.infinity, 6.h),
            painter: _TornEdgePainter(color: AppColors.spaceDivider),
          ),
          SizedBox(height: AppSpacing.s8),
          Transform.scale(
            scale: stampScale,
            child: Text(
              isCleared ? 'COMPLETED' : 'BOARDED',
              style: AppTextStyles.tag_12.copyWith(
                color: stampColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 바코드 SVG 컨테이너 (fly-away, disabled 공용)
  Widget _buildBarcodeContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.spaceSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: _buildBarcodeSvg(AppColors.textTertiary.withValues(alpha: 0.5)),
    );
  }

  Widget _buildBarcodeSvg(Color color) {
    return SvgPicture.asset(
      'assets/icons/barcode_lavender.svg',
      height: 40.h,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

// ─── 찢긴 엣지 CustomPainter ───

class _TornEdgePainter extends CustomPainter {
  _TornEdgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final random = _SeededRandom(77);
    final segmentWidth = 6.0;
    final segments = (size.width / segmentWidth).ceil();

    path.moveTo(0, size.height / 2);

    for (var i = 0; i < segments; i++) {
      final x = (i + 1) * segmentWidth;
      final y = size.height / 2 + (random.nextDouble() - 0.5) * size.height;
      path.lineTo(x.clamp(0, size.width), y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TornEdgePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// 고정 시드 난수 생성기 (CustomPainter용)
class _SeededRandom {
  _SeededRandom(this._seed);
  int _seed;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return (_seed >> 16) / 32768.0;
  }
}
