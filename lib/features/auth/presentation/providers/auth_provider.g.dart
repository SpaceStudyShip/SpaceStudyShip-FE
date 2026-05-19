// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthDataSourceHash() =>
    r'95a0b0edd77b64b9889b799f7f261a1e504f76b6';

/// FirebaseAuthDataSource Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
///
/// Copied from [firebaseAuthDataSource].
@ProviderFor(firebaseAuthDataSource)
final firebaseAuthDataSourceProvider =
    Provider<FirebaseAuthDataSource>.internal(
      firebaseAuthDataSource,
      name: r'firebaseAuthDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firebaseAuthDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthDataSourceRef = ProviderRef<FirebaseAuthDataSource>;
String _$authRemoteDataSourceHash() =>
    r'08fbc5fbf94c86964791b7f20b39f2504c0e8a74';

/// AuthRemoteDataSource Provider (Retrofit)
///
/// Copied from [authRemoteDataSource].
@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider =
    AutoDisposeProvider<AuthRemoteDataSource>.internal(
      authRemoteDataSource,
      name: r'authRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRemoteDataSourceRef = AutoDisposeProviderRef<AuthRemoteDataSource>;
String _$authRepositoryHash() => r'76a65429e2d010171c010ca11e8101871250895e';

/// AuthRepository Provider
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$signInWithGoogleUseCaseHash() =>
    r'8c98caf1266b3f621de1fff95dbe743d11d7fe48';

/// Google 로그인 UseCase Provider
///
/// Copied from [signInWithGoogleUseCase].
@ProviderFor(signInWithGoogleUseCase)
final signInWithGoogleUseCaseProvider =
    AutoDisposeProvider<SignInWithGoogleUseCase>.internal(
      signInWithGoogleUseCase,
      name: r'signInWithGoogleUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signInWithGoogleUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignInWithGoogleUseCaseRef =
    AutoDisposeProviderRef<SignInWithGoogleUseCase>;
String _$signInWithAppleUseCaseHash() =>
    r'b05f076cc162feb22a75ff665b77b0c9d13bd4c2';

/// Apple 로그인 UseCase Provider
///
/// Copied from [signInWithAppleUseCase].
@ProviderFor(signInWithAppleUseCase)
final signInWithAppleUseCaseProvider =
    AutoDisposeProvider<SignInWithAppleUseCase>.internal(
      signInWithAppleUseCase,
      name: r'signInWithAppleUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signInWithAppleUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignInWithAppleUseCaseRef =
    AutoDisposeProviderRef<SignInWithAppleUseCase>;
String _$signOutUseCaseHash() => r'43363bb12c29608b922dc4b401fe5f632f2dcbe8';

/// 로그아웃 UseCase Provider
///
/// Copied from [signOutUseCase].
@ProviderFor(signOutUseCase)
final signOutUseCaseProvider = AutoDisposeProvider<SignOutUseCase>.internal(
  signOutUseCase,
  name: r'signOutUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signOutUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignOutUseCaseRef = AutoDisposeProviderRef<SignOutUseCase>;
String _$updateNicknameUseCaseHash() =>
    r'd5da31be5fb239d0ec6d3f2feccbb73c0fad3268';

/// 닉네임 변경 UseCase Provider
///
/// Copied from [updateNicknameUseCase].
@ProviderFor(updateNicknameUseCase)
final updateNicknameUseCaseProvider =
    AutoDisposeProvider<UpdateNicknameUseCase>.internal(
      updateNicknameUseCase,
      name: r'updateNicknameUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateNicknameUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateNicknameUseCaseRef =
    AutoDisposeProviderRef<UpdateNicknameUseCase>;
String _$checkNicknameUseCaseHash() =>
    r'f32484a99a3201ed32ca6c672063b265bdd5b5ee';

/// 닉네임 중복 확인 UseCase Provider
///
/// Copied from [checkNicknameUseCase].
@ProviderFor(checkNicknameUseCase)
final checkNicknameUseCaseProvider =
    AutoDisposeProvider<CheckNicknameUseCase>.internal(
      checkNicknameUseCase,
      name: r'checkNicknameUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkNicknameUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CheckNicknameUseCaseRef = AutoDisposeProviderRef<CheckNicknameUseCase>;
String _$withdrawUseCaseHash() => r'29acaec0a21a6ab45418128f1076a00762577253';

/// 회원 탈퇴 UseCase Provider
///
/// Copied from [withdrawUseCase].
@ProviderFor(withdrawUseCase)
final withdrawUseCaseProvider = AutoDisposeProvider<WithdrawUseCase>.internal(
  withdrawUseCase,
  name: r'withdrawUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$withdrawUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WithdrawUseCaseRef = AutoDisposeProviderRef<WithdrawUseCase>;
String _$authStateHash() => r'facb22ebd952358284758f2de88b4f654584d127';

/// Firebase Auth State를 실시간으로 제공하는 StreamProvider
///
/// GoRouter refreshListenable 또는 외부 로그아웃(토큰 만료, 계정 삭제 등) 감지에 사용.
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$isGuestHash() => r'4788dbffb8ca3acb9a23da73c2ffaf1d6d76d3fc';

/// 현재 사용자가 게스트인지 여부
///
/// Copied from [isGuest].
@ProviderFor(isGuest)
final isGuestProvider = AutoDisposeProvider<bool>.internal(
  isGuest,
  name: r'isGuestProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isGuestHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsGuestRef = AutoDisposeProviderRef<bool>;
String _$activeLoginNotifierHash() =>
    r'9c1933f79e775a81e480be7b026021622dd7405b';

/// 현재 진행 중인 소셜 로그인 프로바이더를 추적하는 Notifier
///
/// Copied from [ActiveLoginNotifier].
@ProviderFor(ActiveLoginNotifier)
final activeLoginNotifierProvider =
    AutoDisposeNotifierProvider<
      ActiveLoginNotifier,
      SocialLoginProvider?
    >.internal(
      ActiveLoginNotifier.new,
      name: r'activeLoginNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeLoginNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveLoginNotifier = AutoDisposeNotifier<SocialLoginProvider?>;
String _$authNotifierHash() => r'cc2af010028837e76bb830e34eb6c347704bce3c';

/// 인증 상태를 관리하는 Notifier
///
/// **State**: `AsyncValue<AuthResultEntity?>` - 로그인 결과 (null = 미로그인)
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, AuthResultEntity?>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AutoDisposeAsyncNotifier<AuthResultEntity?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
