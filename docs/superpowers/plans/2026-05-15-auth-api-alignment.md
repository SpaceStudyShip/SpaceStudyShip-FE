# Auth API 계약 정렬 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Auth 도메인 Data/Domain Layer 를 `docs/api-docs.json` (OpenAPI 3.1) 의 6개 엔드포인트 계약에 1:1 정렬하고, 신규 3개 API(닉네임 변경/중복 확인/회원 탈퇴) 를 도입한다.

**Architecture:** 빅뱅 마이그레이션 — 한 PR 내에서 (1) ErrorResponse 스키마를 RFC 7807 → `{code, message}` 로 전환, (2) LoginRequest 를 5필드로 확장, (3) AuthInterceptor 의 `_publicPaths` 및 reissue 분기 수정, (4) 신규 3 엔드포인트의 모델·DataSource·Repository·UseCase·Provider 추가, (5) `docs/api-specs/*.md` 를 새 계약으로 동기화. 호환성 레이어 없음 — 백엔드가 이미 전환 완료. 각 Task 는 RED→GREEN→REFACTOR TDD 사이클.

**Tech Stack:** Flutter 3.9 · Freezed 2.5 · Riverpod 2.6 Generator · Retrofit 4.7 · Dio 5.9 · `mocktail` (신규 dev_dependency)

**Spec:** `docs/superpowers/specs/2026-05-15-auth-api-alignment-design.md`

---

## File Structure (변경 요약)

### Created
- `lib/features/auth/data/models/update_nickname_request_model.dart`
- `lib/features/auth/data/models/update_nickname_response_model.dart`
- `lib/features/auth/data/models/check_nickname_response_model.dart`
- `lib/features/auth/domain/usecases/update_nickname_usecase.dart`
- `lib/features/auth/domain/usecases/check_nickname_usecase.dart`
- `lib/features/auth/domain/usecases/withdraw_usecase.dart`
- `test/core/network/api_error_response_test.dart`
- `test/core/network/dio_exception_handler_test.dart`
- `test/core/network/auth_interceptor_test.dart`
- `test/features/auth/data/models/login_request_model_test.dart`
- `test/features/auth/data/models/update_nickname_request_model_test.dart`
- `test/features/auth/data/models/update_nickname_response_model_test.dart`
- `test/features/auth/data/models/check_nickname_response_model_test.dart`
- `test/features/auth/data/repositories/auth_repository_impl_test.dart`
- `test/features/auth/domain/usecases/update_nickname_usecase_test.dart`
- `test/features/auth/domain/usecases/check_nickname_usecase_test.dart`
- `test/features/auth/domain/usecases/withdraw_usecase_test.dart`

### Modified
- `pubspec.yaml` (mocktail 추가)
- `lib/core/network/api_error_response.dart` (4필드 → 2필드)
- `lib/core/network/dio_exception_handler.dart` (code switch + 신규 매핑)
- `lib/core/network/auth_interceptor.dart` (publicPaths, reissue 분기, model 파싱, message 필드)
- `lib/core/errors/app_exception.dart` (5 신규 서브타입)
- `lib/features/auth/data/models/login_request_model.dart` (3 필드 추가)
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` (3 신규 메서드)
- `lib/features/auth/data/repositories/auth_repository_impl.dart` (device helper + 3 신규 메서드)
- `lib/features/auth/domain/repositories/auth_repository.dart` (3 신규 메서드)
- `lib/features/auth/presentation/providers/auth_provider.dart` (3 UseCase Provider + 3 AuthNotifier 메서드)
- `docs/api-specs/00_common.md` (에러 포맷 재기재)
- `docs/api-specs/01_auth.md` (LoginRequest 5 필드, 에러 코드 정렬)

---

## Phase Map

| Phase | Tasks | Theme |
|---|---|---|
| P1 인프라 | 1 | mocktail dependency |
| P2 ErrorResponse 스키마 | 2, 3, 4 | ApiErrorResponse + Exception + DioExceptionHandler |
| P3 AuthInterceptor 정리 | 5 | publicPaths + reissue code 분기 + model 파싱 |
| P4 LoginRequest 확장 | 6, 7 | 5필드 모델 + device 정보 helper |
| P5 신규 3 API — Data | 8, 9, 10, 11 | 모델 3개 + DataSource 3 메서드 + Repository 3 메서드 |
| P6 신규 3 API — Domain | 12, 13 | UseCase 3개 + Provider 통합 |
| P7 Doc 동기화 + 통합 | 14, 15, 16 | api-specs/*.md + final verification |

---

## Pre-flight Check (실행 시작 전 1회)

- [ ] **Step A: 작업 브랜치 확인**

```bash
git branch --show-current
```

Expected: `20260423_#71_백엔드_Auth_API_연동_소셜_로그인_토큰_닉네임_탈퇴`

- [ ] **Step B: 워킹 트리 clean 확인**

```bash
git status --short
```

Expected: 출력 비어있음 (단, plan 파일 이미 커밋된 상태라면 OK)

- [ ] **Step C: 빌드 그린 베이스라인**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Expected: build_runner 성공, analyze 0 issue, 모든 기존 테스트 통과

---

### Task 1: mocktail dev_dependency 추가

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: pubspec.yaml 의 dev_dependencies 에 mocktail 추가**

`pubspec.yaml` 의 `dev_dependencies:` 블록에서 `change_app_package_name: ^1.5.0` 줄 바로 다음(같은 들여쓰기 레벨, `flutter_launcher_icons:` 블록 시작 전) 에 추가:

```yaml
  # 테스트용 mocking 라이브러리
  mocktail: ^1.0.4
```

- [ ] **Step 2: 패키지 가져오기**

```bash
flutter pub get
```

Expected: `Got dependencies!` 출력. `mocktail` 항목이 lock 파일에 추가됨.

- [ ] **Step 3: import 가능 확인 — 간단한 sanity test**

`test/widget_test.dart` 와 동일 디렉토리에 임시 파일을 만들지는 않고, 다음 Task 의 테스트에서 `import 'package:mocktail/mocktail.dart';` 가 컴파일되는지 P2 진입 시 확인.

```bash
flutter analyze pubspec.yaml
```

Expected: 0 issue

- [ ] **Step 4: 커밋**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore : mocktail dev_dependency 추가 #71"
```

---

### Task 2: ApiErrorResponse 를 `{code, message}` 스키마로 재정의

**Files:**
- Modify: `lib/core/network/api_error_response.dart` (전체 재작성)
- Create: `test/core/network/api_error_response_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/core/network/api_error_response_test.dart` 신규 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/network/api_error_response.dart';

void main() {
  group('ApiErrorResponse', () {
    test('code 와 message 모두 있는 정상 응답을 파싱한다', () {
      final result = ApiErrorResponse.tryParse({
        'code': 'INVALID_TOKEN',
        'message': '인증 정보가 올바르지 않습니다.',
      });

      expect(result, isNotNull);
      expect(result!.code, 'INVALID_TOKEN');
      expect(result.message, '인증 정보가 올바르지 않습니다.');
    });

    test('code 만 있고 message 누락 시 빈 문자열로 graceful 파싱', () {
      final result = ApiErrorResponse.tryParse({'code': 'X'});

      expect(result, isNotNull);
      expect(result!.code, 'X');
      expect(result.message, '');
    });

    test('message 만 있고 code 누락 시 빈 문자열로 graceful 파싱', () {
      final result = ApiErrorResponse.tryParse({'message': 'Y'});

      expect(result, isNotNull);
      expect(result!.code, '');
      expect(result.message, 'Y');
    });

    test('code 와 message 모두 없으면 null 반환', () {
      expect(ApiErrorResponse.tryParse({}), isNull);
      expect(ApiErrorResponse.tryParse({'title': 'old', 'detail': 'rfc7807'}),
          isNull);
    });

    test('data 가 Map 이 아니면 null 반환', () {
      expect(ApiErrorResponse.tryParse(null), isNull);
      expect(ApiErrorResponse.tryParse('string'), isNull);
      expect(ApiErrorResponse.tryParse([1, 2, 3]), isNull);
    });

    test('toString 은 [code] message 포맷', () {
      const r = ApiErrorResponse(
          code: 'DUPLICATED_NICKNAME', message: '이미 사용 중인 닉네임입니다.');
      expect(r.toString(), '[DUPLICATED_NICKNAME] 이미 사용 중인 닉네임입니다.');
    });
  });
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

```bash
flutter test test/core/network/api_error_response_test.dart
```

Expected: 컴파일 에러 또는 다수 FAIL — 기존 `ApiErrorResponse` 가 `title/status/detail/instance` 4필드 구조라서 `code`/`message` 속성 접근 시 에러.

- [ ] **Step 3: `lib/core/network/api_error_response.dart` 를 새 스키마로 재작성**

```dart
/// 백엔드 공통 에러 응답 모델
///
/// `docs/api-docs.json` 의 ErrorResponse 스키마와 1:1 정렬:
/// ```json
/// {
///   "code": "INVALID_TOKEN",
///   "message": "인증 정보가 올바르지 않습니다."
/// }
/// ```
///
/// 모든 4xx/5xx 응답 본문이 이 형식이며, `DioExceptionHandler` 가
/// `code` 를 기반으로 적절한 `AppException` 서브타입으로 매핑한다.
class ApiErrorResponse {
  /// 에러 식별 코드 (예: INVALID_TOKEN, DUPLICATED_NICKNAME)
  final String code;

  /// 사용자에게 노출 가능한 메시지
  final String message;

  const ApiErrorResponse({required this.code, required this.message});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  /// 응답 데이터에서 안전하게 파싱 시도.
  /// `code` 와 `message` 가 모두 없으면 null 반환 (백엔드 비표준 응답 대비).
  static ApiErrorResponse? tryParse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    if (data['code'] == null && data['message'] == null) return null;
    return ApiErrorResponse.fromJson(data);
  }

  @override
  String toString() => '[$code] $message';
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/core/network/api_error_response_test.dart
```

Expected: 6 tests passed.

- [ ] **Step 5: 빌드는 깨질 것 — 다음 Task 에서 호출자 수정 예정**

```bash
flutter analyze lib/core/network/dio_exception_handler.dart lib/core/network/auth_interceptor.dart
```

Expected: 에러 다수 (apiError.detail, apiError.title, apiError.instance, apiError.status 참조 깨짐). 이는 Task 3 (DioExceptionHandler) 와 Task 5 (AuthInterceptor) 에서 수정.

- [ ] **Step 6: 커밋**

```bash
git add lib/core/network/api_error_response.dart test/core/network/api_error_response_test.dart
git commit -m "feat : ApiErrorResponse 를 code/message 스키마로 재정의 #71"
```

---

### Task 3: 신규 5개 Exception 서브타입 추가

**Files:**
- Modify: `lib/core/errors/app_exception.dart`

- [ ] **Step 1: `lib/core/errors/app_exception.dart` 끝에 5개 서브타입 추가**

기존 `AuthCancelledException` 클래스 다음에 4개 추가 (`AuthException` 하위), 그리고 `ValidationException` 클래스 다음에 1개 추가 (`ValidationException` 하위).

**`AuthException` 하위** — 기존 `AuthCancelledException` 정의 바로 다음 줄에 추가:

```dart
/// 닉네임 중복 (409 DUPLICATED_NICKNAME)
class DuplicatedNicknameException extends AuthException {
  const DuplicatedNicknameException({String? message, super.originalException})
      : super(
          message: message ?? '이미 사용 중인 닉네임입니다.',
          code: 'DUPLICATED_NICKNAME',
        );
}

/// 소셜 ID Token 검증 실패 (401 SOCIAL_LOGIN_FAILED)
class SocialLoginFailedException extends AuthException {
  const SocialLoginFailedException({String? message, super.originalException})
      : super(
          message: message ?? '소셜 로그인에 실패하였습니다.',
          code: 'SOCIAL_LOGIN_FAILED',
        );
}

/// 지원하지 않는 socialType (400 UNSUPPORTED_SOCIAL_TYPE)
class UnsupportedSocialTypeException extends AuthException {
  const UnsupportedSocialTypeException(
      {String? message, super.originalException})
      : super(
          message: message ?? '지원하지 않는 소셜 로그인 방식입니다.',
          code: 'UNSUPPORTED_SOCIAL_TYPE',
        );
}

/// 보호 API 인증 실패 (401 UNAUTHENTICATED_REQUEST)
class UnauthenticatedRequestException extends AuthException {
  const UnauthenticatedRequestException(
      {String? message, super.originalException})
      : super(
          message: message ?? '로그인이 필요합니다.',
          code: 'UNAUTHENTICATED_REQUEST',
        );
}
```

**`ValidationException` 하위** — 기존 `ValidationException` 정의 바로 다음 줄에 추가:

```dart
/// 입력값 유효성 오류 (400 INVALID_INPUT_VALUE) — 모든 도메인 공용
class InvalidInputValueException extends ValidationException {
  const InvalidInputValueException(
      {String? message, super.originalException})
      : super(
          message: message ?? '입력값이 올바르지 않습니다.',
          code: 'INVALID_INPUT_VALUE',
        );
}
```

- [ ] **Step 2: analyze 로 컴파일 확인**

```bash
flutter analyze lib/core/errors/app_exception.dart
```

Expected: 0 issue (Task 2 가 ApiErrorResponse 만 깨뜨려서 app_exception.dart 자체는 영향 없음)

- [ ] **Step 3: 커밋**

```bash
git add lib/core/errors/app_exception.dart
git commit -m "feat : Auth/Validation Exception 서브타입 5개 추가 #71"
```

---

### Task 4: DioExceptionHandler 를 `{code, message}` 및 신규 Exception 매핑으로 리팩토링

**Files:**
- Modify: `lib/core/network/dio_exception_handler.dart`
- Create: `test/core/network/dio_exception_handler_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/core/network/dio_exception_handler_test.dart` 신규 생성:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/core/network/dio_exception_handler.dart';

DioException _exception({
  required int statusCode,
  required Map<String, dynamic> data,
  String path = '/api/test',
  String method = 'POST',
}) {
  final req = RequestOptions(path: path, method: method);
  return DioException(
    requestOptions: req,
    response: Response(
      requestOptions: req,
      statusCode: statusCode,
      data: data,
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('DioExceptionHandler code-based mapping', () {
    test('409 DUPLICATED_NICKNAME → DuplicatedNicknameException', () {
      final e = _exception(statusCode: 409, data: {
        'code': 'DUPLICATED_NICKNAME',
        'message': '이미 사용 중인 닉네임입니다.',
      });

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<DuplicatedNicknameException>());
      expect(result.code, 'DUPLICATED_NICKNAME');
      expect(result.message, '이미 사용 중인 닉네임입니다.');
    });

    test('401 SOCIAL_LOGIN_FAILED → SocialLoginFailedException', () {
      final e = _exception(statusCode: 401, data: {
        'code': 'SOCIAL_LOGIN_FAILED',
        'message': '소셜 로그인에 실패하였습니다.',
      });

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<SocialLoginFailedException>());
    });

    test('400 UNSUPPORTED_SOCIAL_TYPE → UnsupportedSocialTypeException', () {
      final e = _exception(statusCode: 400, data: {
        'code': 'UNSUPPORTED_SOCIAL_TYPE',
        'message': '지원하지 않는 소셜 로그인 방식입니다.',
      });

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<UnsupportedSocialTypeException>());
    });

    test('401 UNAUTHENTICATED_REQUEST → UnauthenticatedRequestException', () {
      final e = _exception(statusCode: 401, data: {
        'code': 'UNAUTHENTICATED_REQUEST',
        'message': '로그인이 필요합니다.',
      });

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<UnauthenticatedRequestException>());
    });

    test('400 INVALID_INPUT_VALUE → InvalidInputValueException', () {
      final e = _exception(statusCode: 400, data: {
        'code': 'INVALID_INPUT_VALUE',
        'message': 'nickname: 닉네임은 2자 이상 10자 이하여야 합니다.',
      });

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<InvalidInputValueException>());
      expect(result.message, 'nickname: 닉네임은 2자 이상 10자 이하여야 합니다.');
    });

    test('500 INTERNAL_SERVER_ERROR → ServerException', () {
      final e = _exception(statusCode: 500, data: {
        'code': 'INTERNAL_SERVER_ERROR',
        'message': '서버 내부 오류가 발생했습니다.',
      });

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<ServerException>());
    });

    test('알 수 없는 code + 401 → 기본 AuthException', () {
      final e = _exception(statusCode: 401, data: {
        'code': 'UNKNOWN_CODE',
        'message': '뭐 이상한 거',
      });

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<AuthException>());
      expect(result, isNot(isA<SocialLoginFailedException>()));
      expect(result, isNot(isA<UnauthenticatedRequestException>()));
      expect(result.message, '뭐 이상한 거');
    });

    test('apiError null (비표준 응답) + 400 → ValidationException 폴백', () {
      final e = _exception(statusCode: 400, data: {});

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<ValidationException>());
    });

    test('타임아웃 → NetworkException', () {
      final req = RequestOptions(path: '/x');
      final e = DioException(
        requestOptions: req,
        type: DioExceptionType.connectionTimeout,
      );

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<NetworkException>());
      expect(result.code, 'timeout');
    });
  });
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

```bash
flutter test test/core/network/dio_exception_handler_test.dart
```

Expected: 컴파일 에러 (`apiError.detail` 등) 또는 모든 케이스 FAIL (code 분기 없음).

- [ ] **Step 3: `lib/core/network/dio_exception_handler.dart` 를 다음 내용으로 전체 교체**

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import 'api_error_response.dart';

/// DioException → AppException 공통 변환 유틸리티
///
/// 모든 Repository 에서 DioException 을 일관된 방식으로 처리한다.
///
/// **동작**:
/// 1. 응답 본문에서 `{code, message}` 파싱 (api-docs.json ErrorResponse)
/// 2. `code` 기반으로 신규 5개 Exception 서브타입 매핑
/// 3. 미매핑 code + HTTP 상태 코드 폴백 매핑
/// 4. kDebugMode 에서 전체 에러 debugPrint
class DioExceptionHandler {
  DioExceptionHandler._();

  static AppException handle(DioException e) {
    final apiError = ApiErrorResponse.tryParse(e.response?.data);
    _logError(e, apiError);

    if (_isTimeoutError(e)) {
      return NetworkException(
        message: apiError?.message ?? '서버 연결 시간이 초과되었습니다.',
        code: 'timeout',
        originalException: e,
      );
    }

    if (_isConnectionError(e)) {
      return NetworkException(
        message: apiError?.message ?? '네트워크 연결을 확인하세요.',
        code: 'connection-error',
        originalException: e,
      );
    }

    // 1) code 기반 매핑 우선 (api-docs.json 의 명시 코드)
    if (apiError != null && apiError.code.isNotEmpty) {
      switch (apiError.code) {
        case 'DUPLICATED_NICKNAME':
          return DuplicatedNicknameException(
              message: apiError.message, originalException: e);
        case 'SOCIAL_LOGIN_FAILED':
          return SocialLoginFailedException(
              message: apiError.message, originalException: e);
        case 'UNSUPPORTED_SOCIAL_TYPE':
          return UnsupportedSocialTypeException(
              message: apiError.message, originalException: e);
        case 'UNAUTHENTICATED_REQUEST':
          return UnauthenticatedRequestException(
              message: apiError.message, originalException: e);
        case 'INVALID_INPUT_VALUE':
          return InvalidInputValueException(
              message: apiError.message, originalException: e);
        case 'INVALID_TOKEN':
          // reissue 401 — 강제 로그아웃은 AuthInterceptor 가 직접 처리.
          // 여기서는 그저 AuthException 으로 분류만.
          return AuthException(
            message: apiError.message,
            code: apiError.code,
            originalException: e,
          );
        case 'INTERNAL_SERVER_ERROR':
          return ServerException(
            message: apiError.message,
            code: apiError.code,
            originalException: e,
          );
      }
    }

    // 2) HTTP 상태 코드 폴백 매핑
    final statusCode = e.response?.statusCode;
    final message = apiError?.message ?? '';
    final code = apiError?.code ?? '';

    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message: message.isNotEmpty ? message : '서버에 문제가 발생했습니다.',
        code: code.isNotEmpty ? code : 'server-error',
        originalException: e,
      );
    }

    return switch (statusCode) {
      400 => ValidationException(
          message: message.isNotEmpty ? message : '잘못된 요청입니다.',
          code: code.isNotEmpty ? code : 'bad-request',
          originalException: e,
        ),
      401 => AuthException(
          message: message.isNotEmpty ? message : '인증에 실패했습니다.',
          code: code.isNotEmpty ? code : 'unauthorized',
          originalException: e,
        ),
      403 => AuthException(
          message: message.isNotEmpty ? message : '접근 권한이 없습니다.',
          code: code.isNotEmpty ? code : 'forbidden',
          originalException: e,
        ),
      404 => ServerException(
          message: message.isNotEmpty ? message : '요청한 리소스를 찾을 수 없습니다.',
          code: code.isNotEmpty ? code : 'not-found',
          originalException: e,
        ),
      409 => ServerException(
          message: message.isNotEmpty ? message : '요청이 현재 상태와 충돌합니다.',
          code: code.isNotEmpty ? code : 'conflict',
          originalException: e,
        ),
      _ => NetworkException(
          message: message.isNotEmpty ? message : '네트워크 연결을 확인하세요.',
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
      debugPrint('   code: ${apiError.code}');
      debugPrint('   message: ${apiError.message}');
    } else {
      debugPrint('❌ API 에러 [$statusCode] $method $path');
      debugPrint('   type: ${e.type}');
      debugPrint('   message: ${e.message}');
    }
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/core/network/dio_exception_handler_test.dart
```

Expected: 9 tests passed.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/network/dio_exception_handler.dart test/core/network/dio_exception_handler_test.dart
git commit -m "feat : DioExceptionHandler 가 code 기반 Exception 매핑 #71"
```

---

### Task 5: AuthInterceptor 정리 — publicPaths · reissue code · model 파싱 · message 필드

**Files:**
- Modify: `lib/core/network/auth_interceptor.dart`
- Create: `test/core/network/auth_interceptor_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/core/network/auth_interceptor_test.dart` 신규 생성:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/constants/api_endpoints.dart';
import 'package:space_study_ship/core/network/auth_interceptor.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';

class _MockTokenStorage extends Mock implements SecureTokenStorage {}

class _CapturingHandler extends RequestInterceptorHandler {
  RequestOptions? captured;
  @override
  void next(RequestOptions options) {
    captured = options;
    super.next(options);
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  DioException? captured;
  bool resolved = false;
  Response<dynamic>? resolvedResponse;

  @override
  void next(DioException err) {
    captured = err;
    super.next(err);
  }

  @override
  void resolve(Response response, [bool callFollowingResponseInterceptor = false]) {
    resolved = true;
    resolvedResponse = response;
    super.resolve(response, callFollowingResponseInterceptor);
  }
}

void main() {
  late _MockTokenStorage storage;
  late Dio plainDio;
  late List<String> forceLogoutMessages;
  late AuthInterceptor interceptor;

  setUp(() {
    storage = _MockTokenStorage();
    plainDio = Dio();
    forceLogoutMessages = [];
    interceptor = AuthInterceptor(
      tokenStorage: storage,
      plainDio: plainDio,
      onForceLogout: ({String? message}) async {
        forceLogoutMessages.add(message ?? '<null>');
      },
    );

    when(() => storage.getAccessToken()).thenAnswer((_) async => 'AT');
    when(() => storage.getRefreshToken()).thenAnswer((_) async => 'RT');
    when(() => storage.clearTokens()).thenAnswer((_) async {});
  });

  group('_publicPaths', () {
    test('login 요청에는 Authorization 헤더 주입하지 않음', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: ApiEndpoints.login);

      await Future<void>(() => interceptor.onRequest(options, handler));

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('logout 요청에는 Authorization 헤더 주입하지 않음 (NEW)', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: ApiEndpoints.logout);

      await Future<void>(() => interceptor.onRequest(options, handler));

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('reissue 요청에는 Authorization 헤더 주입하지 않음', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: ApiEndpoints.reissue);

      await Future<void>(() => interceptor.onRequest(options, handler));

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('check-nickname 요청에는 Authorization 헤더 주입 (FIX)', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: ApiEndpoints.checkNickname);

      await Future<void>(() => interceptor.onRequest(options, handler));

      expect(options.headers['Authorization'], 'Bearer AT');
    });

    test('일반 보호 API 요청에 Authorization 헤더 주입', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: '/api/todos');

      await Future<void>(() => interceptor.onRequest(options, handler));

      expect(options.headers['Authorization'], 'Bearer AT');
    });
  });

  group('reissue 분기', () {
    test('reissue API 가 401 INVALID_TOKEN 응답 → 강제 로그아웃 + message 전달', () async {
      final handler = _CapturingErrorHandler();
      final req = RequestOptions(path: ApiEndpoints.reissue);
      final err = DioException(
        requestOptions: req,
        response: Response(
          requestOptions: req,
          statusCode: 401,
          data: {
            'code': 'INVALID_TOKEN',
            'message': '인증 정보가 올바르지 않습니다.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      await Future<void>(() => interceptor.onError(err, handler));

      expect(forceLogoutMessages, ['인증 정보가 올바르지 않습니다.']);
      expect(handler.captured, isNotNull);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

```bash
flutter test test/core/network/auth_interceptor_test.dart
```

Expected: 다음 케이스 FAIL —
- "logout 요청에는 Authorization 헤더 주입하지 않음 (NEW)" — 현재 logout 이 publicPaths 에 없음
- "check-nickname 요청에는 Authorization 헤더 주입 (FIX)" — 현재 publicPaths 에 잘못 등록
- reissue 분기 테스트는 `code` 필드 사용으로 변경됐어야 통과

- [ ] **Step 3: `lib/core/network/auth_interceptor.dart` 의 `_publicPaths` 수정**

기존:
```dart
static const List<String> _publicPaths = [
  ApiEndpoints.login,
  ApiEndpoints.reissue,
  ApiEndpoints.checkNickname, // 닉네임 중복 확인 (인증 불필요)
];
```

다음으로 교체:
```dart
/// 인증 토큰이 불필요한 API 경로
///
/// - login: 신규 인증 시작점
/// - logout: 본문 refreshToken 으로 인증 (api-docs.json: "인증 불필요(실제 동작상)")
///   만료 토큰 상태에서도 reissue 우회로 즉시 로그아웃 가능
/// - reissue: refreshToken 으로 인증 (Access Token 만료된 상태에서 호출)
static const List<String> _publicPaths = [
  ApiEndpoints.login,
  ApiEndpoints.logout,
  ApiEndpoints.reissue,
];
```

- [ ] **Step 4: `lib/core/network/auth_interceptor.dart` 의 reissue 401 분기에 code 검증 추가**

기존 `onError` 안의 다음 블록:
```dart
// reissue API 자체가 401이면 강제 로그아웃
if (err.requestOptions.path.contains(ApiEndpoints.reissue)) {
  final apiError = ApiErrorResponse.tryParse(err.response?.data);
  await _handleForceLogout(message: apiError?.detail);
  return handler.next(err);
}
```

다음으로 교체:
```dart
// reissue API 자체가 401 이면 강제 로그아웃
// 정상 동작 시 백엔드는 code == "INVALID_TOKEN" 응답 (api-docs.json 명시)
if (err.requestOptions.path.contains(ApiEndpoints.reissue)) {
  final apiError = ApiErrorResponse.tryParse(err.response?.data);
  if (kDebugMode && apiError != null && apiError.code != 'INVALID_TOKEN') {
    debugPrint(
        '⚠️ reissue 401 응답이 예상 외 code: ${apiError.code} — 강제 로그아웃은 진행');
  }
  await _handleForceLogout(message: apiError?.message);
  return handler.next(err);
}
```

- [ ] **Step 5: reissue 본문 파싱을 `TokenReissueResponseModel` 로 통일**

`onError` 안의 reissue 성공 분기 (`if (response.statusCode == 200)` 블록) 를 다음으로 교체:

먼저 import 추가 (파일 상단):
```dart
import '../../features/auth/data/models/token_reissue_response_model.dart';
```

(주의: core 에서 features 로의 import — 기존 보고서에 따르면 core → feature 의존성 역전 원칙이지만, 모델 파싱 한정으로 허용. 만약 lint 가 막으면 `// ignore_for_file: depend_on_referenced_packages` 가 아니라 그냥 정정 — core 에 모델을 옮길지 결정 필요. 일단 진행하고 P7 에서 점검.)

그리고 분기 로직:
```dart
if (response.statusCode == 200) {
  TokenReissueResponseModel parsed;
  try {
    parsed = TokenReissueResponseModel.fromJson(
        response.data as Map<String, dynamic>);
  } catch (parseErr) {
    if (kDebugMode) {
      debugPrint('❌ 토큰 재발급 응답 파싱 실패: $parseErr / data=${response.data}');
    }
    await _handleForceLogout();
    return handler.next(err);
  }

  await _tokenStorage.saveTokens(
    accessToken: parsed.tokens.accessToken,
    refreshToken: parsed.tokens.refreshToken,
  );

  if (kDebugMode) {
    debugPrint('🔄 토큰 재발급 성공');
  }

  final retryResponse = await _retryRequest(
    err.requestOptions,
    parsed.tokens.accessToken,
  );
  return handler.resolve(retryResponse);
} else {
  await _handleForceLogout();
  return handler.next(err);
}
```

- [ ] **Step 6: catch 블록의 `detail` → `message` 필드 교체**

기존:
```dart
errorDetail = ApiErrorResponse.tryParse(e.response?.data)?.detail;
```

다음으로 교체:
```dart
errorDetail = ApiErrorResponse.tryParse(e.response?.data)?.message;
```

- [ ] **Step 7: 테스트 통과 확인**

```bash
flutter test test/core/network/auth_interceptor_test.dart
```

Expected: 6 tests passed.

- [ ] **Step 8: 전체 analyze (이 시점에 core/network 가 모두 그린)**

```bash
flutter analyze lib/core/network/
```

Expected: 0 issue.

- [ ] **Step 9: 커밋**

```bash
git add lib/core/network/auth_interceptor.dart test/core/network/auth_interceptor_test.dart
git commit -m "fix : AuthInterceptor publicPaths 정렬 및 reissue code 분기 #71"
```

---

### Task 6: LoginRequestModel 에 fcmToken/deviceType/deviceId 3 필드 추가

**Files:**
- Modify: `lib/features/auth/data/models/login_request_model.dart`
- Create: `test/features/auth/data/models/login_request_model_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/auth/data/models/login_request_model_test.dart` 신규 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/data/models/login_request_model.dart';

void main() {
  group('LoginRequestModel', () {
    test('5필드를 모두 직렬화한다', () {
      const model = LoginRequestModel(
        socialType: 'GOOGLE',
        idToken: 'eyJhbGc...',
        fcmToken: 'fcm-abc',
        deviceType: 'IOS',
        deviceId: '550e8400-e29b-41d4-a716-446655440000',
      );

      final json = model.toJson();

      expect(json.keys, containsAll(
          ['socialType', 'idToken', 'fcmToken', 'deviceType', 'deviceId']));
      expect(json['socialType'], 'GOOGLE');
      expect(json['idToken'], 'eyJhbGc...');
      expect(json['fcmToken'], 'fcm-abc');
      expect(json['deviceType'], 'IOS');
      expect(json['deviceId'], '550e8400-e29b-41d4-a716-446655440000');
    });

    test('fromJson 라운드트립', () {
      const original = LoginRequestModel(
        socialType: 'APPLE',
        idToken: 't1',
        fcmToken: 'f1',
        deviceType: 'ANDROID',
        deviceId: '11111111-2222-3333-4444-555555555555',
      );

      final round = LoginRequestModel.fromJson(original.toJson());

      expect(round, original);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

```bash
flutter test test/features/auth/data/models/login_request_model_test.dart
```

Expected: 컴파일 에러 (fcmToken/deviceType/deviceId named param 없음).

- [ ] **Step 3: `lib/features/auth/data/models/login_request_model.dart` 를 다음으로 교체**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_model.freezed.dart';
part 'login_request_model.g.dart';

/// 소셜 로그인 요청 DTO
///
/// `POST /api/auth/login` 요청 바디. `docs/api-docs.json` 의
/// `LoginRequest` 스키마와 1:1 정렬.
///
/// **필수 필드 (5개)**:
/// - [socialType]: `KAKAO` | `GOOGLE` | `APPLE`
/// - [idToken]: Firebase ID Token
/// - [fcmToken]: FCM 디바이스 토큰 (minLength: 0 — 발급 실패 시 빈 문자열 fallback)
/// - [deviceType]: `IOS` | `ANDROID`
/// - [deviceId]: UUID v4 (`^[0-9a-fA-F-]{36}$`)
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String socialType,
    required String idToken,
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
}
```

- [ ] **Step 4: build_runner 로 .freezed.dart / .g.dart 재생성**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: build_runner 성공, `login_request_model.freezed.dart` / `login_request_model.g.dart` 가 5필드 반영하여 갱신.

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/features/auth/data/models/login_request_model_test.dart
```

Expected: 2 tests passed.

- [ ] **Step 6: 호출부가 빨갛게 변하는지 analyze 확인 (Task 7 에서 수정 예정)**

```bash
flutter analyze lib/features/auth/data/repositories/auth_repository_impl.dart
```

Expected: error — `_performSocialLogin` 의 LoginRequestModel 생성자 호출이 3 필드 누락으로 깨짐. Task 7 에서 수정.

- [ ] **Step 7: 커밋**

```bash
git add lib/features/auth/data/models/login_request_model.dart \
        lib/features/auth/data/models/login_request_model.freezed.dart \
        lib/features/auth/data/models/login_request_model.g.dart \
        test/features/auth/data/models/login_request_model_test.dart
git commit -m "feat : LoginRequest 에 fcmToken/deviceType/deviceId 3 필드 추가 #71"
```

---

### Task 7: AuthRepositoryImpl 에 _collectDeviceInfo helper + _performSocialLogin 호출부 갱신

**Files:**
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`

- [ ] **Step 1: 파일 상단의 import 블록에 device 인프라 추가**

기존 import 블록에 다음을 (`secure_token_storage.dart` import 다음 줄에) 추가:

```dart
import '../../../../core/services/device/device_id_manager.dart';
import '../../../../core/services/device/device_info_service.dart';
import '../../../../core/services/fcm/firebase_messaging_service.dart';
```

- [ ] **Step 2: 클래스 내부에 `_collectDeviceInfo` private helper 추가**

`_cleanupFirebaseSession` 메서드 위에 (Private Helpers 섹션 시작 부분) 다음 메서드 추가:

```dart
/// 디바이스 메타 정보 수집 (fcmToken / deviceType / deviceId)
///
/// `docs/api-docs.json` LoginRequest 의 3 필드를 채우기 위해 사용.
/// FCM 토큰 발급 실패 시 빈 문자열로 fallback (백엔드가 `minLength: 0` 허용).
Future<({String fcmToken, String deviceType, String deviceId})>
    _collectDeviceInfo() async {
  final fcmToken =
      (await FirebaseMessagingService.instance().getFcmToken()) ?? '';
  final deviceType = DeviceInfoService.getDeviceType();
  final deviceId = await DeviceIdManager.getOrCreateDeviceId();

  if (kDebugMode) {
    debugPrint('📱 LoginRequest device info — '
        'type=$deviceType, id=$deviceId, fcmEmpty=${fcmToken.isEmpty}');
  }

  return (fcmToken: fcmToken, deviceType: deviceType, deviceId: deviceId);
}
```

- [ ] **Step 3: `_performSocialLogin` 의 `LoginRequestModel` 생성 호출 갱신**

기존:
```dart
final response = await _authRemoteDataSource.login(
  LoginRequestModel(socialType: socialType, idToken: idToken),
);
```

다음으로 교체:
```dart
final deviceInfo = await _collectDeviceInfo();
final response = await _authRemoteDataSource.login(
  LoginRequestModel(
    socialType: socialType,
    idToken: idToken,
    fcmToken: deviceInfo.fcmToken,
    deviceType: deviceInfo.deviceType,
    deviceId: deviceInfo.deviceId,
  ),
);
```

- [ ] **Step 4: analyze 통과 확인**

```bash
flutter analyze lib/features/auth/data/repositories/auth_repository_impl.dart
```

Expected: 0 issue.

- [ ] **Step 5: 전체 그린 확인 (지금까지 작업 전체 회귀 점검)**

```bash
flutter analyze
flutter test
```

Expected: analyze 0 issue, 모든 테스트 통과.

- [ ] **Step 6: 커밋**

```bash
git add lib/features/auth/data/repositories/auth_repository_impl.dart
git commit -m "feat : _performSocialLogin 에 device 정보 helper 적용 #71"
```

---

### Task 8: 신규 3 모델 파일 생성 (UpdateNicknameRequest/Response, CheckNicknameResponse)

**Files:**
- Create: `lib/features/auth/data/models/update_nickname_request_model.dart`
- Create: `lib/features/auth/data/models/update_nickname_response_model.dart`
- Create: `lib/features/auth/data/models/check_nickname_response_model.dart`
- Create: `test/features/auth/data/models/update_nickname_request_model_test.dart`
- Create: `test/features/auth/data/models/update_nickname_response_model_test.dart`
- Create: `test/features/auth/data/models/check_nickname_response_model_test.dart`

- [ ] **Step 1: 3개 실패 테스트 작성**

`test/features/auth/data/models/update_nickname_request_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_request_model.dart';

void main() {
  test('UpdateNicknameRequestModel 직렬화 라운드트립', () {
    const m = UpdateNicknameRequestModel(nickname: '우주탐험가');
    final round = UpdateNicknameRequestModel.fromJson(m.toJson());

    expect(round, m);
    expect(m.toJson(), {'nickname': '우주탐험가'});
  });
}
```

`test/features/auth/data/models/update_nickname_response_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_response_model.dart';

void main() {
  test('UpdateNicknameResponseModel 직렬화 라운드트립', () {
    const m = UpdateNicknameResponseModel(nickname: '우주탐험가');
    final round = UpdateNicknameResponseModel.fromJson(m.toJson());

    expect(round, m);
    expect(m.toJson(), {'nickname': '우주탐험가'});
  });
}
```

`test/features/auth/data/models/check_nickname_response_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:space_study_ship/features/auth/data/models/check_nickname_response_model.dart';

void main() {
  test('CheckNicknameResponseModel available=true 파싱', () {
    final m = CheckNicknameResponseModel.fromJson({'available': true});
    expect(m.available, isTrue);
  });

  test('CheckNicknameResponseModel available=false 파싱', () {
    final m = CheckNicknameResponseModel.fromJson({'available': false});
    expect(m.available, isFalse);
  });
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

```bash
flutter test test/features/auth/data/models/update_nickname_request_model_test.dart \
             test/features/auth/data/models/update_nickname_response_model_test.dart \
             test/features/auth/data/models/check_nickname_response_model_test.dart
```

Expected: 컴파일 에러 (모델 파일이 없음).

- [ ] **Step 3: 3개 모델 파일 생성**

`lib/features/auth/data/models/update_nickname_request_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_nickname_request_model.freezed.dart';
part 'update_nickname_request_model.g.dart';

/// 닉네임 변경 요청 DTO
///
/// `PATCH /api/auth/nickname` 요청 바디.
/// 닉네임 규칙: 2~10자, 한글/영문 대소문자/숫자 (`^[가-힣a-zA-Z0-9]+$`)
@freezed
class UpdateNicknameRequestModel with _$UpdateNicknameRequestModel {
  const factory UpdateNicknameRequestModel({
    required String nickname,
  }) = _UpdateNicknameRequestModel;

  factory UpdateNicknameRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateNicknameRequestModelFromJson(json);
}
```

`lib/features/auth/data/models/update_nickname_response_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_nickname_response_model.freezed.dart';
part 'update_nickname_response_model.g.dart';

/// 닉네임 변경 응답 DTO
///
/// `PATCH /api/auth/nickname` 응답 (200). 변경된 닉네임을 반환.
@freezed
class UpdateNicknameResponseModel with _$UpdateNicknameResponseModel {
  const factory UpdateNicknameResponseModel({
    required String nickname,
  }) = _UpdateNicknameResponseModel;

  factory UpdateNicknameResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateNicknameResponseModelFromJson(json);
}
```

`lib/features/auth/data/models/check_nickname_response_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_nickname_response_model.freezed.dart';
part 'check_nickname_response_model.g.dart';

/// 닉네임 중복 확인 응답 DTO
///
/// `GET /api/auth/check-nickname` 응답 (200).
/// `available: true` 면 사용 가능, `false` 면 이미 사용 중.
@freezed
class CheckNicknameResponseModel with _$CheckNicknameResponseModel {
  const factory CheckNicknameResponseModel({
    required bool available,
  }) = _CheckNicknameResponseModel;

  factory CheckNicknameResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CheckNicknameResponseModelFromJson(json);
}
```

- [ ] **Step 4: build_runner 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: 6개의 .freezed.dart/.g.dart 파일 생성.

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/features/auth/data/models/update_nickname_request_model_test.dart \
             test/features/auth/data/models/update_nickname_response_model_test.dart \
             test/features/auth/data/models/check_nickname_response_model_test.dart
```

Expected: 4 tests passed.

- [ ] **Step 6: 커밋**

```bash
git add lib/features/auth/data/models/update_nickname_request_model.dart \
        lib/features/auth/data/models/update_nickname_request_model.freezed.dart \
        lib/features/auth/data/models/update_nickname_request_model.g.dart \
        lib/features/auth/data/models/update_nickname_response_model.dart \
        lib/features/auth/data/models/update_nickname_response_model.freezed.dart \
        lib/features/auth/data/models/update_nickname_response_model.g.dart \
        lib/features/auth/data/models/check_nickname_response_model.dart \
        lib/features/auth/data/models/check_nickname_response_model.freezed.dart \
        lib/features/auth/data/models/check_nickname_response_model.g.dart \
        test/features/auth/data/models/
git commit -m "feat : 닉네임/탈퇴 DTO 3개 추가 #71"
```

---

### Task 9: AuthRemoteDataSource 에 3 신규 메서드 추가

**Files:**
- Modify: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

- [ ] **Step 1: import 블록에 3 신규 모델 추가**

기존 import 블록에 추가:
```dart
import '../models/check_nickname_response_model.dart';
import '../models/update_nickname_request_model.dart';
import '../models/update_nickname_response_model.dart';
```

- [ ] **Step 2: 클래스 내부에 3 메서드 추가 (`reissue` 메서드 다음에)**

기존 `reissue` 메서드 정의 끝부분 (`);` 다음) 에 추가:

```dart

  /// 닉네임 변경
  ///
  /// `PATCH /api/auth/nickname` — 인증 필요.
  ///
  /// - 200: 변경 성공
  /// - 400 INVALID_INPUT_VALUE: 형식 오류
  /// - 401 UNAUTHENTICATED_REQUEST: 인증 실패
  /// - 409 DUPLICATED_NICKNAME: 이미 사용 중
  @PATCH('/api/auth/nickname')
  Future<UpdateNicknameResponseModel> updateNickname(
    @Body() UpdateNicknameRequestModel request,
  );

  /// 닉네임 중복 확인
  ///
  /// `GET /api/auth/check-nickname?nickname=...` — 인증 필요.
  ///
  /// - 200: `{available: bool}`
  /// - 400 INVALID_INPUT_VALUE: 형식 오류
  /// - 401 UNAUTHENTICATED_REQUEST: 인증 실패
  @GET('/api/auth/check-nickname')
  Future<CheckNicknameResponseModel> checkNickname(
    @Query('nickname') String nickname,
  );

  /// 회원 탈퇴
  ///
  /// `DELETE /api/auth/withdraw` — 인증 필요. 요청 본문 없음.
  ///
  /// - 204: 탈퇴 성공 (멱등)
  /// - 401 UNAUTHENTICATED_REQUEST: 인증 실패
  @DELETE('/api/auth/withdraw')
  Future<void> withdraw();
```

추가로 import 부분에 `retrofit` 의 `@PATCH` 어노테이션이 이미 export 되는지 확인 — 기존 `@POST`, `@DELETE` 와 동일한 import 경로 (`package:retrofit/retrofit.dart`).

- [ ] **Step 3: build_runner 로 retrofit `_AuthRemoteDataSource` 재생성**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `auth_remote_datasource.g.dart` 가 3개 신규 메서드 구현 포함.

- [ ] **Step 4: analyze**

```bash
flutter analyze lib/features/auth/data/datasources/
```

Expected: 0 issue.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/auth/data/datasources/auth_remote_datasource.dart \
        lib/features/auth/data/datasources/auth_remote_datasource.g.dart
git commit -m "feat : AuthRemoteDataSource 에 nickname/withdraw 메서드 3개 추가 #71"
```

---

### Task 10: AuthRepository 인터페이스에 3 신규 메서드 추가

**Files:**
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`

- [ ] **Step 1: 기존 `signOut()` 메서드 정의 다음 줄에 3 메서드 시그니처 추가**

`abstract class AuthRepository` 클래스 안, `Future<void> signOut();` 정의 끝 다음 줄에 추가:

```dart

  /// 닉네임 변경
  ///
  /// `PATCH /api/auth/nickname` 호출 후 새 닉네임 문자열 반환.
  ///
  /// Throws:
  /// - [InvalidInputValueException] (400): 클라이언트 사전 검증 실패 또는 서버 형식 오류
  /// - [UnauthenticatedRequestException] (401)
  /// - [DuplicatedNicknameException] (409)
  Future<String> updateNickname(String nickname);

  /// 닉네임 중복 확인
  ///
  /// `GET /api/auth/check-nickname` 호출. true = 사용 가능, false = 이미 사용 중.
  ///
  /// Throws:
  /// - [InvalidInputValueException] (400)
  /// - [UnauthenticatedRequestException] (401)
  Future<bool> checkNickname(String nickname);

  /// 회원 탈퇴
  ///
  /// `DELETE /api/auth/withdraw` 호출 후 Firebase signOut + 로컬 토큰 삭제.
  /// 204 응답 / Firebase 측 사용자 부재 / 외부 시스템 일시 오류 모두 정상 완료로 처리 (멱등).
  ///
  /// Throws:
  /// - [UnauthenticatedRequestException] (401)
  Future<void> withdraw();
```

- [ ] **Step 2: analyze 확인 — Impl 미구현으로 빨갛게 변하는지**

```bash
flutter analyze lib/features/auth/
```

Expected: error `Missing concrete implementations of 'AuthRepository.updateNickname'` 등 3건. Task 11 에서 구현.

- [ ] **Step 3: 커밋 (아직 깨진 상태 — 다음 Task 에서 즉시 GREEN)**

```bash
git add lib/features/auth/domain/repositories/auth_repository.dart
git commit -m "feat : AuthRepository 인터페이스에 nickname/withdraw 메서드 추가 #71"
```

---

### Task 11: AuthRepositoryImpl 에 updateNickname/checkNickname/withdraw 구현

**Files:**
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Create: `test/features/auth/data/repositories/auth_repository_impl_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/auth/data/repositories/auth_repository_impl_test.dart` 신규 생성:

```dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:space_study_ship/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:space_study_ship/features/auth/data/models/check_nickname_response_model.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_request_model.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_response_model.dart';
import 'package:space_study_ship/features/auth/data/repositories/auth_repository_impl.dart';

class _MockFirebase extends Mock implements FirebaseAuthDataSource {}

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockStorage extends Mock implements SecureTokenStorage {}

class _FakeUpdateReq extends Fake implements UpdateNicknameRequestModel {}

void main() {
  late _MockFirebase firebase;
  late _MockRemote remote;
  late _MockStorage storage;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_FakeUpdateReq());
  });

  setUp(() {
    firebase = _MockFirebase();
    remote = _MockRemote();
    storage = _MockStorage();
    repo = AuthRepositoryImpl(
      firebaseAuthDataSource: firebase,
      authRemoteDataSource: remote,
      tokenStorage: storage,
    );
  });

  group('updateNickname', () {
    test('성공 시 응답 닉네임 반환', () async {
      when(() => remote.updateNickname(any())).thenAnswer(
          (_) async => const UpdateNicknameResponseModel(nickname: '우주탐험가'));

      final result = await repo.updateNickname('우주탐험가');

      expect(result, '우주탐험가');
      final captured =
          verify(() => remote.updateNickname(captureAny())).captured.single
              as UpdateNicknameRequestModel;
      expect(captured.nickname, '우주탐험가');
    });

    test('409 응답 → DuplicatedNicknameException', () async {
      final req = RequestOptions(path: '/api/auth/nickname');
      when(() => remote.updateNickname(any())).thenThrow(DioException(
        requestOptions: req,
        response: Response(
          requestOptions: req,
          statusCode: 409,
          data: {
            'code': 'DUPLICATED_NICKNAME',
            'message': '이미 사용 중인 닉네임입니다.',
          },
        ),
        type: DioExceptionType.badResponse,
      ));

      expect(() => repo.updateNickname('우주탐험가'),
          throwsA(isA<DuplicatedNicknameException>()));
    });
  });

  group('checkNickname', () {
    test('available: true 응답 → true 반환', () async {
      when(() => remote.checkNickname('우주탐험가')).thenAnswer(
          (_) async => const CheckNicknameResponseModel(available: true));

      expect(await repo.checkNickname('우주탐험가'), isTrue);
    });

    test('available: false 응답 → false 반환', () async {
      when(() => remote.checkNickname('user')).thenAnswer(
          (_) async => const CheckNicknameResponseModel(available: false));

      expect(await repo.checkNickname('user'), isFalse);
    });
  });

  group('withdraw', () {
    test('204 응답 시 Firebase signOut → clearTokens 순서로 호출', () async {
      when(() => remote.withdraw()).thenAnswer((_) async {});
      when(() => firebase.signOut()).thenAnswer((_) async {});
      when(() => storage.clearTokens()).thenAnswer((_) async {});

      await repo.withdraw();

      verifyInOrder([
        () => remote.withdraw(),
        () => firebase.signOut(),
        () => storage.clearTokens(),
      ]);
    });

    test('500 응답 시 토큰 유지 (clearTokens 미호출) 후 ServerException 전파', () async {
      final req = RequestOptions(path: '/api/auth/withdraw');
      when(() => remote.withdraw()).thenThrow(DioException(
        requestOptions: req,
        response: Response(
          requestOptions: req,
          statusCode: 500,
          data: {
            'code': 'INTERNAL_SERVER_ERROR',
            'message': '서버 내부 오류',
          },
        ),
        type: DioExceptionType.badResponse,
      ));

      expect(() => repo.withdraw(), throwsA(isA<ServerException>()));
      verifyNever(() => firebase.signOut());
      verifyNever(() => storage.clearTokens());
    });
  });
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

```bash
flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart
```

Expected: 컴파일 에러 (`updateNickname`/`checkNickname`/`withdraw` 미구현).

- [ ] **Step 3: `AuthRepositoryImpl` 에 3 메서드 구현**

`lib/features/auth/data/repositories/auth_repository_impl.dart` 의 import 블록에 추가:

```dart
import '../models/check_nickname_response_model.dart';
import '../models/update_nickname_request_model.dart';
```

(`UpdateNicknameResponseModel` 은 반환 타입이 String 으로 변환되므로 import 불필요. 단, 변수 타입 명시 시 필요하면 추가.)

기존 `signOut()` 메서드 닫는 중괄호 다음 (Private Helpers 섹션 시작 전) 에 다음 3 메서드 추가:

```dart

  // ============================================
  // 닉네임
  // ============================================

  @override
  Future<String> updateNickname(String nickname) async {
    try {
      final response = await _authRemoteDataSource.updateNickname(
        UpdateNicknameRequestModel(nickname: nickname),
      );
      if (kDebugMode) {
        debugPrint('✅ 닉네임 변경 성공: ${response.nickname}');
      }
      return response.nickname;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(
          message: '닉네임 변경 중 오류가 발생했습니다.', originalException: e);
    }
  }

  @override
  Future<bool> checkNickname(String nickname) async {
    try {
      final response = await _authRemoteDataSource.checkNickname(nickname);
      return response.available;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(
          message: '닉네임 중복 확인 중 오류가 발생했습니다.', originalException: e);
    }
  }

  // ============================================
  // 회원 탈퇴
  // ============================================

  @override
  Future<void> withdraw() async {
    try {
      await _authRemoteDataSource.withdraw();

      // 204 성공 시에만 도달.
      // 멱등 보장: Firebase signOut 실패도 무시하고 토큰 삭제는 진행.
      try {
        await _firebaseAuthDataSource.signOut();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ withdraw 후 Firebase signOut 실패 (무시): $e');
        }
      }
      await _tokenStorage.clearTokens();

      if (kDebugMode) {
        debugPrint('✅ 회원 탈퇴 완료 (백엔드 + Firebase + 토큰 삭제)');
      }
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(
          message: '회원 탈퇴 중 오류가 발생했습니다.', originalException: e);
    }
  }
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart
```

Expected: 6 tests passed.

- [ ] **Step 5: analyze**

```bash
flutter analyze lib/features/auth/
```

Expected: 0 issue.

- [ ] **Step 6: 커밋**

```bash
git add lib/features/auth/data/repositories/auth_repository_impl.dart \
        test/features/auth/data/repositories/auth_repository_impl_test.dart
git commit -m "feat : AuthRepositoryImpl 에 nickname/withdraw 메서드 3개 구현 #71"
```

---

### Task 12: 신규 3 UseCase 생성 (UpdateNickname / CheckNickname / Withdraw)

**Files:**
- Create: `lib/features/auth/domain/usecases/update_nickname_usecase.dart`
- Create: `lib/features/auth/domain/usecases/check_nickname_usecase.dart`
- Create: `lib/features/auth/domain/usecases/withdraw_usecase.dart`
- Create: `test/features/auth/domain/usecases/update_nickname_usecase_test.dart`
- Create: `test/features/auth/domain/usecases/check_nickname_usecase_test.dart`
- Create: `test/features/auth/domain/usecases/withdraw_usecase_test.dart`

- [ ] **Step 1: 실패하는 UpdateNicknameUseCase 테스트 작성**

`test/features/auth/domain/usecases/update_nickname_usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/domain/usecases/update_nickname_usecase.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late UpdateNicknameUseCase useCase;

  setUp(() {
    repo = _MockRepo();
    useCase = UpdateNicknameUseCase(repository: repo);
  });

  group('사전 정규식 검증', () {
    test('빈 문자열 → InvalidInputValueException', () {
      expect(() => useCase.execute(''),
          throwsA(isA<InvalidInputValueException>()));
      verifyNever(() => repo.updateNickname(any()));
    });

    test('1자 (너무 짧음) → InvalidInputValueException', () {
      expect(() => useCase.execute('가'),
          throwsA(isA<InvalidInputValueException>()));
    });

    test('11자 (너무 김) → InvalidInputValueException', () {
      expect(() => useCase.execute('우주탐험가1234567'),
          throwsA(isA<InvalidInputValueException>()));
    });

    test('특수문자 포함 → InvalidInputValueException', () {
      expect(() => useCase.execute('우주!'),
          throwsA(isA<InvalidInputValueException>()));
    });

    test('이모지 포함 → InvalidInputValueException', () {
      expect(() => useCase.execute('우주\u{1F680}'),
          throwsA(isA<InvalidInputValueException>()));
    });

    test('공백 포함 → InvalidInputValueException', () {
      expect(() => useCase.execute('우주 탐험가'),
          throwsA(isA<InvalidInputValueException>()));
    });
  });

  group('정규식 통과', () {
    test('한글 2-10자 → repository 호출', () async {
      when(() => repo.updateNickname('우주탐험가'))
          .thenAnswer((_) async => '우주탐험가');

      final result = await useCase.execute('우주탐험가');

      expect(result, '우주탐험가');
      verify(() => repo.updateNickname('우주탐험가')).called(1);
    });

    test('영문+숫자 → repository 호출', () async {
      when(() => repo.updateNickname('user123'))
          .thenAnswer((_) async => 'user123');

      expect(await useCase.execute('user123'), 'user123');
    });
  });
}
```

- [ ] **Step 2: 실패하는 CheckNicknameUseCase 테스트 작성**

`test/features/auth/domain/usecases/check_nickname_usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/domain/usecases/check_nickname_usecase.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late CheckNicknameUseCase useCase;

  setUp(() {
    repo = _MockRepo();
    useCase = CheckNicknameUseCase(repository: repo);
  });

  test('형식 불일치 → InvalidInputValueException', () {
    expect(() => useCase.execute('a'),
        throwsA(isA<InvalidInputValueException>()));
    verifyNever(() => repo.checkNickname(any()));
  });

  test('형식 통과 + available=true → true', () async {
    when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
    expect(await useCase.execute('우주탐험가'), isTrue);
  });

  test('형식 통과 + available=false → false', () async {
    when(() => repo.checkNickname('taken')).thenAnswer((_) async => false);
    expect(await useCase.execute('taken'), isFalse);
  });
}
```

- [ ] **Step 3: 실패하는 WithdrawUseCase 테스트 작성**

`test/features/auth/domain/usecases/withdraw_usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/domain/usecases/withdraw_usecase.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  test('execute() 는 repository.withdraw() 를 1회 호출한다', () async {
    final repo = _MockRepo();
    final useCase = WithdrawUseCase(repository: repo);

    when(() => repo.withdraw()).thenAnswer((_) async {});

    await useCase.execute();

    verify(() => repo.withdraw()).called(1);
  });
}
```

- [ ] **Step 4: 테스트 실행하여 모두 실패 확인**

```bash
flutter test test/features/auth/domain/usecases/update_nickname_usecase_test.dart \
             test/features/auth/domain/usecases/check_nickname_usecase_test.dart \
             test/features/auth/domain/usecases/withdraw_usecase_test.dart
```

Expected: 컴파일 에러 (UseCase 파일 없음).

- [ ] **Step 5: 3개 UseCase 파일 생성**

`lib/features/auth/domain/usecases/update_nickname_usecase.dart`:

```dart
import '../../../../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';

/// 닉네임 변경 UseCase
///
/// **사전 검증** (api-docs.json 닉네임 규칙):
/// - 길이: 2 ~ 10 자
/// - 허용 문자: 한글, 영문 대소문자, 숫자
/// - 정규식: `^[가-힣a-zA-Z0-9]+$`
///
/// 클라이언트 검증 실패 시 즉시 [InvalidInputValueException] throw.
/// 서버측 race(동시에 다른 사용자가 같은 닉네임 점유) 는 repository 에서 처리.
class UpdateNicknameUseCase {
  static final RegExp _pattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
  static const int _minLength = 2;
  static const int _maxLength = 10;

  final AuthRepository _repository;

  UpdateNicknameUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<String> execute(String nickname) async {
    if (nickname.length < _minLength || nickname.length > _maxLength) {
      throw const InvalidInputValueException(
          message: '닉네임은 2자 이상 10자 이하여야 합니다.');
    }
    if (!_pattern.hasMatch(nickname)) {
      throw const InvalidInputValueException(
          message: '닉네임은 한글, 영문, 숫자만 사용할 수 있습니다.');
    }
    return _repository.updateNickname(nickname);
  }
}
```

`lib/features/auth/domain/usecases/check_nickname_usecase.dart`:

```dart
import '../../../../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';

/// 닉네임 중복 확인 UseCase
///
/// 사전 검증 규칙은 [UpdateNicknameUseCase] 와 동일.
/// 통과 시 repository 호출하여 서버 응답의 `available` 그대로 반환.
class CheckNicknameUseCase {
  static final RegExp _pattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
  static const int _minLength = 2;
  static const int _maxLength = 10;

  final AuthRepository _repository;

  CheckNicknameUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<bool> execute(String nickname) async {
    if (nickname.length < _minLength || nickname.length > _maxLength) {
      throw const InvalidInputValueException(
          message: '닉네임은 2자 이상 10자 이하여야 합니다.');
    }
    if (!_pattern.hasMatch(nickname)) {
      throw const InvalidInputValueException(
          message: '닉네임은 한글, 영문, 숫자만 사용할 수 있습니다.');
    }
    return _repository.checkNickname(nickname);
  }
}
```

`lib/features/auth/domain/usecases/withdraw_usecase.dart`:

```dart
import '../repositories/auth_repository.dart';

/// 회원 탈퇴 UseCase
///
/// `DELETE /api/auth/withdraw` 호출. 토큰 삭제 + Firebase signOut 은
/// Repository 내부에서 트랜잭션 단위로 처리.
class WithdrawUseCase {
  final AuthRepository _repository;

  WithdrawUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<void> execute() => _repository.withdraw();
}
```

- [ ] **Step 6: 테스트 통과 확인**

```bash
flutter test test/features/auth/domain/usecases/update_nickname_usecase_test.dart \
             test/features/auth/domain/usecases/check_nickname_usecase_test.dart \
             test/features/auth/domain/usecases/withdraw_usecase_test.dart
```

Expected: 12 tests passed.

- [ ] **Step 7: 커밋**

```bash
git add lib/features/auth/domain/usecases/update_nickname_usecase.dart \
        lib/features/auth/domain/usecases/check_nickname_usecase.dart \
        lib/features/auth/domain/usecases/withdraw_usecase.dart \
        test/features/auth/domain/usecases/
git commit -m "feat : nickname/withdraw UseCase 3개 추가 #71"
```

---

### Task 13: AuthProvider 에 3 UseCase Provider + AuthNotifier 메서드 3개 추가

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

- [ ] **Step 1: import 블록에 3 신규 UseCase 추가**

기존 import 블록 (sign_in_with_apple/google/sign_out usecase import 옆) 에 추가:

```dart
import '../../domain/usecases/check_nickname_usecase.dart';
import '../../domain/usecases/update_nickname_usecase.dart';
import '../../domain/usecases/withdraw_usecase.dart';
```

- [ ] **Step 2: 기존 `signOutUseCaseProvider` 다음에 3 UseCase Provider 추가**

기존 `SignOutUseCase signOutUseCase(Ref ref)` 함수 끝 다음 줄에 추가:

```dart

/// 닉네임 변경 UseCase Provider
@riverpod
UpdateNicknameUseCase updateNicknameUseCase(Ref ref) {
  return UpdateNicknameUseCase(repository: ref.watch(authRepositoryProvider));
}

/// 닉네임 중복 확인 UseCase Provider
@riverpod
CheckNicknameUseCase checkNicknameUseCase(Ref ref) {
  return CheckNicknameUseCase(repository: ref.watch(authRepositoryProvider));
}

/// 회원 탈퇴 UseCase Provider
@riverpod
WithdrawUseCase withdrawUseCase(Ref ref) {
  return WithdrawUseCase(repository: ref.watch(authRepositoryProvider));
}
```

- [ ] **Step 3: `AuthNotifier` 클래스에 3 메서드 추가**

기존 `void forceLogout() { state = const AsyncValue.data(null); }` 메서드 다음 (클래스 닫는 `}` 직전) 에 추가:

```dart

  /// 닉네임 변경
  ///
  /// 성공 시 현재 상태의 nickname 을 갱신하고 isNewMember=false 처리.
  Future<void> updateNickname(String nickname) async {
    final useCase = ref.read(updateNicknameUseCaseProvider);
    final newNickname = await useCase.execute(nickname);

    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(nickname: newNickname, isNewMember: false),
      );
    }
  }

  /// 닉네임 중복 확인
  ///
  /// 정규식 실패 시 [InvalidInputValueException], 서버 응답이면 true/false 반환.
  Future<bool> checkNickname(String nickname) {
    return ref.read(checkNicknameUseCaseProvider).execute(nickname);
  }

  /// 회원 탈퇴
  ///
  /// 백엔드 응답 + Firebase signOut + 토큰 삭제 완료 후 state=null 로 종료.
  /// GoRouter 가 state 변화 감지하여 로그인 화면으로 이동.
  Future<void> withdraw() async {
    // 타이머 강제 리셋 (세션 저장 없이)
    ref.read(timerNotifierProvider.notifier).forceReset();

    final previous = state;
    state = const AsyncValue.loading();

    try {
      await ref.read(withdrawUseCaseProvider).execute();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = previous;
      debugPrint('❌ 회원 탈퇴 실패: $e\n$stack');
      rethrow;
    }
  }
```

- [ ] **Step 4: build_runner 실행하여 auth_provider.g.dart 갱신**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `auth_provider.g.dart` 가 3개 신규 Provider 코드 포함.

- [ ] **Step 5: analyze**

```bash
flutter analyze lib/features/auth/
```

Expected: 0 issue.

- [ ] **Step 6: 커밋**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart \
        lib/features/auth/presentation/providers/auth_provider.g.dart
git commit -m "feat : AuthNotifier 에 nickname/withdraw 메서드 + Provider 추가 #71"
```

---

### Task 14: docs/api-specs/00_common.md 에러 포맷 갱신

**Files:**
- Modify: `docs/api-specs/00_common.md`

- [ ] **Step 1: 에러 응답 섹션 재작성**

`docs/api-specs/00_common.md` 의 "에러 응답" 섹션 (`### 에러 응답` 줄부터 다음 `---` 직전까지) 을 다음으로 교체:

```markdown
### 에러 응답

모든 에러는 `code` 와 `message` 두 필드를 갖는 JSON 형식으로 응답합니다.

```json
{
  "code": "INVALID_TOKEN",
  "message": "인증 정보가 올바르지 않습니다."
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `code` | String | 에러 식별 코드 (예: INVALID_TOKEN, DUPLICATED_NICKNAME). 클라이언트의 Exception 분기에 사용 |
| `message` | String | 사용자에게 노출 가능한 메시지 |

### 공통 에러 코드

| HTTP Status | code | 설명 | 클라이언트 처리 |
|-------------|------|------|--------------|
| 400 | `INVALID_INPUT_VALUE` | 요청 파라미터 형식/제약 위반 | 입력값 확인 |
| 400 | `UNSUPPORTED_SOCIAL_TYPE` | 지원하지 않는 소셜 플랫폼 | (Auth 전용) |
| 401 | `UNAUTHENTICATED_REQUEST` | 토큰 없음 또는 유효하지 않음 | `/api/auth/reissue` 시도 |
| 401 | `INVALID_TOKEN` | Refresh Token 만료/탈취/변조 | 로그아웃 + 로그인 화면 |
| 401 | `SOCIAL_LOGIN_FAILED` | 소셜 ID Token 검증 실패 | 재로그인 |
| 409 | `DUPLICATED_NICKNAME` | 이미 사용 중인 닉네임 | 중복 안내 |
| 500 | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 | "잠시 후 다시" 안내 |
```

- [ ] **Step 2: 미리보기 확인 (선택)**

`docs/api-specs/00_common.md` 를 IDE 에서 열어 마크다운 렌더링이 깨지지 않는지 확인.

- [ ] **Step 3: 커밋**

```bash
git add docs/api-specs/00_common.md
git commit -m "docs : 00_common.md 에러 포맷을 code/message 스키마로 갱신 #71"
```

---

### Task 15: docs/api-specs/01_auth.md 갱신

**Files:**
- Modify: `docs/api-specs/01_auth.md`

- [ ] **Step 1: LoginRequest Request Body 표를 5필드로 갱신**

기존 "## 1. 소셜 로그인" 섹션의 "### Request Body" 표와 예시를 다음으로 교체:

````markdown
### Request Body

| 필드 | 타입 | 필수 | 설명 | 예시 |
|------|------|------|------|------|
| `socialType` | String | O | 소셜 로그인 플랫폼 (`KAKAO` / `GOOGLE` / `APPLE`) | `"GOOGLE"` |
| `idToken` | String | O | Firebase 발급 ID Token | `"eyJhbG..."` |
| `fcmToken` | String | O | FCM 디바이스 토큰 (minLength: 0 — 발급 실패 시 빈 문자열 허용) | `"dK3mL9xRTp2..."` |
| `deviceType` | String | O | 디바이스 OS (`IOS` / `ANDROID`) | `"IOS"` |
| `deviceId` | String | O | 디바이스 UUID v4 (`^[0-9a-fA-F-]{36}$`) | `"550e8400-e29b-41d4-a716-446655440000"` |

```json
{
  "socialType": "GOOGLE",
  "idToken": "eyJhbGciOiJSUzI1NiIs...",
  "fcmToken": "dK3mL9xRTp2...",
  "deviceType": "IOS",
  "deviceId": "550e8400-e29b-41d4-a716-446655440000"
}
```
````

- [ ] **Step 2: 모든 에러 표를 `code` 컬럼으로 재작성**

각 엔드포인트 섹션의 "### Error" 표를 `code` 기반으로 갱신. RFC 7807 의 `title` 컬럼을 모두 `code` 로 교체하고 백엔드 실제 코드 사용.

예시 — "## 1. 소셜 로그인" 의 Error 표:

```markdown
### Error

| Status | code | 상황 |
|--------|------|------|
| 400 | `INVALID_INPUT_VALUE` | 필수 필드 누락 또는 형식 오류 |
| 400 | `UNSUPPORTED_SOCIAL_TYPE` | socialType 이 KAKAO/GOOGLE/APPLE 외 값 |
| 401 | `SOCIAL_LOGIN_FAILED` | Firebase ID Token 검증 실패 |
| 500 | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 |
```

"## 3. 토큰 재발급" 의 Error 표:

```markdown
### Error

| Status | code | 상황 | 클라이언트 처리 |
|--------|------|------|--------------|
| 401 | `INVALID_TOKEN` | Refresh Token 만료/DB 불일치/변조 | 로그아웃 + 로그인 화면 이동 |
| 500 | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 | 재시도 안내 |
```

"## 5. 닉네임 중복 확인" 의 Error 표:

```markdown
### Error

| Status | code | 상황 |
|--------|------|------|
| 400 | `INVALID_INPUT_VALUE` | 닉네임 형식 오류 |
| 401 | `UNAUTHENTICATED_REQUEST` | 인증 실패 |
| 500 | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 |
```

"## 6. 닉네임 변경" 의 Error 표:

```markdown
### Error

| Status | code | 상황 |
|--------|------|------|
| 400 | `INVALID_INPUT_VALUE` | 닉네임 형식 오류 |
| 401 | `UNAUTHENTICATED_REQUEST` | 인증 실패 |
| 409 | `DUPLICATED_NICKNAME` | 이미 사용 중인 닉네임 |
| 500 | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 |
```

"## 4. 회원 탈퇴" 에는 Error 표가 없다면 다음을 추가:

```markdown
### Error

| Status | code | 상황 |
|--------|------|------|
| 401 | `UNAUTHENTICATED_REQUEST` | 인증 실패 |
| 500 | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 (멱등성으로 보통은 204) |
```

- [ ] **Step 3: 커밋**

```bash
git add docs/api-specs/01_auth.md
git commit -m "docs : 01_auth.md LoginRequest 5필드 및 에러 코드 정렬 #71"
```

---

### Task 16: 통합 검증 — build_runner · analyze · 전체 테스트

**Files:** (검증만)

- [ ] **Step 1: 모든 생성 파일 일관성 위해 build_runner 재실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: 성공. 변경 사항이 있으면 git status 에 .freezed.dart / .g.dart 갱신 표시.

- [ ] **Step 2: 만약 build_runner 갱신 파일이 있으면 커밋**

```bash
git status --short
```

생성 파일이 갱신되었다면:
```bash
git add lib/
git commit -m "chore : build_runner 재실행으로 생성 파일 일관성 확보 #71"
```

(없으면 skip)

- [ ] **Step 3: flutter analyze — 전체 0 issue**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: flutter test — 전체 그린**

```bash
flutter test
```

Expected: 모든 테스트 통과. 최소한 다음 신규 테스트 파일이 보고서에 포함:
- `test/core/network/api_error_response_test.dart` (6 tests)
- `test/core/network/dio_exception_handler_test.dart` (9 tests)
- `test/core/network/auth_interceptor_test.dart` (6 tests)
- `test/features/auth/data/models/login_request_model_test.dart` (2 tests)
- `test/features/auth/data/models/update_nickname_request_model_test.dart` (1 test)
- `test/features/auth/data/models/update_nickname_response_model_test.dart` (1 test)
- `test/features/auth/data/models/check_nickname_response_model_test.dart` (2 tests)
- `test/features/auth/data/repositories/auth_repository_impl_test.dart` (6 tests)
- `test/features/auth/domain/usecases/update_nickname_usecase_test.dart` (8 tests)
- `test/features/auth/domain/usecases/check_nickname_usecase_test.dart` (3 tests)
- `test/features/auth/domain/usecases/withdraw_usecase_test.dart` (1 test)

총 신규 테스트: **45개 이상**

- [ ] **Step 5: 성공 기준 매뉴얼 체크 (spec Section 11)**

다음을 grep / find 로 확인:

```bash
# 1. ApiErrorResponse 가 code/message 만 갖는지
grep -n "title\|detail\|instance" lib/core/network/api_error_response.dart
# Expected: 0 hits (RFC 7807 필드 흔적 없음)

# 2. LoginRequest 가 5필드인지
grep -E "required String" lib/features/auth/data/models/login_request_model.dart | wc -l
# Expected: 5

# 3. _publicPaths 가 login/logout/reissue 만 포함
grep -A5 "_publicPaths" lib/core/network/auth_interceptor.dart | head -10
# Expected: login, logout, reissue 만 (checkNickname 없음)

# 4. 신규 6개 메서드 (DataSource + Repository) 가 존재
grep -E "updateNickname|checkNickname|withdraw" lib/features/auth/data/datasources/auth_remote_datasource.dart | wc -l
# Expected: ≥ 3

grep -E "updateNickname|checkNickname|withdraw" lib/features/auth/domain/repositories/auth_repository.dart | wc -l
# Expected: ≥ 3
```

- [ ] **Step 6: spec 의 success criteria 9개 항목 매뉴얼 체크 후 통과 표시**

`docs/superpowers/specs/2026-05-15-auth-api-alignment-design.md` Section 11 의 9개 기준을 하나씩 확인.

- [ ] **Step 7: 최종 푸시 전 git log 정렬 확인**

```bash
git log --oneline origin/main..HEAD
```

Expected: 이 plan 의 task 별 커밋이 순서대로 출력됨. 누락 commit 없음.

- [ ] **Step 8: 푸시 (PR 생성 준비)**

```bash
git push -u origin 20260423_#71_백엔드_Auth_API_연동_소셜_로그인_토큰_닉네임_탈퇴
```

Expected: 모든 커밋 푸시 성공.

- [ ] **Step 9: 종료 커밋 없음 — PR 생성은 사용자 결정**

PR 본문은 spec(`docs/superpowers/specs/2026-05-15-auth-api-alignment-design.md`) 의 Section 1, 3, 11 을 인용하여 작성하면 됨. 사용자가 `gh pr create` 를 직접 실행하거나 별도 요청 시 진행.

---

## Rollback Plan

만약 머지 후 백엔드가 다시 RFC 7807 로 회귀하는 등 비상 상황이 발생하면:

```bash
git revert <merge-commit-sha>
```

이 plan 의 각 task 가 독립 커밋이므로 부분 revert 도 가능하지만, **부분 revert 는 권장하지 않음** — ErrorResponse 와 LoginRequest 가 결합되어 있어 일부만 되돌리면 컴파일 깨짐.

---

## Notes / Followups (Out of Scope)

- UI 신규 화면 3개 (NicknameSetup, NicknameEdit, Withdraw confirm dialog) — 별도 spec
- GoRouter `isNewMember` destination 연결 (`AuthNotifier.updateNicknameCompleted` dead code 정리) — UI spec 과 같이 처리
- FCM 권한 거부 시 사용자 UX 흐름 — 별도 이슈
- 닉네임 금지어 필터링 클라이언트 사전 검증 — 백엔드 결정 의존

## Spec Coverage Note — FirebaseAuthErrorHandler

Spec Section 6.1 은 `lib/features/auth/data/utils/firebase_auth_error_handler.dart` 에 `SOCIAL_LOGIN_FAILED` / `UNSUPPORTED_SOCIAL_TYPE` 매핑 추가를 명시했으나, 코드 흐름 분석 결과:

- `FirebaseAuthErrorHandler.createAuthException(FirebaseAuthException)` 는 Firebase SDK 가 throw 하는 `FirebaseAuthException` 만 처리한다 (`code`: `user-not-found`, `network-request-failed` 등 Firebase 측 코드).
- 백엔드 응답의 `SOCIAL_LOGIN_FAILED` (401) 와 `UNSUPPORTED_SOCIAL_TYPE` (400) 은 `AuthRemoteDataSource.login()` 의 `DioException` 으로 전달되어 `AuthRepositoryImpl._performSocialLogin` 의 `on DioException catch` 분기에서 `DioExceptionHandler.handle()` 로 라우팅된다 (Task 4 에서 매핑 완료).

따라서 `FirebaseAuthErrorHandler` 에 백엔드 코드를 추가해도 도달 불가능한 dead branch 가 되므로 **의도적으로 skip**. spec coverage 는 Task 4 (DioExceptionHandler) 가 완전히 대신한다.
