import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 연료 게이지 위젯 - 우주 테마
///
/// **사용 예시**:
/// ```dart
/// FuelGauge(
///   currentFuel: 3,
///   showLabel: true,
/// )
/// ```
class FuelGauge extends StatelessWidget {
  const FuelGauge({
    super.key,
    required this.currentFuel,
    this.maxFuel,
    this.showLabel = true,
    this.showIcon = true,
    this.size = FuelGaugeSize.medium,
  });

  /// 현재 연료량 (예: 3통)
  final int currentFuel;

  /// 최대 연료량 (표시용, null이면 표시 안 함)
  final int? maxFuel;

  /// 라벨 표시 여부
  final bool showLabel;

  /// 아이콘 표시 여부
  final bool showIcon;

  /// 크기
  final FuelGaugeSize size;

  /// 연료 상태에 따른 색상
  Color get _fuelColor {
    if (maxFuel != null) {
      final percentage = (currentFuel / maxFuel!) * 100;
      if (percentage >= 75) return AppColors.fuelFull;
      if (percentage >= 50) return AppColors.fuelMedium;
      if (percentage >= 25) return AppColors.fuelLow;
      return AppColors.fuelEmpty;
    }
    // maxFuel이 없으면 절대값 기준
    if (currentFuel >= 5) return AppColors.fuelFull;
    if (currentFuel >= 3) return AppColors.fuelMedium;
    if (currentFuel >= 1) return AppColors.fuelLow;
    return AppColors.fuelEmpty;
  }

  TextStyle get _textStyle {
    switch (size) {
      case FuelGaugeSize.small:
        return AppTextStyles.tag_12;
      case FuelGaugeSize.medium:
        return AppTextStyles.paragraph_14;
      case FuelGaugeSize.large:
        return AppTextStyles.label_16;
    }
  }

  double get _iconSize {
    switch (size) {
      case FuelGaugeSize.small:
        return 14.w;
      case FuelGaugeSize.medium:
        return 18.w;
      case FuelGaugeSize.large:
        return 22.w;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuelText = maxFuel != null
        ? '$currentFuel/$maxFuel통'
        : '$currentFuel통';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            Icons.local_gas_station_rounded,
            size: _iconSize,
            color: _fuelColor,
          ),
          SizedBox(width: AppSpacing.s4),
        ],
        if (showLabel) ...[
          Text(
            '보유 연료: ',
            style: _textStyle.copyWith(color: AppColors.textSecondary),
          ),
        ],
        Text(fuelText, style: _textStyle.copyWith(color: _fuelColor)),
      ],
    );
  }
}

enum FuelGaugeSize { small, medium, large }
