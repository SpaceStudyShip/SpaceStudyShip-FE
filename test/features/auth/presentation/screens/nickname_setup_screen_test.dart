import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/core/widgets/buttons/app_button.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/presentation/providers/auth_provider.dart';
import 'package:space_study_ship/features/auth/presentation/providers/nickname_mode.dart';
import 'package:space_study_ship/features/auth/presentation/screens/nickname_setup_screen.dart';
import 'package:space_study_ship/features/settings/presentation/providers/settings_provider.dart';

class _MockRepo extends Mock implements AuthRepository {}

class _MockTokenStorage extends Mock implements SecureTokenStorage {}

/// build() 를 동기적으로 고정값 반환하도록 오버라이드한 가짜 AuthNotifier.
/// 실제 AuthNotifier.build() 는 Firebase/Storage 비동기 I/O 를 수행하므로
/// 위젯 테스트에서는 이 fake 로 대체한다.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AuthResultEntity? _user;
  @override
  FutureOr<AuthResultEntity?> build() => _user;
}

void main() {
  late _MockRepo repo;
  late _MockTokenStorage tokenStorage;

  setUp(() {
    repo = _MockRepo();
    tokenStorage = _MockTokenStorage();
    when(() => tokenStorage.saveIsNewMember(any())).thenAnswer((_) async {});
  });

  Widget makeApp(NicknameMode mode, AuthResultEntity user) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        secureTokenStorageProvider.overrideWithValue(tokenStorage),
        authNotifierProvider.overrideWith(() => _FakeAuthNotifier(user)),
        // SpaceBackground 가 watch 하는 설정 provider 는 SharedPreferences
        // 초기화가 필요하므로 위젯 테스트에서는 고정값으로 오버라이드한다.
        starTwinkleEnabledProvider.overrideWithValue(false),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) =>
            MaterialApp(home: NicknameSetupScreen(mode: mode)),
      ),
    );
  }

  testWidgets('mode=initialSetup → AppBar 없음 + 시스템 백 차단', (tester) async {
    await tester.pumpWidget(
      makeApp(
        NicknameMode.initialSetup,
        const AuthResultEntity(
          memberId: 1,
          nickname: 'abc12',
          isNewMember: true,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(AppBar), findsNothing);
    final popScope = tester.widget<PopScope>(
      find.byKey(const Key('nickname-setup-popscope')),
    );
    expect(popScope.canPop, isFalse);
  });

  testWidgets('mode=edit → AppBar 없음 (UI 동일) + 시스템 백 허용', (tester) async {
    await tester.pumpWidget(
      makeApp(
        NicknameMode.edit,
        const AuthResultEntity(
          memberId: 1,
          nickname: 'abc12',
          isNewMember: false,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(AppBar), findsNothing);
    // 두 모드 모두 동일한 헤딩을 노출한다.
    expect(find.text('닉네임을 정해주세요'), findsOneWidget);
    final popScope = tester.widget<PopScope>(
      find.byKey(const Key('nickname-setup-popscope')),
    );
    expect(popScope.canPop, isTrue);
  });

  testWidgets('진입 직후 확인 버튼 활성 (idle)', (tester) async {
    await tester.pumpWidget(
      makeApp(
        NicknameMode.initialSetup,
        const AuthResultEntity(
          memberId: 1,
          nickname: 'abc12',
          isNewMember: true,
        ),
      ),
    );
    await tester.pump();
    final btn = tester.widget<AppButton>(
      find.byKey(const Key('nickname-confirm-button')),
    );
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('입력 변경 → 확인 비활성, 중복확인 활성', (tester) async {
    await tester.pumpWidget(
      makeApp(
        NicknameMode.initialSetup,
        const AuthResultEntity(
          memberId: 1,
          nickname: 'abc12',
          isNewMember: true,
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), '우주탐험가');
    await tester.pump();

    final confirm = tester.widget<AppButton>(
      find.byKey(const Key('nickname-confirm-button')),
    );
    expect(confirm.onPressed, isNull);

    final check = tester.widget<AppButton>(
      find.byKey(const Key('nickname-check-button')),
    );
    expect(check.onPressed, isNotNull);
  });
}
