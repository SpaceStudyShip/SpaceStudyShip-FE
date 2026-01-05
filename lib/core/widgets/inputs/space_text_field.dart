import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import 'formatters/input_formatters.dart';

/// 입력 자동 포맷 타입 (테슬러/밀러 법칙)
enum SpaceInputFormat {
  /// 포맷 없음
  none,

  /// 전화번호: 010-1234-5678
  phone,

  /// 카드번호: 1234 5678 9012 3456
  card,

  /// 계좌번호: 123-4567-890123
  account,

  /// 통화: 1,000,000
  currency,

  /// 이메일: 소문자 자동 변환
  email,
}

/// 우주공부선 Text Field
///
/// Toss UX 원칙이 적용된 텍스트 입력 위젯입니다.
///
/// **적용된 UX 심리학 법칙:**
/// - 포스텔의 법칙: 유연한 입력 수용 (autoTrim, 자동 포맷팅)
/// - 테슬러의 법칙: 복잡성 흡수 (자동 완성, 포맷팅)
/// - 밀러의 법칙: 청킹 (전화번호, 카드번호 자동 분리)
/// - 도허티 임계: 실시간 유효성 검사 (400ms 디바운스)
///
/// **Toss 라이팅 원칙:**
/// - hintText: "이름" (X: "이름을 입력하세요")
/// - helperText: 추가 안내 (필요시)
///
/// **사용 예시:**
/// ```dart
/// SpaceTextField(
///   hintText: '휴대폰 번호',
///   autoFormat: SpaceInputFormat.phone,
///   keyboardType: TextInputType.phone,
/// )
/// ```
class SpaceTextField extends StatefulWidget {
  /// SpaceTextField 생성자
  const SpaceTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.helperText,
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
    // 새 기능 (Toss UX 원칙)
    this.autoFormat = SpaceInputFormat.none,
    this.autoTrimWhitespace = true,
    this.showCharacterCount = false,
    this.validateOnChange = false,
    this.validationDebounce = const Duration(milliseconds: 400),
  });

  /// TextField Controller
  final TextEditingController? controller;

  /// Hint 텍스트 (Toss 라이팅: "이름" - 간결하게)
  final String? hintText;

  /// Label 텍스트
  final String? labelText;

  /// 도움말 텍스트 (힌트 아래)
  final String? helperText;

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

  /// 입력 포맷터 (커스텀)
  final List<TextInputFormatter>? inputFormatters;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백 (엔터 키)
  final ValueChanged<String>? onSubmitted;

  /// 유효성 검증 함수
  final FormFieldValidator<String>? validator;

  /// Focus Node
  final FocusNode? focusNode;

  /// 자동 포맷 타입 (테슬러/밀러 법칙)
  final SpaceInputFormat autoFormat;

  /// 앞뒤 공백 자동 제거 (포스텔 법칙)
  final bool autoTrimWhitespace;

  /// 글자 수 표시
  final bool showCharacterCount;

  /// 입력 중 유효성 검사 (도허티 임계)
  final bool validateOnChange;

  /// 유효성 검사 디바운스 시간
  final Duration validationDebounce;

  @override
  State<SpaceTextField> createState() => _SpaceTextFieldState();
}

class _SpaceTextFieldState extends State<SpaceTextField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  List<TextInputFormatter> get _formatters {
    final formatters = <TextInputFormatter>[];

    // 자동 포맷터 추가 (테슬러/밀러 법칙)
    switch (widget.autoFormat) {
      case SpaceInputFormat.phone:
        formatters.add(PhoneInputFormatter());
      case SpaceInputFormat.card:
        formatters.add(CardInputFormatter());
      case SpaceInputFormat.account:
        formatters.add(AccountInputFormatter());
      case SpaceInputFormat.currency:
        formatters.add(CurrencyInputFormatter());
      case SpaceInputFormat.email:
        formatters.add(EmailInputFormatter());
      case SpaceInputFormat.none:
        break;
    }

    // 커스텀 포맷터 추가
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    return formatters;
  }

  TextInputType? get _keyboardType {
    if (widget.keyboardType != null) return widget.keyboardType;

    // 자동 포맷에 따른 키보드 타입 설정
    switch (widget.autoFormat) {
      case SpaceInputFormat.phone:
      case SpaceInputFormat.card:
      case SpaceInputFormat.account:
      case SpaceInputFormat.currency:
        return TextInputType.number;
      case SpaceInputFormat.email:
        return TextInputType.emailAddress;
      case SpaceInputFormat.none:
        return null;
    }
  }

  void _handleChanged(String value) {
    // 공백 자동 제거 (포스텔 법칙)
    final processedValue = widget.autoTrimWhitespace ? value.trim() : value;

    // 실시간 유효성 검사 (도허티 임계)
    if (widget.validateOnChange && widget.validator != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.validationDebounce, () {
        if (mounted) {
          setState(() {
            _validationError = widget.validator!(processedValue);
          });
        }
      });
    }

    widget.onChanged?.call(processedValue);
  }

  String? get _displayError {
    // 외부 에러가 우선
    if (widget.errorText != null) return widget.errorText;
    // 실시간 검증 에러
    if (widget.validateOnChange) return _validationError;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: _keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: _formatters,
          onChanged: _handleChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: AppTextStyles.body1.regular().copyWith(
                color: AppColors.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            errorText: _displayError,
            helperText: widget.helperText,
            filled: true,
            fillColor: AppColors.spaceElevated,
            counterText: widget.showCharacterCount ? null : '',
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppColors.textSecondary,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
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
              borderSide: BorderSide(
                color: AppColors.spaceDivider.withValues(alpha: 0.5),
              ),
            ),
            contentPadding: AppPadding.all16,
            hintStyle: AppTextStyles.body2.regular().copyWith(
                  color: AppColors.textTertiary,
                ),
            labelStyle: AppTextStyles.body2.medium().copyWith(
                  color: AppColors.textSecondary,
                ),
            helperStyle: AppTextStyles.caption.regular().copyWith(
                  color: AppColors.textTertiary,
                ),
            errorStyle: AppTextStyles.caption.regular().copyWith(
                  color: AppColors.error,
                ),
          ),
        ),
      ],
    );
  }
}
