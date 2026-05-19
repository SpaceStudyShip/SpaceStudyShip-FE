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
