import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/spacing_and_radius.dart';

/// 우주공부선 Card
///
/// Material 3 Card 기반의 카드 컴포넌트입니다.
/// 우주 테마의 spaceSurface 배경색을 사용하며,
/// 다양한 콘텐츠를 담을 수 있습니다.
///
/// **기본 사용**:
/// ```dart
/// SpaceCard(
///   child: Text('카드 내용'),
/// )
/// ```
///
/// **패딩 있는 카드**:
/// ```dart
/// SpaceCard(
///   padding: AppPadding.all16,
///   child: Column(
///     children: [
///       Text('제목'),
///       Text('내용'),
///     ],
///   ),
/// )
/// ```
///
/// **클릭 가능한 카드**:
/// ```dart
/// SpaceCard(
///   onTap: () {
///     // 카드 클릭 처리
///   },
///   child: ListTile(
///     title: Text('클릭 가능한 카드'),
///   ),
/// )
/// ```
class SpaceCard extends StatelessWidget {
  /// Card 생성자
  const SpaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.width,
    this.height,
  });

  /// 카드 내부 콘텐츠
  final Widget child;

  /// 카드 내부 패딩
  final EdgeInsetsGeometry? padding;

  /// 카드 외부 마진
  final EdgeInsetsGeometry? margin;

  /// 카드 배경색 (미지정 시 spaceSurface)
  final Color? color;

  /// 카드 모서리 반경 (미지정 시 AppRadius.card)
  final BorderRadius? borderRadius;

  /// 카드 그림자 높이
  final double? elevation;

  /// 카드 클릭 콜백
  final VoidCallback? onTap;

  /// 카드 너비
  final double? width;

  /// 카드 높이
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      child: Card(
        color: color ?? AppColors.spaceSurface,
        shadowColor: AppColors.primary.withValues(alpha: 0.1),
        elevation: elevation ?? 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? AppRadius.card,
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: borderRadius ?? AppRadius.card,
                child: _buildContent(),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (padding != null) {
      return Padding(
        padding: padding!,
        child: child,
      );
    }
    return child;
  }
}
