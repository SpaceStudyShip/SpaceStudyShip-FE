import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/domain/entities/auth_result_entity.dart';
import 'package:space_study_ship/routes/app_router.dart';
import 'package:space_study_ship/routes/route_paths.dart';

void main() {
  group('resolveAuthRedirect', () {
    test('인증 로딩 중 → null (현재 위치 유지)', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.loading(),
          location: RoutePaths.home,
          splashDone: true,
        ),
        isNull,
      );
    });

    test('스플래시 + splash 최소시간 미완료 → null', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(null),
          location: RoutePaths.splash,
          splashDone: false,
        ),
        isNull,
      );
    });

    test('미로그인 → /login', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(null),
          location: RoutePaths.home,
          splashDone: true,
        ),
        RoutePaths.login,
      );
    });

    test('미로그인 + 이미 /login → null', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(null),
          location: RoutePaths.login,
          splashDone: true,
        ),
        isNull,
      );
    });

    test('신규 회원(비게스트) → /nickname-setup', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(
            AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: true),
          ),
          location: RoutePaths.home,
          splashDone: true,
        ),
        RoutePaths.nicknameSetup,
      );
    });

    test('신규 회원 + 이미 /nickname-setup → null', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(
            AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: true),
          ),
          location: RoutePaths.nicknameSetup,
          splashDone: true,
        ),
        isNull,
      );
    });

    test('기존 회원이 /login 에 있으면 → /home', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(
            AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: false),
          ),
          location: RoutePaths.login,
          splashDone: true,
        ),
        RoutePaths.home,
      );
    });

    test('기존 회원이 일반 화면에 있으면 → null', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(
            AuthResultEntity(memberId: 1, nickname: 'abc', isNewMember: false),
          ),
          location: RoutePaths.timer,
          splashDone: true,
        ),
        isNull,
      );
    });

    test('게스트 + isNewMember=true (이상 케이스) → /home (isNewMember 무시)', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(
            AuthResultEntity(
              memberId: -1,
              nickname: '게스트',
              isNewMember: true,
              isGuest: true,
            ),
          ),
          location: RoutePaths.login,
          splashDone: true,
        ),
        RoutePaths.home,
      );
    });

    test('닉네임 완료 후(isNewMember=false) /nickname-setup 에 있으면 → /home', () {
      expect(
        resolveAuthRedirect(
          authState: const AsyncValue.data(
            AuthResultEntity(memberId: 1, nickname: '우주', isNewMember: false),
          ),
          location: RoutePaths.nicknameSetup,
          splashDone: true,
        ),
        RoutePaths.home,
      );
    });
  });
}
