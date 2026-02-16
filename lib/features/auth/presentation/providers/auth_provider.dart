import 'package:dio/dio.dart';
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
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/utils/firebase_auth_error_handler.dart';
import '../../../todo/presentation/providers/todo_provider.dart';

part 'auth_provider.g.dart';

// ============================================================================
// SharedPreferences Keys
// ============================================================================

/// 게스트 모드 여부 키
const kIsGuestKey = 'is_guest';

// ============================================================================
// Core Infrastructure Providers
// ============================================================================

/// SecureTokenStorage Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
@Riverpod(keepAlive: true)
SecureTokenStorage secureTokenStorage(Ref ref) {
  return SecureTokenStorage();
}

/// FirebaseAuthDataSource Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
@Riverpod(keepAlive: true)
FirebaseAuthDataSource firebaseAuthDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

/// Dio Provider (AuthInterceptor 포함)
///
/// 앱 생애주기 동안 유지 (keepAlive) — HTTP 클라이언트는 dispose되면 안 됨
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);

  return DioClient.create(
    tokenStorage: tokenStorage,
    onForceLogout: () async {
      // 강제 로그아웃: Firebase 로그아웃 + 토큰 삭제 + 상태 초기화
      final firebaseDataSource = ref.read(firebaseAuthDataSourceProvider);
      await firebaseDataSource.signOut();
      await tokenStorage.clearTokens();

      // AuthNotifier 상태를 null로 초기화하여 GoRouter 리다이렉트 트리거
      ref.read(authNotifierProvider.notifier).forceLogout();

      debugPrint('🚨 강제 로그아웃 완료 (토큰 만료/재발급 실패)');
    },
  );
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
///
/// Google/Apple 로그인 시작 시 해당 프로바이더로 설정,
/// 로그인 완료/실패 시 null로 초기화.
/// LoginScreen에서 버튼별 로딩/비활성화 상태를 결정하는 데 사용.
@riverpod
class ActiveLoginNotifier extends _$ActiveLoginNotifier {
  @override
  SocialLoginProvider? build() => null;

  void set(SocialLoginProvider provider) => state = provider;
  void clear() => state = null;
}

/// Firebase Auth State를 실시간으로 제공하는 StreamProvider
///
/// GoRouter의 refreshListenable로 사용되어
/// 인증 상태 변경 시 자동으로 라우팅을 재평가합니다.
@riverpod
Stream<User?> authState(Ref ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return dataSource.authStateChanges();
}

/// 인증 상태를 관리하는 Notifier
///
/// UseCase를 통해 로그인/로그아웃을 수행하며
/// 로딩/에러 상태를 관리합니다.
///
/// **State**: `AsyncValue<AuthResultEntity?>` - 로그인 결과 (null = 미로그인)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthResultEntity?> build() async {
    // ── Firebase-only 모드 ──
    // 백엔드 API 연동 전까지 Firebase Auth 상태만으로 인증 판단
    final dataSource = ref.watch(firebaseAuthDataSourceProvider);
    final currentUser = dataSource.currentUser;

    if (currentUser != null) {
      return AuthResultEntity(
        userId: 0, // 백엔드 연동 전 임시값
        nickname: currentUser.displayName ?? '',
        isNewUser: false,
      );
    }

    // Firebase 유저 없을 때 → 게스트 모드 확인
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(kIsGuestKey) == true) {
      return const AuthResultEntity(
        userId: -1,
        nickname: '게스트',
        isNewUser: false,
        isGuest: true,
      );
    }

    return null;

    // TODO: 백엔드 API 연동 시 위 블록 삭제 후 아래 주석 해제
    // ──────────────────────────────────────────────
    // final tokenStorage = ref.watch(secureTokenStorageProvider);
    //
    // if (currentUser != null) {
    //   final hasTokens = await tokenStorage.hasTokens();
    //   if (!hasTokens) return null;
    //
    //   return AuthResultEntity(
    //     userId: await tokenStorage.getUserId() ?? 0,
    //     nickname: currentUser.displayName ?? '',
    //     isNewUser: false,
    //   );
    // }
    //
    // return null;
    // ──────────────────────────────────────────────
  }

  /// Google 로그인 수행
  ///
  /// UseCase를 통해 Firebase 로그인 → 백엔드 로그인 → 토큰 저장을 수행합니다.
  /// 성공 시 [AuthResultEntity]를 state에 설정합니다.
  Future<void> signInWithGoogle() async {
    ref
        .read(activeLoginNotifierProvider.notifier)
        .set(SocialLoginProvider.google);
    state = const AsyncValue.loading();

    try {
      final useCase = ref.read(signInWithGoogleUseCaseProvider);
      final result = await useCase.execute();
      state = AsyncValue.data(result);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Google'),
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

  /// Apple 로그인 수행
  ///
  /// UseCase를 통해 Firebase 로그인 → 백엔드 로그인 → 토큰 저장을 수행합니다.
  /// 성공 시 [AuthResultEntity]를 state에 설정합니다.
  Future<void> signInWithApple() async {
    ref
        .read(activeLoginNotifierProvider.notifier)
        .set(SocialLoginProvider.apple);
    state = const AsyncValue.loading();

    try {
      final useCase = ref.read(signInWithAppleUseCaseProvider);
      final result = await useCase.execute();
      state = AsyncValue.data(result);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Apple'),
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

  /// 게스트로 로그인
  ///
  /// SharedPreferences에 게스트 상태를 저장하고
  /// 게스트 AuthResultEntity를 state에 설정합니다.
  Future<void> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIsGuestKey, true);
    state = const AsyncValue.data(
      AuthResultEntity(
        userId: -1,
        nickname: '게스트',
        isNewUser: false,
        isGuest: true,
      ),
    );
  }

  /// 로그아웃
  ///
  /// 백엔드 + Firebase + 토큰 삭제를 모두 수행합니다.
  /// 게스트 모드인 경우 SharedPreferences만 정리합니다.
  Future<void> signOut() async {
    // 게스트 모드 → SharedPreferences 정리만
    final currentUser = state.valueOrNull;
    if (currentUser?.isGuest == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kIsGuestKey);

      // 게스트 할일 데이터 삭제
      final todoRepo = ref.read(todoRepositoryProvider);
      await todoRepo.clearAll();
      debugPrint('🧹 게스트 캐시 삭제 완료 ($kIsGuestKey, todos, categories)');
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final useCase = ref.read(signOutUseCaseProvider);
      await useCase.execute();
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Logout'),
        StackTrace.current,
      );
    } catch (e, stack) {
      if (e is AppException) {
        state = AsyncValue.error(e, stack);
      } else {
        state = AsyncValue.error(
          AuthException(message: '로그아웃에 실패했습니다.', originalException: e),
          stack,
        );
      }
    }
  }

  /// 닉네임 설정 완료 후 상태 갱신
  ///
  /// isNewUser를 false로 변경하여 GoRouter가 다시
  /// /nickname-setup으로 리다이렉트하지 않도록 합니다.
  void updateNicknameCompleted(String nickname) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(nickname: nickname, isNewUser: false),
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
