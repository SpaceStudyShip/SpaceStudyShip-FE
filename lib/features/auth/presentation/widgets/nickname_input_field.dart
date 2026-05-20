import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../providers/nickname_form_provider.dart';

/// 닉네임 입력 + 우측 중복확인 버튼 + 우상단 카운터.
///
/// 상위 위젯은 [NicknameFormState] 를 구독하여 상태와 콜백을 주입한다.
class NicknameInputField extends StatefulWidget {
  const NicknameInputField({
    super.key,
    required this.initialValue,
    required this.currentLength,
    required this.status,
    required this.isCheckingDuplicate,
    required this.onChanged,
    required this.onCheckDuplicate,
  });

  /// 진입 시점 서버 닉네임 (TextField 초기값).
  final String initialValue;

  /// 현재 입력 글자 수 (카운터 표시용).
  final int currentLength;

  final NicknameValidationStatus status;
  final bool isCheckingDuplicate;
  final ValueChanged<String> onChanged;
  final VoidCallback onCheckDuplicate;

  @override
  State<NicknameInputField> createState() => _NicknameInputFieldState();
}

class _NicknameInputFieldState extends State<NicknameInputField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canCheckDuplicate =>
      widget.status == NicknameValidationStatus.needsCheck &&
      !widget.isCheckingDuplicate;

  String get _buttonLabel {
    if (widget.status == NicknameValidationStatus.available) return '사용가능';
    return '중복확인';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 카운터 (우상단)
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.s4),
          child: Text(
            '${widget.currentLength}/10',
            style: AppTextStyles.tag_12.copyWith(color: AppColors.textTertiary),
          ),
        ),
        // 입력 + 우측 버튼
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                hintText: '닉네임',
                maxLength: 10,
                onChanged: widget.onChanged,
              ),
            ),
            SizedBox(width: AppSpacing.s8),
            AppButton(
              key: const Key('nickname-check-button'),
              text: _buttonLabel,
              onPressed: _canCheckDuplicate ? widget.onCheckDuplicate : null,
              isLoading: widget.isCheckingDuplicate,
              width: 88.w,
              height: 56.h,
              borderRadius: AppRadius.large,
            ),
          ],
        ),
      ],
    );
  }
}
