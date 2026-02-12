# Auth Clean Architecture Refactor - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor the authentication system to follow Clean Architecture patterns based on the SpaceStudyShip reference implementation, isolating Firebase SDK calls in the Data layer, adding UseCase layer, and making all dependencies injectable.

**Architecture:** Extract Firebase SDK calls from Presentation layer (`auth_provider.dart`) into a dedicated `FirebaseAuthDataSource` in the Data layer. Add UseCase layer for single-responsibility business logic. Refactor `AuthRepositoryImpl` to encapsulate the full login flow (Firebase auth → ID Token → backend login → save tokens). Make `SecureTokenStorage` instance-based for testability. Add auth-aware GoRouter redirect with `_GoRouterRefreshNotifier`.

**Tech Stack:** Flutter 3.9.2+, Riverpod 2.6.1, Freezed 2.5.7, GoogleSignIn v7.2.0, Dio 5.9.0, Retrofit 4.7.2, GoRouter, Firebase Auth

---

## Reference Architecture (SpaceStudyShip-FE)

```
features/auth/
├── data/
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart   ← Firebase SDK 격리 (NEW)
│   │   └── auth_remote_datasource.dart     ← reissue() 추가, typed logout
│   ├── models/
│   │   ├── login_request_model.dart        ← 기존 유지
│   │   ├── login_response_model.dart       ← 기존 유지
│   │   ├── logout_request_model.dart       ← NEW
│   │   ├── token_reissue_request_model.dart  ← NEW
│   │   └── token_reissue_response_model.dart ← NEW
│   └── repositories/
│       └── auth_repository_impl.dart       ← 3 deps, _performSocialLogin
├── domain/
│   ├── entities/
│   │   └── auth_result_entity.dart         ← LEAN (no tokens)
│   ├── repositories/
│   │   └── auth_repository.dart            ← signInWithGoogle/Apple/signOut
│   ├── usecases/                           ← NEW
│   │   ├── sign_in_with_google_usecase.dart
│   │   ├── sign_in_with_apple_usecase.dart
│   │   └── sign_out_usecase.dart
│   └── utils/
│       └── firebase_auth_error_handler.dart ← NEW
└── presentation/
    ├── providers/
    │   └── auth_provider.dart              ← UseCase 사용, Firebase 제거
    └── screens/
        ├── login_screen.dart               ← 변경 없음
        └── splash_screen.dart              ← 변경 없음

core/
├── errors/
│   ├── exceptions.dart                     ← NEW (AuthException)
│   └── api_error_response.dart             ← NEW (RFC 7807)
├── storage/
│   └── secure_token_storage.dart           ← NEW (instance-based)
└── services/dio/interceptors/
    └── auth_interceptor.dart               ← typed models 사용
```

## Current vs Target Comparison

| 항목               | 현재 (문제)                         | 목표 (레퍼런스)                              |
| ------------------ | ----------------------------------- | -------------------------------------------- |
| Firebase SDK       | `auth_provider.dart` (Presentation) | `firebase_auth_datasource.dart` (Data)       |
| Repository.login() | raw params 전달                     | `signInWithGoogle()` / `signInWithApple()`   |
| Token 저장         | Repository에서 static 호출          | Repository에서 instance 주입                 |
| SecureStorage      | static methods (테스트 불가)        | instance-based (DI, 테스트 가능)             |
| Error 처리         | catch-all, generic                  | `AuthException` + `FirebaseAuthErrorHandler` |
| LoginResultEntity  | tokens 포함                         | lean (userId, nickname, isNewUser만)         |
| UseCase            | 없음                                | SignInWithGoogle/Apple/SignOut               |
| 토큰 갱신          | raw Map + response.data[]           | typed `TokenReissueRequest/Response`         |
| GoRouter redirect  | 없음 (수동 navigation)              | `_GoRouterRefreshNotifier` + redirect        |

---

## Phase 1: Core Infrastructure (비파괴적 - 기존 코드와 병존)

### Task 1: Create AuthException and ApiErrorResponse

**Files:**

- Create: `lib/core/errors/exceptions.dart`
- Create: `lib/core/errors/api_error_response.dart`

**Step 1: Create exceptions.dart**

```dart
// lib/core/errors/exceptions.dart

/// 인증 관련 예외
///
/// Firebase 인증 실패, 서버 로그인 실패 등 인증 과정에서 발생하는 예외입니다.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// 서버 API 예외
///
/// DioException을 사용자 친화적으로 변환한 예외입니다.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}
```

**Step 2: Create api_error_response.dart**

```dart
// lib/core/errors/api_error_response.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error_response.freezed.dart';
part 'api_error_response.g.dart';

/// RFC 7807 Problem Details 형식의 API 에러 응답
///
/// Spring Boot 서버의 에러 응답을 파싱합니다.
@freezed
class ApiErrorResponse with _$ApiErrorResponse {
  const factory ApiErrorResponse({
    required String title,
    required int status,
    String? detail,
    String? instance,
  }) = _ApiErrorResponse;

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseFromJson(json);

  /// 안전한 파싱 (실패 시 null 반환)
  static ApiErrorResponse? tryParse(dynamic data) {
    if (data is Map<String, dynamic>) {
      try {
        return ApiErrorResponse.fromJson(data);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
```

**Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 4: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 5: Commit**

```bash
git add lib/core/errors/
git commit -m "feat(auth): AuthException, ServerException, ApiErrorResponse 추가

- AuthException: 인증 과정 예외 (Firebase, 서버 로그인)
- ServerException: API 서버 예외
- ApiErrorResponse: RFC 7807 Problem Details 파싱"
```

---

### Task 2: Create SecureTokenStorage (instance-based)

**Files:**

- Create: `lib/core/storage/secure_token_storage.dart`

> 기존 `SecureStorageService`는 삭제하지 않고, 새로운 instance-based `SecureTokenStorage`를 먼저 만듭니다.
> 이후 Task에서 기존 참조를 교체합니다.

**Step 1: Create secure_token_storage.dart**

```dart
// lib/core/storage/secure_token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰 보안 저장소 (Instance-based)
///
/// 생성자 주입을 통해 테스트 가능한 토큰 저장소입니다.
/// FlutterSecureStorage를 사용하여 accessToken, refreshToken, userId를 관리합니다.
class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _userIdKey = 'USER_ID';

  // ═══════════════════════════════════════════════════
  // Access Token
  // ═══════════════════════════════════════════════════

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  // ═══════════════════════════════════════════════════
  // Refresh Token
  // ═══════════════════════════════════════════════════

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  // ═══════════════════════════════════════════════════
  // Tokens (convenience)
  // ═══════════════════════════════════════════════════

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  // ═══════════════════════════════════════════════════
  // User ID
  // ═══════════════════════════════════════════════════

  Future<int?> getUserId() async {
    final id = await _storage.read(key: _userIdKey);
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> saveUserId(int id) =>
      _storage.write(key: _userIdKey, value: id.toString());

  // ═══════════════════════════════════════════════════
  // Lifecycle
  // ═══════════════════════════════════════════════════

  Future<void> clearTokens() => _storage.deleteAll();

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/storage/secure_token_storage.dart
git commit -m "feat(auth): instance-based SecureTokenStorage 추가

- 생성자 주입으로 테스트 가능한 토큰 저장소
- getUserId()가 int? 반환 (레퍼런스 패턴)
- 기존 SecureStorageService와 병존 (이후 마이그레이션)"
```

---

### Task 3: Create Typed Models (Logout, TokenReissue)

**Files:**

- Create: `lib/features/auth/data/models/logout_request_model.dart`
- Create: `lib/features/auth/data/models/token_reissue_request_model.dart`
- Create: `lib/features/auth/data/models/token_reissue_response_model.dart`

**Step 1: Create logout_request_model.dart**

```dart
// lib/features/auth/data/models/logout_request_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_request_model.freezed.dart';
part 'logout_request_model.g.dart';

/// 로그아웃 요청 모델
///
/// POST /api/v1/auth/logout 요청 바디
@freezed
class LogoutRequestModel with _$LogoutRequestModel {
  const factory LogoutRequestModel({
    required String refreshToken,
  }) = _LogoutRequestModel;

  factory LogoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestModelFromJson(json);
}
```

**Step 2: Create token_reissue_request_model.dart**

```dart
// lib/features/auth/data/models/token_reissue_request_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_reissue_request_model.freezed.dart';
part 'token_reissue_request_model.g.dart';

/// 토큰 재발급 요청 모델
///
/// POST /api/v1/auth/refresh 요청 바디
@freezed
class TokenReissueRequestModel with _$TokenReissueRequestModel {
  const factory TokenReissueRequestModel({
    required String refreshToken,
  }) = _TokenReissueRequestModel;

  factory TokenReissueRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TokenReissueRequestModelFromJson(json);
}
```

**Step 3: Create token_reissue_response_model.dart**

```dart
// lib/features/auth/data/models/token_reissue_response_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'login_response_model.dart'; // TokensModel 재사용

part 'token_reissue_response_model.freezed.dart';
part 'token_reissue_response_model.g.dart';

/// 토큰 재발급 응답 모델
///
/// POST /api/v1/auth/refresh 응답 바디
@freezed
class TokenReissueResponseModel with _$TokenReissueResponseModel {
  const factory TokenReissueResponseModel({
    required TokensModel tokens,
  }) = _TokenReissueResponseModel;

  factory TokenReissueResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenReissueResponseModelFromJson(json);
}
```

**Step 4: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 5: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 6: Commit**

```bash
git add lib/features/auth/data/models/logout_request_model.dart \
        lib/features/auth/data/models/token_reissue_request_model.dart \
        lib/features/auth/data/models/token_reissue_response_model.dart
git commit -m "feat(auth): LogoutRequestModel, TokenReissue Request/Response 모델 추가

- LogoutRequestModel: refreshToken 기반 로그아웃 요청
- TokenReissueRequestModel: refreshToken 기반 토큰 갱신 요청
- TokenReissueResponseModel: 갱신된 TokensModel 응답"
```

---

### Task 4: Create FirebaseAuthErrorHandler

**Files:**

- Create: `lib/features/auth/domain/utils/firebase_auth_error_handler.dart`

**Step 1: Create firebase_auth_error_handler.dart**

```dart
// lib/features/auth/domain/utils/firebase_auth_error_handler.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';

/// Firebase 인증 에러 핸들러
///
/// Firebase 에러 코드를 한국어 사용자 친화적 메시지로 변환합니다.
class FirebaseAuthErrorHandler {
  /// Firebase 에러 코드 → 한국어 메시지 변환
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      // Google Sign-In 에러
      case 'ERROR_ABORTED_BY_USER':
      case 'sign_in_canceled':
        return '로그인이 취소되었습니다';
      case 'ERROR_NETWORK_REQUEST_FAILED':
      case 'network-request-failed':
        return '네트워크 연결을 확인해 주세요';
      case 'ERROR_OPERATION_NOT_ALLOWED':
      case 'operation-not-allowed':
        return '이 로그인 방법은 현재 사용할 수 없습니다';

      // Firebase Auth 에러
      case 'account-exists-with-different-credential':
        return '다른 로그인 방법으로 가입된 계정입니다';
      case 'invalid-credential':
        return '인증 정보가 유효하지 않습니다';
      case 'user-disabled':
        return '비활성화된 계정입니다. 고객센터에 문의해 주세요';
      case 'user-not-found':
        return '등록되지 않은 사용자입니다';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해 주세요';
      case 'invalid-api-key':
        debugPrint('[FirebaseAuth] ❌ API Key 설정 오류');
        return '앱 설정에 문제가 있습니다. 업데이트 후 다시 시도해 주세요';

      default:
        debugPrint('[FirebaseAuth] ❌ 알 수 없는 에러 코드: $errorCode');
        return '로그인 중 문제가 발생했습니다. 다시 시도해 주세요';
    }
  }

  /// FirebaseAuthException → AuthException 변환
  static AuthException createAuthException(FirebaseAuthException e) {
    return AuthException(
      getErrorMessage(e.code),
      code: e.code,
    );
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/auth/domain/utils/firebase_auth_error_handler.dart
git commit -m "feat(auth): FirebaseAuthErrorHandler 추가

- Firebase 에러 코드 → 한국어 사용자 친화적 메시지 변환
- Google Sign-In, Firebase Auth 에러 코드 매핑
- FirebaseAuthException → AuthException 변환 헬퍼"
```

---

### Task 5: Create FirebaseAuthDataSource

**Files:**

- Create: `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

> **중요:** GoogleSignIn v7.2.0 API 사용 (`GoogleSignIn.instance.authenticate()`)
> 레퍼런스는 v6 API 사용하므로, 우리 프로젝트에 맞게 v7 API로 작성합니다.

**Step 1: Create firebase_auth_datasource.dart**

```dart
// lib/features/auth/data/datasources/firebase_auth_datasource.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/utils/firebase_auth_error_handler.dart';

/// Firebase 인증 데이터소스
///
/// Firebase SDK 호출을 Data Layer에 격리합니다.
/// Google/Apple 소셜 로그인 → Firebase Auth → ID Token 발급
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Google 로그인 → Firebase ID Token 발급
  ///
  /// GoogleSignIn v7: `GoogleSignIn.instance.authenticate()` 사용
  Future<String> signInWithGoogle() async {
    try {
      // 1. Google Sign-In (v7 singleton API)
      final googleAccount = await GoogleSignIn.instance.authenticate();

      // 2. Firebase Auth credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAccount.authentication.idToken,
      );

      // 3. Firebase 로그인 → ID Token
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw const AuthException(
          'Firebase ID Token 발급에 실패했습니다',
          code: 'id-token-null',
        );
      }

      debugPrint('[FirebaseAuth] ✅ Google 로그인 성공');
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('로그인이 취소되었습니다', code: 'sign_in_canceled');
      }
      debugPrint('[FirebaseAuth] ❌ Google Sign-In 실패: ${e.code}');
      throw AuthException(
        'Google 로그인에 실패했습니다: ${e.message}',
        code: e.code.name,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthErrorHandler.createAuthException(e);
    }
  }

  /// Apple 로그인 → Firebase ID Token 발급 (iOS 전용)
  Future<String> signInWithApple() async {
    if (!Platform.isIOS) {
      throw const AuthException(
        'Apple 로그인은 iOS에서만 지원됩니다',
        code: 'platform-not-supported',
      );
    }

    try {
      // 1. Apple Sign In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Firebase Auth credential
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3. Firebase 로그인 → ID Token
      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw const AuthException(
          'Firebase ID Token 발급에 실패했습니다',
          code: 'id-token-null',
        );
      }

      debugPrint('[FirebaseAuth] ✅ Apple 로그인 성공');
      return idToken;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException('로그인이 취소되었습니다', code: 'sign_in_canceled');
      }
      debugPrint('[FirebaseAuth] ❌ Apple Sign-In 실패: ${e.code}');
      throw AuthException('Apple 로그인에 실패했습니다', code: e.code.name);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthErrorHandler.createAuthException(e);
    }
  }

  /// Firebase 로그아웃
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
    debugPrint('[FirebaseAuth] ✅ Firebase 로그아웃 완료');
  }

  /// 현재 사용자의 ID Token 가져오기
  Future<String?> getIdToken() async {
    return _firebaseAuth.currentUser?.getIdToken();
  }
}
```

**Step 2: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/auth/data/datasources/firebase_auth_datasource.dart
git commit -m "feat(auth): FirebaseAuthDataSource 추가 - Firebase SDK Data Layer 격리

- Google 로그인 (GoogleSignIn v7 API)
- Apple 로그인 (iOS 전용)
- Firebase 로그아웃 + Google 로그아웃
- AuthException 변환, FirebaseAuthErrorHandler 연동"
```

---

## Phase 2: Domain Layer Refactor

### Task 6: Refactor Domain Entities and Repository Interface

**Files:**

- Create: `lib/features/auth/domain/entities/auth_result_entity.dart` (lean version)
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`
- Delete: `lib/features/auth/domain/entities/auth_token_entity.dart` (토큰은 storage concern)
- Delete: `lib/features/auth/domain/entities/login_result_entity.dart` (auth_result_entity로 교체)

> **핵심 변경:** `LoginResultEntity`(tokens 포함) → `AuthResultEntity`(lean, tokens 없음)
> 토큰은 Repository에서 SecureTokenStorage에 직접 저장하며, Domain Layer에 노출하지 않습니다.

**Step 1: Create auth_result_entity.dart (lean)**

```dart
// lib/features/auth/domain/entities/auth_result_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result_entity.freezed.dart';
part 'auth_result_entity.g.dart';

/// 인증 결과 엔티티 (Lean)
///
/// 로그인 후 UI에 필요한 정보만 담습니다.
/// JWT 토큰은 Repository에서 SecureTokenStorage에 직접 저장하므로
/// Domain Entity에 포함하지 않습니다.
@freezed
class AuthResultEntity with _$AuthResultEntity {
  const factory AuthResultEntity({
    required int userId,
    required String nickname,
    required bool isNewUser,
  }) = _AuthResultEntity;

  factory AuthResultEntity.fromJson(Map<String, dynamic> json) =>
      _$AuthResultEntityFromJson(json);
}
```

**Step 2: Refactor auth_repository.dart**

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
import '../entities/auth_result_entity.dart';

/// 인증 리포지토리 인터페이스
///
/// Repository가 전체 인증 흐름을 캡슐화합니다:
/// Firebase 소셜 로그인 → ID Token 획득 → 서버 로그인 → 토큰 저장
abstract class AuthRepository {
  /// Google 소셜 로그인 (Firebase → 서버 → 토큰 저장 전체 흐름)
  Future<AuthResultEntity> signInWithGoogle();

  /// Apple 소셜 로그인 (Firebase → 서버 → 토큰 저장 전체 흐름, iOS 전용)
  Future<AuthResultEntity> signInWithApple();

  /// 로그아웃 (서버 → Firebase → 토큰 삭제)
  Future<void> signOut();

  /// 회원 탈퇴 (서버 → Firebase → 토큰 삭제)
  Future<void> withdraw();

  /// 로그인 상태 확인 (저장된 토큰 존재 여부)
  Future<bool> isLoggedIn();
}
```

**Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 4: Run flutter analyze**

```bash
flutter analyze
```

Expected: 기존 `LoginResultEntity`, `AuthTokenEntity` 참조하는 파일에서 에러 발생 가능.
→ 이 에러들은 Task 8, 9, 10에서 순차적으로 해결합니다.
→ 여기서는 새 entity와 interface만 생성하고, 기존 파일은 아직 삭제하지 않습니다.

> **주의:** 이 시점에서 기존 `LoginResultEntity`, `AuthTokenEntity`를 삭제하면
> `auth_repository_impl.dart`, `auth_provider.dart`, `login_response_model.dart` 등에서
> 컴파일 에러가 발생합니다. 기존 파일은 Phase 3에서 일괄 교체 후 삭제합니다.

**Step 5: Commit**

```bash
git add lib/features/auth/domain/entities/auth_result_entity.dart \
        lib/features/auth/domain/repositories/auth_repository.dart
git commit -m "feat(auth): lean AuthResultEntity + 새 AuthRepository 인터페이스

- AuthResultEntity: userId, nickname, isNewUser만 (tokens 제거)
- AuthRepository: signInWithGoogle/signInWithApple/signOut/withdraw
- Repository가 전체 인증 흐름을 캡슐화하는 패턴"
```

---

### Task 7: Create UseCase Layer

**Files:**

- Create: `lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart`
- Create: `lib/features/auth/domain/usecases/sign_in_with_apple_usecase.dart`
- Create: `lib/features/auth/domain/usecases/sign_out_usecase.dart`

**Step 1: Create sign_in_with_google_usecase.dart**

```dart
// lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

/// Google 로그인 UseCase
///
/// Single Responsibility: Google 소셜 로그인 실행
class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  const SignInWithGoogleUseCase(this._repository);

  Future<AuthResultEntity> execute() => _repository.signInWithGoogle();
}
```

**Step 2: Create sign_in_with_apple_usecase.dart**

```dart
// lib/features/auth/domain/usecases/sign_in_with_apple_usecase.dart
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

/// Apple 로그인 UseCase (iOS 전용)
///
/// Single Responsibility: Apple 소셜 로그인 실행
class SignInWithAppleUseCase {
  final AuthRepository _repository;

  const SignInWithAppleUseCase(this._repository);

  Future<AuthResultEntity> execute() => _repository.signInWithApple();
}
```

**Step 3: Create sign_out_usecase.dart**

```dart
// lib/features/auth/domain/usecases/sign_out_usecase.dart
import '../repositories/auth_repository.dart';

/// 로그아웃 UseCase
///
/// Single Responsibility: 로그아웃 (서버 + Firebase + 토큰 삭제)
class SignOutUseCase {
  final AuthRepository _repository;

  const SignOutUseCase(this._repository);

  Future<void> execute() => _repository.signOut();
}
```

**Step 4: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues (UseCase는 새 AuthRepository interface만 참조)

**Step 5: Commit**

```bash
git add lib/features/auth/domain/usecases/
git commit -m "feat(auth): UseCase 레이어 추가

- SignInWithGoogleUseCase
- SignInWithAppleUseCase
- SignOutUseCase
- Single Responsibility Principle 적용"
```

---

## Phase 3: Data + Presentation Layer Refactor (Breaking Changes)

### Task 8: Update AuthRemoteDataSource with Typed Models

**Files:**

- Modify: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

**Step 1: Refactor auth_remote_datasource.dart**

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/logout_request_model.dart';
import '../models/token_reissue_request_model.dart';
import '../models/token_reissue_response_model.dart';

part 'auth_remote_datasource.g.dart';

/// 인증 원격 데이터소스
///
/// Spring Boot 서버의 인증 API를 호출합니다.
/// 모든 요청/응답에 typed Freezed 모델을 사용합니다.
@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  /// 소셜 로그인 (회원가입 겸용)
  @POST(ApiEndpoints.login)
  Future<LoginResponseModel> login(@Body() LoginRequestModel request);

  /// 로그아웃
  @POST(ApiEndpoints.logout)
  Future<void> logout(@Body() LogoutRequestModel request);

  /// 토큰 재발급
  @POST(ApiEndpoints.refresh)
  Future<TokenReissueResponseModel> reissue(
      @Body() TokenReissueRequestModel request);

  /// 회원 탈퇴
  @DELETE(ApiEndpoints.withdraw)
  Future<void> withdraw();
}
```

**Step 2: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: `auth_repository_impl.dart`에서 에러 (logout 시그니처 변경) → Task 9에서 해결

**Step 4: Commit**

```bash
git add lib/features/auth/data/datasources/auth_remote_datasource.dart \
        lib/features/auth/data/datasources/auth_remote_datasource.g.dart
git commit -m "feat(auth): AuthRemoteDataSource에 typed models 적용

- logout: Map<String, String> → LogoutRequestModel
- reissue: TokenReissueRequest/Response typed 엔드포인트 추가"
```

---

### Task 9: Refactor LoginResponseModel toEntity and AuthRepositoryImpl

**Files:**

- Modify: `lib/features/auth/data/models/login_response_model.dart` (toEntity → AuthResultEntity)
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart` (3 deps, full flow)

> **핵심 변경:** Repository가 Firebase → 서버 → 토큰 저장 전체 흐름을 캡슐화합니다.
> `_performSocialLogin()` 공통 헬퍼로 중복 제거.
> `_cleanupFirebaseSession()` 서버 실패 시 Firebase 세션 정리.

**Step 1: Update login_response_model.dart toEntity**

`LoginResponseModelX.toEntity()`를 `AuthResultEntity`로 변경합니다:

```dart
// lib/features/auth/data/models/login_response_model.dart
// ... (기존 LoginResponseModel, TokensModel 유지)

// 변경: LoginResultEntity → AuthResultEntity
extension LoginResponseModelX on LoginResponseModel {
  AuthResultEntity toEntity() => AuthResultEntity(
        userId: userId,
        nickname: nickname,
        isNewUser: isNewUser,
      );
}
```

import도 변경:

```dart
import '../../domain/entities/auth_result_entity.dart';
// 삭제: import '../../domain/entities/auth_token_entity.dart';
// 삭제: import '../../domain/entities/login_result_entity.dart';
```

**Step 2: Rewrite auth_repository_impl.dart**

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/device/device_id_manager.dart';
import '../../../../core/services/device/device_info_service.dart';
import '../../../../core/services/fcm/firebase_messaging_service.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';

/// 인증 리포지토리 구현체
///
/// 3개의 의존성을 주입받아 전체 인증 흐름을 캡슐화합니다:
/// - FirebaseAuthDataSource: Firebase 소셜 로그인 + ID Token
/// - AuthRemoteDataSource: 서버 API 호출
/// - SecureTokenStorage: JWT 토큰 저장
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final SecureTokenStorage _tokenStorage;

  AuthRepositoryImpl(
    this._firebaseAuthDataSource,
    this._remoteDataSource,
    this._tokenStorage,
  );

  @override
  Future<AuthResultEntity> signInWithGoogle() async {
    return _performSocialLogin(
      socialPlatform: 'GOOGLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithGoogle(),
    );
  }

  @override
  Future<AuthResultEntity> signInWithApple() async {
    return _performSocialLogin(
      socialPlatform: 'APPLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithApple(),
    );
  }

  /// 소셜 로그인 공통 로직
  ///
  /// 1. Firebase 소셜 로그인 → ID Token
  /// 2. FCM Token + Device 정보 수집
  /// 3. 서버 로그인 API 호출
  /// 4. JWT 토큰 저장
  /// 5. 실패 시 Firebase 세션 정리
  Future<AuthResultEntity> _performSocialLogin({
    required String socialPlatform,
    required Future<String> Function() firebaseSignIn,
  }) async {
    // 1. Firebase 소셜 로그인 → ID Token
    final idToken = await firebaseSignIn();

    try {
      // 2. 디바이스 정보 수집
      final fcmService = FirebaseMessagingService.instance();
      final fcmToken = await fcmService.getFcmToken();
      final deviceId = await DeviceIdManager.getOrCreateDeviceId();
      final deviceType = DeviceInfoService.getDeviceType();

      // 3. 서버 로그인
      final request = LoginRequestModel(
        socialPlatform: socialPlatform,
        idToken: idToken,
        fcmToken: fcmToken,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      final response = await _remoteDataSource.login(request);

      // 4. 토큰 저장
      await _tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );
      await _tokenStorage.saveUserId(response.userId);

      debugPrint(
          '[AuthRepository] ✅ 로그인 성공: userId=${response.userId}, isNew=${response.isNewUser}');
      return response.toEntity();
    } on DioException catch (e) {
      // 서버 로그인 실패 → Firebase 세션 정리
      await _cleanupFirebaseSession();
      debugPrint('[AuthRepository] ❌ 서버 로그인 실패: ${e.message}');
      throw ServerException(
        '서버 연결에 실패했습니다. 잠시 후 다시 시도해 주세요',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      await _cleanupFirebaseSession();
      debugPrint('[AuthRepository] ❌ 로그인 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // 1. 서버 로그아웃 (refreshToken 전송)
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _remoteDataSource
            .logout(LogoutRequestModel(refreshToken: refreshToken));
      }
    } catch (e) {
      debugPrint('[AuthRepository] ⚠️ 서버 로그아웃 실패 (로컬은 진행): $e');
    }

    // 2. Firebase 로그아웃
    await _firebaseAuthDataSource.signOut();

    // 3. 토큰 삭제
    await _tokenStorage.clearTokens();
    debugPrint('[AuthRepository] ✅ 로그아웃 완료');
  }

  @override
  Future<void> withdraw() async {
    // 1. 서버 회원 탈퇴
    await _remoteDataSource.withdraw();

    // 2. Firebase 로그아웃
    await _firebaseAuthDataSource.signOut();

    // 3. 토큰 삭제
    await _tokenStorage.clearTokens();
    debugPrint('[AuthRepository] ✅ 회원 탈퇴 완료');
  }

  @override
  Future<bool> isLoggedIn() => _tokenStorage.hasTokens();

  /// Firebase 세션 정리 (서버 로그인 실패 시)
  ///
  /// 서버 로그인이 실패했지만 Firebase 인증은 성공한 경우,
  /// 불일치 상태를 방지하기 위해 Firebase 세션을 정리합니다.
  Future<void> _cleanupFirebaseSession() async {
    try {
      await _firebaseAuthDataSource.signOut();
      debugPrint('[AuthRepository] 🧹 Firebase 세션 정리 완료');
    } catch (e) {
      debugPrint('[AuthRepository] ⚠️ Firebase 세션 정리 실패: $e');
    }
  }
}
```

**Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 4: Run flutter analyze**

```bash
flutter analyze
```

Expected: `auth_provider.dart`에서 에러 (LoginResultEntity 참조, AuthNotifier 구조) → Task 10에서 해결

**Step 5: Commit**

```bash
git add lib/features/auth/data/models/login_response_model.dart \
        lib/features/auth/data/repositories/auth_repository_impl.dart
git commit -m "refactor(auth): AuthRepositoryImpl - 3 deps, 전체 인증 흐름 캡슐화

- FirebaseAuthDataSource + AuthRemoteDataSource + SecureTokenStorage 주입
- _performSocialLogin() 공통 로직 (중복 제거)
- _cleanupFirebaseSession() 서버 실패 시 Firebase 세션 정리
- toEntity() → lean AuthResultEntity (tokens 제거)"
```

---

### Task 10: Refactor AuthNotifier (Providers)

**Files:**

- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

> **핵심 변경:**
>
> - Firebase SDK import 전부 제거 (Presentation Layer에서 Firebase 의존성 제거)
> - UseCase를 통한 호출로 변경
> - Provider DI 체인: FirebaseAuthDataSource → AuthRemoteDataSource → SecureTokenStorage → Repository → UseCases → AuthNotifier

**Step 1: Rewrite auth_provider.dart**

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/dio/dio_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

part 'auth_provider.g.dart';

// ═══════════════════════════════════════════════════
// DI Chain: DataSource → Repository → UseCase
// ═══════════════════════════════════════════════════

@riverpod
SecureTokenStorage secureTokenStorage(Ref ref) {
  return SecureTokenStorage();
}

@riverpod
FirebaseAuthDataSource firebaseAuthDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(ref.read(dioProvider));
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.read(firebaseAuthDataSourceProvider),
    ref.read(authRemoteDataSourceProvider),
    ref.read(secureTokenStorageProvider),
  );
}

@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return SignInWithGoogleUseCase(ref.read(authRepositoryProvider));
}

@riverpod
SignInWithAppleUseCase signInWithAppleUseCase(Ref ref) {
  return SignInWithAppleUseCase(ref.read(authRepositoryProvider));
}

@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
}

// ═══════════════════════════════════════════════════
// Auth State
// ═══════════════════════════════════════════════════

/// 인증 상태 열거형
enum AuthStatus { initial, authenticated, unauthenticated }

/// 인증 상태 Notifier
///
/// UseCase를 통해 인증 로직을 실행합니다.
/// Firebase SDK 의존성이 없는 순수한 Presentation Layer입니다.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthStatus> build() async {
    final repository = ref.read(authRepositoryProvider);
    final isLoggedIn = await repository.isLoggedIn();
    return isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  /// Google 로그인
  Future<AuthResultEntity?> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(signInWithGoogleUseCaseProvider);
      final result = await useCase.execute();
      state = const AsyncValue.data(AuthStatus.authenticated);
      return result;
    } on AuthException catch (e, st) {
      if (e.code == 'sign_in_canceled') {
        state = const AsyncValue.data(AuthStatus.unauthenticated);
        return null;
      }
      debugPrint('[Auth] ❌ Google 로그인 실패: ${e.message}');
      state = AsyncValue.error(e, st);
      return null;
    } catch (e, st) {
      debugPrint('[Auth] ❌ Google 로그인 실패: $e');
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Apple 로그인 (iOS 전용)
  Future<AuthResultEntity?> loginWithApple() async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(signInWithAppleUseCaseProvider);
      final result = await useCase.execute();
      state = const AsyncValue.data(AuthStatus.authenticated);
      return result;
    } on AuthException catch (e, st) {
      if (e.code == 'sign_in_canceled') {
        state = const AsyncValue.data(AuthStatus.unauthenticated);
        return null;
      }
      debugPrint('[Auth] ❌ Apple 로그인 실패: ${e.message}');
      state = AsyncValue.error(e, st);
      return null;
    } catch (e, st) {
      debugPrint('[Auth] ❌ Apple 로그인 실패: $e');
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      final useCase = ref.read(signOutUseCaseProvider);
      await useCase.execute();
      state = const AsyncValue.data(AuthStatus.unauthenticated);
    } catch (e, st) {
      debugPrint('[Auth] ❌ 로그아웃 실패: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// 회원 탈퇴
  Future<void> withdraw() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.withdraw();
      state = const AsyncValue.data(AuthStatus.unauthenticated);
    } catch (e, st) {
      debugPrint('[Auth] ❌ 회원 탈퇴 실패: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
```

**Step 2: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: `login_screen.dart`에서 `LoginResultEntity` 참조 에러 → Step 4에서 해결

**Step 4: Update login_screen.dart (LoginResultEntity → AuthResultEntity)**

`login_screen.dart`에서 `result.isNewUser` 사용하는 부분만 import 변경:

- `import '../../domain/entities/login_result_entity.dart'` 삭제 (있다면)
- `AuthResultEntity`는 provider 내부에서 처리하므로 screen에서는 `result?.isNewUser`만 참조

> 현재 `login_screen.dart`는 `LoginResultEntity?` 타입으로 result를 받고 있습니다.
> `AuthResultEntity?`로 변경합니다. 필드가 동일(userId, nickname, isNewUser)하므로
> `result.isNewUser` 로직은 그대로 동작합니다.

**Step 5: Update splash_screen.dart (SecureStorageService → SecureTokenStorage)**

`splash_screen.dart`에서:

- `import '../../../../core/services/storage/secure_storage_service.dart'` → `import '../../../../core/storage/secure_token_storage.dart'`
- `SecureStorageService.isLoggedIn()` → `SecureTokenStorage().hasTokens()`

> 또는 splash_screen을 ConsumerWidget으로 변경하여 `secureTokenStorageProvider`를 사용할 수도 있지만,
> splash에서는 Riverpod이 아직 초기화되지 않을 수 있으므로 직접 인스턴스 생성이 안전합니다.

**Step 6: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found (또는 auth_interceptor 관련 에러 → Task 11에서 해결)

**Step 7: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart \
        lib/features/auth/presentation/providers/auth_provider.g.dart \
        lib/features/auth/presentation/screens/login_screen.dart \
        lib/features/auth/presentation/screens/splash_screen.dart
git commit -m "refactor(auth): AuthNotifier UseCase 패턴 적용, Firebase SDK 제거

- Presentation Layer에서 Firebase SDK 의존성 완전 제거
- DI Chain: DataSource → Repository → UseCase → AuthNotifier
- AuthException 코드 기반 취소 감지 (sign_in_canceled)
- login_screen: AuthResultEntity 타입으로 변경
- splash_screen: SecureTokenStorage 사용"
```

---

### Task 11: Update AuthInterceptor with Typed Models

**Files:**

- Modify: `lib/core/services/dio/interceptors/auth_interceptor.dart`
- Modify: `lib/core/services/dio/dio_client.dart` (SecureTokenStorage 주입)

**Step 1: Refactor auth_interceptor.dart**

```dart
// lib/core/services/dio/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/api_endpoints.dart';
import '../../../storage/secure_token_storage.dart';
import '../../../../features/auth/data/models/token_reissue_request_model.dart';
import '../../../../features/auth/data/models/token_reissue_response_model.dart';

/// JWT 인증 인터셉터
///
/// 모든 API 요청에 accessToken을 자동 주입하고,
/// 401 응답 시 refreshToken으로 자동 갱신을 시도합니다.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureTokenStorage _tokenStorage;

  /// 로그아웃 콜백 (토큰 갱신 실패 시 호출)
  final VoidCallback? onLoggedOut;

  AuthInterceptor(
    this._dio,
    this._tokenStorage, {
    this.onLoggedOut,
  });

  /// 인증이 필요없는 공개 API 경로
  static const _publicPaths = [
    ApiEndpoints.login,
    ApiEndpoints.refresh,
  ];

  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 공개 API는 토큰 불필요
    if (_publicPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return handler.next(err);
    }

    // 공개 API에서 401이면 갱신 시도하지 않음
    if (_publicPaths.any((path) => err.requestOptions.path.contains(path))) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // 새 토큰으로 원래 요청 재시도
        final token = await _tokenStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } else {
        // 갱신 실패 → 로그아웃
        await _tokenStorage.clearTokens();
        onLoggedOut?.call();
        return handler.next(err);
      }
    } catch (e) {
      debugPrint('[AuthInterceptor] ❌ 토큰 갱신 중 오류: $e');
      await _tokenStorage.clearTokens();
      onLoggedOut?.call();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// refreshToken으로 새 accessToken 발급 시도 (typed models 사용)
  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final request = TokenReissueRequestModel(refreshToken: refreshToken);
      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: request.toJson(),
      );

      final reissueResponse =
          TokenReissueResponseModel.fromJson(response.data);
      await _tokenStorage.saveTokens(
        accessToken: reissueResponse.tokens.accessToken,
        refreshToken: reissueResponse.tokens.refreshToken,
      );

      debugPrint('[AuthInterceptor] ✅ 토큰 갱신 성공');
      return true;
    } catch (e) {
      debugPrint('[AuthInterceptor] ❌ 토큰 갱신 실패: $e');
      return false;
    }
  }
}
```

**Step 2: Update dio_client.dart (SecureTokenStorage 주입)**

```dart
// lib/core/services/dio/dio_client.dart
// AuthInterceptor에 SecureTokenStorage 인스턴스 전달
dio.interceptors.addAll([
  AuthInterceptor(dio, SecureTokenStorage()),
  // ... LogInterceptor
]);
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/services/dio/interceptors/auth_interceptor.dart \
        lib/core/services/dio/dio_client.dart
git commit -m "refactor(auth): AuthInterceptor typed models + SecureTokenStorage 주입

- TokenReissueRequestModel/ResponseModel typed 모델 사용
- SecureTokenStorage instance 주입 (static 제거)
- dio_client에서 SecureTokenStorage 인스턴스 전달"
```

---

## Phase 4: GoRouter Auth Redirect + Cleanup

### Task 12: GoRouter Auth-Aware Redirect

**Files:**

- Modify: `lib/routes/app_router.dart`

> 레퍼런스 패턴: `_GoRouterRefreshNotifier`가 `authNotifierProvider`를 listen하여
> 인증 상태 변경 시 GoRouter가 자동으로 redirect를 재평가합니다.

**Step 1: Add \_GoRouterRefreshNotifier and redirect to app_router.dart**

`appRouterProvider` 안에 다음을 추가합니다:

```dart
// app_router.dart에 추가할 부분

/// GoRouter 인증 상태 감지 Notifier
///
/// AuthNotifier의 상태 변경을 GoRouter의 refreshListenable로 전달합니다.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref, ProviderListenable<AsyncValue<AuthStatus>> provider) {
    ref.listen(provider, (_, __) {
      notifyListeners();
    });
  }
}

// GoRouter에 추가할 설정:
// refreshListenable: _GoRouterRefreshNotifier(ref, authNotifierProvider),
// redirect: (context, state) {
//   final authState = ref.read(authNotifierProvider);
//   final isAuthenticated = authState.valueOrNull == AuthStatus.authenticated;
//   final isAuthRoute = state.matchedLocation == RoutePaths.login ||
//       state.matchedLocation == RoutePaths.splash;
//
//   if (!isAuthenticated && !isAuthRoute) {
//     return RoutePaths.login;
//   }
//   if (isAuthenticated && isAuthRoute) {
//     return RoutePaths.home;
//   }
//   return null;
// },
```

> **주의:** redirect 로직은 splash → login → home 흐름과 충돌하지 않도록
> onboarding 경로도 예외로 처리해야 합니다.

**Step 2: Full app_router.dart rewrite with redirect**

`RoutePaths.splash`, `RoutePaths.login`, `RoutePaths.onboarding`은 인증 불필요 경로입니다.
`redirect`에서 이 경로들을 예외로 처리합니다.

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: _GoRouterRefreshNotifier(ref, authNotifierProvider),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated =
          authState.valueOrNull == AuthStatus.authenticated;

      final authPaths = [
        RoutePaths.login,
        RoutePaths.splash,
        RoutePaths.onboarding,
      ];
      final isAuthRoute = authPaths.contains(state.matchedLocation);

      // 인증되지 않은 사용자가 보호된 경로 접근 시 → 로그인
      if (!isAuthenticated && !isAuthRoute) {
        return RoutePaths.login;
      }

      // 인증된 사용자가 로그인/스플래시 접근 시 → 홈
      if (isAuthenticated &&
          (state.matchedLocation == RoutePaths.login ||
              state.matchedLocation == RoutePaths.splash)) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      // ... 기존 routes 유지
    ],
    // ... 기존 errorBuilder 유지
  );
});
```

**Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 4: Commit**

```bash
git add lib/routes/app_router.dart
git commit -m "feat(auth): GoRouter auth-aware redirect + _GoRouterRefreshNotifier

- _GoRouterRefreshNotifier: AuthNotifier 상태 변경 시 redirect 재평가
- 미인증 사용자 → 자동 로그인 리다이렉트
- 인증된 사용자 login/splash 접근 → 자동 홈 리다이렉트
- onboarding 경로 예외 처리"
```

---

### Task 13: Cleanup - Remove Deprecated Files

**Files:**

- Delete: `lib/features/auth/domain/entities/login_result_entity.dart`
- Delete: `lib/features/auth/domain/entities/login_result_entity.freezed.dart`
- Delete: `lib/features/auth/domain/entities/login_result_entity.g.dart`
- Delete: `lib/features/auth/domain/entities/auth_token_entity.dart`
- Delete: `lib/features/auth/domain/entities/auth_token_entity.freezed.dart`
- Delete: `lib/features/auth/domain/entities/auth_token_entity.g.dart`
- Verify: `lib/core/services/storage/secure_storage_service.dart` 참조가 남아있는지 확인

**Step 1: 잔여 참조 확인**

```bash
grep -r "LoginResultEntity" lib/ --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"
grep -r "AuthTokenEntity" lib/ --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"
grep -r "SecureStorageService" lib/ --include="*.dart"
grep -r "login_result_entity" lib/ --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"
grep -r "auth_token_entity" lib/ --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"
```

> 잔여 참조가 있으면 모두 교체한 후 삭제합니다.
> `SecureStorageService` 참조가 남아있다면 `SecureTokenStorage`로 교체합니다.

**Step 2: Delete deprecated files**

```bash
rm lib/features/auth/domain/entities/login_result_entity.dart
rm lib/features/auth/domain/entities/login_result_entity.freezed.dart
rm lib/features/auth/domain/entities/login_result_entity.g.dart
rm lib/features/auth/domain/entities/auth_token_entity.dart
rm lib/features/auth/domain/entities/auth_token_entity.freezed.dart
rm lib/features/auth/domain/entities/auth_token_entity.g.dart
```

**Step 3: SecureStorageService 마이그레이션**

- `SecureStorageService`를 참조하는 모든 파일을 `SecureTokenStorage`로 교체
- 교체 완료 후 `lib/core/services/storage/secure_storage_service.dart` 삭제

```bash
rm lib/core/services/storage/secure_storage_service.dart
```

**Step 4: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 5: Run flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 6: Commit**

```bash
git add -A
git commit -m "refactor(auth): deprecated 파일 삭제 + SecureStorageService 마이그레이션

- LoginResultEntity, AuthTokenEntity 삭제 (AuthResultEntity로 통합)
- SecureStorageService → SecureTokenStorage 완전 마이그레이션
- 모든 참조 교체 완료, flutter analyze 통과"
```

---

## Phase 5: Final Verification

### Task 14: Final Build + Analyze + Verification

**Step 1: Clean build_runner**

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 2: Flutter analyze**

```bash
flutter analyze
```

Expected: No issues found

**Step 3: Verify Clean Architecture layers**

```bash
# Presentation Layer에 Firebase SDK import가 없는지 확인
grep -r "firebase_auth" lib/features/auth/presentation/ --include="*.dart"
grep -r "google_sign_in" lib/features/auth/presentation/ --include="*.dart"
grep -r "sign_in_with_apple" lib/features/auth/presentation/ --include="*.dart"
```

Expected: 0 results (Firebase SDK가 Presentation에서 완전히 제거됨)

```bash
# Domain Layer에 Flutter/외부 패키지 import가 없는지 확인 (freezed_annotation 제외)
grep -r "package:flutter" lib/features/auth/domain/ --include="*.dart" | grep -v "foundation.dart"
grep -r "package:dio" lib/features/auth/domain/ --include="*.dart"
```

Expected: 0 results (Domain은 순수 Dart)

**Step 4: Final commit**

```bash
git add -A
git commit -m "chore(auth): Clean Architecture 리팩토링 최종 검증 완료

- Presentation Layer: Firebase SDK 의존성 0개
- Domain Layer: 순수 Dart (Flutter 의존성 0개)
- Data Layer: Firebase SDK 격리, typed models
- flutter analyze: No issues found"
```

---

## Summary: Files Changed

### New Files (10개)

| File                                                  | Description                    |
| ----------------------------------------------------- | ------------------------------ |
| `core/errors/exceptions.dart`                         | AuthException, ServerException |
| `core/errors/api_error_response.dart`                 | RFC 7807 에러 파싱             |
| `core/storage/secure_token_storage.dart`              | Instance-based 토큰 저장소     |
| `auth/data/datasources/firebase_auth_datasource.dart` | Firebase SDK 격리              |
| `auth/data/models/logout_request_model.dart`          | Typed 로그아웃 요청            |
| `auth/data/models/token_reissue_request_model.dart`   | Typed 토큰 갱신 요청           |
| `auth/data/models/token_reissue_response_model.dart`  | Typed 토큰 갱신 응답           |
| `auth/domain/entities/auth_result_entity.dart`        | Lean 인증 결과 (tokens 없음)   |
| `auth/domain/usecases/sign_in_with_*.dart`            | UseCase x3                     |
| `auth/domain/utils/firebase_auth_error_handler.dart`  | Firebase 에러 한국어 변환      |

### Modified Files (7개)

| File                                                   | Changes                                  |
| ------------------------------------------------------ | ---------------------------------------- |
| `auth/data/datasources/auth_remote_datasource.dart`    | typed logout, reissue 추가               |
| `auth/data/models/login_response_model.dart`           | toEntity → AuthResultEntity              |
| `auth/data/repositories/auth_repository_impl.dart`     | 3 deps, \_performSocialLogin             |
| `auth/domain/repositories/auth_repository.dart`        | signInWithGoogle/Apple/signOut           |
| `auth/presentation/providers/auth_provider.dart`       | UseCase DI, Firebase 제거                |
| `core/services/dio/interceptors/auth_interceptor.dart` | typed models, SecureTokenStorage         |
| `routes/app_router.dart`                               | auth redirect, \_GoRouterRefreshNotifier |

### Deleted Files (4개)

| File                                                | Reason                    |
| --------------------------------------------------- | ------------------------- |
| `auth/domain/entities/login_result_entity.dart`     | AuthResultEntity로 대체   |
| `auth/domain/entities/auth_token_entity.dart`       | 토큰은 storage concern    |
| `core/services/storage/secure_storage_service.dart` | SecureTokenStorage로 대체 |
| + Generated files (`.freezed.dart`, `.g.dart`)      | 삭제된 소스의 생성 파일   |

### Architecture Before → After

```
BEFORE:
LoginScreen → AuthNotifier → [GoogleSignIn, FirebaseAuth, SignInWithApple] + Repository → DataSource
                 (Presentation에서 Firebase SDK 직접 호출)

AFTER:
LoginScreen → AuthNotifier → UseCase → Repository → [FirebaseAuthDataSource + RemoteDataSource + TokenStorage]
                 (Presentation은 UseCase만 호출, Firebase SDK는 Data Layer에 격리)
```
