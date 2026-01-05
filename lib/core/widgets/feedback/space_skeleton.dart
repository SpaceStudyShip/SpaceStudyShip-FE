import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';

/// 우주공부선 Skeleton UI
///
/// Toss UX 원칙이 적용된 스켈레톤 로딩 위젯입니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 도허티 임계: 콘텐츠 형태를 미리 보여줌으로써 로딩 시간 체감 감소
/// - 테슬러의 법칙: 복잡한 로딩 로직을 단순한 UI로 표현
/// - 심미적 사용성: 부드러운 시머 애니메이션
///
/// **사용 예시:**
/// ```dart
/// // 기본 사각형
/// SpaceSkeleton(width: 100, height: 20)
///
/// // 원형 아바타
/// SpaceSkeleton.avatar()
///
/// // 텍스트 줄
/// SpaceSkeleton.text(lines: 3)
///
/// // 카드
/// SpaceSkeleton.card(height: 120)
///
/// // 리스트 아이템
/// SpaceSkeleton.listTile()
/// ```
class SpaceSkeleton extends StatelessWidget {
  /// 기본 SpaceSkeleton 생성자
  const SpaceSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  /// 너비
  final double? width;

  /// 높이
  final double? height;

  /// 모서리 반경
  final BorderRadius? borderRadius;

  /// 원형 여부
  final bool isCircle;

  /// 텍스트 스켈레톤
  factory SpaceSkeleton.text({
    double? width,
    int lines = 1,
    double lineHeight = 16,
    double lineSpacing = 8,
  }) {
    return _SpaceSkeletonText(
      width: width,
      lines: lines,
      lineHeight: lineHeight,
      lineSpacing: lineSpacing,
    );
  }

  /// 아바타 스켈레톤
  factory SpaceSkeleton.avatar({double size = 48}) {
    return SpaceSkeleton(
      width: size,
      height: size,
      isCircle: true,
    );
  }

  /// 카드 스켈레톤
  factory SpaceSkeleton.card({
    double? width,
    double height = 120,
  }) {
    return _SpaceSkeletonCard(
      width: width,
      height: height,
    );
  }

  /// 리스트 타일 스켈레톤
  factory SpaceSkeleton.listTile() {
    return const _SpaceSkeletonListTile();
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.spaceDivider,
      highlightColor: AppColors.spaceElevated,
      child: Container(
        width: width?.w,
        height: height?.h,
        decoration: BoxDecoration(
          color: AppColors.spaceDivider,
          borderRadius: isCircle
              ? null
              : (borderRadius ?? AppRadius.small),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

/// 텍스트 스켈레톤 (내부 구현)
class _SpaceSkeletonText extends SpaceSkeleton {
  const _SpaceSkeletonText({
    super.width,
    required this.lines,
    required this.lineHeight,
    required this.lineSpacing,
  });

  final int lines;
  final double lineHeight;
  final double lineSpacing;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.spaceDivider,
      highlightColor: AppColors.spaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (index) {
          // 마지막 줄은 80% 너비
          final isLastLine = index == lines - 1 && lines > 1;
          final lineWidth = isLastLine ? 0.8 : 1.0;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < lines - 1 ? lineSpacing.h : 0,
            ),
            child: FractionallySizedBox(
              widthFactor: width != null ? null : lineWidth,
              child: Container(
                width: width?.w,
                height: lineHeight.h,
                decoration: BoxDecoration(
                  color: AppColors.spaceDivider,
                  borderRadius: AppRadius.small,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 카드 스켈레톤 (내부 구현)
class _SpaceSkeletonCard extends SpaceSkeleton {
  const _SpaceSkeletonCard({
    super.width,
    required double height,
  }) : super(height: height);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.spaceDivider,
      highlightColor: AppColors.spaceElevated,
      child: Container(
        width: width?.w,
        height: height?.h,
        padding: AppPadding.all16,
        decoration: BoxDecoration(
          color: AppColors.spaceDivider,
          borderRadius: AppRadius.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 영역
            Container(
              width: 150.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: AppColors.spaceElevated,
                borderRadius: AppRadius.small,
              ),
            ),
            SizedBox(height: 12.h),
            // 설명 영역
            Container(
              width: double.infinity,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.spaceElevated,
                borderRadius: AppRadius.small,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 200.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.spaceElevated,
                borderRadius: AppRadius.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 리스트 타일 스켈레톤 (내부 구현)
class _SpaceSkeletonListTile extends SpaceSkeleton {
  const _SpaceSkeletonListTile();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.spaceDivider,
      highlightColor: AppColors.spaceElevated,
      child: Padding(
        padding: AppPadding.listItemPadding,
        child: Row(
          children: [
            // 아바타
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: AppColors.spaceDivider,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: AppColors.spaceDivider,
                      borderRadius: AppRadius.small,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 200.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.spaceDivider,
                      borderRadius: AppRadius.small,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
