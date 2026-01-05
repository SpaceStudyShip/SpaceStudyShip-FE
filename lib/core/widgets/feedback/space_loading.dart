import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 로딩 타입 (도허티 임계)
enum SpaceLoadingType {
  /// 기본 원형 스피너
  spinner,

  /// 점 3개 애니메이션
  dots,

  /// 진행률 표시
  progress,
}

/// 우주공부선 Loading Indicator
///
/// Toss UX 원칙이 적용된 로딩 인디케이터입니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 도허티 임계: 0.4초 이내 시각적 피드백
/// - 테슬러의 법칙: 예상 시간 표시로 불확실성 감소
/// - 피크엔드 법칙: 톡톡 튀는 애니메이션으로 지루함 해소
///
/// **사용 예시:**
/// ```dart
/// // 기본 스피너
/// SpaceLoading()
///
/// // 메시지와 함께
/// SpaceLoading(message: '불러오는 중...')
///
/// // 진행률 표시
/// SpaceLoading(
///   type: SpaceLoadingType.progress,
///   progress: 0.75,
///   message: '업로드 중...',
/// )
/// ```
class SpaceLoading extends StatefulWidget {
  /// SpaceLoading 생성자
  const SpaceLoading({
    super.key,
    this.type = SpaceLoadingType.spinner,
    this.message,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
    this.progress,
    this.estimatedSeconds,
  });

  /// 로딩 타입
  final SpaceLoadingType type;

  /// 로딩 메시지
  final String? message;

  /// 인디케이터 크기
  final double size;

  /// 인디케이터 선 두께
  final double strokeWidth;

  /// 인디케이터 색상
  final Color? color;

  /// 진행률 (0.0 ~ 1.0, type이 progress일 때)
  final double? progress;

  /// 예상 시간 (초)
  final int? estimatedSeconds;

  @override
  State<SpaceLoading> createState() => _SpaceLoadingState();
}

class _SpaceLoadingState extends State<SpaceLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  Color get _color => widget.color ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(),
          if (widget.message != null || widget.estimatedSeconds != null) ...[
            SizedBox(height: 16.h),
            _buildMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    switch (widget.type) {
      case SpaceLoadingType.spinner:
        return _buildSpinner();
      case SpaceLoadingType.dots:
        return _buildDots();
      case SpaceLoadingType.progress:
        return _buildProgress();
    }
  }

  Widget _buildSpinner() {
    return SizedBox(
      width: widget.size.w,
      height: widget.size.w,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth.w,
        valueColor: AlwaysStoppedAnimation<Color>(_color),
      ),
    );
  }

  Widget _buildDots() {
    return SizedBox(
      width: widget.size.w * 2,
      height: widget.size.w / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _dotsController,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_dotsController.value - delay).clamp(0.0, 1.0);
              final scale = 0.5 + (0.5 * _bounce(value));
              final opacity = 0.3 + (0.7 * _bounce(value));

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: _color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  double _bounce(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      return 1 - ((-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2)) / 2;
    }
  }

  Widget _buildProgress() {
    return SizedBox(
      width: widget.size.w,
      height: widget.size.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: widget.progress,
            strokeWidth: widget.strokeWidth.w,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            backgroundColor: _color.withValues(alpha: 0.2),
          ),
          if (widget.progress != null)
            Text(
              '${(widget.progress! * 100).toInt()}%',
              style: AppTextStyles.caption.semiBold().copyWith(
                    color: _color,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    final messages = <String>[];

    if (widget.message != null) {
      messages.add(widget.message!);
    }

    if (widget.estimatedSeconds != null) {
      messages.add('약 ${widget.estimatedSeconds}초 남음');
    }

    return Column(
      children: messages
          .map((msg) => Text(
                msg,
                style: AppTextStyles.body2.regular().copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ))
          .toList(),
    );
  }
}

/// 기존 코드 호환을 위한 deprecated alias
@Deprecated('Use SpaceLoading instead')
typedef SpaceLoadingIndicator = SpaceLoading;
