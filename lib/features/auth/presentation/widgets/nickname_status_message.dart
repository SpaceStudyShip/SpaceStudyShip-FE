import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../providers/nickname_form_provider.dart';

/// 닉네임 폼 status 별 안내/에러 메시지를 표시한다.
/// errorMessage 가 비어 있고 status 가 idle 이면 빈 영역(공간 보존).
class NicknameStatusMessage extends StatelessWidget {
  const NicknameStatusMessage({
    super.key,
    required this.status,
    required this.errorMessage,
  });

  final NicknameValidationStatus status;
  final String? errorMessage;

  Color _color() {
    switch (status) {
      case NicknameValidationStatus.available:
        return AppColors.info;
      case NicknameValidationStatus.invalidFormat:
      case NicknameValidationStatus.unavailable:
        return AppColors.error;
      case NicknameValidationStatus.needsCheck:
        return AppColors.textSecondary;
      case NicknameValidationStatus.idle:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = errorMessage ?? '';
    return SizedBox(
      height: AppSpacing.s20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTextStyles.tag_12.copyWith(color: _color()),
        ),
      ),
    );
  }
}
