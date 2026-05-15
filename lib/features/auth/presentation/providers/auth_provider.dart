import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/utils/firebase_auth_error_handler.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
import '../../../exploration/presentation/providers/exploration_provider.dart';
import '../../../fuel/presentation/providers/fuel_provider.dart';
import '../../../timer/presentation/providers/timer_provider.dart';
import '../../../timer/presentation/providers/timer_session_provider.dart';
import '../../../todo/presentation/providers/todo_provider.dart';

part 'auth_provider.g.dart';

// ============================================================================
// SharedPreferences Keys
// ============================================================================

/// 게스트 모드 여부 키
const kIsGuestKey = 'is_guest';

/// 게스트 모드 식별 sentinel memberId
const int kGuestMemberId = -1;

// ============================================================================
// Core Infrastructure Providers
// ============================================================================
//
// secureTokenStorageProvider 는 lib/core/storage/secure_token_storage.dart 에서 정의.
// dioProvider / forceLogoutCallbackNotifierProvider 는 lib/core/network/dio_client.dart 에서 정의.

/// FirebaseAuthDataSource Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
@Riverpod(keepAlive: true)
FirebaseAuthDataSource firebaseAuthDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

// ============================================================================
// Data Layer Providers
// ============================================================================

/// AuthRemoteDataSource Provider (Retrofit)
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSource(dio);
}

/// AuthRepository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    firebaseAuthDataSource: ref.watch(firebaseAuthDataSourceProvider),
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
}

// ============================================================================
// Domain Layer Providers (UseCases)
// ============================================================================

/// Google 로그인 UseCase Provider
@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return SignInWithGoogleUseCase(repository: ref.watch(authRepositoryProvider));
}

/// Apple 로그인 UseCase Provider
@riverpod
SignInWithAppleUseCase signInWithAppleUseCase(Ref ref) {
  return SignInWithAppleUseCase(repository: ref.watch(authRepositoryProvider));
}

/// 로그아웃 UseCase Provider
@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(repository: ref.watch(authRepositoryProvider));
}

// ============================================================================
// Presentation Layer Providers
// ============================================================================

/// 현재 로그인 진행 중인 소셜 프로바이더
enum SocialLoginProvider { google, apple }

/// 현재 진행 중인 소셜 로그인 프로바이더를 추적하는 Notifier
@riverpod
class ActiveLoginNotifier extends _$ActiveLoginNotifier {
  @override
  SocialLoginProvider? build() => null;

  void set(SocialLoginProvider provider) => state = provider;
  void clear() => state = null;
}

/// Firebase Auth State를 실시간으로 제공하는 StreamProvider
///
/// GoRouter refreshListenable 또는 외부 로그아웃(토큰 만료, 계정 삭제 등) 감지에 사용.
@riverpod
Stream<User?> authState(Ref ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return dataSource.authStateChanges();
}

/// 인증 상태를 관리하는 Notifier
///
/// **State**: `AsyncValue<AuthResultEntity?>` - 로그인 결과 (null = 미로그인)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthResultEntity?> build() async {
    // ============================================
    // 강제 로그아웃 콜백 등록 (core → auth 역전 패턴)
    // ============================================
    // Future.microtask로 지연: build() 중 다른 provider 수정 금지 (Riverpod 제약)
    Future.microtask(() {
      ref.read(forceLogoutCallbackNotifierProvider.notifier).register(({
        String? message,
      }) async {
        await ref.read(firebaseAuthDataSourceProvider).signOut();
        await ref.read(secureTokenStorageProvider).clearTokens();
        if (message != null) {
          ref.read(forceLogoutMessageProvider.notifier).state = message;
        }
        forceLogout();
        debugPrint(
          '🚨 강제 로그아웃 완료 (토큰 만료/재발급 실패)'
          '${message != null ? ' 사유: $message' : ''}',
        );
      });
    });

    // auto-dispose 시 콜백 해제 — 죽은 ref 접근 방지
    ref.onDispose(() {
      ref.read(forceLogoutCallbackNotifierProvider.notifier).unregister();
    });

    // ============================================
    // Cold-start 복원: Firebase + JWT 모두 있어야 인증
    // ============================================
    final dataSource = ref.watch(firebaseAuthDataSourceProvider);
    final tokenStorage = ref.watch(secureTokenStorageProvider);
    final currentUser = dataSource.currentUser;

    if (currentUser != null) {
      final hasTokens = await tokenStorage.hasTokens();
      if (!hasTokens) {
        debugPrint('[AuthNotifier] JWT 없음 → Firebase 세션 초기화');
        try {
          await dataSource.signOut();
        } catch (_) {}
        await tokenStorage.clearTokens();
        return null;
      }

      final memberId = await tokenStorage.getMemberId();
      if (memberId == null) {
        debugPrint('[AuthNotifier] memberId 없음 → 세션 초기화');
        try {
          await dataSource.signOut();
        } catch (_) {}
        await tokenStorage.clearTokens();
        return null;
      }

      final isNewMember = await tokenStorage.getIsNewMember();

      return AuthResultEntity(
        memberId: memberId,
        nickname: currentUser.displayName ?? '',
        isNewMember: isNewMember,
      );
    }

    // Firebase 유저 없을 때 → 게스트 모드 확인
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(kIsGuestKey) == true) {
      return const AuthResultEntity(
        memberId: kGuestMemberId,
        nickname: '게스트',
        isNewMember: false,
        isGuest: true,
      );
    }

    return null;
  }

  /// 소셜 로그인 공통 처리
  Future<void> _signInWithSocial({
    required SocialLoginProvider provider,
    required Future<AuthResultEntity> Function() execute,
    required String providerName,
  }) async {
    ref.read(activeLoginNotifierProvider.notifier).set(provider);
    state = const AsyncValue.loading();

    try {
      final result = await execute();
      state = AsyncValue.data(result);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: providerName),
        StackTrace.current,
      );
      rethrow;
    } catch (e, stack) {
      if (e is AppException) {
        state = AsyncValue.error(e, stack);
      } else {
        state = AsyncValue.error(
          AuthException(message: '알 수 없는 오류가 발생했습니다.', originalException: e),
          stack,
        );
      }
      rethrow;
    } finally {
      ref.read(activeLoginNotifierProvider.notifier).clear();
    }
  }

  /// Google 로그인 수행
  Future<void> signInWithGoogle() async {
    await _signInWithSocial(
      provider: SocialLoginProvider.google,
      execute: () => ref.read(signInWithGoogleUseCaseProvider).execute(),
      providerName: 'Google',
    );
  }

  /// Apple 로그인 수행
  Future<void> signInWithApple() async {
    await _signInWithSocial(
      provider: SocialLoginProvider.apple,
      execute: () => ref.read(signInWithAppleUseCaseProvider).execute(),
      providerName: 'Apple',
    );
  }

  /// 게스트로 로그인
  Future<void> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIsGuestKey, true);

    // 이전 게스트 세션 잔여 데이터 방어적 정리 (앱 강종 대비)
    await _clearGuestData();

    state = const AsyncValue.data(
      AuthResultEntity(
        memberId: kGuestMemberId,
        nickname: '게스트',
        isNewMember: false,
        isGuest: true,
      ),
    );
  }

  /// 로그아웃
  ///
  /// 백엔드 + Firebase + 토큰 삭제를 모두 수행합니다.
  /// 게스트 모드인 경우 SharedPreferences만 정리합니다.
  Future<void> signOut() async {
    // 타이머 강제 리셋 (세션 저장 없이)
    ref.read(timerNotifierProvider.notifier).forceReset();

    // 게스트 모드 → SharedPreferences 정리만
    final currentUser = state.valueOrNull;
    if (currentUser?.isGuest == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kIsGuestKey);
      await _clearGuestData();
      debugPrint(
        '🧹 게스트 캐시 삭제 완료 ($kIsGuestKey, todos, categories, timer sessions, fuel, exploration)',
      );
      state = const AsyncValue.data(null);
      return;
    }

    final previous = state;
    state = const AsyncValue.loading();

    try {
      final useCase = ref.read(signOutUseCaseProvider);
      await useCase.execute();
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = previous;
      debugPrint('❌ 로그아웃 실패 (Firebase): $e');
    } catch (e, stack) {
      state = previous;
      debugPrint('❌ 로그아웃 실패: $e\n$stack');
    }
  }

  /// 게스트 데이터 일괄 삭제 (디스크 + 메모리 캐시)
  Future<void> _clearGuestData() async {
    // 각 저장소 독립 삭제 — 하나 실패해도 나머지 계속 진행
    final clearTasks = <Future<void> Function()>[
      () => ref.read(todoRepositoryProvider).clearAll(),
      () => ref.read(timerSessionRepositoryProvider).clearAll(),
      () => ref.read(fuelRepositoryProvider).clearAll(),
      () => ref.read(explorationRepositoryProvider).clearAll(),
      () => ref.read(badgeRepositoryProvider).clearAll(),
    ];

    for (final task in clearTasks) {
      try {
        await task();
      } catch (e) {
        debugPrint('게스트 데이터 삭제 실패: $e');
      }
    }

    // 메모리 캐시 무효화 (예외 발생 불가)
    ref.invalidate(timerSessionListNotifierProvider);
    ref.invalidate(todoListNotifierProvider);
    ref.invalidate(categoryListNotifierProvider);
    ref.invalidate(fuelNotifierProvider);
    ref.invalidate(explorationNotifierProvider);
    ref.invalidate(badgeNotifierProvider);
  }

  /// 닉네임 설정 완료 후 상태 갱신
  ///
  /// isNewMember를 false로 변경하여 GoRouter가 다시
  /// 닉네임 설정 화면으로 리다이렉트하지 않도록 합니다.
  void updateNicknameCompleted(String nickname) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(nickname: nickname, isNewMember: false),
      );
    }
  }

  /// 강제 로그아웃 (AuthInterceptor에서 호출)
  ///
  /// 토큰 재발급 실패 시 state를 null로 초기화하여
  /// GoRouter가 로그인 화면으로 리다이렉트하도록 합니다.
  void forceLogout() {
    state = const AsyncValue.data(null);
  }
}

/// 현재 사용자가 게스트인지 여부
@riverpod
bool isGuest(Ref ref) {
  return ref.watch(authNotifierProvider).valueOrNull?.isGuest ?? false;
}
