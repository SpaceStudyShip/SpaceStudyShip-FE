import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/text_styles.dart';

/// 앱 전역 테마 설정
///
/// 우주 테마 다크 모드 전용 앱
class AppTheme {
  AppTheme._();

  /// 다크 테마 (기본)
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 색상 스킴
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.spaceSurface,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnSecondary,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),

    // 배경색
    scaffoldBackgroundColor: AppColors.spaceBackground,

    // AppBar 테마
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.spaceBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading_20.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),

    // 카드 테마
    cardTheme: CardThemeData(
      color: AppColors.spaceSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.spaceDivider, width: 1),
      ),
    ),

    // 다이얼로그 테마
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.spaceSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTextStyles.heading_20.copyWith(
        color: AppColors.textPrimary,
      ),
      contentTextStyle: AppTextStyles.paragraph_14.copyWith(
        color: AppColors.textSecondary,
      ),
    ),

    // 바텀시트 테마
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.spaceSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // 바텀네비게이션 테마
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.spaceBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // 텍스트 테마
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.heading_24.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineMedium: AppTextStyles.heading_20.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineSmall: AppTextStyles.subHeading_18.copyWith(
        color: AppColors.textPrimary,
      ),
      titleLarge: AppTextStyles.label_16.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTextStyles.paragraph_14.copyWith(
        color: AppColors.textPrimary,
      ),
      bodyMedium: AppTextStyles.paragraph_14.copyWith(
        color: AppColors.textSecondary,
      ),
      bodySmall: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
      labelLarge: AppTextStyles.label_16.copyWith(color: AppColors.textPrimary),
      labelMedium: AppTextStyles.tag_12.copyWith(
        color: AppColors.textSecondary,
      ),
      labelSmall: AppTextStyles.tag_10.copyWith(color: AppColors.textTertiary),
    ),

    // Divider 테마
    dividerTheme: DividerThemeData(
      color: AppColors.spaceDivider,
      thickness: 1,
      space: 1,
    ),

    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.spaceSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.spaceDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.spaceDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTextStyles.paragraph_14.copyWith(
        color: AppColors.textTertiary,
      ),
      labelStyle: AppTextStyles.tag_12.copyWith(color: AppColors.textSecondary),
    ),

    // 아이콘 테마
    iconTheme: const IconThemeData(color: AppColors.textPrimary),

    // 탭바 테마
    tabBarTheme: TabBarThemeData(
      indicatorColor: AppColors.primary,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: AppTextStyles.label_16,
      unselectedLabelStyle: AppTextStyles.paragraph_14,
    ),

    // 스낵바 테마
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.spaceElevated,
      contentTextStyle: AppTextStyles.paragraph_14.copyWith(
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
