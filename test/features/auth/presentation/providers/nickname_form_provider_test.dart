import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:space_study_ship/features/auth/presentation/providers/nickname_form_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/features/auth/presentation/providers/nickname_mode.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

class _MockTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  ProviderContainer makeContainer(String serverNickname) {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    // family provider warm-up
    c.read(nicknameFormNotifierProvider(serverNickname));
    return c;
  }

  group('build() 진입 직후', () {
    test('input=serverNickname, status=idle', () {
      final c = makeContainer('민첩한괴도5308');
      final s = c.read(nicknameFormNotifierProvider('민첩한괴도5308'));
      expect(s.input, '민첩한괴도5308');
      expect(s.serverNickname, '민첩한괴도5308');
      expect(s.status, NicknameValidationStatus.idle);
    });
  });

  group('onInputChanged 상태 전이', () {
    test('입력 변경 (다른 유효 값) → needsCheck', () {
      final c = makeContainer('abc12');
      c.read(nicknameFormNotifierProvider('abc12').notifier)
          .onInputChanged('우주탐험가');
      final s = c.read(nicknameFormNotifierProvider('abc12'));
      expect(s.status, NicknameValidationStatus.needsCheck);
      expect(s.errorMessage, isNotNull);
    });

    test('입력값을 서버 닉네임으로 되돌림 → idle', () {
      final c = makeContainer('abc12');
      final n = c.read(nicknameFormNotifierProvider('abc12').notifier);
      n.onInputChanged('우주탐험가');
      n.onInputChanged('abc12');
      expect(n.state.status, NicknameValidationStatus.idle);
    });

    test('1자 입력 → invalidFormat', () {
      final c = makeContainer('abc12');
      final n = c.read(nicknameFormNotifierProvider('abc12').notifier);
      n.onInputChanged('우');
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });

    test('11자 입력 → invalidFormat', () {
      final c = makeContainer('abc12');
      final n = c.read(nicknameFormNotifierProvider('abc12').notifier);
      n.onInputChanged('우주탐험가12345678');
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });

    test('특수문자 포함 → invalidFormat', () {
      final c = makeContainer('abc12');
      final n = c.read(nicknameFormNotifierProvider('abc12').notifier);
      n.onInputChanged('우주@');
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });

    test('이모지 포함 → invalidFormat', () {
      final c = makeContainer('abc12');
      final n = c.read(nicknameFormNotifierProvider('abc12').notifier);
      n.onInputChanged('우주\u{1F680}');   // 🚀
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
    });
  });

  group('checkDuplicate', () {
    late _MockAuthRepo repo;
    late ProviderContainer container;

    setUp(() {
      repo = _MockAuthRepo();
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
    });

    test('available=true → status=available', () async {
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.available);
      expect(n.state.isCheckingDuplicate, isFalse);
    });

    test('available=false → status=unavailable', () async {
      when(() => repo.checkNickname('taken')).thenAnswer((_) async => false);
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('taken');
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.unavailable);
    });

    test('InvalidInputValueException → status=invalidFormat', () async {
      when(() => repo.checkNickname(any())).thenThrow(
        const InvalidInputValueException(message: '금지어'),
      );
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('욕설');
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.invalidFormat);
      expect(n.state.errorMessage, '금지어');
    });

    test('isCheckingDuplicate 플래그 토글', () async {
      when(() => repo.checkNickname(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return true;
      });
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      final future = n.checkDuplicate();
      expect(n.state.isCheckingDuplicate, isTrue);
      await future;
      expect(n.state.isCheckingDuplicate, isFalse);
    });

    test('await 중 입력 변경 → 결과 폐기 (status 변화 없음)', () async {
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return true;
      });

      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      final future = n.checkDuplicate();
      // await 중 사용자가 입력을 다른 값으로 변경
      n.onInputChanged('xy');
      await future;

      // 결과가 폐기되어야 함 — status 는 'xy' 입력 시점의 needsCheck 유지
      expect(n.state.status, NicknameValidationStatus.needsCheck);
      expect(n.state.isCheckingDuplicate, isFalse);
    });
  });

  group('submit', () {
    late _MockAuthRepo repo;
    late _MockTokenStorage tokenStorage;
    late ProviderContainer container;

    setUp(() {
      repo = _MockAuthRepo();
      tokenStorage = _MockTokenStorage();
      when(() => tokenStorage.saveIsNewMember(any())).thenAnswer((_) async {});
      when(() => tokenStorage.saveNickname(any())).thenAnswer((_) async {});
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          secureTokenStorageProvider.overrideWithValue(tokenStorage),
        ],
      );
      addTearDown(() {
        runZonedGuarded(() => container.dispose(), (error, stack) {});
      });
    });

    test('status=idle, mode=initialSetup → markNicknameConfirmed 호출 + onCompleted', () async {
      final auth = container.read(authNotifierProvider.notifier);
      auth.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
      );
      var completed = false;

      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      await n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () => completed = true,
        onError: (_) {},
      );

      expect(completed, isTrue);
      expect(container.read(authNotifierProvider).value!.isNewMember, isFalse);
      verify(() => tokenStorage.saveIsNewMember(false)).called(1);
      verifyNever(() => repo.updateNickname(any()));
    });

    test('status=available → updateNickname 호출 + onCompleted', () async {
      when(() => repo.updateNickname('우주탐험가'))
          .thenAnswer((_) async => '우주탐험가');
      final auth = container.read(authNotifierProvider.notifier);
      auth.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc12', isNewMember: true),
      );

      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();
      expect(n.state.status, NicknameValidationStatus.available);

      var completed = false;
      await n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () => completed = true,
        onError: (_) {},
      );

      expect(completed, isTrue);
      verify(() => repo.updateNickname('우주탐험가')).called(1);
      verify(() => tokenStorage.saveIsNewMember(false)).called(1);
      expect(container.read(authNotifierProvider).value!.nickname, '우주탐험가');
    });

    test('submit 중 DuplicatedNicknameException → status=unavailable', () async {
      when(() => repo.updateNickname(any()))
          .thenThrow(const DuplicatedNicknameException());
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();

      await n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () {},
        onError: (_) {},
      );

      expect(n.state.status, NicknameValidationStatus.unavailable);
      expect(n.state.errorMessage, contains('다른 분이'));
    });

    test('submit 중 InvalidInputValueException → status=invalidFormat', () async {
      when(() => repo.updateNickname(any())).thenThrow(
        const InvalidInputValueException(message: '금지어'),
      );
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();

      await n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () {},
        onError: (_) {},
      );

      expect(n.state.status, NicknameValidationStatus.invalidFormat);
      expect(n.state.errorMessage, '금지어');
    });

    test('isSubmitting 토글', () async {
      when(() => repo.updateNickname(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 'x';
      });
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();

      final future = n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () {},
        onError: (_) {},
      );
      expect(n.state.isSubmitting, isTrue);
      await future;
      expect(n.state.isSubmitting, isFalse);
    });

    test('submit 중 NetworkException → onError 콜백 호출 + status available 유지', () async {
      when(() => repo.updateNickname(any()))
          .thenThrow(const NetworkException(message: 'no connection'));
      final n = container.read(
        nicknameFormNotifierProvider('abc12').notifier,
      );
      n.onInputChanged('우주탐험가');
      when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
      await n.checkDuplicate();

      String? errorMessage;
      await n.submit(
        mode: NicknameMode.initialSetup,
        onCompleted: () {},
        onError: (msg) => errorMessage = msg,
      );

      expect(errorMessage, '연결 상태를 확인해주세요');
      expect(n.state.status, NicknameValidationStatus.available);
      expect(n.state.isSubmitting, isFalse);
    });
  });
}
