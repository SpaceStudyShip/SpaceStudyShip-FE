# Auth 파일 통합 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 외부에서 가져온 Auth Clean Architecture 파일들을 현재 프로젝트에서 `flutter analyze` 에러 없이 동작하도록 수정

**Architecture:** 가져온 파일들 자체는 잘 작성되어 있으나, 현재 프로젝트와 3가지 불일치가 있음: (1) `api_endpoints.dart` 파일 누락, (2) `firebase_auth` / `sign_in_with_apple` 패키지 미설치 + `google_sign_in` v7 API 비호환, (3) `EnvConfig` getter 이름 불일치

**Tech Stack:** Flutter, Dio, Retrofit, Firebase Auth, Google Sign-In, flutter_dotenv

---

## 현재 에러 요약 (flutter analyze)

| # | 에러 원인 | 영향 파일 수 | 에러 수 |
|---|----------|------------|--------|
| 1 | `api_endpoints.dart` 파일 없음 | 2개 (auth_interceptor, auth_remote_datasource) | 9개 |
| 2 | `firebase_auth` 패키지 미설치 | 2개 (firebase_auth_datasource, firebase_auth_error_handler) | ~25개 |
| 3 | `sign_in_with_apple` 패키지 미설치 | 1개 (firebase_auth_datasource) | ~5개 |
| 4 | `google_sign_in` v7 API 비호환 | 1개 (firebase_auth_datasource) | ~5개 |
| 5 | `EnvConfig.apiBaseUrl` getter 없음 | 1개 (dio_client) | 1개 |

---

## Task 1: `api_endpoints.dart` 생성

**Files:**
- Create: `lib/core/constants/api_endpoints.dart`

**Step 1: 엔드포인트 사용처 확인**

현재 코드에서 `ApiEndpoints`를 참조하는 곳:
- `auth_interceptor.dart`: `ApiEndpoints.login`, `ApiEndpoints.reissue`, `ApiEndpoints.checkNickname`
- `auth_remote_datasource.dart`: `ApiEndpoints.login`, `ApiEndpoints.logout`, `ApiEndpoints.reissue`

**Step 2: 파일 생성**

```dart
/// API 엔드포인트 상수
///
/// 백엔드 Spring Boot API의 모든 엔드포인트를 중앙에서 관리합니다.
/// Retrofit DataSource와 AuthInterceptor에서 참조합니다.
abstract class ApiEndpoints {
  // ============================================
  // Auth
  // ============================================
  static const login = '/api/auth/login';
  static const logout = '/api/auth/logout';
  static const reissue = '/api/auth/reissue';
  static const withdraw = '/api/auth/withdraw';
  static const checkNickname = '/api/auth/check-nickname';
}
```

**Step 3: 검증**

Run: `grep -r "ApiEndpoints" lib/ --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"`
Expected: 3개 파일에서 모두 동일한 import path로 참조

---

## Task 2: `pubspec.yaml` 패키지 추가 + 버전 수정

**Files:**
- Modify: `pubspec.yaml`

**Step 1: 패키지 추가/수정**

변경사항:
```yaml
# 추가
firebase_auth: ^5.5.0          # Firebase 인증 (Google/Apple 소셜 로그인)
sign_in_with_apple: ^7.0.1     # Apple 소셜 로그인

# 수정 (v7 → v6, 기존 코드 API 호환)
google_sign_in: ^6.2.1         # Was: ^7.2.0
```

**Step 2: 패키지 설치**

Run: `flutter pub get`
Expected: 의존성 충돌 없이 설치 완료

> **참고:** `google_sign_in ^7.2.0`은 완전히 새로운 stream 기반 API로, 가져온 `firebase_auth_datasource.dart` 코드와 호환되지 않음. v6으로 다운그레이드하여 기존 `.signIn()` → `UserCredential` 패턴 유지.

---

## Task 3: `env_config.dart` 수정

**Files:**
- Modify: `lib/core/config/env_config.dart`

**Step 1: dotenv 연동 + apiBaseUrl getter 추가**

변경사항:
1. `flutter_dotenv` import 추가
2. `initialize()`에서 `dotenv.load()` 호출
3. `_apiUrl`을 dotenv `API_BASE_URL`에서 읽도록 변경
4. `static String get apiBaseUrl` getter 추가 (`dio_client.dart`에서 사용)
5. `static bool get useMockApi` getter 추가 (Mock API 인터셉터용)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String? _apiUrl;
  static String? _webSocketUrl;
  static bool _isInitialized = false;

  /// API Base URL (DioClient에서 사용)
  static String get apiBaseUrl => _apiUrl ?? '';

  /// API Base URL (기존 호환)
  static String get apiUrl => _apiUrl ?? '';

  /// WebSocket URL
  static String get webSocketUrl => _webSocketUrl ?? '';

  /// Mock API 사용 여부
  static bool get useMockApi {
    final value = dotenv.env['USE_MOCK_API'] ?? 'false';
    return value.toLowerCase() == 'true';
  }

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ [EnvConfig] 이미 초기화되었습니다.');
      return;
    }

    try {
      debugPrint('🔧 [EnvConfig] 환경 설정 초기화 시작...');

      // .env 파일 로드
      await dotenv.load(fileName: '.env');

      // 환경 변수에서 읽기 (없으면 기본값)
      _apiUrl = dotenv.env['API_BASE_URL'] ?? _getDefaultApiUrl();
      _webSocketUrl = _getDefaultWebSocketUrl();

      _isInitialized = true;
      debugPrint('✅ [EnvConfig] 환경 설정 초기화 완료');
      debugPrint('📡 [EnvConfig] API URL: $_apiUrl');
      debugPrint('📡 [EnvConfig] Mock API: ${useMockApi}');
    } catch (e, stackTrace) {
      debugPrint('❌ [EnvConfig] 환경 설정 초기화 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      _apiUrl = _getDefaultApiUrl();
      _webSocketUrl = _getDefaultWebSocketUrl();
      _isInitialized = true;
    }
  }

  // ... (기존 _getDefaultApiUrl, _getDefaultWebSocketUrl, reset 유지)
}
```

---

## Task 4: `build_runner` 실행

**Step 1: 코드 생성**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

Expected: `auth_remote_datasource.g.dart` 재생성 (ApiEndpoints import 반영)

---

## Task 5: `flutter analyze` 검증

**Step 1: 정적 분석 실행**

Run: `flutter analyze`
Expected: 0 errors

---

## 참고: 변경하지 않는 파일들

아래 파일들은 현재 상태 그대로 유지 (이미 올바름):
- `lib/core/errors/app_exception.dart` ✅
- `lib/core/errors/failure.dart` ✅
- `lib/core/network/api_error_response.dart` ✅
- `lib/core/network/dio_exception_handler.dart` ✅
- `lib/core/network/auth_interceptor.dart` ✅ (api_endpoints.dart 생성으로 해결)
- `lib/core/network/dio_client.dart` ✅ (EnvConfig.apiBaseUrl 추가로 해결)
- `lib/core/storage/secure_token_storage.dart` ✅
- `lib/core/services/device/device_id_manager.dart` ✅
- `lib/core/services/device/device_info_service.dart` ✅
- `lib/features/auth/domain/**` (전체) ✅
- `lib/features/auth/data/models/**` (전체) ✅
- `lib/features/auth/data/repositories/auth_repository_impl.dart` ✅
- `lib/features/auth/data/datasources/firebase_auth_datasource.dart` ✅ (패키지 설치로 해결)
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` ✅ (api_endpoints.dart 생성으로 해결)
