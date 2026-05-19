import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/models/token_reissue_response_model.dart';
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
  /// 재시도 요청도 _plainDio로 수행하여 QueuedInterceptor 큐 교착 방지.
  final Dio _plainDio;

  /// 강제 로그아웃 콜백
  ///
  /// 토큰 재발급 실패 시 호출됩니다.
  /// Presentation Layer에서 Firebase 로그아웃 + 로그인 화면 이동을 처리합니다.
  /// [message]: 백엔드 에러 메시지 (`ApiErrorResponse.message`) — 로그인 화면에서 스낵바로 표시
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
  /// - login: 신규 인증 시작점
  /// - logout: 본문 refreshToken 으로 인증 (api-docs.json: "인증 불필요(실제 동작상)")
  ///   만료 토큰 상태에서도 reissue 우회로 즉시 로그아웃 가능
  /// - reissue: refreshToken 으로 인증 (Access Token 만료된 상태에서 호출)
  static const List<String> _publicPaths = [
    ApiEndpoints.login,
    ApiEndpoints.logout,
    ApiEndpoints.reissue,
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

    // reissue API 자체가 401 이면 강제 로그아웃
    // 정상 동작 시 백엔드는 code == "INVALID_TOKEN" 응답 (api-docs.json 명시)
    if (err.requestOptions.path.contains(ApiEndpoints.reissue)) {
      final apiError = ApiErrorResponse.tryParse(err.response?.data);
      if (kDebugMode && apiError != null && apiError.code != 'INVALID_TOKEN') {
        debugPrint(
          '⚠️ reissue 401 응답이 예상 외 code: ${apiError.code} — 강제 로그아웃은 진행',
        );
      }
      await _handleForceLogout(message: apiError?.message);
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
        TokenReissueResponseModel parsed;
        try {
          parsed = TokenReissueResponseModel.fromJson(
            response.data as Map<String, dynamic>,
          );
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
    } catch (e) {
      String? errorDetail;
      if (e is DioException) {
        errorDetail = ApiErrorResponse.tryParse(e.response?.data)?.message;
        if (kDebugMode) {
          debugPrint('❌ [Reissue] 토큰 재발급 실패: ${e.response?.statusCode}');
          debugPrint('   responseData: ${e.response?.data}');
        }
      } else if (kDebugMode) {
        debugPrint('❌ [Reissue] 토큰 재발급 실패 (non-Dio): $e');
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
  /// `_isRetry` extra 플래그로 재시도 식별.
  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    final retryOptions = requestOptions.copyWith(
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken',
      },
      extra: {...requestOptions.extra, '_isRetry': true},
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
