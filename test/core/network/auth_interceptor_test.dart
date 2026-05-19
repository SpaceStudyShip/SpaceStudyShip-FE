import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/constants/api_endpoints.dart';
import 'package:space_study_ship/core/network/auth_interceptor.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';

class _MockTokenStorage extends Mock implements SecureTokenStorage {}

/// `AuthInterceptor.onRequest` 는 `void ... async` 시그니처라 외부에서 await 로
/// 직접 완료를 기다릴 수 없다. handler.next 가 호출될 때 complete 되는
/// Completer 를 두어 안의 async 작업이 끝난 시점을 확정한다.
class _CapturingHandler extends RequestInterceptorHandler {
  RequestOptions? captured;
  final Completer<void> done = Completer<void>();

  @override
  void next(RequestOptions options) {
    captured = options;
    if (!done.isCompleted) done.complete();
    // 본 핸들러는 테스트용 — 실제 인터셉터 체인을 진행시키지 않고
    // 캡처만 수행. (super.next 는 큐 처리 중 unhandled error 를 유발)
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  DioException? captured;
  bool resolved = false;
  Response<dynamic>? resolvedResponse;
  final Completer<void> done = Completer<void>();

  @override
  void next(DioException err) {
    captured = err;
    if (!done.isCompleted) done.complete();
    // 캡처만 수행. super.next 는 _completer.completeError 로
    // unhandled async error 를 발생시키므로 호출하지 않음.
  }

  @override
  void resolve(Response response) {
    resolved = true;
    resolvedResponse = response;
    if (!done.isCompleted) done.complete();
    // 캡처만 수행. super.resolve 호출 시 _completer.complete 가 동작하지만
    // 테스트 컨텍스트에서는 후속 체인이 없으므로 호출 불필요.
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

      interceptor.onRequest(options, handler);
      await handler.done.future;

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('logout 요청에는 Authorization 헤더 주입하지 않음 (NEW)', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: ApiEndpoints.logout);

      interceptor.onRequest(options, handler);
      await handler.done.future;

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('reissue 요청에는 Authorization 헤더 주입하지 않음', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: ApiEndpoints.reissue);

      interceptor.onRequest(options, handler);
      await handler.done.future;

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('check-nickname 요청에는 Authorization 헤더 주입 (FIX)', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: ApiEndpoints.checkNickname);

      interceptor.onRequest(options, handler);
      await handler.done.future;

      expect(options.headers['Authorization'], 'Bearer AT');
    });

    test('일반 보호 API 요청에 Authorization 헤더 주입', () async {
      final handler = _CapturingHandler();
      final options = RequestOptions(path: '/api/todos');

      interceptor.onRequest(options, handler);
      await handler.done.future;

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
          data: {'code': 'INVALID_TOKEN', 'message': '인증 정보가 올바르지 않습니다.'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(err, handler);
      await handler.done.future;

      expect(forceLogoutMessages, ['인증 정보가 올바르지 않습니다.']);
      expect(handler.captured, isNotNull);
    });
  });
}
