import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 앱 전역 그라데이션 정의
///
/// 카드, 헤더, 배경 등에 사용되는 재사용 그라데이션.
class AppGradients {
  AppGradients._();

  // ============================================
  // 카드/서페이스 그라데이션
  // ============================================

  /// 카드 서페이스 - 서틀한 깊이감 (기본 카드 배경용)
  static const LinearGradient cardSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2340), Color(0xFF151930)],
  );

  /// 카드 서페이스 (강조) - primary 틴트
  static const LinearGradient cardSurfaceAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2545), Color(0xFF131835)],
  );

  // ============================================
  // 액센트 그라데이션
  // ============================================

  /// Primary 액센트 - 버튼, 강조 요소
  static const LinearGradient primaryAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
  );

  /// 업적/달성 그라데이션 - gold accent
  static const LinearGradient achievement = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD740), Color(0xFFFFA000)],
  );

  /// Cosmic header - 헤더 배경용
  static const LinearGradient cosmicHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.6, 1.0],
    colors: [Color(0xFF0D1230), Color(0xFF0A0E27), Color(0x000A0E27)],
  );

  // ============================================
  // 메달 그라데이션 (랭킹용)
  // ============================================

  /// 금메달
  static const LinearGradient goldMedal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
  );

  /// 은메달
  static const LinearGradient silverMedal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
  );

  /// 동메달
  static const LinearGradient bronzeMedal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD7A86E), Color(0xFFA67C52)],
  );

  // ============================================
  // 상태 그라데이션
  // ============================================

  /// 타이머 실행 중 - 서틀한 blue glow
  static LinearGradient timerRunning = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.timerRunning.withValues(alpha: 0.08),
      Colors.transparent,
    ],
  );

  /// 스탯 칩 배경 - 서틀한 서페이스
  static const LinearGradient statChip = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2440), Color(0xFF171C35)],
  );
}
