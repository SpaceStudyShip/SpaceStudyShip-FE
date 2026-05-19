import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';
import '../buttons/app_button.dart';

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
///   confirmText: '삭제',
///   cancelText: '취소',
///   isDestructive: true,
///   onConfirm: () => delete(),
/// );
///
/// // Confirmation phrase 입력 (탈퇴 등 destructive action)
/// AppDialog.show(
///   context: context,
///   title: '정말 탈퇴하시겠어요?',
///   message: '되돌릴 수 없어요. 확인을 위해 phrase 를 입력해 주세요.',
///   confirmationPhrases: ['탈퇴하기', 'delete'],
///   confirmationHint: '탈퇴하기 또는 delete 입력',
///   confirmText: '탈퇴',
///   cancelText: '취소',
///   isDestructive: true,
///   onConfirm: () => withdraw(),
/// );
///
/// // 간편 확인 (bool 반환)
/// final result = await AppDialog.confirm(
///   context: context,
///   title: '저장할까요?',
/// );
/// if (result == true) { /* 저장 */ }
/// ```
class AppDialog extends StatefulWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.customContent,
    this.confirmationPhrases,
    this.confirmationHint,
  });

  /// 제목 (필수)
  final String title;

  /// 메시지 (선택)
  final String? message;

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

  /// 확인 텍스트필드 phrase 후보 (예: `['탈퇴하기', 'delete']`).
  ///
  /// 입력값이 `trim().toLowerCase()` 변환 후 후보 중 하나와 매치되어야
  /// 확인 버튼이 활성화됨. null 이면 textfield 표시 안 함 (기존 동작 유지).
  final List<String>? confirmationPhrases;

  /// 확인 텍스트필드 hint. [confirmationPhrases] 가 있을 때만 사용.
  final String? confirmationHint;

  // ============================================
  // 정적 메서드
  // ============================================

  /// 다이얼로그 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? customContent,
    List<String>? confirmationPhrases,
    String? confirmationHint,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: TossDesignTokens.animationNormal,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          customContent: customContent,
          confirmationPhrases: confirmationPhrases,
          confirmationHint: confirmationHint,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            onConfirm?.call();
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
            onCancel?.call();
          },
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
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
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

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  late final TextEditingController _confirmationController;

  @override
  void initState() {
    super.initState();
    _confirmationController = TextEditingController()
      ..addListener(_onConfirmationChanged);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _onConfirmationChanged() {
    if (!mounted) return;
    // Trigger rebuild so confirm button reflects match state.
    setState(() {});
  }

  /// 확인 버튼 활성 여부.
  ///
  /// `confirmationPhrases` 가 null 이면 항상 true (기존 동작).
  /// 있으면 입력값 `trim().toLowerCase()` 가 후보 중 하나와 일치해야 true.
  bool get _isConfirmEnabled {
    final phrases = widget.confirmationPhrases;
    if (phrases == null) return true;
    final normalized = _confirmationController.text.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return phrases.any((p) => p.toLowerCase() == normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300.w,
        margin: AppPadding.horizontal24,
        padding: AppPadding.all24,
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
              // 제목
              Text(
                widget.title,
                style: AppTextStyles.heading_20.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),

              // 메시지 또는 커스텀 콘텐츠
              if (widget.message != null || widget.customContent != null) ...[
                SizedBox(height: AppSpacing.s24),
                widget.customContent ??
                    Text(
                      widget.message!,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
              ],

              // Confirmation textfield (phrase 가 주어진 경우)
              if (widget.confirmationPhrases != null) ...[
                SizedBox(height: AppSpacing.s16),
                TextField(
                  controller: _confirmationController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label_16.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: widget.confirmationHint,
                    hintStyle: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.spaceSurface,
                    contentPadding: AppPadding.all12,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.medium,
                      borderSide: BorderSide(color: AppColors.spaceDivider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.medium,
                      borderSide: BorderSide(
                        color: widget.isDestructive
                            ? AppColors.error
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.s24),

              // 버튼들
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final hasCancel = widget.cancelText != null;
    final confirmCallback = _isConfirmEnabled ? widget.onConfirm : null;

    if (hasCancel) {
      return Row(
        children: [
          // 취소 버튼
          Expanded(
            child: AppButton(
              text: widget.cancelText!,
              backgroundColor: AppColors.spaceSurface,
              borderColor: AppColors.spaceDivider,
              foregroundColor: AppColors.textSecondary,
              height: 48.h,
              onPressed: widget.onCancel,
            ),
          ),
          SizedBox(width: AppSpacing.s12),
          // 확인 버튼
          Expanded(
            child: AppButton(
              text: widget.confirmText,
              backgroundColor: widget.isDestructive
                  ? AppColors.error
                  : AppColors.primary,
              borderColor: widget.isDestructive
                  ? AppColors.error
                  : AppColors.primaryDark,
              height: 48.h,
              onPressed: confirmCallback,
            ),
          ),
        ],
      );
    }

    // 확인 버튼만
    return AppButton(
      text: widget.confirmText,
      backgroundColor: widget.isDestructive
          ? AppColors.error
          : AppColors.primary,
      borderColor: widget.isDestructive
          ? AppColors.error
          : AppColors.primaryDark,
      width: double.infinity,
      height: 48.h,
      onPressed: confirmCallback,
    );
  }
}
