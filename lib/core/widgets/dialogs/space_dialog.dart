import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../buttons/space_button.dart';

/// 다이얼로그 감정 타입 (피크엔드 법칙)
enum SpaceDialogEmotion {
  /// 감정 없음 (기본)
  none,

  /// 성공
  success,

  /// 경고
  warning,

  /// 에러
  error,

  /// 정보
  info,
}

/// 우주공부선 Dialog
///
/// Toss UX 원칙이 적용된 다이얼로그입니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 힉의 법칙: 선택지 최대 2개 (확인/취소)
/// - 피크엔드 법칙: 감정 공감 메시지 + 아이콘
/// - 심미적 사용성: 부드러운 애니메이션, 둥글둥글한 디자인
/// - 밀러의 법칙: 내용을 청크로 구분
///
/// **Toss 라이팅 원칙:**
/// - title: "삭제할까요?" (X: "삭제 확인")
/// - message: "삭제하면 되돌릴 수 없어요" (감정 공감)
///
/// **사용 예시:**
/// ```dart
/// SpaceDialog.show(
///   context: context,
///   title: '삭제할까요?',
///   message: '삭제하면 되돌릴 수 없어요',
///   emotion: SpaceDialogEmotion.warning,
///   confirmText: '삭제',
///   cancelText: '취소',
///   onConfirm: () => deleteItem(),
/// );
///
/// // 간편 확인 다이얼로그
/// final result = await SpaceDialog.confirm(
///   context: context,
///   title: '저장할까요?',
///   message: '변경사항이 저장돼요',
/// );
/// ```
class SpaceDialog extends StatelessWidget {
  /// 기본 Dialog 생성자
  const SpaceDialog({
    super.key,
    this.title,
    this.message,
    this.child,
    this.emotion = SpaceDialogEmotion.none,
    this.headerIcon,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonType = SpaceButtonType.primary,
    this.barrierDismissible = true,
  });

  /// 다이얼로그 제목 (Toss 라이팅: "삭제할까요?")
  final String? title;

  /// 다이얼로그 메시지
  final String? message;

  /// 커스텀 위젯 (message 대신 사용)
  final Widget? child;

  /// 감정 타입 (피크엔드 법칙)
  final SpaceDialogEmotion emotion;

  /// 헤더 아이콘 (커스텀)
  final Widget? headerIcon;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 취소 버튼 텍스트 (null이면 취소 버튼 없음)
  final String? cancelText;

  /// 확인 버튼 콜백
  final VoidCallback? onConfirm;

  /// 취소 버튼 콜백
  final VoidCallback? onCancel;

  /// 확인 버튼 타입
  final SpaceButtonType confirmButtonType;

  /// 외부 클릭 시 닫힘 여부
  final bool barrierDismissible;

  /// 감정별 아이콘 매핑
  IconData? get _emotionIcon {
    switch (emotion) {
      case SpaceDialogEmotion.success:
        return Icons.check_circle;
      case SpaceDialogEmotion.warning:
        return Icons.warning;
      case SpaceDialogEmotion.error:
        return Icons.error;
      case SpaceDialogEmotion.info:
        return Icons.info;
      case SpaceDialogEmotion.none:
        return null;
    }
  }

  /// 감정별 색상 매핑
  Color get _emotionColor {
    switch (emotion) {
      case SpaceDialogEmotion.success:
        return AppColors.success;
      case SpaceDialogEmotion.warning:
        return AppColors.warning;
      case SpaceDialogEmotion.error:
        return AppColors.error;
      case SpaceDialogEmotion.info:
        return AppColors.primary;
      case SpaceDialogEmotion.none:
        return AppColors.textSecondary;
    }
  }

  /// SpaceDialog를 표시하는 헬퍼 메서드
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? child,
    SpaceDialogEmotion emotion = SpaceDialogEmotion.none,
    Widget? headerIcon,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    SpaceButtonType confirmButtonType = SpaceButtonType.primary,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SpaceDialog(
          title: title,
          message: message,
          child: child,
          emotion: emotion,
          headerIcon: headerIcon,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          confirmButtonType: confirmButtonType,
          barrierDismissible: barrierDismissible,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// 간편 확인 다이얼로그
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String cancelText = '취소',
    SpaceDialogEmotion emotion = SpaceDialogEmotion.none,
  }) async {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      emotion: emotion,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        constraints: BoxConstraints(
          maxWidth: 320.w,
          minWidth: 280.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.spaceSurface,
          borderRadius: AppRadius.large,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘 (피크엔드 법칙)
                if (headerIcon != null || _emotionIcon != null) ...[
                  headerIcon ??
                      Icon(
                        _emotionIcon,
                        size: 48.w,
                        color: _emotionColor,
                      ),
                  SizedBox(height: 16.h),
                ],

                // 제목
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.heading4.bold().copyWith(
                          color: AppColors.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                ],

                // 메시지 또는 커스텀 위젯
                if (message != null)
                  Text(
                    message!,
                    style: AppTextStyles.body2.regular().copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                if (child != null) child!,

                SizedBox(height: 24.h),

                // 버튼 영역 (힉의 법칙: 최대 2개)
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    // 취소 버튼이 없는 경우: 확인 버튼만
    if (cancelText == null) {
      return SpaceButton(
        text: confirmText,
        type: confirmButtonType,
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm?.call();
        },
      );
    }

    // 확인/취소 버튼 모두 있는 경우
    return Row(
      children: [
        // 취소 버튼
        Expanded(
          child: SpaceButton(
            text: cancelText!,
            type: SpaceButtonType.secondary,
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
          ),
        ),
        SizedBox(width: 12.w),
        // 확인 버튼
        Expanded(
          child: SpaceButton(
            text: confirmText,
            type: confirmButtonType,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
          ),
        ),
      ],
    );
  }
}
