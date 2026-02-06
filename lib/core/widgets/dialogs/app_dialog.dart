import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';
import '../buttons/app_button.dart';

/// 다이얼로그 감정 타입 (피크엔드 법칙)
enum AppDialogEmotion {
  /// 성공 (초록 체크)
  success,

  /// 경고 (주황 경고)
  warning,

  /// 에러 (빨강 에러)
  error,

  /// 정보 (파랑 정보)
  info,

  /// 기본 (아이콘 없음)
  none,
}

/// 앱 전역에서 사용하는 다이얼로그 컴포넌트 - 토스 스타일
///
/// **기본 스펙**:
/// - 모서리: 24px 라운드
/// - 배경: spaceElevated
/// - 애니메이션: 스케일 + 페이드
///
/// **사용 예시**:
/// ```dart
/// // 기본 다이얼로그
/// AppDialog.show(
///   context: context,
///   title: '저장할까요?',
///   message: '변경사항이 저장돼요',
///   onConfirm: () => save(),
/// );
///
/// // 확인/취소 다이얼로그
/// AppDialog.show(
///   context: context,
///   title: '삭제할까요?',
///   message: '삭제하면 되돌릴 수 없어요',
///   emotion: AppDialogEmotion.warning,
///   confirmText: '삭제',
///   cancelText: '취소',
///   isDestructive: true,
///   onConfirm: () => delete(),
/// );
///
/// // 간편 확인 (bool 반환)
/// final result = await AppDialog.confirm(
///   context: context,
///   title: '저장할까요?',
/// );
/// if (result == true) { /* 저장 */ }
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.emotion = AppDialogEmotion.none,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.customContent,
  });

  /// 제목 (필수)
  final String title;

  /// 메시지 (선택)
  final String? message;

  /// 감정 타입 (아이콘 결정)
  final AppDialogEmotion emotion;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 취소 버튼 텍스트 (null이면 취소 버튼 없음)
  final String? cancelText;

  /// 확인 콜백
  final VoidCallback? onConfirm;

  /// 취소 콜백
  final VoidCallback? onCancel;

  /// 위험 액션 여부 (true면 확인 버튼 빨간색)
  final bool isDestructive;

  /// 커스텀 콘텐츠 (message 대신 사용)
  final Widget? customContent;

  // ============================================
  // 정적 메서드
  // ============================================

  /// 다이얼로그 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    AppDialogEmotion emotion = AppDialogEmotion.none,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: TossDesignTokens.animationNormal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          emotion: emotion,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          isDestructive: isDestructive,
          customContent: customContent,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: TossDesignTokens.springCurve,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// 간편 확인 다이얼로그 (bool 반환)
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    AppDialogEmotion emotion = AppDialogEmotion.none,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
  }) async {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: TossDesignTokens.animationNormal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          emotion: emotion,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: TossDesignTokens.springCurve,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // ============================================
  // UI 빌드
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300.w,
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.spaceElevated,
          borderRadius: AppRadius.xxlarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 감정 아이콘
              if (emotion != AppDialogEmotion.none) ...[
                _buildEmotionIcon(),
                SizedBox(height: 16.h),
              ],

              // 제목
              Text(
                title,
                style: AppTextStyles.heading_20.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),

              // 메시지 또는 커스텀 콘텐츠
              if (message != null || customContent != null) ...[
                SizedBox(height: 12.h),
                customContent ??
                    Text(
                      message!,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
              ],

              SizedBox(height: 24.h),

              // 버튼들
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionIcon() {
    final IconData icon;
    final Color color;

    switch (emotion) {
      case AppDialogEmotion.success:
        icon = Icons.check_circle;
        color = AppColors.success;
      case AppDialogEmotion.warning:
        icon = Icons.warning;
        color = AppColors.warning;
      case AppDialogEmotion.error:
        icon = Icons.error;
        color = AppColors.error;
      case AppDialogEmotion.info:
        icon = Icons.info;
        color = AppColors.info;
      case AppDialogEmotion.none:
        return const SizedBox.shrink();
    }

    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32.w, color: color),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final hasCancel = cancelText != null;

    if (hasCancel) {
      return Row(
        children: [
          // 취소 버튼
          Expanded(
            child: AppButton(
              text: cancelText!,
              backgroundColor: AppColors.spaceSurface,
              borderColor: AppColors.spaceDivider,
              foregroundColor: AppColors.textSecondary,
              height: 48.h,
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
            ),
          ),
          SizedBox(width: 12.w),
          // 확인 버튼
          Expanded(
            child: AppButton(
              text: confirmText,
              backgroundColor: isDestructive
                  ? AppColors.error
                  : AppColors.primary,
              borderColor: isDestructive
                  ? AppColors.error
                  : AppColors.primaryDark,
              height: 48.h,
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),
          ),
        ],
      );
    }

    // 확인 버튼만
    return AppButton(
      text: confirmText,
      backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
      borderColor: isDestructive ? AppColors.error : AppColors.primaryDark,
      width: double.infinity,
      height: 48.h,
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call();
      },
    );
  }
}
