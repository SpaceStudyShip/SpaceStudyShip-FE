import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/spacing_and_radius.dart';
import '../../../constants/text_styles.dart';

/// 우주공부선 Text Field
///
/// Material 3 TextField 기반의 입력 필드입니다.
/// 우주 테마의 색상과 스타일을 적용하며,
/// 다양한 입력 타입을 지원합니다.
///
/// **기본 사용**:
/// ```dart
/// SpaceTextField(
///   hintText: '이름을 입력하세요',
///   onChanged: (value) {
///     print('입력값: $value');
///   },
/// )
/// ```
///
/// **비밀번호 입력**:
/// ```dart
/// SpaceTextField(
///   hintText: '비밀번호',
///   obscureText: true,
///   prefixIcon: Icons.lock,
/// )
/// ```
///
/// **에러 상태**:
/// ```dart
/// SpaceTextField(
///   hintText: '이메일',
///   errorText: '유효한 이메일을 입력하세요',
/// )
/// ```
class SpaceTextField extends StatelessWidget {
  /// Text Field 생성자
  const SpaceTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
  });

  /// TextField Controller
  final TextEditingController? controller;

  /// Hint 텍스트 (placeholder)
  final String? hintText;

  /// Label 텍스트
  final String? labelText;

  /// 에러 메시지
  final String? errorText;

  /// 좌측 아이콘
  final IconData? prefixIcon;

  /// 우측 아이콘 위젯
  final Widget? suffixIcon;

  /// 비밀번호 모드 (텍스트 숨김)
  final bool obscureText;

  /// 활성화 여부
  final bool enabled;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 최대 줄 수
  final int? maxLines;

  /// 최대 글자 수
  final int? maxLength;

  /// 키보드 타입
  final TextInputType? keyboardType;

  /// 텍스트 입력 액션
  final TextInputAction? textInputAction;

  /// 입력 포맷터
  final List<TextInputFormatter>? inputFormatters;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백 (엔터 키)
  final ValueChanged<String>? onSubmitted;

  /// 유효성 검증 함수
  final FormFieldValidator<String>? validator;

  /// Focus Node
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: AppTextStyles.body1.regular().copyWith(
            color: AppColors.textPrimary,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.spaceElevated,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.textSecondary,
              )
            : null,
        suffixIcon: suffixIcon,
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.spaceDivider.withValues(alpha: 0.5)),
        ),
        contentPadding: AppPadding.all16,
        hintStyle: AppTextStyles.body2.regular().copyWith(
              color: AppColors.textTertiary,
            ),
        labelStyle: AppTextStyles.body2.medium().copyWith(
              color: AppColors.textSecondary,
            ),
        errorStyle: AppTextStyles.caption.regular().copyWith(
              color: AppColors.error,
            ),
      ),
    );
  }
}
