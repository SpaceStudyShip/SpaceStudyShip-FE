import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/nickname_form_provider.dart';
import '../providers/nickname_mode.dart';
import '../widgets/nickname_input_field.dart';
import '../widgets/nickname_status_message.dart';

/// 닉네임 설정/변경 공용 화면.
///
/// 두 모드의 UI 는 완전히 동일하며(AppBar 없는 전체화면), 차이는 동작뿐이다.
/// - [NicknameMode.initialSetup]: 신규 회원 첫 로그인. 시스템 백 차단,
///   완료 시 GoRouter redirect 가 자동으로 /home 으로 이동.
/// - [NicknameMode.edit]: 설정 메뉴 자발적 변경. 시스템 백 허용,
///   완료 시 context.pop() 으로 종료.
class NicknameSetupScreen extends ConsumerWidget {
  const NicknameSetupScreen({super.key, required this.mode});

  final NicknameMode mode;

  bool _canSubmit(NicknameValidationStatus s) =>
      s == NicknameValidationStatus.idle ||
      s == NicknameValidationStatus.available;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial =
        ref.watch(authNotifierProvider).valueOrNull?.nickname ?? '';
    final form = ref.watch(nicknameFormNotifierProvider(initial));
    final notifier =
        ref.read(nicknameFormNotifierProvider(initial).notifier);

    return PopScope(
      key: const Key('nickname-setup-popscope'),
      canPop: mode == NicknameMode.edit,
      child: Scaffold(
        backgroundColor: AppColors.spaceBackground,
        body: Stack(
          children: [
            const Positioned.fill(child: SpaceBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: AppPadding.all20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: AppSpacing.s48),
                              Text(
                                '닉네임을 정해주세요',
                                style: AppTextStyles.heading_24
                                    .copyWith(color: Colors.white),
                              ),
                              SizedBox(height: AppSpacing.s8),
                              Text(
                                '함께 우주를 탐험할 이름이에요',
                                style: AppTextStyles.paragraph_14.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.s32),
                              NicknameInputField(
                                initialValue: initial,
                                currentLength: form.input.length,
                                status: form.status,
                                isCheckingDuplicate: form.isCheckingDuplicate,
                                onChanged: notifier.onInputChanged,
                                onCheckDuplicate: notifier.checkDuplicate,
                              ),
                              SizedBox(height: AppSpacing.s12),
                              NicknameStatusMessage(
                                status: form.status,
                                errorMessage: form.errorMessage,
                              ),
                              const Spacer(),
                              AppButton(
                                key: const Key('nickname-confirm-button'),
                                text: '확인',
                                isLoading: form.isSubmitting,
                                onPressed: _canSubmit(form.status) &&
                                        !form.isSubmitting
                                    ? () => notifier.submit(
                                          mode: mode,
                                          onCompleted: () {
                                            if (mode == NicknameMode.edit &&
                                                context.mounted) {
                                              context.pop();
                                            }
                                            // initialSetup: GoRouter redirect
                                            // 가 자동으로 /home 으로 이동
                                          },
                                          onError: (message) {
                                            if (context.mounted) {
                                              AppSnackBar.error(
                                                context,
                                                message,
                                              );
                                            }
                                          },
                                        )
                                    : null,
                                width: double.infinity,
                                height: 56.h,
                              ),
                              SizedBox(height: AppSpacing.s24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
