import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/spacing_and_radius.dart';
import '../../../constants/text_styles.dart';
import '../../atoms/buttons/space_primary_button.dart';

/// 우주공부선 Dialog
///
/// Material 3 AlertDialog 기반의 다이얼로그입니다.
/// 우주 테마의 색상과 스타일을 적용하며,
/// 제목, 내용, 액션 버튼을 지원합니다.
///
/// **기본 사용**:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => SpaceDialog(
///     title: '알림',
///     content: '작업이 완료되었습니다.',
///     confirmText: '확인',
///   ),
/// );
/// ```
///
/// **확인/취소 다이얼로그**:
/// ```dart
/// final result = await showDialog<bool>(
///   context: context,
///   builder: (context) => SpaceDialog(
///     title: '삭제 확인',
///     content: '정말로 삭제하시겠습니까?',
///     confirmText: '삭제',
///     cancelText: '취소',
///     onConfirm: () => Navigator.pop(context, true),
///     onCancel: () => Navigator.pop(context, false),
///   ),
/// );
/// ```
///
/// **커스텀 콘텐츠**:
/// ```dart
/// SpaceDialog.custom(
///   title: '설정',
///   child: Column(
///     children: [
///       SwitchListTile(...),
///       CheckboxListTile(...),
///     ],
///   ),
///   confirmText: '저장',
/// )
/// ```
class SpaceDialog extends StatelessWidget {
  /// 기본 Dialog 생성자
  const SpaceDialog({
    super.key,
    this.title,
    this.content,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
  }) : child = null;

  /// 커스텀 콘텐츠 Dialog 생성자
  const SpaceDialog.custom({
    super.key,
    this.title,
    required this.child,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
  }) : content = null;

  /// 다이얼로그 제목
  final String? title;

  /// 다이얼로그 내용 (텍스트)
  final String? content;

  /// 커스텀 위젯 (content 대신 사용)
  final Widget? child;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 취소 버튼 텍스트 (null이면 취소 버튼 표시 안 함)
  final String? cancelText;

  /// 확인 버튼 클릭 콜백
  final VoidCallback? onConfirm;

  /// 취소 버튼 클릭 콜백
  final VoidCallback? onCancel;

  /// 다이얼로그 외부 클릭 시 닫힘 여부
  final bool barrierDismissible;

  /// SpaceDialog를 표시하는 헬퍼 메서드
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? content,
    Widget? child,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child != null
          ? SpaceDialog.custom(
              title: title,
              confirmText: confirmText,
              cancelText: cancelText,
              onConfirm: onConfirm,
              onCancel: onCancel,
              barrierDismissible: barrierDismissible,
              child: child,
            )
          : SpaceDialog(
              title: title,
              content: content,
              confirmText: confirmText,
              cancelText: cancelText,
              onConfirm: onConfirm,
              onCancel: onCancel,
              barrierDismissible: barrierDismissible,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.spaceSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
      ),
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.heading4.bold().copyWith(
                    color: AppColors.textPrimary,
                  ),
            )
          : null,
      content: _buildContent(),
      actions: _buildActions(context),
      contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
      actionsPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
    );
  }

  Widget? _buildContent() {
    if (child != null) {
      return child;
    }

    if (content != null) {
      return Text(
        content!,
        style: AppTextStyles.body2.regular().copyWith(
              color: AppColors.textSecondary,
            ),
      );
    }

    return null;
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    // 취소 버튼
    if (cancelText != null) {
      actions.add(
        Expanded(
          child: TextButton(
            onPressed: onCancel ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: AppPadding.buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.button,
              ),
            ),
            child: Text(
              cancelText!,
              style: AppTextStyles.body1.medium(),
            ),
          ),
        ),
      );
      actions.add(SizedBox(width: 12.w));
    }

    // 확인 버튼
    actions.add(
      Expanded(
        child: SpacePrimaryButton(
          text: confirmText,
          onPressed: onConfirm ?? () => Navigator.pop(context),
        ),
      ),
    );

    return [
      Row(
        children: actions,
      ),
    ];
  }
}
