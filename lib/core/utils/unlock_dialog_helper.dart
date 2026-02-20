import 'package:flutter/material.dart';

import '../../features/fuel/domain/exceptions/fuel_exceptions.dart';
import '../widgets/dialogs/app_dialog.dart';
import '../widgets/feedback/app_snackbar.dart';

/// 해금 다이얼로그 공통 유틸리티
///
/// 행성/지역 해금 시 동일한 확인 다이얼로그 + 에러 핸들링 패턴을 제공합니다.
void showUnlockDialog({
  required BuildContext context,
  required String nodeName,
  required int requiredFuel,
  required Future<void> Function() onUnlock,
}) {
  AppDialog.show(
    context: context,
    title: '$nodeName 해금',
    message: '연료 $requiredFuel통을 소비하여\n$nodeName을(를) 해금하시겠습니까?',
    emotion: AppDialogEmotion.info,
    confirmText: '해금하기',
    cancelText: '취소',
    onConfirm: () async {
      try {
        await onUnlock();
        if (context.mounted) {
          AppSnackBar.success(context, '$nodeName이(가) 해금되었습니다!');
        }
      } on InsufficientFuelException catch (e) {
        if (context.mounted) {
          AppSnackBar.error(context, e.toString());
        }
      } catch (_) {
        if (context.mounted) {
          AppSnackBar.error(context, '해금에 실패했습니다.');
        }
      }
    },
  );
}
