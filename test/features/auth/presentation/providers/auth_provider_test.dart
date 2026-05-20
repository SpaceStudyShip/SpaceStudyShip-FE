import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/features/auth/domain/usecases/update_nickname_usecase.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';

class _MockTokenStorage extends Mock implements SecureTokenStorage {}

class _MockUpdateNicknameUseCase extends Mock
    implements UpdateNicknameUseCase {}

void main() {
  late _MockTokenStorage tokenStorage;
  late ProviderContainer container;

  setUp(() {
    tokenStorage = _MockTokenStorage();
    when(() => tokenStorage.saveIsNewMember(any())).thenAnswer((_) async {});
    when(() => tokenStorage.saveNickname(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [secureTokenStorageProvider.overrideWithValue(tokenStorage)],
    );
  });

  tearDown(() {
    // AuthNotifier.build() 의 onDispose 콜백은 forceLogoutCallbackNotifierProvider
    // 를 read 하는데, ProviderContainer 전체 dispose 중에는 의존 provider 가 이미
    // 정리되어 "Bad state" 예외가 발생할 수 있다. Riverpod 의 runGuarded 가 이
    // 예외를 Zone 으로 전파하므로, runZonedGuarded 로 흡수한다 (본 단위 테스트의
    // 검증 대상이 아님).
    runZonedGuarded(() => container.dispose(), (_, _) {});
  });

  group('markNicknameConfirmed', () {
    test(
      'isNewMember=true 상태 → false 로 전환 + saveIsNewMember(false) 호출',
      () async {
        final notifier = container.read(authNotifierProvider.notifier);
        notifier.state = const AsyncValue.data(
          AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: true),
        );

        await notifier.markNicknameConfirmed();

        expect(
          container.read(authNotifierProvider).value!.isNewMember,
          isFalse,
        );
        expect(container.read(authNotifierProvider).value!.nickname, 'abc');
        verify(() => tokenStorage.saveIsNewMember(false)).called(1);
      },
    );

    test('isNewMember=false 상태 → no-op (storage 호출 없음)', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: false),
      );

      await notifier.markNicknameConfirmed();

      verifyNever(() => tokenStorage.saveIsNewMember(any()));
    });

    test('state.value=null 상태 → no-op', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(null);

      await notifier.markNicknameConfirmed();

      verifyNever(() => tokenStorage.saveIsNewMember(any()));
    });
  });

  group('updateNickname storage sync', () {
    test('성공 시 state 갱신 + saveIsNewMember(false) await 호출', () async {
      final useCase = _MockUpdateNicknameUseCase();
      when(() => useCase.execute('우주탐험가')).thenAnswer((_) async => '우주탐험가');

      final c = ProviderContainer(
        overrides: [
          secureTokenStorageProvider.overrideWithValue(tokenStorage),
          updateNicknameUseCaseProvider.overrideWithValue(useCase),
        ],
      );
      addTearDown(() {
        runZonedGuarded(() => c.dispose(), (_, _) {});
      });

      final notifier = c.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(
        AuthResultEntity(memberId: 1, nickname: 'old', isNewMember: true),
      );

      await notifier.updateNickname('우주탐험가');

      final result = c.read(authNotifierProvider).value!;
      expect(result.nickname, '우주탐험가');
      expect(result.isNewMember, isFalse);
      verify(() => useCase.execute('우주탐험가')).called(1);
      verify(() => tokenStorage.saveIsNewMember(false)).called(1);
      verify(() => tokenStorage.saveNickname('우주탐험가')).called(1);
    });

    test('state.value=null 상태 → storage 호출 없음 (no-op)', () async {
      final useCase = _MockUpdateNicknameUseCase();
      when(() => useCase.execute(any())).thenAnswer((_) async => 'x');

      final c = ProviderContainer(
        overrides: [
          secureTokenStorageProvider.overrideWithValue(tokenStorage),
          updateNicknameUseCaseProvider.overrideWithValue(useCase),
        ],
      );
      addTearDown(() {
        runZonedGuarded(() => c.dispose(), (_, _) {});
      });

      final notifier = c.read(authNotifierProvider.notifier);
      notifier.state = const AsyncValue.data(null);

      await notifier.updateNickname('우주탐험가');

      verify(() => useCase.execute('우주탐험가')).called(1);
      verifyNever(() => tokenStorage.saveIsNewMember(any()));
    });
  });
}
