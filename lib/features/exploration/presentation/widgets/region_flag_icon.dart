import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 지역 국기 아이콘 위젯
///
/// 국가 코드 기반 국기를 원형으로 표시합니다.
/// 잠긴 상태에서는 잠금 아이콘을, 유효하지 않은 코드에는 앱 로고를 표시합니다.
class RegionFlagIcon extends StatelessWidget {
  const RegionFlagIcon({
    super.key,
    required this.icon,
    required this.size,
    this.isLocked = false,
  });

  /// 국가 코드 (예: 'KR', 'JP')
  final String icon;

  /// 아이콘 크기
  final double size;

  /// 잠금 상태
  final bool isLocked;

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
      return CountryFlag.fromCountryCode(
        icon,
        theme: ImageTheme(width: size, height: size, shape: const Circle()),
      );
    } catch (_) {
      return ClipOval(
        child: Image.asset(
          'assets/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
