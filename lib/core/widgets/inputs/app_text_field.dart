import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../constants/toss_design_tokens.dart';

/// 입력 자동 포맷팅 타입
enum AppInputFormat {
  /// 전화번호 (010-1234-5678)
  phone,

  /// 카드번호 (1234 5678 9012 3456)
  card,

  /// 계좌번호 (123-4567-890123)
  account,

  /// 금액 (1,000,000)
  currency,

  /// 이메일 (소문자 자동 변환)
  email,
}

/// 앱 전역에서 사용하는 공용 텍스트 입력 컴포넌트 - 토스 스타일
///
/// **기본 스펙**:
/// - 높이: 56px (터치 영역 확보)
/// - 모서리: 12px 라운드
/// - 폰트: AppTextStyles.paragraph_14
///
/// **토스 스타일**:
/// - 포커스 시 primary 테두리
/// - 에러 시 error 테두리
/// - 부드러운 전환 애니메이션
///
/// **자동 포맷팅** (테슬러/밀러 법칙):
/// - phone: 010-1234-5678
/// - card: 1234 5678 9012 3456
/// - currency: 1,000,000
/// - email: 소문자 자동 변환
///
/// **사용 예시**:
/// ```dart
/// // 기본 입력
/// AppTextField(
///   hintText: '이름',
///   onChanged: (value) => print(value),
/// )
///
/// // 전화번호 자동 포맷팅
/// AppTextField(
///   hintText: '휴대폰 번호',
///   autoFormat: AppInputFormat.phone,
///   keyboardType: TextInputType.phone,
/// )
///
/// // 에러 표시
/// AppTextField(
///   hintText: '이메일',
///   errorText: '올바른 이메일을 입력해 주세요',
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.autoFormat,
    this.inputFormatters,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.validator,
  });

  /// 텍스트 컨트롤러
  final TextEditingController? controller;

  /// 힌트 텍스트 (플레이스홀더)
  final String? hintText;

  /// 라벨 텍스트 (상단 레이블)
  final String? labelText;

  /// 에러 텍스트 (빨간색 하단 메시지)
  final String? errorText;

  /// 도움 텍스트 (회색 하단 메시지)
  final String? helperText;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백 (엔터 키)
  final ValueChanged<String>? onSubmitted;

  /// 비밀번호 모드 (마스킹)
  final bool obscureText;

  /// 활성화 여부
  final bool enabled;

  /// 읽기 전용
  final bool readOnly;

  /// 자동 포커스
  final bool autofocus;

  /// 최대 줄 수
  final int maxLines;

  /// 최대 글자 수
  final int? maxLength;

  /// 키보드 타입
  final TextInputType? keyboardType;

  /// 키보드 액션 버튼
  final TextInputAction? textInputAction;

  /// 왼쪽 아이콘
  final IconData? prefixIcon;

  /// 오른쪽 위젯 (아이콘 또는 버튼)
  final Widget? suffixIcon;

  /// 자동 포맷팅 타입
  final AppInputFormat? autoFormat;

  /// 커스텀 입력 포맷터
  final List<TextInputFormatter>? inputFormatters;

  /// 포커스 노드
  final FocusNode? focusNode;

  /// 텍스트 정렬
  final TextAlign textAlign;

  /// 유효성 검사 함수
  final String? Function(String?)? validator;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleChanged(String value) {
    // 실시간 유효성 검사
    if (widget.validator != null) {
      setState(() {
        _validationError = widget.validator!(value);
      });
    }
    widget.onChanged?.call(value);
  }

  // ============================================
  // 자동 포맷팅 헬퍼
  // ============================================

  List<TextInputFormatter> _buildFormatters() {
    final formatters = <TextInputFormatter>[];

    // 커스텀 포맷터 우선
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
      return formatters;
    }

    // 자동 포맷팅
    if (widget.autoFormat != null) {
      switch (widget.autoFormat!) {
        case AppInputFormat.phone:
          formatters.addAll([
            FilteringTextInputFormatter.digitsOnly,
            _PhoneNumberFormatter(),
            LengthLimitingTextInputFormatter(13), // 010-1234-5678
          ]);
        case AppInputFormat.card:
          formatters.addAll([
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
            LengthLimitingTextInputFormatter(19), // 1234 5678 9012 3456
          ]);
        case AppInputFormat.account:
          formatters.addAll([
            FilteringTextInputFormatter.digitsOnly,
            _AccountNumberFormatter(),
          ]);
        case AppInputFormat.currency:
          formatters.addAll([
            FilteringTextInputFormatter.digitsOnly,
            _CurrencyFormatter(),
          ]);
        case AppInputFormat.email:
          formatters.add(_EmailFormatter());
      }
    }

    return formatters;
  }

  // ============================================
  // UI 빌드
  // ============================================

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null || _validationError != null;
    final errorMessage = widget.errorText ?? _validationError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.paragraph_14.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
        ],

        // 입력 필드
        AnimatedContainer(
          duration: TossDesignTokens.animationFast,
          curve: TossDesignTokens.smoothCurve,
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.spaceSurface : AppColors.spaceBackground,
            borderRadius: AppRadius.large,
            border: Border.all(
              color: _getBorderColor(hasError),
              width: _isFocused ? 2.0 : 1.0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType ?? _getKeyboardType(),
            textInputAction: widget.textInputAction,
            textAlign: widget.textAlign,
            inputFormatters: _buildFormatters(),
            onChanged: _handleChanged,
            onSubmitted: widget.onSubmitted,
            style: AppTextStyles.paragraph_14.copyWith(
              color: widget.enabled ? Colors.white : AppColors.textDisabled,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textTertiary,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: InputBorder.none,
              counterText: '', // 글자 수 카운터 숨김
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20.w,
                      color: _isFocused ? AppColors.primary : AppColors.textTertiary,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
            ),
          ),
        ),

        // 에러/도움 메시지
        if (errorMessage != null || widget.helperText != null) ...[
          SizedBox(height: 8.h),
          Text(
            errorMessage ?? widget.helperText!,
            style: AppTextStyles.tag_12.copyWith(
              color: hasError ? AppColors.error : AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor(bool hasError) {
    if (!widget.enabled) return Colors.transparent;
    if (hasError) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.spaceDivider;
  }

  TextInputType? _getKeyboardType() {
    if (widget.autoFormat == null) return null;
    switch (widget.autoFormat!) {
      case AppInputFormat.phone:
      case AppInputFormat.card:
      case AppInputFormat.account:
      case AppInputFormat.currency:
        return TextInputType.number;
      case AppInputFormat.email:
        return TextInputType.emailAddress;
    }
  }

  Widget? _buildSuffixIcon() {
    // 비밀번호 토글 버튼
    if (widget.obscureText) {
      return GestureDetector(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20.w,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return widget.suffixIcon;
  }
}

// ============================================
// 입력 포맷터 구현
// ============================================

/// 전화번호 포맷터 (010-1234-5678)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// 카드번호 포맷터 (1234 5678 9012 3456)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// 계좌번호 포맷터 (123-4567-890123)
class _AccountNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// 금액 포맷터 (1,000,000)
class _CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.tryParse(digits) ?? 0;
    final formatted = _formatNumber(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
      count++;
    }

    return buffer.toString().split('').reversed.join();
  }
}

/// 이메일 포맷터 (소문자 자동 변환)
class _EmailFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
