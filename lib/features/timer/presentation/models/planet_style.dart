import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 행성/항성의 시각적 스타일 정의
///
/// 향후 탐험 시스템에서 해금한 행성별 커스텀 스타일 매핑에 사용.
class PlanetStyle {
  const PlanetStyle({
    required this.baseColor,
    required this.highlightColor,
    required this.shadowColor,
    this.glowColor,
  });

  /// 구체의 기본 색상 (그라데이션 중간)
  final Color baseColor;

  /// 하이라이트 색상 (좌상단 광원 반사)
  final Color highlightColor;

  /// 그림자 색상 (우하단 어둠)
  final Color shadowColor;

  /// 외곽 글로우 색상 (null이면 baseColor 20% opacity 사용)
  final Color? glowColor;

  /// 기본 항성 스타일 (태양 — 골드 계열)
  static const star = PlanetStyle(
    baseColor: AppColors.accentGold,
    highlightColor: AppColors.accentGoldLight,
    shadowColor: AppColors.accentGoldDark,
  );

  /// 기본 행성 스타일 (파란 행성 — primary 계열)
  static const planet = PlanetStyle(
    baseColor: AppColors.primary,
    highlightColor: AppColors.primaryLight,
    shadowColor: AppColors.primaryDark,
  );
}
