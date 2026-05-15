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
/// 앱 생애주기 동안 유지 (keepAlive) — HTTP 클라이언트는 dispose되면 안 됨.
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

/// Dio HTTP 클라이언트 설정
///
/// 앱 전체에서 사용되는 Dio 인스턴스를 생성합니다.
/// AuthInterceptor를 통해 JWT 토큰 자동 주입 및 재발급을 처리합니다.
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

    // reissue 및 재시도 전용 plain Dio (인터셉터 없음)
    // AuthInterceptor 재진입으로 인한 이중 강제 로그아웃 방지
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
