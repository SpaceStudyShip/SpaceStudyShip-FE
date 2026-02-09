import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 로딩 타입
enum AppLoadingType {
  /// 기본 원형 스피너
  spinner,

  /// 점 3개 애니메이션
  dots,

  /// 진행률 표시
  progress,
}

/// 앱 전역에서 사용하는 로딩 인디케이터 - 토스 스타일
///
/// **사용 예시**:
/// ```dart
/// // 기본 스피너
/// AppLoading()
///
/// // 메시지와 함께
/// AppLoading(message: '불러오는 중...')
///
/// // 진행률 표시
/// AppLoading(
///   type: AppLoadingType.progress,
///   progress: 0.75,
///   message: '업로드 중...',
/// )
///
/// // 점 애니메이션
/// AppLoading(type: AppLoadingType.dots)
/// ```
class AppLoading extends StatefulWidget {
  const AppLoading({
    super.key,
    this.type = AppLoadingType.spinner,
    this.message,
    this.progress,
    this.size,
    this.color,
  });

  /// 로딩 타입 (기본: spinner)
  final AppLoadingType type;

  /// 로딩 메시지
  final String? message;

  /// 진행률 (0.0 - 1.0, progress 타입에서만 사용)
  final double? progress;

  /// 크기 (기본: 32px)
  final double? size;

  /// 색상 (기본: primary)
  final Color? color;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _effectiveSize => widget.size ?? 32.w;
  Color get _effectiveColor => widget.color ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoader(),
        if (widget.message != null) ...[
          SizedBox(height: AppSpacing.s12),
          Text(
            widget.message!,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoader() {
    switch (widget.type) {
      case AppLoadingType.spinner:
        return SizedBox(
          width: _effectiveSize,
          height: _effectiveSize,
          child: CircularProgressIndicator(
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(_effectiveColor),
          ),
        );

      case AppLoadingType.dots:
        return _DotsLoader(
          size: _effectiveSize,
          color: _effectiveColor,
          controller: _controller,
        );

      case AppLoadingType.progress:
        return SizedBox(
          width: _effectiveSize * 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: widget.progress,
                backgroundColor: AppColors.spaceDivider,
                valueColor: AlwaysStoppedAnimation<Color>(_effectiveColor),
                minHeight: 4.h,
                borderRadius: BorderRadius.circular(2.r),
              ),
              if (widget.progress != null) ...[
                SizedBox(height: AppSpacing.s8),
                Text(
                  '${(widget.progress! * 100).toInt()}%',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}

/// 점 3개 로딩 애니메이션
class _DotsLoader extends StatelessWidget {
  const _DotsLoader({
    required this.size,
    required this.color,
    required this.controller,
  });

  final double size;
  final Color color;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final dotSize = size / 4;

    return SizedBox(
      width: size,
      height: dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (controller.value + delay) % 1.0;
              final scale = 0.5 + 0.5 * _bounce(value);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
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
}
