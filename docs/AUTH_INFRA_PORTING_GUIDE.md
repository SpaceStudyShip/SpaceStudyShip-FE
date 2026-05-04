# Flutter Auth Infra Porting Guide

> **새 Flutter 프로젝트에 이 repo의 Auth 인프라(JWT 자동 주입 + 토큰 자동 재발급 + 강제 로그아웃)를 그대로 이식하기 위한 자기충족적 가이드.**
>
> 이 문서 하나만 보고 다른 코드 에이전트(Claude Code 등)가 새 프로젝트에 setup을 끝낼 수 있도록 작성됨.

---

## 0. Snapshot Info

- **스냅샷 일자**: 2026-05-04
- **원본 repo**: `cops_and_robbers` (Flutter 3.9.2+, Dart 3.9.2+)
- **검증된 시나리오**: Firebase Google/Apple 로그인 → JWT 토큰 발급 → API 자동 인증 → 401 시 자동 reissue → reissue 실패 시 강제 로그아웃

원본 인프라 코드가 갱신되면 이 가이드도 PR에서 같이 갱신해야 함. 그렇지 않으면 동기화 깨짐.

---

## 1. Overview

### 무엇을 옮기는가

| 카테고리 | 파일 | 그대로 복사? |
| --- | --- | --- |
| Core 에러 정의 | `core/errors/app_exception.dart` | ✅ 그대로 |
| Core 네트워크 | `core/network/api_error_response.dart` | ✅ 그대로 |
| Core 네트워크 | `core/network/dio_exception_handler.dart` | ✅ 그대로 |
| Core 스토리지 | `core/storage/secure_token_storage.dart` | ✅ 그대로 |
| Core 인터셉터 | `core/network/auth_interceptor.dart` | ⚠️ `_publicPaths`만 프로젝트별 조정 |
| Core 클라이언트 | `core/network/dio_client.dart` | ✅ 그대로 |
| Core 환경 | `core/config/env_config.dart` | ⚠️ 환경 변수 키 추가/수정 |
| Core 상수 | `core/constants/api_endpoints.dart` | ⚠️ 프로젝트별로 전체 작성 |
| Auth 도메인 | `features/auth/domain/entities/auth_result_entity.dart` | ⚠️ 프로젝트별 필드 조정 |
| Auth 도메인 | `features/auth/domain/repositories/auth_repository.dart` | ✅ 그대로 |
| Auth 도메인 | `features/auth/domain/utils/firebase_auth_error_handler.dart` | ✅ 그대로 |
| Auth 데이터 | `features/auth/data/datasources/firebase_auth_datasource.dart` | ✅ 그대로 (Apple 미사용 시 제거) |
| Auth 데이터 | `features/auth/data/datasources/auth_remote_datasource.dart` | ✅ 그대로 |
| Auth 데이터 | `features/auth/data/models/*` | ⚠️ DTO 필드는 백엔드 응답 스펙에 맞게 |
| Auth 데이터 | `features/auth/data/repositories/auth_repository_impl.dart` | ⚠️ 프로젝트별 추가 필드 처리 |
| Auth 표현 | `features/auth/presentation/providers/auth_provider.dart` | ⚠️ Cold-start 복원 로직 프로젝트별 |

### 핵심 동작 흐름

```
[App Start]
   ↓
EnvConfig.initialize() → Firebase.initializeApp() → tokenStorage.clearTokensIfReinstalled()
   ↓
runApp(ProviderScope)
   ↓
AuthNotifier.build() — forceLogoutCallback 등록 + 토큰 복원
   ↓
[로그인]
   ↓
FirebaseAuthDataSource.signInWithGoogle() → ID Token
   ↓
AuthRemoteDataSource.login(idToken, ...) → JWT (access + refresh)
   ↓
SecureTokenStorage.saveTokens() / saveUserId() / saveIsNewUser()
   ↓
[이후 API 호출]
   ↓
AuthInterceptor.onRequest: Authorization 헤더 자동 주입
   ↓
[401 발생]
   ↓
AuthInterceptor.onError: refreshToken으로 /api/auth/reissue 호출
   ├─ 성공 → 새 토큰 저장 → 원래 요청 재시도
   └─ 실패 → forceLogoutCallback 호출 → Firebase signOut + 토큰 삭제 + 로그인 화면
```

### 핵심 설계 결정

- **`QueuedInterceptor` 사용** — 동시에 401 받은 여러 요청이 단 한 번의 reissue를 공유하도록 큐잉
- **별도의 `_plainDio`** — reissue 호출이 자기 자신의 Interceptor를 다시 타지 않도록 인터셉터 없는 Dio 인스턴스 사용
- **재시도 헤더(`extra['_isRetry']`)** — 재시도된 요청이 또 401이면 무한 루프 방지하고 즉시 강제 로그아웃
- **콜백 기반 강제 로그아웃** — `core`가 `feature`를 모르도록 `forceLogoutCallbackNotifier`로 의존성 역전

---

## 2. Dependencies (`pubspec.yaml`)

새 프로젝트의 `pubspec.yaml`에 다음을 추가. **버전은 정확히 일치시킬 것.** 특히 `retrofit: 4.7.3` 핀.

```yaml
environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter

  # 상태 관리
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # 데이터 모델 (불변)
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # 네트워크 & 인증
  dio: ^5.9.0
  retrofit: 4.7.3                  # ⚠️ 4.9.x logError 시그니처 호환성 이슈로 4.7.3 고정
  flutter_secure_storage: ^9.2.4
  flutter_dotenv: ^6.0.0
  shared_preferences: ^2.3.4       # iOS 재설치 감지용

  # 소셜 로그인
  google_sign_in: ^6.2.3
  sign_in_with_apple: ^6.1.3       # Apple 미사용 시 제거 가능
  firebase_core: ^4.1.0
  firebase_auth: ^6.1.3

  # 라우팅 (GoRouter redirect로 인증 가드)
  go_router: ^17.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner: ^2.4.14
  riverpod_generator: ^2.6.2
  freezed: ^2.5.7
  json_serializable: ^6.9.2
  retrofit_generator: ^9.1.8
```

`.env` 파일을 프로젝트 루트에 생성:

```
API_BASE_URL=https://api.example.com
```

`pubspec.yaml`의 `flutter:` 섹션에 `.env`를 asset으로 등록:

```yaml
flutter:
  assets:
    - .env
```

---

## 3. Folder Structure

```
lib/
├── core/
│   ├── config/
│   │   └── env_config.dart
│   ├── constants/
│   │   └── api_endpoints.dart
│   ├── errors/
│   │   └── app_exception.dart
│   ├── network/
│   │   ├── api_error_response.dart
│   │   ├── auth_interceptor.dart
│   │   ├── dio_client.dart
│   │   └── dio_exception_handler.dart
│   └── storage/
│       └── secure_token_storage.dart
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   ├── auth_remote_datasource.dart
        │   │   └── firebase_auth_datasource.dart
        │   ├── models/
        │   │   ├── login_request_model.dart
        │   │   ├── login_response_model.dart
        │   │   ├── logout_request_model.dart
        │   │   ├── token_reissue_request_model.dart
        │   │   └── token_reissue_response_model.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── auth_result_entity.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart
        │   └── utils/
        │       └── firebase_auth_error_handler.dart
        └── presentation/
            └── providers/
                └── auth_provider.dart
```

---

## 4. Files to Create (Full Source)

각 파일의 전체 소스. 코드 블록을 그대로 해당 경로에 저장.

### 4.1 `lib/core/errors/app_exception.dart`

**역할**: 앱 전역 예외 계층. 모든 커스텀 예외의 부모.

```dart
/// 앱 전역 예외 클래스
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// 네트워크 관련 예외
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 인증 관련 예외
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 사용자가 로그인을 취소한 경우
class AuthCancelledException extends AuthException {
  const AuthCancelledException() : super(message: '로그인이 취소되었습니다.');
}

/// 검증 관련 예외
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 서버 관련 예외
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalException,
  });
}
```

> 프로젝트별로 추가 예외(DatabaseException, WebSocketException, LocationException 등)는 자유롭게 추가.

### 4.2 `lib/core/network/api_error_response.dart`

**역할**: 백엔드 RFC 7807 Problem Details 응답 파서.

```dart
/// 백엔드 공통 에러 응답 모델 (RFC 7807 Problem Details)
///
/// 백엔드의 모든 에러 응답은 이 형식을 따릅니다:
/// ```json
/// {
///   "title": "유효하지 않은 입력값",
///   "status": 400,
///   "detail": "idToken: 소셜 인증 토큰(ID Token)은 필수입니다.",
///   "instance": "/api/auth/login"
/// }
/// ```
class ApiErrorResponse {
  final String title;
  final int status;
  final String detail;
  final String instance;

  const ApiErrorResponse({
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      title: json['title'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      detail: json['detail'] as String? ?? '',
      instance: json['instance'] as String? ?? '',
    );
  }

  /// 응답 데이터에서 안전하게 파싱 시도
  ///
  /// 파싱 실패 시 null 반환 (백엔드가 RFC 7807 형식이 아닌 경우)
  static ApiErrorResponse? tryParse(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;

    // title과 detail이 모두 없으면 RFC 7807 형식이 아닌 것으로 판단
    if (data['title'] == null && data['detail'] == null) return null;

    return ApiErrorResponse.fromJson(data);
  }

  @override
  String toString() {
    return '[$status] $title | $detail (instance: $instance)';
  }
}
```

> 백엔드가 RFC 7807을 안 따르면 `tryParse`가 null을 반환하므로 자연스러운 폴백이 됨.

### 4.3 `lib/core/network/dio_exception_handler.dart`

**역할**: `DioException` → `AppException` 변환을 한곳에 집중. 모든 Repository는 `catch (DioException e) { throw DioExceptionHandler.handle(e); }`만 쓰면 됨.

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import 'api_error_response.dart';

/// DioException → AppException 공통 변환 유틸리티
class DioExceptionHandler {
  DioExceptionHandler._();

  static AppException handle(DioException e) {
    final apiError = ApiErrorResponse.tryParse(e.response?.data);
    _logError(e, apiError);

    if (_isTimeoutError(e)) {
      return NetworkException(
        message: apiError?.detail ?? '서버 연결 시간이 초과되었습니다.',
        code: 'timeout',
        originalException: e,
      );
    }

    if (_isConnectionError(e)) {
      return NetworkException(
        message: apiError?.detail ?? '네트워크 연결을 확인하세요.',
        code: 'connection-error',
        originalException: e,
      );
    }

    final statusCode = e.response?.statusCode;
    final detail = apiError?.detail ?? '';
    final title = apiError?.title ?? '';

    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message: detail.isNotEmpty ? detail : '서버에 문제가 발생했습니다.',
        code: title.isNotEmpty ? title : 'server-error',
        originalException: e,
      );
    }

    return switch (statusCode) {
      400 => ValidationException(
        message: detail.isNotEmpty ? detail : '잘못된 요청입니다.',
        code: title.isNotEmpty ? title : 'bad-request',
        originalException: e,
      ),
      401 => AuthException(
        message: detail.isNotEmpty ? detail : '인증에 실패했습니다.',
        code: title.isNotEmpty ? title : 'unauthorized',
        originalException: e,
      ),
      403 => AuthException(
        message: detail.isNotEmpty ? detail : '접근 권한이 없습니다.',
        code: title.isNotEmpty ? title : 'forbidden',
        originalException: e,
      ),
      404 => ServerException(
        message: detail.isNotEmpty ? detail : '요청한 리소스를 찾을 수 없습니다.',
        code: title.isNotEmpty ? title : 'not-found',
        originalException: e,
      ),
      409 => ServerException(
        message: detail.isNotEmpty ? detail : '요청이 현재 상태와 충돌합니다.',
        code: title.isNotEmpty ? title : 'conflict',
        originalException: e,
      ),
      _ => NetworkException(
        message: detail.isNotEmpty ? detail : '네트워크 연결을 확인하세요.',
        code: 'network-error',
        originalException: e,
      ),
    };
  }

  static bool _isTimeoutError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }

  static bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError;
  }

  static void _logError(DioException e, ApiErrorResponse? apiError) {
    if (!kDebugMode) return;

    final method = e.requestOptions.method;
    final path = e.requestOptions.path;
    final statusCode = e.response?.statusCode ?? 0;

    if (apiError != null) {
      debugPrint('❌ API 에러 [$statusCode] $method $path');
      debugPrint('   title: ${apiError.title}');
      debugPrint('   detail: ${apiError.detail}');
      debugPrint('   instance: ${apiError.instance}');
    } else {
      debugPrint('❌ API 에러 [$statusCode] $method $path');
      debugPrint('   type: ${e.type}');
      debugPrint('   message: ${e.message}');
    }
  }
}
```

### 4.4 `lib/core/storage/secure_token_storage.dart`

**역할**: JWT 토큰을 `flutter_secure_storage`에 저장. iOS Keychain은 앱 삭제 후에도 데이터가 남기 때문에, `clearTokensIfReinstalled()`로 재설치를 감지해 토큰을 초기화.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'secure_token_storage.g.dart';

/// JWT 토큰 보안 저장소
class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  // ============================================
  // Storage Keys
  // ============================================

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _isNewUserKey = 'is_new_user';

  // ============================================
  // Token 저장
  // ============================================

  /// Access Token과 Refresh Token을 동시에 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    if (kDebugMode) {
      debugPrint('✅ 토큰 저장 완료 (accessToken length: ${accessToken.length})');
    }
  }

  /// 사용자 ID 저장
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  /// 신규 회원 여부 저장
  Future<void> saveIsNewUser(bool value) async {
    await _storage.write(key: _isNewUserKey, value: value ? 'true' : 'false');
  }

  // ============================================
  // Token 조회
  // ============================================

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  /// 신규 회원 여부 조회 (fail-safe: 값 없거나 'true' 아니면 false)
  Future<bool> getIsNewUser() async {
    final value = await _storage.read(key: _isNewUserKey);
    return value == 'true';
  }

  // ============================================
  // Token 삭제
  // ============================================

  /// 모든 토큰 삭제 (로그아웃, 강제 로그아웃 시 호출)
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _isNewUserKey),
    ]);
    if (kDebugMode) {
      debugPrint('✅ 토큰 삭제 완료');
    }
  }

  /// 토큰 존재 여부 확인
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // ============================================
  // 재설치 감지 및 Keychain 초기화 (iOS)
  // ============================================

  static const String _freshInstallKey = 'has_run_before';

  /// 앱 재설치 시 이전 토큰을 삭제
  ///
  /// iOS는 앱 삭제 후에도 Keychain 데이터가 남아있어
  /// 재설치 시 만료된 토큰으로 인증을 시도할 수 있음.
  /// SharedPreferences는 양 플랫폼 모두 앱 삭제 시 제거되므로
  /// 플래그 부재 = 신규 설치로 판단하여 토큰을 초기화.
  ///
  /// **반드시 main()에서 runApp() 전에 호출.**
  Future<void> clearTokensIfReinstalled() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRunBefore = prefs.getBool(_freshInstallKey) ?? false;

    if (!hasRunBefore) {
      await clearTokens();
      await prefs.setBool(_freshInstallKey, true);
      if (kDebugMode) {
        debugPrint('🔄 재설치 감지 — Keychain 토큰 초기화 완료');
      }
    }
  }
}

/// SecureTokenStorage Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
@Riverpod(keepAlive: true)
SecureTokenStorage secureTokenStorage(Ref ref) {
  return SecureTokenStorage();
}
```

### 4.5 `lib/core/network/auth_interceptor.dart`

**역할**: 모든 요청에 토큰 자동 주입 + 401 시 자동 reissue + Lock 기반 동시성 처리.

⚠️ **수정 포인트**: `_publicPaths` 목록(인증 불필요 경로). 프로젝트마다 조정.

```dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_token_storage.dart';
import 'api_error_response.dart';

/// JWT 인증 인터셉터
///
/// 모든 API 요청에 Access Token을 자동으로 주입하고,
/// 401 응답 시 Refresh Token으로 자동 재발급을 시도합니다.
///
/// [QueuedInterceptor]를 사용하여 async 작업(토큰 조회, 재발급)이
/// 완료될 때까지 후속 요청을 큐에 대기시킵니다.
/// 일반 [Interceptor]는 async void 문제로 토큰 주입 전에 요청이 전송될 수 있습니다.
///
/// **동작 흐름**:
/// 1. `onRequest`: Authorization 헤더에 Bearer Token 주입
/// 2. `onError` (401): refreshToken으로 `/api/auth/reissue` 호출
///    - 성공: 새 토큰 저장 → 원래 요청 재시도
///    - 실패: 토큰 삭제 → 강제 로그아웃 콜백 실행
class AuthInterceptor extends QueuedInterceptor {
  final SecureTokenStorage _tokenStorage;

  /// 토큰 재발급 및 재시도 전용 Dio (인터셉터 없음)
  ///
  /// reissue API 호출 시 AuthInterceptor를 타지 않도록
  /// 별도의 plain Dio 인스턴스를 사용합니다.
  /// 이를 통해 reissue 401 시 이중 강제 로그아웃 방지.
  final Dio _plainDio;

  /// 강제 로그아웃 콜백
  ///
  /// 토큰 재발급 실패 시 호출됩니다.
  /// Presentation Layer에서 Firebase 로그아웃 + 로그인 화면 이동을 처리합니다.
  /// [message]: 백엔드 에러 메시지 (RFC 7807 detail) — 로그인 화면에서 스낵바로 표시
  final Future<void> Function({String? message}) onForceLogout;

  AuthInterceptor({
    required SecureTokenStorage tokenStorage,
    required Dio plainDio,
    required this.onForceLogout,
  }) : _tokenStorage = tokenStorage,
       _plainDio = plainDio;

  // ============================================
  // 토큰 자동 주입을 제외할 경로
  // ============================================

  /// 인증 토큰이 불필요한 API 경로
  ///
  /// ⚠️ 프로젝트별로 조정.
  static const List<String> _publicPaths = [
    ApiEndpoints.login,
    ApiEndpoints.reissue,
    // 예: 닉네임 중복 확인, 회원가입 등 인증 전 호출 가능한 경로 추가
  ];

  bool _isPublicPath(String path) {
    return _publicPaths.any((publicPath) => path == publicPath);
  }

  // ============================================
  // QueuedInterceptor Overrides
  // ============================================

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }

    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // reissue API 자체가 401이면 강제 로그아웃
    if (err.requestOptions.path.contains(ApiEndpoints.reissue)) {
      final apiError = ApiErrorResponse.tryParse(err.response?.data);
      await _handleForceLogout(message: apiError?.detail);
      return handler.next(err);
    }

    if (_isPublicPath(err.requestOptions.path)) {
      return handler.next(err);
    }

    // 이미 재시도한 요청이 다시 401이면 무한 루프 방지 → 강제 로그아웃
    if (err.requestOptions.extra['_isRetry'] == true) {
      await _handleForceLogout();
      return handler.next(err);
    }

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        await _handleForceLogout();
        return handler.next(err);
      }

      if (kDebugMode) {
        debugPrint('🔑 [Reissue] 토큰 재발급 요청 시작');
      }

      // /api/auth/reissue 호출 (plain Dio 사용 — 인터셉터 재진입 방지)
      final response = await _plainDio.post(
        ApiEndpoints.reissue,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final tokens = response.data['tokens'] as Map<String, dynamic>?;
        final newAccessToken = tokens?['accessToken'] as String?;
        final newRefreshToken = tokens?['refreshToken'] as String?;

        if (newAccessToken == null || newRefreshToken == null) {
          await _handleForceLogout();
          return handler.next(err);
        }

        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        if (kDebugMode) {
          debugPrint('🔄 토큰 재발급 성공');
        }

        // 원래 요청 재시도
        final retryResponse = await _retryRequest(
          err.requestOptions,
          newAccessToken,
        );
        return handler.resolve(retryResponse);
      } else {
        await _handleForceLogout();
        return handler.next(err);
      }
    } catch (e) {
      String? errorDetail;
      if (e is DioException) {
        errorDetail = ApiErrorResponse.tryParse(e.response?.data)?.detail;
        if (kDebugMode) {
          debugPrint('❌ [Reissue] 토큰 재발급 실패: ${e.response?.statusCode}');
        }
      }
      await _handleForceLogout(message: errorDetail);
      return handler.next(err);
    }
  }

  // ============================================
  // Private Methods
  // ============================================

  /// 원래 요청을 새 토큰으로 재시도
  ///
  /// [_plainDio]를 사용하여 QueuedInterceptor 큐 교착 상태를 방지.
  /// _plainDio에는 AuthInterceptor가 없으므로 무한 루프 위험 없음.
  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    final retryOptions = requestOptions.copyWith(
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken',
      },
    );
    return await _plainDio.fetch(retryOptions);
  }

  /// 강제 로그아웃 처리
  Future<void> _handleForceLogout({String? message}) async {
    if (kDebugMode) {
      debugPrint('🚨 강제 로그아웃 실행${message != null ? ' (사유: $message)' : ''}');
    }
    await _tokenStorage.clearTokens();
    await onForceLogout(message: message);
  }
}
```

### 4.6 `lib/core/network/dio_client.dart`

**역할**: Dio 인스턴스 생성 + Interceptor 와이어업 + 강제 로그아웃 콜백 슬롯 제공.

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env_config.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';

part 'dio_client.g.dart';

/// 강제 로그아웃 콜백 함수 타입
typedef ForceLogoutFn = Future<void> Function({String? message});

/// 강제 로그아웃 시 사용자에게 표시할 메시지
///
/// reissue 실패 시 백엔드 에러 detail을 저장.
/// 로그인 화면에서 1회 소비(consume) 후 null로 초기화.
final forceLogoutMessageProvider = StateProvider<String?>((ref) => null);

/// 강제 로그아웃 콜백 Provider
///
/// auth 모듈에서 구체적인 로그아웃 동작을 등록.
/// core 모듈이 feature 모듈에 의존하지 않기 위한 역전 패턴.
@Riverpod(keepAlive: true)
class ForceLogoutCallbackNotifier extends _$ForceLogoutCallbackNotifier {
  @override
  ForceLogoutFn? build() => null;

  void register(ForceLogoutFn callback) {
    state = callback;
  }

  void unregister() {
    state = null;
  }
}

/// Dio Provider (AuthInterceptor 포함)
///
/// 앱 생애주기 동안 유지 (keepAlive).
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);

  return DioClient.create(
    tokenStorage: tokenStorage,
    onForceLogout: ({String? message}) async {
      final callback = ref.read(forceLogoutCallbackNotifierProvider);
      if (callback != null) {
        await callback(message: message);
      } else {
        debugPrint('🚨 forceLogoutCallback 미등록 — 토큰만 삭제');
        await tokenStorage.clearTokens();
      }
    },
  );
}

class DioClient {
  DioClient._();

  static Dio create({
    required SecureTokenStorage tokenStorage,
    required Future<void> Function({String? message}) onForceLogout,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final dio = Dio(baseOptions);

    // reissue 전용 plain Dio (인터셉터 없음)
    final plainDio = Dio(baseOptions);

    dio.interceptors.addAll([
      AuthInterceptor(
        tokenStorage: tokenStorage,
        plainDio: plainDio,
        onForceLogout: onForceLogout,
      ),
      if (kDebugMode)
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (log) => debugPrint('📡 $log'),
        ),
    ]);

    return dio;
  }
}
```

### 4.7 `lib/core/config/env_config.dart`

**역할**: `.env` 파일 로드 및 환경 변수 접근.

⚠️ **수정 포인트**: 프로젝트별 환경 변수 키 추가/제거.

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 설정 클래스
class EnvConfig {
  EnvConfig._();

  /// .env 파일 초기화 (main()에서 호출 필수)
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  /// 백엔드 API 기본 URL
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }
}
```

### 4.8 `lib/core/constants/api_endpoints.dart`

**역할**: API 엔드포인트 중앙 관리.

⚠️ **수정 포인트**: 전체. 프로젝트별 엔드포인트로 작성. 아래는 auth만 포함된 최소 예시.

```dart
class ApiEndpoints {
  ApiEndpoints._();

  // ============================================
  // Auth API
  // ============================================

  /// 소셜 로그인
  static const String login = '/api/auth/login';

  /// 로그아웃
  static const String logout = '/api/auth/logout';

  /// 토큰 재발급
  static const String reissue = '/api/auth/reissue';

  // 프로젝트별 엔드포인트는 여기 아래에 추가...
}
```

### 4.9 `lib/features/auth/domain/entities/auth_result_entity.dart`

**역할**: 로그인 결과 도메인 엔티티.

⚠️ **수정 포인트**: 프로젝트가 추가로 필요한 필드(예: `requiresAgreement`) 추가.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result_entity.freezed.dart';

/// 로그인 결과 엔티티
@freezed
class AuthResultEntity with _$AuthResultEntity {
  const factory AuthResultEntity({
    required int userId,
    required String nickname,
    required bool isNewUser,
  }) = _AuthResultEntity;
}
```

### 4.10 `lib/features/auth/domain/repositories/auth_repository.dart`

**역할**: Repository 인터페이스.

```dart
import '../entities/auth_result_entity.dart';

/// Auth Repository 인터페이스
abstract class AuthRepository {
  /// 소셜 로그인 (Google)
  Future<AuthResultEntity> signInWithGoogle();

  /// 소셜 로그인 (Apple). Apple 미지원 시 제거.
  Future<AuthResultEntity> signInWithApple();

  /// 로그아웃
  Future<void> signOut();
}
```

### 4.11 `lib/features/auth/domain/utils/firebase_auth_error_handler.dart`

**역할**: Firebase 에러 코드 → 사용자 친화적 메시지 변환.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';

class FirebaseAuthErrorHandler {
  FirebaseAuthErrorHandler._();

  static String getErrorMessage(String errorCode, {String? provider}) {
    switch (errorCode) {
      case 'user-not-found':
        return '로그인 정보를 가져올 수 없습니다. 다시 시도해주세요.';
      case 'token-not-available':
        return '인증 토큰 발급에 실패했습니다. 다시 시도해주세요.';
      case 'token-validation-failed':
        return 'Firebase 인증 토큰 검증에 실패했습니다. 다시 로그인해주세요.';
      case 'ERROR_ABORTED_BY_USER':
        return '로그인이 취소되었습니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'invalid-credential':
        return '잘못된 인증 정보입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이 로그인 방법은 현재 사용할 수 없습니다.';
      case 'firebase-api-key-invalid':
        return 'Firebase 설정에 문제가 있습니다. 잠시 후 다시 시도해주세요.';
      case 'internal-error':
        return 'Firebase 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        if (provider != null) {
          return '$provider 로그인에 실패했습니다. 다시 시도해주세요.';
        }
        return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
  }

  static AuthException createAuthException(
    FirebaseAuthException e, {
    String? customMessage,
    String? provider,
  }) {
    String errorCode = e.code;

    if (e.code == 'internal-error' && _isApiKeyError(e)) {
      errorCode = 'firebase-api-key-invalid';
      if (kDebugMode) {
        debugPrint('🔥 Firebase API Key 에러 감지 — google-services.json / GoogleService-Info.plist 확인');
      }
    }

    return AuthException(
      message: customMessage ?? getErrorMessage(errorCode, provider: provider),
      code: errorCode,
      originalException: e,
    );
  }

  static bool _isApiKeyError(FirebaseAuthException e) {
    final message = e.message?.toLowerCase() ?? '';
    return message.contains('api key') || message.contains('api_key_invalid');
  }
}
```

### 4.12 `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

**역할**: Firebase Auth + Google/Apple Sign-In 통합. Apple 미사용 시 해당 메서드와 import 제거.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Firebase Auth State Stream (GoRouter refreshListenable용)
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Google 로그인 수행
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Apple 로그인 수행. 미지원 시 이 메서드와 sign_in_with_apple import 제거.
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      // 사용자 취소 → Firebase 에러 코드로 변환
      if (e.code == AuthorizationErrorCode.canceled ||
          e.code == AuthorizationErrorCode.unknown) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  User? get currentUser => _firebaseAuth.currentUser;

  /// Firebase ID Token (백엔드 인증용)
  Future<String> getIdToken({bool forceRefresh = false}) async {
    final User? user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user is currently signed in',
      );
    }

    final String? idToken = await user.getIdToken(forceRefresh);

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'token-not-available',
        message: 'Failed to retrieve Firebase ID Token',
      );
    }

    return idToken;
  }
}
```

### 4.13 `lib/features/auth/data/datasources/auth_remote_datasource.dart`

**역할**: 백엔드 Auth API Retrofit 클라이언트.

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/logout_request_model.dart';
import '../models/token_reissue_request_model.dart';
import '../models/token_reissue_response_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  /// 소셜 로그인
  @POST(ApiEndpoints.login)
  Future<LoginResponseModel> login(@Body() LoginRequestModel request);

  /// 로그아웃 (응답 본문 없음, 204)
  @POST(ApiEndpoints.logout)
  Future<void> logout(@Body() LogoutRequestModel request);

  /// 토큰 재발급
  @POST(ApiEndpoints.reissue)
  Future<TokenReissueResponseModel> reissue(
    @Body() TokenReissueRequestModel request,
  );
}
```

### 4.14 `lib/features/auth/data/models/login_request_model.dart`

⚠️ **수정 포인트**: 백엔드가 요구하는 필드만. 이 프로젝트는 `fcmToken`/`deviceType`/`deviceId`까지 요구하지만, 새 프로젝트는 보통 더 단순함.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_model.freezed.dart';
part 'login_request_model.g.dart';

/// 소셜 로그인 요청 DTO
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    /// 소셜 플랫폼 (`GOOGLE`, `APPLE`)
    required String socialPlatform,

    /// Firebase ID Token
    required String idToken,

    // 프로젝트별 추가 필드 예시 (필요한 경우만)
    // required String fcmToken,
    // required String deviceType,
    // required String deviceId,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
}
```

### 4.15 `lib/features/auth/data/models/login_response_model.dart`

⚠️ **수정 포인트**: 백엔드 응답 스키마에 맞춰 필드 조정. **`tokens`는 nested 필수** (AuthInterceptor가 `response.data['tokens']`를 읽음).

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_model.freezed.dart';
part 'login_response_model.g.dart';

/// 소셜 로그인 응답 DTO
///
/// 응답 예시:
/// ```json
/// {
///   "userId": 1,
///   "nickname": "홍길동",
///   "tokens": {
///     "accessToken": "eyJhbG...",
///     "refreshToken": "eyJhbG..."
///   },
///   "isNewUser": false
/// }
/// ```
@freezed
class LoginResponseModel with _$LoginResponseModel {
  const factory LoginResponseModel({
    required int userId,
    required String nickname,
    required TokensModel tokens,
    required bool isNewUser,
  }) = _LoginResponseModel;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
}

/// JWT 토큰 페어 DTO
@freezed
class TokensModel with _$TokensModel {
  const factory TokensModel({
    required String accessToken,
    required String refreshToken,
  }) = _TokensModel;

  factory TokensModel.fromJson(Map<String, dynamic> json) =>
      _$TokensModelFromJson(json);
}
```

### 4.16 `lib/features/auth/data/models/token_reissue_request_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_reissue_request_model.freezed.dart';
part 'token_reissue_request_model.g.dart';

@freezed
class TokenReissueRequestModel with _$TokenReissueRequestModel {
  const factory TokenReissueRequestModel({
    required String refreshToken,
  }) = _TokenReissueRequestModel;

  factory TokenReissueRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TokenReissueRequestModelFromJson(json);
}
```

### 4.17 `lib/features/auth/data/models/token_reissue_response_model.dart`

⚠️ **주의**: 응답이 nested 구조 (`{tokens: {...}}`). flat이 아님.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'login_response_model.dart';

part 'token_reissue_response_model.freezed.dart';
part 'token_reissue_response_model.g.dart';

/// 토큰 재발급 응답 DTO
///
/// 응답 예시:
/// ```json
/// {
///   "tokens": {
///     "accessToken": "eyJhbG...",
///     "refreshToken": "eyJhbG..."
///   }
/// }
/// ```
@freezed
class TokenReissueResponseModel with _$TokenReissueResponseModel {
  const factory TokenReissueResponseModel({
    required TokensModel tokens,
  }) = _TokenReissueResponseModel;

  factory TokenReissueResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenReissueResponseModelFromJson(json);
}
```

### 4.18 `lib/features/auth/data/models/logout_request_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_request_model.freezed.dart';
part 'logout_request_model.g.dart';

@freezed
class LogoutRequestModel with _$LogoutRequestModel {
  const factory LogoutRequestModel({
    required String refreshToken,
  }) = _LogoutRequestModel;

  factory LogoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestModelFromJson(json);
}
```

### 4.19 `lib/features/auth/data/repositories/auth_repository_impl.dart`

⚠️ **수정 포인트**: `_performSocialLogin`에서 `LoginRequestModel`에 주입할 필드. 프로젝트가 FCM/DeviceId를 요구하면 여기서 주입.

```dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth Repository 구현체
///
/// Firebase Auth + 백엔드 API를 조합하여 인증 흐름을 처리.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;
  final SecureTokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource firebaseAuthDataSource,
    required AuthRemoteDataSource authRemoteDataSource,
    required SecureTokenStorage tokenStorage,
  }) : _firebaseAuthDataSource = firebaseAuthDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _tokenStorage = tokenStorage;

  @override
  Future<AuthResultEntity> signInWithGoogle() async {
    return _performSocialLogin(
      provider: 'GOOGLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithGoogle(),
    );
  }

  @override
  Future<AuthResultEntity> signInWithApple() async {
    return _performSocialLogin(
      provider: 'APPLE',
      firebaseSignIn: () => _firebaseAuthDataSource.signInWithApple(),
    );
  }

  /// 소셜 로그인 공통 로직
  Future<AuthResultEntity> _performSocialLogin({
    required String provider,
    required Future<dynamic> Function() firebaseSignIn,
  }) async {
    try {
      // 1. Firebase 소셜 로그인
      await firebaseSignIn();

      // 2. Firebase ID Token 획득
      final idToken = await _firebaseAuthDataSource.getIdToken();

      // 3. 백엔드 로그인 API 호출
      // ⚠️ 프로젝트별: LoginRequestModel에 fcmToken/deviceId 등 추가 필드 주입
      final response = await _authRemoteDataSource.login(
        LoginRequestModel(
          socialPlatform: provider,
          idToken: idToken,
        ),
      );

      // 4. JWT 토큰 + 메타정보 저장
      await _tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );
      await _tokenStorage.saveUserId(response.userId);
      await _tokenStorage.saveIsNewUser(response.isNewUser);

      if (kDebugMode) {
        debugPrint('✅ 백엔드 로그인 성공 ($provider) — userId=${response.userId}');
      }

      return AuthResultEntity(
        userId: response.userId,
        nickname: response.nickname,
        isNewUser: response.isNewUser,
      );
    } on DioException catch (e) {
      // 백엔드 호출 실패 → Firebase 세션 정리 (재로그인 가능 상태로)
      await _cleanupFirebaseSession(provider);
      throw DioExceptionHandler.handle(e);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ERROR_ABORTED_BY_USER') {
        throw const AuthCancelledException();
      }
      throw AuthException(message: '로그인 중 오류가 발생했습니다.', originalException: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: '로그인 중 오류가 발생했습니다.', originalException: e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // 1. 백엔드 로그아웃 (refreshToken 전달)
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          await _authRemoteDataSource.logout(
            LogoutRequestModel(refreshToken: refreshToken),
          );
        } catch (e) {
          // 백엔드 로그아웃 실패해도 로컬 정리는 계속 진행
          debugPrint('⚠️ 백엔드 로그아웃 실패 (무시하고 계속 진행): $e');
        }
      }

      // 2. Firebase 로그아웃
      await _firebaseAuthDataSource.signOut();

      // 3. 로컬 토큰 삭제
      await _tokenStorage.clearTokens();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(message: '로그아웃 중 오류가 발생했습니다.', originalException: e);
    }
  }

  Future<void> _cleanupFirebaseSession(String provider) async {
    try {
      await _firebaseAuthDataSource.signOut();
    } catch (_) {}
  }
}
```

### 4.20 `lib/features/auth/presentation/providers/auth_provider.dart`

⚠️ **수정 포인트**: `build()` 안의 cold-start 복원 로직(주석 표시). 프로젝트별로 약관/프로필 조회 등 추가.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/utils/firebase_auth_error_handler.dart';

part 'auth_provider.g.dart';

// ============================================================================
// Core Infrastructure Providers
// ============================================================================

@Riverpod(keepAlive: true)
FirebaseAuthDataSource firebaseAuthDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

// ============================================================================
// Data Layer Providers
// ============================================================================

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSource(dio);
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    firebaseAuthDataSource: ref.watch(firebaseAuthDataSourceProvider),
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
}

// ============================================================================
// Auth State Stream (GoRouter refreshListenable용)
// ============================================================================

@riverpod
Stream<User?> authState(Ref ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return dataSource.authStateChanges();
}

// ============================================================================
// Auth Notifier
// ============================================================================

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
      if (!hasTokens) return null;

      final userId = await tokenStorage.getUserId();
      if (userId == null) {
        debugPrint('[AuthNotifier] userId 없음 → 세션 초기화');
        try {
          await dataSource.signOut();
        } catch (_) {}
        await tokenStorage.clearTokens();
        return null;
      }

      // ⚠️ 프로젝트별 cold-start 복원:
      // 약관 동의 상태, 백엔드 프로필 조회 등 여기서 처리.
      // 각 조회는 독립적으로 실패를 허용하여 한쪽이 실패해도 다른 값은 반영.

      final isNewUser = await tokenStorage.getIsNewUser();

      return AuthResultEntity(
        userId: userId,
        nickname: currentUser.displayName ?? '',
        isNewUser: isNewUser,
      );
    }

    return null;
  }

  /// Google 로그인 수행
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
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
    }
  }

  /// Apple 로그인 수행. Apple 미지원 시 제거.
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final result = await ref.read(authRepositoryProvider).signInWithApple();
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
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        AuthException(message: '로그아웃에 실패했습니다.', originalException: e),
        stack,
      );
    }
  }

  /// 강제 로그아웃 (AuthInterceptor에서 호출)
  ///
  /// 토큰 재발급 실패 시 state를 null로 초기화하여
  /// GoRouter가 로그인 화면으로 리다이렉트하도록 유도.
  ///
  /// ⚠️ 프로젝트별: 전역 캐시, 튜토리얼 플래그 등 정리 추가.
  void forceLogout() {
    state = const AsyncValue.data(null);
  }
}
```

---

## 5. Setup Steps (순서대로)

### 5.1 의존성 추가

`pubspec.yaml`에 §2의 dependencies/dev_dependencies 복붙 후:

```bash
flutter pub get
```

### 5.2 `.env` 파일

프로젝트 루트에 `.env` 생성:

```
API_BASE_URL=https://your-api-domain.com
```

`.gitignore`에 `.env` 추가 (이미 있어야 정상).

### 5.3 파일 복사

§4의 모든 파일을 정확한 경로에 생성.

### 5.4 Firebase 연결

- Android: `android/app/google-services.json` 다운로드 후 배치
- iOS: `ios/Runner/GoogleService-Info.plist` 다운로드 후 Xcode에 추가
- iOS Apple 로그인: Xcode → Signing & Capabilities → "Sign In with Apple" 추가

### 5.5 `main.dart` 초기화 순서

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env_config.dart';
import 'core/storage/secure_token_storage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. .env 로드 (가장 먼저 — 다른 코드가 EnvConfig.apiBaseUrl 참조하기 전)
  await EnvConfig.initialize();

  // 2. Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. iOS 재설치 시 Keychain 잔존 토큰 정리
  await SecureTokenStorage().clearTokensIfReinstalled();

  // 4. Riverpod 컨테이너로 앱 시작
  runApp(const ProviderScope(child: MyApp()));
}
```

### 5.6 코드 생성

```bash
dart run build_runner build --delete-conflicting-outputs
```

다음 파일들이 생성되어야 함:
- `secure_token_storage.g.dart`
- `dio_client.g.dart`
- `auth_remote_datasource.g.dart`
- `auth_provider.g.dart`
- `login_request_model.{freezed,g}.dart`
- `login_response_model.{freezed,g}.dart`
- `token_reissue_request_model.{freezed,g}.dart`
- `token_reissue_response_model.{freezed,g}.dart`
- `logout_request_model.{freezed,g}.dart`
- `auth_result_entity.freezed.dart`

### 5.7 GoRouter redirect 설정 (예시)

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(
    ref.watch(authStateProvider.stream),
  ),
  redirect: (context, state) {
    final authResult = ref.read(authNotifierProvider).valueOrNull;
    final isLoginPage = state.matchedLocation == '/login';

    // 미인증 → 로그인 화면
    if (authResult == null && !isLoginPage) {
      return '/login';
    }

    // 인증됨 + 로그인 화면 → 홈
    if (authResult != null && isLoginPage) {
      return '/home';
    }

    return null;
  },
  routes: [
    // ...
  ],
);
```

### 5.8 동작 확인

새 프로젝트에서:
1. 로그인 → SecureStorage에 토큰 저장 확인 (Android: `adb shell run-as <pkg> ls /data/data/<pkg>/shared_prefs/`)
2. 백엔드에서 access token 만료 후 보호 API 호출 → reissue 자동 발생 → 원래 요청 재시도 성공
3. refresh token까지 만료 → 강제 로그아웃 → 로그인 화면으로 이동

---

## 6. Per-Project Customization Checklist

새 프로젝트에서 반드시 손봐야 하는 곳:

- [ ] **`.env`**: `API_BASE_URL` 값을 새 백엔드로
- [ ] **`api_endpoints.dart`**: `login` / `logout` / `reissue` 경로 확인. 백엔드가 다른 경로 쓰면 변경
- [ ] **`auth_interceptor.dart` `_publicPaths`**: 인증 불필요 경로 목록 (회원가입, 닉네임 중복확인 등 추가)
- [ ] **`login_request_model.dart`**: 백엔드가 요구하는 필드만 (FCM 토큰, 디바이스 ID 등 추가/제거)
- [ ] **`login_response_model.dart`**: 백엔드 응답 스키마와 1:1 매칭. **`tokens` nested 구조는 유지.**
- [ ] **`token_reissue_response_model.dart`**: 응답이 nested인지 flat인지 확인. flat이면 `AuthInterceptor.onError`의 파싱 로직(`response.data['tokens']`)도 같이 변경
- [ ] **`auth_result_entity.dart`**: 프로젝트가 추가로 필요한 필드 (`requiresAgreement` 등) 추가
- [ ] **`auth_repository_impl.dart` `_performSocialLogin`**: `LoginRequestModel`에 주입할 필드 (FCM/DeviceId 필요 시 호출 추가)
- [ ] **`auth_provider.dart` `build()`**: cold-start 시 추가 복원 로직 (백엔드 프로필 조회, 약관 상태 조회 등)
- [ ] **`auth_provider.dart` `forceLogout()`**: 강제 로그아웃 시 추가 정리 (튜토리얼 플래그, 전역 캐시 등)
- [ ] **GoRouter redirect**: 인증 상태에 따른 라우팅 정책
- [ ] **Apple 로그인 미사용 시**: `firebase_auth_datasource.dart`에서 Apple 메서드와 `sign_in_with_apple` import 제거. `auth_repository.dart`/`auth_repository_impl.dart`/`auth_provider.dart`의 `signInWithApple` 메서드도 제거. `pubspec.yaml`에서 `sign_in_with_apple` 제거

---

## 7. Common Gotchas

### 7.1 `retrofit: 4.7.3` 핀
4.9.x 버전에서 `ParseErrorLogger.logError` 시그니처가 4개 인자로 바뀜. 하지만 `retrofit_generator`가 3개만 넘겨서 빌드 실패. **반드시 `4.7.3`으로 고정.**

### 7.2 Reissue 응답 nested 구조
재발급 응답이 `{accessToken, refreshToken}` 평탄 구조가 아니라 `{tokens: {accessToken, refreshToken}}` 중첩 구조여야 함.
- `AuthInterceptor.onError`가 `response.data['tokens']`로 파싱
- 백엔드가 평탄 구조로 내려주면 `auth_interceptor.dart`의 파싱 로직과 `token_reissue_response_model.dart`/`login_response_model.dart`를 같이 수정

### 7.3 autoDispose Provider + 비동기 작업
`@riverpod`는 기본 autoDispose. 401 reissue처럼 긴 비동기 중에 UI에서 provider 구독이 끊기면 dispose되어 죽은 ref 접근으로 crash 가능. **UI의 `build()`에서 `ref.watch(authNotifierProvider)`를 유지하거나, 핵심 인프라는 `keepAlive: true`로 선언.**

### 7.4 `forceLogoutCallback` 등록 시점
`AuthNotifier.build()` 안의 `Future.microtask` 블록이 등록 책임을 갖는다. `build()` 동기 코드에서 직접 등록하면 Riverpod이 "build() 중 다른 provider 수정 금지"로 에러를 발생시킴. **microtask로 한 틱 미루는 패턴 유지.**

### 7.5 `_plainDio` (인터셉터 없는 별도 Dio)
- reissue 호출 자체가 Interceptor를 다시 타지 않게
- 재시도 요청도 `_plainDio.fetch(retryOptions)`로 보내서 QueuedInterceptor 큐 교착 방지

이 두 역할을 같은 인스턴스가 담당. 인스턴스를 분리하거나 메인 Dio로 갈아끼우면 무한 루프나 데드락 발생.

### 7.6 iOS Keychain 재설치 잔존
iOS는 앱을 삭제해도 Keychain의 토큰이 남음. `SecureTokenStorage.clearTokensIfReinstalled()`를 `main()`에서 `runApp()` 전에 호출해야 함. SharedPreferences는 양 플랫폼 모두 앱 삭제 시 지워지므로 "플래그 부재 = 신규 설치"로 판단.

### 7.7 `build_runner` 빠뜨림
어노테이션(`@riverpod`, `@freezed`, `@RestApi`, `@JsonSerializable`)을 추가/수정한 뒤에는 항상:
```bash
dart run build_runner build --delete-conflicting-outputs
```
"part 'xxx.g.dart' not found" 에러는 거의 다 이거 안 돌려서 생김.

### 7.8 동시 401 처리
`Interceptor` 대신 `QueuedInterceptor`를 쓰는 이유 — 일반 `Interceptor`는 async void 문제로 토큰 주입 전에 후속 요청이 출발 가능. `QueuedInterceptor`는 onRequest의 async 작업이 끝날 때까지 큐잉. 동시에 401 받은 여러 요청이 단 한 번의 reissue를 공유하는 동작도 큐잉으로 자연스럽게 보장됨.

### 7.9 Repository에서 에러 처리
모든 `DioException`은 `DioExceptionHandler.handle(e)` 한 줄로만 변환:
```dart
try {
  final response = await _api.someApi(request);
  return SomeEntity(...);
} on DioException catch (e) {
  throw DioExceptionHandler.handle(e);
}
```
직접 status code 분기하지 말 것 — 변환 로직이 흩어져 일관성 깨짐.

---

## 8. 최소 검증 시나리오

새 프로젝트에 setup 후 아래 4개 시나리오를 직접 돌려보면 안전:

1. **정상 로그인** — 로그인 후 SecureStorage에 access/refresh 토큰 저장됐는지 (디버그 로그로 확인)
2. **자동 토큰 주입** — 로그인 후 보호 API 호출 → Authorization 헤더가 자동으로 붙는지 (LogInterceptor 출력 확인)
3. **자동 reissue** — 백엔드에서 인위적으로 access token 만료 → 보호 API 호출 → reissue 후 원래 요청이 재시도되어 성공하는지
4. **강제 로그아웃** — refresh token도 만료 → 보호 API 호출 → reissue 실패 → 토큰 삭제 → 로그인 화면으로 자동 이동

이 4개가 통과하면 인프라 부분은 사실상 동작 보증.
