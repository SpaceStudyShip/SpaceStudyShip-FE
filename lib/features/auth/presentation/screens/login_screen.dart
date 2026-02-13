import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/animations/entrance_animations.dart';
import '../../../../core/widgets/atoms/gradient_circle_icon.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/buttons/social_login_button.dart';
import '../../../../core/widgets/backgrounds/space_background.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/auth_provider.dart';

/// 로그인 스크린
///
/// Google / Apple 소셜 로그인을 제공합니다.
/// Apple 로그인은 iOS에서만 표시됩니다.
/// 로그인 성공 시 GoRouter redirect가 자동으로 홈 화면으로 이동합니다.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    } catch (_) {
      if (!mounted) return;
      _showLoginError();
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();
    } catch (_) {
      if (!mounted) return;
      _showLoginError();
    }
  }

  Future<void> _handleGuestSignIn() async {
    AppSnackBar.warning(context, '게스트 모드에서는 정보가 저장되지 않습니다');
    await ref.read(authNotifierProvider.notifier).signInAsGuest();
    // GoRouter redirect가 /login → /onboarding으로 자동 이동
  }

  void _showLoginError() {
    final authState = ref.read(authNotifierProvider);
    final error = authState.error;
    final message = (error is AuthException)
        ? error.message
        : '로그인에 실패했어요. 다시 시도해 주세요.';
    AppSnackBar.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final activeLogin = ref.watch(activeLoginNotifierProvider);
    final isLoading = authState.isLoading;
    final isGoogleLoading =
        isLoading && activeLogin == SocialLoginProvider.google;
    final isAppleLoading =
        isLoading && activeLogin == SocialLoginProvider.apple;

    return Scaffold(
      backgroundColor: AppColors.spaceBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          SafeArea(
            child: Padding(
              padding: AppPadding.all20,
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 로고 — Hero로 스플래시에서 자연스럽게 이어짐
                  Hero(
                    tag: 'rocket-icon',
                    flightShuttleBuilder:
                        (
                          flightContext,
                          animation,
                          direction,
                          fromContext,
                          toContext,
                        ) {
                          return Material(
                            color: Colors.transparent,
                            child: toContext.widget,
                          );
                        },
                    child: GradientCircleIcon(
                      icon: Icons.rocket_launch_rounded,
                      color: AppColors.primary,
                      size: 80,
                      iconSize: 36,
                      gradientColors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.s16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      '우주공부선에 오신 것을\n환영합니다!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading_24.copyWith(
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      '함께 우주를 탐험하며 공부해요',
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Google 로그인 버튼
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: GoogleLoginButton(
                      isLoading: isGoogleLoading,
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                    ),
                  ),

                  // Apple 로그인 버튼 (iOS만)
                  if (Platform.isIOS) ...[
                    SizedBox(height: AppSpacing.s12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 400),
                      child: AppleLoginButton(
                        isLoading: isAppleLoading,
                        onPressed: isLoading ? null : _handleAppleSignIn,
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.s16),

                  // 게스트로 시작하기
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 500),
                    child: TextButton(
                      onPressed: isLoading ? null : _handleGuestSignIn,
                      child: Text(
                        '게스트로 시작하기',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.s8),

                  // 약관 안내
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      '로그인 시 서비스 이용약관 및 개인정보 처리방침에\n동의하는 것으로 간주됩니다.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.s32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
