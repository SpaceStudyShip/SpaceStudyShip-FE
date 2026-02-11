import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전역 TextStyle 상수
///
/// 사용법:
/// ```dart
/// // 기본 사용
/// Text('제목', style: AppTextStyles.heading_24)
/// Text('본문', style: AppTextStyles.paragraph_14)
///
/// // 색상 변경
/// Text('빨간 제목', style: AppTextStyles.heading_24.copyWith(color: Colors.red))
/// ```
///
/// Weight:
/// - SemiBold: heading01, heading02, subHeading, label
/// - Medium: paragraph, toast, callout, calloutSmall
class AppTextStyles {
  // Private 생성자 - 인스턴스화 방지
  AppTextStyles._();

  // ============================================
  // Heading Styles (SemiBold)
  // ============================================

  /// SemiBold28 - 초대 코드 (28px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get semibold28 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 28.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// Heading01 - 메인 타이틀 (24px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get heading_24 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 24.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// Heading02 - 섹션 제목 (20px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get heading_20 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 20.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  /// SubHeading - 서브 제목 (18px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get subHeading_18 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 18.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Body Styles (Medium)
  // ============================================

  /// Label - 라벨, 강조 텍스트 (16px SemiBold)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get label_16 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 16.sp,
    height: 1.0, // 140% line height
    letterSpacing: -0.32,
  );

  static TextStyle get label16Medium => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 16.sp,
    height: 1.0, // 140% line height
    letterSpacing: -0.32,
  );

  /// Paragraph - 본문 (14px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px
  static TextStyle get paragraph_14 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.4, // 140% line height
    letterSpacing: -0.32,
  );

  static TextStyle get paragraph_14_100 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 14.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get paragraph14Semibold => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 14.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Small Styles (Medium)
  // ============================================

  /// Callout / Tag - 작은 라벨, 태그 (12px Medium)
  /// Line Height: 140%, Letter Spacing: -0.32px

  static TextStyle get tag_12 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 12.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  static TextStyle get tag_10 => TextStyle(
    fontFamily: 'Pretendard-Medium',
    fontSize: 10.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Navigation Styles
  // ============================================

  /// Tag SemiBold - 네비게이션 탭 선택 상태 (10px SemiBold)
  /// Line Height: 100%, Letter Spacing: -0.32px
  static TextStyle get tag10Semibold => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 10.sp,
    height: 1.0, // 100% line height
    letterSpacing: -0.32,
  );

  // ============================================
  // Timer Styles (SemiBold, wide letter spacing)
  // ============================================

  /// Timer Small - 리스트 아이템용 타이머 (24px SemiBold)
  /// Line Height: 100%, Letter Spacing: 2px
  static TextStyle get timer_24 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 24.sp,
    height: 1.0, // 100% line height
    letterSpacing: 2,
  );

  /// Timer Medium - 서브 타이머 (32px SemiBold)
  /// Line Height: 100%, Letter Spacing: 2px
  static TextStyle get timer_32 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 32.sp,
    height: 1.0, // 100% line height
    letterSpacing: 2,
  );

  /// Timer Large - 메인 타이머 (48px SemiBold)
  /// Line Height: 100%, Letter Spacing: 3px
  static TextStyle get timer_48 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 48.sp,
    height: 1.0, // 100% line height
    letterSpacing: 3,
  );

  /// Timer XLarge - 집중 화면 타이머 (64px SemiBold)
  /// Line Height: 100%, Letter Spacing: 4px
  static TextStyle get timer_64 => TextStyle(
    fontFamily: 'Pretendard-SemiBold',
    fontSize: 64.sp,
    height: 1.0, // 100% line height
    letterSpacing: 4,
  );
}
