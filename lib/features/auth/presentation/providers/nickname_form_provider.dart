import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import 'nickname_mode.dart';
import 'auth_provider.dart';

part 'nickname_form_provider.freezed.dart';
part 'nickname_form_provider.g.dart';

/// 닉네임 입력 폼의 검증 상태.
enum NicknameValidationStatus {
  /// 입력값 == 진입 시점 서버 닉네임 (변경 없음).
  idle,

  /// 정규식 또는 길이 위반.
  invalidFormat,

  /// 형식 OK + 입력값 != 서버 닉네임 + 중복확인 미수행.
  needsCheck,

  /// 중복확인 통과.
  available,

  /// 중복확인 실패 또는 PATCH 시점 race.
  unavailable,
}

/// 닉네임 입력 폼 상태.
@freezed
class NicknameFormState with _$NicknameFormState {
  const factory NicknameFormState({
    required String input,
    required String serverNickname,
    @Default(NicknameValidationStatus.idle) NicknameValidationStatus status,
    String? errorMessage,
    @Default(false) bool isCheckingDuplicate,
    @Default(false) bool isSubmitting,
  }) = _NicknameFormState;
}

/// 닉네임 정규식 (UseCase 와 동일 규칙).
final RegExp _kNicknamePattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
const int _kNicknameMinLength = 2;
const int _kNicknameMaxLength = 10;

@riverpod
class NicknameFormNotifier extends _$NicknameFormNotifier {
  @override
  NicknameFormState build(String serverNickname) {
    return NicknameFormState(
      input: serverNickname,
      serverNickname: serverNickname,
      status: NicknameValidationStatus.idle,
    );
  }

  void onInputChanged(String value) {
    final trimmed = value;
    // 1) 진입 닉네임과 동일 → idle
    if (trimmed == state.serverNickname) {
      state = state.copyWith(
        input: trimmed,
        status: NicknameValidationStatus.idle,
        errorMessage: null,
      );
      return;
    }
    // 2) 형식 검증
    if (trimmed.length < _kNicknameMinLength ||
        trimmed.length > _kNicknameMaxLength ||
        !_kNicknamePattern.hasMatch(trimmed)) {
      state = state.copyWith(
        input: trimmed,
        status: NicknameValidationStatus.invalidFormat,
        errorMessage: '2~10자, 한글/영문/숫자만 사용할 수 있어요',
      );
      return;
    }
    // 3) 형식 OK → 중복확인 필요
    state = state.copyWith(
      input: trimmed,
      status: NicknameValidationStatus.needsCheck,
      errorMessage: '중복 확인을 해주세요',
    );
  }

  /// 명시적 버튼 클릭으로만 호출. status=needsCheck 가 아니면 no-op.
  Future<void> checkDuplicate() async {
    if (state.status != NicknameValidationStatus.needsCheck) return;
    state = state.copyWith(isCheckingDuplicate: true);
    final inputAtCall = state.input;
    try {
      final available = await ref
          .read(checkNicknameUseCaseProvider)
          .execute(inputAtCall);
      if (state.input != inputAtCall) {
        // 사용자가 도중에 입력을 변경 — 결과 폐기, isCheckingDuplicate 만 해제
        state = state.copyWith(isCheckingDuplicate: false);
        return;
      }
      state = state.copyWith(
        isCheckingDuplicate: false,
        status: available
            ? NicknameValidationStatus.available
            : NicknameValidationStatus.unavailable,
        errorMessage: available ? '사용 가능한 닉네임이에요' : '이미 사용 중인 닉네임이에요',
      );
    } on InvalidInputValueException catch (e) {
      state = state.copyWith(
        isCheckingDuplicate: false,
        status: NicknameValidationStatus.invalidFormat,
        errorMessage: e.message,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ NicknameFormNotifier.checkDuplicate failed: $e\n$stackTrace',
      );
      // 네트워크/기타 — 상태는 needsCheck 로 복원, 메시지만 갱신
      state = state.copyWith(
        isCheckingDuplicate: false,
        status: NicknameValidationStatus.needsCheck,
        errorMessage: '확인에 실패했어요. 잠시 후 다시 시도해주세요',
      );
    }
  }

  /// 확인 버튼 클릭. status 가 idle 또는 available 일 때만 의미 있음.
  /// onCompleted 는 mode 별 후처리(예: edit 모드 pop) 콜백.
  Future<void> submit({
    required NicknameMode mode,
    required void Function() onCompleted,
    required void Function(String message) onError,
  }) async {
    // 1) 입력값 == 서버 닉네임 — PATCH 스킵
    if (state.status == NicknameValidationStatus.idle) {
      if (mode == NicknameMode.initialSetup) {
        await ref.read(authNotifierProvider.notifier).markNicknameConfirmed();
      }
      onCompleted();
      return;
    }

    // 2) 중복확인 통과 — PATCH 호출
    if (state.status != NicknameValidationStatus.available) return;

    state = state.copyWith(isSubmitting: true);
    try {
      await ref.read(authNotifierProvider.notifier).updateNickname(state.input);
      state = state.copyWith(isSubmitting: false);
      onCompleted();
    } on DuplicatedNicknameException {
      state = state.copyWith(
        isSubmitting: false,
        status: NicknameValidationStatus.unavailable,
        errorMessage: '방금 다른 분이 사용하기 시작했어요. 다른 닉네임을 입력해주세요',
      );
    } on InvalidInputValueException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        status: NicknameValidationStatus.invalidFormat,
        errorMessage: e.message,
      );
    } on NetworkException {
      // 네트워크 오류 — status 는 available 유지(재시도 가능), SnackBar 로 안내
      state = state.copyWith(isSubmitting: false);
      onError('연결 상태를 확인해주세요');
    } catch (e, stackTrace) {
      debugPrint('❌ NicknameFormNotifier.submit failed: $e\n$stackTrace');
      // 알 수 없는 오류 — status 는 available 유지, SnackBar 로 안내
      state = state.copyWith(isSubmitting: false);
      onError('잠시 후 다시 시도해주세요');
    }
  }
}
