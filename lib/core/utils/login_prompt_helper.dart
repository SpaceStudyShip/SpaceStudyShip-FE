import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/dialogs/app_dialog.dart';
import '../widgets/feedback/app_snackbar.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// 게스트 로그인 유도 다이얼로그
///
/// 게스트 모드에서 로그인이 필요한 기능 접근 시 사용합니다.
/// 확인 시 로그아웃(→ 로그인 화면 이동), 취소 시 아무 동작 없음.
Future<void> showLoginPrompt({
  required BuildContext context,
  required WidgetRef ref,
  required String message,
}) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: '로그인이 필요해요',
    message: '$message\n게스트 모드의 데이터는 초기화돼요.',
    confirmText: '로그인',
    cancelText: '취소',
  );
  if (confirmed == true && context.mounted) {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, '로그인 화면 전환에 실패했습니다.');
      }
    }
  }
}
