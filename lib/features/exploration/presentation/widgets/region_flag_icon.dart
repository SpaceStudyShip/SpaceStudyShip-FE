import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';

/// 지역 국기 아이콘 위젯
///
/// 국가 코드 기반 국기를 표시합니다.
/// [isCircular]로 원형 클리핑 적용 여부 선택 (기본: 원본 그대로).
/// 잠긴 상태에서는 잠금 아이콘을 표시합니다.
class RegionFlagIcon extends StatelessWidget {
  const RegionFlagIcon({
    super.key,
    required this.icon,
    required this.size,
    this.isLocked = false,
    this.isCircular = false,
  });

  /// 국가 코드 (예: 'KR', 'JP')
  final String icon;

  /// 아이콘 크기
  final double size;

  /// 잠금 상태
  final bool isLocked;

  /// 원형 클리핑 여부 (false = 원본 그대로)
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.spaceDivider.withValues(alpha: 0.2),
        ),
        child: Center(
          child: Icon(
            Icons.lock_rounded,
            size: size * 0.4,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    try {
      if (isCircular) {
        return CountryFlag.fromCountryCode(
          icon,
          theme: ImageTheme(width: size, height: size, shape: const Circle()),
        );
      }
      // 내부 라디우스 4px (외부 컨테이너의 1/2)
      return ClipRRect(
        borderRadius: AppRadius.small,
        child: CountryFlag.fromCountryCode(
          icon,
          theme: ImageTheme(width: size, height: size * 2 / 3),
        ),
      );
    } catch (_) {
      return Image.asset(
        'assets/app_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
  }
}
