# Auth API 계약 정렬 (#71)

> 백엔드 OpenAPI (`docs/api-docs.json`) 와 클라이언트 Auth 도메인의 Data/Domain Layer 를 1:1 로 정렬하고, 신규 3개 엔드포인트(닉네임 변경/중복 확인/회원 탈퇴)를 도입한다.

| 항목 | 값 |
|---|---|
| 이슈 | #71 백엔드 Auth API 연동 — 소셜 로그인 / 토큰 / 닉네임 / 탈퇴 |
| 작업 브랜치 | `20260423_#71_백엔드_Auth_API_연동_소셜_로그인_토큰_닉네임_탈퇴` |
| 베이스 | `origin/main` 머지 완료 (이슈 #72 인프라 포함) |
| Ground truth | `docs/api-docs.json` (사용자 확정: 2026-05-15) |
| Out-of-scope | UI 신규 화면, GoRouter 분기 보강, isNewMember destination 연결 |

---

## 1. 배경

이전 작업(이슈 #72) 완료 직후 백엔드 contract 가 갱신되었다. 이전 시점 보고서(`.report/20260515_#72_Auth_인프라_백엔드연동_최종.md`) 는 "에러 포맷은 RFC 7807 이 실제 백엔드 응답과 일치", "fcmToken 등은 백엔드가 받지 않음" 으로 명시했으나, 현재 백엔드는 `docs/api-docs.json` 의 OpenAPI 스펙으로 갈아엎혔다. 따라서 이번 작업은 보고서 진술이 아닌 `api-docs.json` 을 ground truth 로 따른다.

또한 이슈 #71 의 명칭이 "소셜 로그인 / 토큰 / 닉네임 / 탈퇴" 를 모두 포함하므로 Auth 도메인 6개 엔드포인트 전체를 한 번에 정렬한다.

---

## 2. 현황 vs Ground truth 차이

| 항목 | 현재 코드 (post #72) | `api-docs.json` (ground truth) | Gap |
|---|---|---|---|
| 에러 응답 모델 | `ApiErrorResponse{title, status, detail, instance}` (RFC 7807) | `{code: string, message: string}` | 🔴 전면 재정의 |
| `detail` 사용처 | `DioExceptionHandler`, `AuthInterceptor._handleForceLogout` | `message` | 🔴 호출자 일괄 수정 |
| LoginRequest 필수 | `socialType`, `idToken` | `socialType`, `idToken`, `fcmToken`, `deviceType`, `deviceId` | 🔴 3 필드 추가 |
| reissue 실패 식별 | RFC 7807 `detail` 텍스트 의존 | `code == "INVALID_TOKEN"` | 🟡 분기 추가 |
| `PATCH /api/auth/nickname` | path 상수도 없음 | 정의됨, 200/400/401/409/500 | 🟢 신규 구현 |
| `GET /api/auth/check-nickname` | path 상수 존재, but **interceptor 의 `_publicPaths` 에 잘못 등록** (실제는 인증 필요) | 정의됨, 200/400/401/500 | 🟢 신규 구현 + 🔴 버그픽스 |
| `DELETE /api/auth/withdraw` | path 상수만 존재 | 정의됨, 204/401/500 | 🟢 신규 구현 |
| 에러 코드 분기 | 없음 (메시지 텍스트만 사용) | `INVALID_TOKEN`, `DUPLICATED_NICKNAME`, `SOCIAL_LOGIN_FAILED`, `UNAUTHENTICATED_REQUEST`, `UNSUPPORTED_SOCIAL_TYPE`, `INVALID_INPUT_VALUE`, `INTERNAL_SERVER_ERROR` | 🟡 Exception 서브타입 도입 |
| `docs/api-specs/00_common.md`, `01_auth.md` | RFC 7807 + 2필드 LoginRequest 로 기재 | `{code, message}` + 5필드 | 🟡 doc 동기화 |

---

## 3. 목표

1. `api-docs.json` 의 Auth 태그 6개 엔드포인트와 클라이언트 Data Layer 가 필드/메서드/시그니처 수준에서 일치한다.
2. 백엔드 신규 에러 코드를 도메인 Exception 으로 매핑하여 상위 레이어가 텍스트 비교 없이 분기 가능하다.
3. `flutter analyze` 0 issue, 신규/수정 코드 단위 테스트 ≥ 80%.
4. `docs/api-specs/` 가 코드와 동일 ground truth 를 가리킨다.

**Out of scope**: UI 신규 화면(NicknameSetup, NicknameEdit, Withdraw confirm), GoRouter 분기 destination, `updateNicknameCompleted` dead code 정리, FCM 권한 거부 시 사용자 UX 흐름.

---

## 4. 결정 사항 (확정)

| ID | 결정 | 근거 |
|---|---|---|
| D-1 | Ground truth = `docs/api-docs.json` | 사용자 확정 — 백엔드가 OpenAPI 스펙으로 갈아엎힘 |
| D-2 | 범위 = Auth 도메인 전체 6 API | 이슈 #71 명칭이 닉네임/탈퇴 포함 |
| D-3 | UI 작업 미포함 (Domain/Data 만) | 이번 spec 은 "계약 정렬" 에 집중. UI 는 후속 spec |
| D-4 | Migration 방식 = 한 PR · 빅뱅 · 호환성 없음 | 백엔드 이미 전환 완료, 양쪽 fallback 은 죽은 코드만 양산 |
| D-5 | `withdraw` 후 토큰 삭제 위치 = Repository 내부 | 한 트랜잭션 책임. 기존 `signOut` 흐름과 대칭 |
| D-6 | 에러 코드 → Exception 매핑 위치 = `DioExceptionHandler.handle()` | 모든 feature 가 공통 활용 |
| D-7 | `checkNickname` 반환 타입 = `Future<bool>` | 사전 정규식 검증으로 400 차단, 서버 응답은 `available` 만 사용 |
| D-8 | doc 동기화 포함 (P6 단계) | 다음 작업자가 다시 헷갈리는 것 방지 |

---

## 5. 아키텍처

### 5.1 의존성 흐름 (변화 없음)

```
Presentation (AuthNotifier) → Domain (UseCase × N) → Domain (AuthRepository iface)
                                                            ▲
                                              Data (AuthRepositoryImpl)
                                                            │
                                              Data (AuthRemoteDataSource) + Core (Dio, Interceptor, ErrorResponse)
```

### 5.2 새 Exception 계층

```
AppException
├── AuthException
│   ├── AuthCancelledException                 (기존)
│   ├── DuplicatedNicknameException            (신규: 409 DUPLICATED_NICKNAME)
│   ├── SocialLoginFailedException             (신규: 401 SOCIAL_LOGIN_FAILED)
│   ├── UnsupportedSocialTypeException         (신규: 400 UNSUPPORTED_SOCIAL_TYPE)
│   └── UnauthenticatedRequestException        (신규: 401 UNAUTHENTICATED_REQUEST)
└── ValidationException                         (기존)
    └── InvalidInputValueException              (신규: 400 INVALID_INPUT_VALUE — 모든 도메인 공용)
```

`INTERNAL_SERVER_ERROR` 는 기존 `ServerException` 으로, 매핑 안 된 코드는 기존 `AuthException` / `NetworkException` 으로 fallback. `InvalidInputValueException` 만 `ValidationException` 하위에 두는 이유: Auth 외 도메인(Todo, Timer, …)에서도 400 INVALID_INPUT_VALUE 응답이 발생하므로 의미적으로 Auth 에 종속되지 않음.

### 5.3 AuthInterceptor 변경 두 가지

1. **`_publicPaths` 에서 `checkNickname` 제거** — api-docs.json 이 401 UNAUTHENTICATED_REQUEST 를 명시. 인증 필수.
2. **reissue 401 시 code 명시 검증** — `apiError.code == "INVALID_TOKEN"` 인 경우에만 강제 로그아웃을 "토큰 만료" 로 분류. 기타 401 도 강제 로그아웃은 하되 로그/메시지가 구분 가능.

---

## 6. 변경 파일 매트릭스

### 6.1 수정 파일

| 파일 | 변경 요약 |
|---|---|
| `lib/core/network/api_error_response.dart` | 4필드 → 2필드(`code`, `message`). `tryParse` 도 `code`/`message` 둘 다 부재 시 null. `toString` 갱신 |
| `lib/core/network/dio_exception_handler.dart` | `detail` → `message` 일괄. `handle()` 안에서 `apiError.code` switch 로 신규 5개 서브타입 매핑 |
| `lib/core/network/auth_interceptor.dart` | (a) `_publicPaths` 에서 `checkNickname` 제거 (b) `_publicPaths` 에 `logout` 추가 — api-docs.json 이 "인증 불필요(실제 동작상)" 명시. 만료 토큰 상태에서도 로그아웃이 reissue 우회로 즉시 성공 (c) reissue 401 시 `apiError.code == "INVALID_TOKEN"` 명시 검증 (d) message 소스를 `detail` → `message` (e) reissue 응답 파싱을 raw `response.data['tokens']` → `TokenReissueResponseModel.fromJson` 으로 통일 — **`TokenReissueResponseModel` 자체는 이미 `{tokens: TokensModel}` 로 정합, 사용처만 교체** |
| `lib/core/errors/app_exception.dart` | 5개 const 서브 Exception 추가 |
| `lib/features/auth/data/utils/firebase_auth_error_handler.dart` | `SOCIAL_LOGIN_FAILED`, `UNSUPPORTED_SOCIAL_TYPE` 매핑 추가. 기존 Firebase 에러 매핑은 보존 |
| `lib/features/auth/data/models/login_request_model.dart` | `fcmToken`, `deviceType`, `deviceId` 3 필드 추가 (모두 `required String`) |
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | 3 메서드 추가 — 시그니처: `@PATCH(updateNickname) Future<UpdateNicknameResponseModel> updateNickname(@Body() UpdateNicknameRequestModel)`, `@GET(checkNickname) Future<CheckNicknameResponseModel> checkNickname(@Query('nickname') String)`, `@DELETE(withdraw) Future<void> withdraw()` — **withdraw 는 요청 본문 없음 (api-docs.json 일치, Body model 만들지 말 것)** |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | (a) `_performSocialLogin` 에서 `_collectDeviceInfo()` helper 로 fcm/deviceType/deviceId 채우기 (b) `updateNickname` / `checkNickname` / `withdraw` 메서드 구현. withdraw 는 204 후 Firebase signOut + clearTokens 까지 처리 |
| `lib/features/auth/domain/repositories/auth_repository.dart` | 인터페이스에 3 메서드: `Future<String> updateNickname(String)`, `Future<bool> checkNickname(String)`, `Future<void> withdraw()` |
| `lib/features/auth/presentation/providers/auth_provider.dart` | 3 UseCase Provider 추가. `AuthNotifier.updateNickname/checkNickname/withdraw` 3 메서드 추가. withdraw 는 state = `AsyncValue.data(null)` 로 종료하여 라우터가 로그인 화면으로 분기 |
| `docs/api-specs/00_common.md` | 에러 포맷 RFC 7807 → `{code, message}` 로 재작성. HTTP Status Code 표 갱신 |
| `docs/api-specs/01_auth.md` | (a) LoginRequest 5필드로 갱신 (b) 에러 표를 `code` 컬럼으로 재작성 (c) `INVALID_REFRESH_TOKEN` → `INVALID_TOKEN`, `NICKNAME_DUPLICATED` → `DUPLICATED_NICKNAME` 등 코드명 일치화 |

### 6.2 신규 파일

| 파일 | 내용 |
|---|---|
| `lib/features/auth/data/models/update_nickname_request_model.dart` | Freezed `{nickname: String}` |
| `lib/features/auth/data/models/update_nickname_response_model.dart` | Freezed `{nickname: String}` |
| `lib/features/auth/data/models/check_nickname_response_model.dart` | Freezed `{available: bool}` |
| `lib/features/auth/domain/usecases/update_nickname_usecase.dart` | 사전 정규식 검증 후 repository 호출 |
| `lib/features/auth/domain/usecases/check_nickname_usecase.dart` | 사전 정규식 검증 후 repository 호출, bool 반환 |
| `lib/features/auth/domain/usecases/withdraw_usecase.dart` | `repository.withdraw()` 호출 (토큰 삭제는 repository 가 처리) |
| `test/features/auth/...` | 신규 단위 테스트 (모델, UseCase, Repository, Interceptor) |

---

## 7. 데이터 구조 상세

### 7.1 `ApiErrorResponse` (재정의)

```dart
class ApiErrorResponse {
  final String code;
  final String message;

  const ApiErrorResponse({required this.code, required this.message});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      ApiErrorResponse(
        code: json['code'] as String? ?? '',
        message: json['message'] as String? ?? '',
      );

  /// 응답 데이터에서 안전하게 파싱 시도.
  /// `code` 와 `message` 가 모두 없으면 null 반환.
  static ApiErrorResponse? tryParse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    if (data['code'] == null && data['message'] == null) return null;
    return ApiErrorResponse.fromJson(data);
  }

  @override
  String toString() => '[$code] $message';
}
```

### 7.2 `LoginRequestModel` (5 필드)

```dart
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String socialType,   // "KAKAO" | "GOOGLE" | "APPLE"
    required String idToken,
    required String fcmToken,     // 신규 — FCM 발급 실패 시 ''
    required String deviceType,   // 신규 — "IOS" | "ANDROID"
    required String deviceId,     // 신규 — UUID v4
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
}
```

### 7.3 신규 Exception 서브타입 (예시)

```dart
class DuplicatedNicknameException extends AuthException {
  const DuplicatedNicknameException({String? message})
      : super(
          message: message ?? '이미 사용 중인 닉네임입니다.',
          code: 'DUPLICATED_NICKNAME',
        );
}

class SocialLoginFailedException extends AuthException { ... }
class UnsupportedSocialTypeException extends AuthException { ... }
class UnauthenticatedRequestException extends AuthException { ... }
class InvalidInputValueException extends ValidationException { ... }
```

### 7.4 `DioExceptionHandler.handle` 매핑 로직 (의사 코드)

```
parse apiError from response
switch apiError.code:
  case "DUPLICATED_NICKNAME"      -> DuplicatedNicknameException(apiError.message)
  case "SOCIAL_LOGIN_FAILED"      -> SocialLoginFailedException(apiError.message)
  case "UNSUPPORTED_SOCIAL_TYPE"  -> UnsupportedSocialTypeException(apiError.message)
  case "UNAUTHENTICATED_REQUEST"  -> UnauthenticatedRequestException(apiError.message)
  case "INVALID_INPUT_VALUE"      -> InvalidInputValueException(apiError.message)
  case "INVALID_TOKEN"            -> AuthException + code (강제 로그아웃은 Interceptor 가 처리)
  case "INTERNAL_SERVER_ERROR"    -> ServerException(apiError.message)
  default                         -> 기존 fallback (statusCode 기반)
```

### 7.5 `_collectDeviceInfo` helper (`AuthRepositoryImpl` private)

```dart
Future<({String fcmToken, String deviceType, String deviceId})> _collectDeviceInfo() async {
  final fcmToken = (await FirebaseMessagingService.instance().getFcmToken()) ?? '';
  final deviceType = DeviceInfoService.getDeviceType();          // "IOS" | "ANDROID"
  final deviceId = await DeviceIdManager.getOrCreateDeviceId();
  return (fcmToken: fcmToken, deviceType: deviceType, deviceId: deviceId);
}
```

FCM 발급 실패 시 빈 문자열 fallback — `api-docs.json` 이 `fcmToken.minLength: 0` 을 허용. 로깅만 남기고 로그인 차단하지 않음. `DeviceIdManager.getOrCreateDeviceId()` 는 `_uuid.v4()` 로 36자 UUID 를 생성하여 `api-docs.json` 의 `deviceId.pattern: "^[0-9a-fA-F-]{36}$"` 을 자동 충족.

### 7.6 닉네임 사전 검증 (UseCase 공통)

```
정규식: ^[가-힣a-zA-Z0-9]+$
길이: 2 ~ 10
실패 시: throw InvalidInputValueException('닉네임은 2~10자, 한글/영문/숫자만 사용할 수 있습니다.')
```

---

## 8. 구현 Phase

각 Phase 는 `superpowers:test-driven-development` 사이클(RED→GREEN→REFACTOR) 로 진행. 한 Phase = 한 subagent 단위 위임 가능.

| Phase | 산출물 | 의존성 |
|---|---|---|
| **P1** ErrorResponse 스키마 전환 | `api_error_response.dart` 재정의, `app_exception.dart` 5 서브타입, `dio_exception_handler.dart` 매핑, `auth_interceptor.dart` 의 message 소스 교체 (reissue 분기는 P3) + 테스트 | — |
| **P2** LoginRequest 5필드 확장 | `login_request_model.dart` 필드 추가, `_collectDeviceInfo` helper, `AuthRepositoryImpl._performSocialLogin` 호출부 갱신 + 테스트 | P1 |
| **P3** AuthInterceptor 정리 | `_publicPaths` 에서 checkNickname 제거, reissue 401 code 검증, `TokenReissueResponseModel` 사용 + 테스트 | P1 |
| **P4** 신규 3개 API — Data | 3 신규 모델, `auth_remote_datasource.dart` 3 메서드, `auth_repository.dart` 인터페이스 3 메서드, `auth_repository_impl.dart` 구현 3 메서드 + 테스트 | P1, P2, P3 |
| **P5** 신규 3개 API — Domain & Presentation | 3 UseCase, 3 UseCase Provider, `AuthNotifier` 3 메서드 + 테스트 | P4 |
| **P6** Doc 동기화 + 통합 검증 | `00_common.md`, `01_auth.md` 갱신. `flutter pub run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test` 전체 그린 확인 | P1..P5 |

---

## 9. Test 전략

| 레이어 | 케이스 |
|---|---|
| `ApiErrorResponse` | `{code, message}` 정상 / 둘 다 없음 → null / partial 필드 graceful / RFC 7807 페이로드는 null |
| `LoginRequestModel.toJson` | 5필드 모두 직렬화, snake_case 변환 없음 |
| 신규 3 모델 | fromJson/toJson 라운드트립 |
| `UpdateNicknameUseCase` / `CheckNicknameUseCase` | 정규식 검증: 빈/너무 짧음/너무 김/특수문자/이모지 → `InvalidInputValueException`. 통과 시 repository 호출 |
| `WithdrawUseCase` | repository.withdraw 호출 확인 |
| `AuthRepositoryImpl.updateNickname` | 409 응답 → `DuplicatedNicknameException` |
| `AuthRepositoryImpl.withdraw` | 204 응답 시 Firebase signOut → clearTokens 순서 호출. 5xx 시 토큰 유지 |
| `AuthRepositoryImpl._performSocialLogin` | LoginRequest 가 5필드로 채워지는지 (helper mock) |
| `AuthInterceptor` reissue 401 | `code == "INVALID_TOKEN"` 응답 → forceLogout(message=server message) |
| `AuthInterceptor` checkNickname | `/api/auth/check-nickname` 요청 시 Authorization 헤더 주입 (회귀) |
| `DioExceptionHandler` | code → Exception 서브타입 매핑 매트릭스 |

목표 coverage ≥ 80%.

---

## 10. Risks & Mitigation

| Risk | 대응 |
|---|---|
| FCM token 발급 실패 (iOS simulator, 권한 거부) | 빈 문자열 fallback (`minLength: 0` 허용). 로그만 남김 |
| 백엔드가 `code` 누락 등 비표준 응답 | `tryParse` 가 null → 기존 fallback 메시지 사용. 강제 로그아웃은 statusCode 기반 유지 |
| `LoginRequestModel` 5필드 변경이 기존 호출부 깨뜨림 | required 라 컴파일러가 빠뜨림 차단. P2 에서 호출부 동시 수정 |
| `withdraw` 진행 중 `signOut` 호출 (race) | `AuthNotifier` 의 `state = AsyncValue.loading()` 으로 UI 버튼 비활성화 — UI 작업이라 spec out-of-scope, 메모만 남김 |
| `_publicPaths` 에서 checkNickname 제거 후 회귀 | P3 테스트로 Authorization 헤더 주입 회귀 케이스 추가 |
| build_runner 산출물 누락 | P6 에서 `--delete-conflicting-outputs` 로 재생성 후 커밋 |

---

## 11. 성공 기준

1. `flutter analyze` → 0 issue
2. `flutter test` → 신규/수정 테스트 100% 통과, coverage ≥ 80% (신규 코드 기준)
3. `LoginRequestModel.toJson()` 이 `socialType / idToken / fcmToken / deviceType / deviceId` 5개를 직렬화
4. `ApiErrorResponse.fromJson({"code":"INVALID_TOKEN","message":"..."})` 정상 파싱, 4필드 RFC 7807 페이로드는 null fallback
5. `AuthRemoteDataSource` 가 6 엔드포인트 모두 정의 (login, logout, reissue, patchNickname, getCheckNickname, deleteWithdraw)
6. `AuthRepository` 인터페이스에 `updateNickname`, `checkNickname`, `withdraw` 메서드 노출
7. `AuthInterceptor._publicPaths` 가 `login`, `logout`, `reissue` 만 포함 (`checkNickname` 제거됨, `logout` 추가됨)
8. `AuthInterceptor` reissue 401 응답에서 `code == "INVALID_TOKEN"` 분기 동작 확인 (테스트)
9. `docs/api-specs/00_common.md` 와 `01_auth.md` 가 `api-docs.json` 과 일치 (수동 diff)

---

## 12. 후속 작업 (별도 spec)

- **#71 후속 spec — Auth UI 마무리**: NicknameSetup 화면, NicknameEdit 화면(프로필), Withdraw confirm dialog, GoRouter `isNewMember` destination 연결, `updateNicknameCompleted` 호출 복구
- **#71 후속 — 회귀 시나리오 통합 테스트**: 신규 가입 → 닉네임 설정 → 변경 → 탈퇴 의 e2e
- **별도 이슈**: FCM 권한 거부 시 사용자 안내 UX, 닉네임 금지어 필터링 클라이언트 사전 검증
