import 'package:flutter/material.dart';

/// 토스 UI 스타일 디자인 토큰
///
/// **컨셉**: 토스 앱의 부드럽고 친근한 인터랙션 패턴을 정의
/// - 스프링 애니메이션: 자연스러운 바운스 효과
/// - 빠른 피드백: 150ms 이내 즉각 반응
/// - 넉넉한 여백: 사용자 친화적 터치 영역
///
/// **사용법**:
/// ```dart
/// AnimatedScale(
///   scale: isPressed ? TossDesignTokens.buttonTapScale : 1.0,
///   duration: TossDesignTokens.animationFast,
///   curve: TossDesignTokens.springCurve,
///   child: ...
/// )
/// ```
class TossDesignTokens {
  // Private 생성자 - 인스턴스화 방지
  TossDesignTokens._();

  // ============================================
  // 애니메이션 Duration
  // ============================================

  /// 빠른 애니메이션 (버튼 탭, 색상 전환)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// 보통 애니메이션 (카드 전환, 페이드)
  static const Duration animationNormal = Duration(milliseconds: 250);

  /// 느린 애니메이션 (페이지 전환, 복잡한 모션)
  static const Duration animationSlow = Duration(milliseconds: 350);

  // ============================================
  // 애니메이션 Curve (토스 특유의 스프링)
  // ============================================

  /// 스프링 커브 - 토스 특유의 부드러운 바운스
  /// 버튼 탭, 스케일 애니메이션에 사용
  static const Curve springCurve = Curves.easeOutBack;

  /// 바운스 커브 - 강조된 애니메이션
  /// 성공 피드백, 완료 애니메이션에 사용
  static const Curve bounceCurve = Curves.elasticOut;

  /// 부드러운 커브 - 기본 전환
  /// 색상, 크기 변경에 사용
  static const Curve smoothCurve = Curves.easeInOut;

  // ============================================
  // 인터랙션 피드백
  // ============================================

  /// 버튼 탭 시 스케일 (3% 축소)
  /// 1.0 → 0.97 변화로 눌림 효과 표현
  static const double buttonTapScale = 0.97;

  /// 카드 탭 시 스케일 (2% 축소)
  /// 버튼보다 살짝 약한 피드백
  static const double cardTapScale = 0.98;

  // ============================================
  // 토스 스타일 여백 (넉넉함 강조)
  // ============================================

  /// 아주 작은 여백 (4px) - 아이콘과 텍스트 사이
  static const double spacingTiny = 4.0;

  /// 작은 여백 (8px) - 밀집된 요소
  static const double spacingSmall = 8.0;

  /// 중간 여백 (16px) - 기본 패딩
  static const double spacingMedium = 16.0;

  /// 큰 여백 (24px) - 섹션 구분
  static const double spacingLarge = 24.0;

  /// 아주 큰 여백 (32px) - 주요 섹션 분리
  static const double spacingHuge = 32.0;

  // ============================================
  // 터치 영역 (접근성)
  // ============================================

  /// 최소 터치 영역 높이 (토스 스타일 - 56px)
  static const double minTouchTargetHeight = 56.0;

  /// 최소 터치 영역 너비
  static const double minTouchTargetWidth = 56.0;
}
