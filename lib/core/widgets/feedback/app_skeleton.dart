import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';

/// 스켈레톤 UI 컴포넌트 - 도허티 임계 적용
///
/// 콘텐츠 형태를 미리 보여줌으로써 사용자에게 빠른 피드백 제공
///
/// **사용 예시**:
/// ```dart
/// // 기본 사각형
/// AppSkeleton(width: 100, height: 20)
///
/// // 원형 아바타
/// AppSkeleton.avatar(size: 48)
///
/// // 텍스트 줄
/// AppSkeleton.text(lines: 3)
///
/// // 카드
/// AppSkeleton.card(height: 120)
///
/// // 리스트 아이템 (아바타 + 텍스트)
/// AppSkeleton.listTile()
/// ```
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  /// 원형 아바타 스켈레톤
  factory AppSkeleton.avatar({double size = 48}) {
    return AppSkeleton(width: size, height: size, shape: BoxShape.circle);
  }

  /// 텍스트 줄 스켈레톤
  static Widget text({int lines = 1, double? width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
          child: AppSkeleton(
            width: isLast && lines > 1
                ? (width ?? double.infinity) * 0.7
                : width,
            height: 14.h,
            borderRadius: AppRadius.small,
          ),
        );
      }),
    );
  }

  /// 카드 스켈레톤
  factory AppSkeleton.card({double? width, double height = 120}) {
    return AppSkeleton(
      width: width ?? double.infinity,
      height: height,
      borderRadius: AppRadius.large,
    );
  }

  /// 리스트 아이템 스켈레톤 (아바타 + 텍스트)
  static Widget listTile() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          AppSkeleton.avatar(size: 48.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  width: double.infinity,
                  height: 14.h,
                  borderRadius: AppRadius.small,
                ),
                SizedBox(height: 8.h),
                AppSkeleton(
                  width: 120.w,
                  height: 12.h,
                  borderRadius: AppRadius.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 너비 (null이면 부모에 맞춤)
  final double? width;

  /// 높이 (null이면 부모에 맞춤)
  final double? height;

  /// 모서리 반경
  final BorderRadius? borderRadius;

  /// 도형 (rectangle 또는 circle)
  final BoxShape shape;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? widget.borderRadius ?? AppRadius.medium
                : null,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                AppColors.spaceSurface,
                AppColors.spaceElevated,
                AppColors.spaceSurface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
