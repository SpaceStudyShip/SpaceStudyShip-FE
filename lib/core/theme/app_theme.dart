import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';

/// 앱 전역 테마 설정
///
/// **우주 테마 (Space Theme)**:
/// - 다크 모드 전용 테마
/// - Material 3 디자인 시스템 기반
/// - 우주 탐험 컨셉의 몰입감 있는 색상과 스타일
///
/// 사용법:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.spaceTheme,
///   themeMode: ThemeMode.dark,
/// )
/// ```
class AppTheme {
  // Private 생성자 - 인스턴스화 방지
  AppTheme._();

  /// 우주 테마 (다크 모드 전용)
  static ThemeData get spaceTheme {
    return ThemeData(
      // ============================================
      // Material 3 활성화
      // ============================================
      useMaterial3: true,

      // ============================================
      // 색상 스킴 (Material 3 ColorScheme)
      // ============================================
      colorScheme: _spaceColorScheme,

      // ============================================
      // Scaffold 기본 배경
      // ============================================
      scaffoldBackgroundColor: AppColors.spaceBackground,

      // ============================================
      // AppBar 테마 (시스템 UI 스타일 포함)
      // ============================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.spaceSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading4.bold().copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 투명 상태바
          statusBarIconBrightness: Brightness.light, // 밝은 아이콘
          systemNavigationBarColor: AppColors.spaceBackground, // 우주 배경색
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ============================================
      // ElevatedButton 테마
      // ============================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: AppPadding.buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.body1.semiBold(),
        ),
      ),

      // ============================================
      // TextButton 테마
      // ============================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: AppPadding.buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.body1.medium(),
        ),
      ),

      // ============================================
      // OutlinedButton 테마
      // ============================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: AppPadding.buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.body1.medium(),
        ),
      ),

      // ============================================
      // Card 테마
      // ============================================
      cardTheme: CardThemeData(
        color: AppColors.spaceSurface,
        shadowColor: AppColors.primary.withValues(alpha: 0.1),
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),

      // ============================================
      // FloatingActionButton 테마
      // ============================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
      ),

      // ============================================
      // InputDecoration 테마 (TextField)
      // ============================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.spaceElevated,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.spaceDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: AppPadding.all16,
        hintStyle: AppTextStyles.body2.regular().copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.body2.medium().copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ============================================
      // Dialog 테마
      // ============================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.spaceSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
        titleTextStyle: AppTextStyles.heading4.bold().copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTextStyles.body2.regular().copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ============================================
      // BottomSheet 테마
      // ============================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.spaceSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.modal),
        modalBackgroundColor: AppColors.spaceSurface,
      ),

      // ============================================
      // Divider 테마
      // ============================================
      dividerTheme: const DividerThemeData(
        color: AppColors.spaceDivider,
        thickness: 1,
        space: 1,
      ),

      // ============================================
      // Icon 테마
      // ============================================
      iconTheme: const IconThemeData(color: AppColors.textPrimary),

      // ============================================
      // ListTile 테마
      // ============================================
      listTileTheme: ListTileThemeData(
        contentPadding: AppPadding.listItemPadding,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        tileColor: AppColors.spaceSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),

      // ============================================
      // Switch 테마
      // ============================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.spaceDivider;
        }),
      ),

      // ============================================
      // Checkbox 테마
      // ============================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        side: const BorderSide(color: AppColors.spaceDivider, width: 2),
      ),

      // ============================================
      // Radio 테마
      // ============================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.spaceDivider;
        }),
      ),

      // ============================================
      // ProgressIndicator 테마
      // ============================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.spaceDivider,
        circularTrackColor: AppColors.spaceDivider,
      ),

      // ============================================
      // SnackBar 테마
      // ============================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.spaceElevated,
        contentTextStyle: AppTextStyles.body2.medium().copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        behavior: SnackBarBehavior.floating,
      ),

      // ============================================
      // TabBar 테마
      // ============================================
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.body2.semiBold(),
        unselectedLabelStyle: AppTextStyles.body2.regular(),
      ),

      // ============================================
      // Tooltip 테마
      // ============================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.spaceElevated,
          borderRadius: AppRadius.small,
        ),
        textStyle: AppTextStyles.caption.regular().copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// 우주 ColorScheme (Material 3)
  static ColorScheme get _spaceColorScheme {
    return const ColorScheme.dark(
      // ============================================
      // Primary Colors
      // ============================================
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,

      // ============================================
      // Secondary Colors
      // ============================================
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnSecondary,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.secondaryLight,

      // ============================================
      // Tertiary Colors (Cosmic Gold)
      // ============================================
      tertiary: AppColors.accentGold,
      onTertiary: AppColors.spaceBackground,
      tertiaryContainer: AppColors.accentGoldDark,
      onTertiaryContainer: AppColors.accentGoldLight,

      // ============================================
      // Error Colors
      // ============================================
      error: AppColors.error,
      onError: AppColors.textOnPrimary,

      // ============================================
      // Background & Surface
      // ============================================
      surface: AppColors.spaceSurface,
      onSurface: AppColors.textPrimary,

      // ============================================
      // Outline (경계선, 구분선)
      // ============================================
      outline: AppColors.spaceDivider,
    );
  }
}
