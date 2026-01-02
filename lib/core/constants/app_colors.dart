import 'package:flutter/material.dart';

/// 앱 전역 색상 상수 - 우주 테마 (다크 모드 전용)
///
/// **컨셉**: 우주 탐험 테마의 신비롭고 몰입감 있는 색상 시스템
/// - Deep Space Blue: 우주의 깊이감과 신뢰
/// - Stellar Purple: 신비로움과 프리미엄 경험
/// - Cosmic Gold: 성취감과 보상
///
/// **전략**: 미니멀 팔레트 (base-light-dark) + 선택적 opacity
/// - 각 컬러당 3단계만 정의 (base, light, dark)
/// - 텍스트는 opacity로 계층 표현
/// - 배경은 명시적 색상 (opacity 사용 안 함)
///
/// 사용법:
/// - 기본: AppColors.primary
/// - 호버: AppColors.primaryLight
/// - Pressed: AppColors.primaryDark
/// - 투명도: AppColors.primary.withOpacity(0.5)
class AppColors {
  // Private 생성자 - 인스턴스화 방지
  AppColors._();

  // ============================================
  // Primary: Deep Space Blue (우주의 깊이)
  // ============================================

  /// Primary Blue - 기본 (버튼 기본 상태, 주요 액션)
  static const Color primary = Color(0xFF2196F3);

  /// Primary Blue - 밝음 (버튼 호버, 강조 요소)
  static const Color primaryLight = Color(0xFF64B5F6);

  /// Primary Blue - 어두움 (버튼 pressed, 선택된 상태)
  static const Color primaryDark = Color(0xFF1565C0);

  // ============================================
  // Secondary: Stellar Purple (신비로움)
  // ============================================

  /// Secondary Purple - 기본 (강조 요소, 뱃지)
  static const Color secondary = Color(0xFF9C27B0);

  /// Secondary Purple - 밝음 (특별 강조, 호버)
  static const Color secondaryLight = Color(0xFFBA68C8);

  /// Secondary Purple - 어두움 (pressed, 비활성)
  static const Color secondaryDark = Color(0xFF7B1FA2);

  // ============================================
  // Accent: Cosmic Gold (성취감)
  // ============================================

  /// Cosmic Gold - 기본 (연료 게이지, 레벨업, 보상)
  static const Color accentGold = Color(0xFFFFC400);

  /// Cosmic Gold - 밝음 (강조 효과, 반짝임)
  static const Color accentGoldLight = Color(0xFFFFD740);

  /// Cosmic Gold - 어두움 (어두운 배경용)
  static const Color accentGoldDark = Color(0xFFFFB300);

  // ============================================
  // Accent: Nebula Pink (특별 이벤트)
  // ============================================

  /// Nebula Pink - 기본 (특별 미션, 이벤트)
  static const Color accentPink = Color(0xFFE91E63);

  /// Nebula Pink - 밝음 (강조)
  static const Color accentPinkLight = Color(0xFFF06292);

  /// Nebula Pink - 어두움 (pressed)
  static const Color accentPinkDark = Color(0xFFC2185B);

  // ============================================
  // Functional: 기능 색상 (단일 색상 + opacity 조합)
  // ============================================

  /// Success Green - 연료 충분, Todo 완료, 성공 상태
  static const Color success = Color(0xFF4CAF50);

  /// Warning Orange - 타이머 일시정지, 주의 필요
  static const Color warning = Color(0xFFFF9800);

  /// Error Red - 연료 부족, 에러, 위험 상태
  static const Color error = Color(0xFFF44336);

  /// Info Blue - 정보성 메시지, 안내
  static const Color info = Color(0xFF2196F3);

  // ============================================
  // Background: 우주 배경 (명시적 색상)
  // ============================================

  /// Space Background - 앱 전체 배경 (깊은 우주)
  static const Color spaceBackground = Color(0xFF0A0E27);

  /// Space Surface - 카드, 다이얼로그 배경
  static const Color spaceSurface = Color(0xFF1A1F3A);

  /// Space Elevated - FAB, 부유하는 요소 배경
  static const Color spaceElevated = Color(0xFF252B47);

  /// Space Divider - 구분선, 경계선
  static const Color spaceDivider = Color(0xFF2D3555);

  // ============================================
  // Text: 텍스트 계층 (opacity 기반)
  // ============================================

  /// Text Primary - 주요 텍스트 (100% 불투명)
  static const Color textPrimary = Colors.white;

  /// Text Secondary - 보조 텍스트 (70% 불투명)
  static final Color textSecondary = Colors.white.withValues(alpha: 0.7);

  /// Text Tertiary - 설명 텍스트 (50% 불투명)
  static final Color textTertiary = Colors.white.withValues(alpha: 0.5);

  /// Text Disabled - 비활성 텍스트 (30% 불투명)
  static final Color textDisabled = Colors.white.withValues(alpha: 0.3);

  /// Text on Primary - Primary 색상 위의 텍스트
  static const Color textOnPrimary = Colors.white;

  /// Text on Secondary - Secondary 색상 위의 텍스트
  static const Color textOnSecondary = Colors.white;

  // ============================================
  // Semantic: 시맨틱 색상 (의미론적 색상)
  // ============================================

  /// Timer Running - 타이머 실행 중
  static const Color timerRunning = Color(0xFF2196F3);

  /// Timer Paused - 타이머 일시정지
  static const Color timerPaused = Color(0xFFFF9800);

  /// Timer Completed - 타이머 완료
  static const Color timerCompleted = Color(0xFF4CAF50);

  /// Fuel Full - 연료 충분 (75-100%)
  static const Color fuelFull = Color(0xFF4CAF50);

  /// Fuel Medium - 연료 보통 (50-74%)
  static const Color fuelMedium = Color(0xFFFFD740);

  /// Fuel Low - 연료 부족 (25-49%)
  static const Color fuelLow = Color(0xFFFF9800);

  /// Fuel Empty - 연료 없음 (0-24%)
  static const Color fuelEmpty = Color(0xFFF44336);

  /// Online - 온라인 상태
  static const Color online = Color(0xFF4CAF50);

  /// Away - 자리비움 상태
  static const Color away = Color(0xFFFF9800);

  /// Offline - 오프라인 상태
  static const Color offline = Color(0xFF9E9E9E);
}
