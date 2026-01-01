import 'package:flutter/foundation.dart';

/// 환경 설정 관리 클래스
/// API URL, WebSocket URL 등 환경별 설정을 중앙에서 관리합니다
class EnvConfig {
  // Private constructor to prevent instantiation
  // 인스턴스화 방지를 위한 private 생성자
  EnvConfig._();

  // 환경 변수
  static String? _apiUrl;
  static String? _webSocketUrl;
  static bool _isInitialized = false;

  /// API Base URL
  static String get apiUrl => _apiUrl ?? '';

  /// WebSocket URL
  static String get webSocketUrl => _webSocketUrl ?? '';

  /// 초기화 여부
  static bool get isInitialized => _isInitialized;

  /// 환경 설정 초기화
  ///
  /// 앱 시작 시 main() 함수에서 호출하여 환경 변수를 로드합니다.
  ///
  /// **사용 예시**:
  /// ```dart
  /// await EnvConfig.initialize();
  /// ```
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ [EnvConfig] 이미 초기화되었습니다.');
      return;
    }

    try {
      debugPrint('🔧 [EnvConfig] 환경 설정 초기화 시작...');

      // TODO: 실제 환경 변수 로드 로직 구현
      // 현재는 기본값만 설정
      // 향후 .env 파일이나 Firebase Remote Config에서 로드 가능
      _apiUrl = _getDefaultApiUrl();
      _webSocketUrl = _getDefaultWebSocketUrl();

      _isInitialized = true;
      debugPrint('✅ [EnvConfig] 환경 설정 초기화 완료');
      debugPrint('📡 [EnvConfig] API URL: $_apiUrl');
      debugPrint('📡 [EnvConfig] WebSocket URL: $_webSocketUrl');
    } catch (e, stackTrace) {
      debugPrint('❌ [EnvConfig] 환경 설정 초기화 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      // 기본값으로 계속 진행
      _apiUrl = _getDefaultApiUrl();
      _webSocketUrl = _getDefaultWebSocketUrl();
      _isInitialized = true;
    }
  }

  /// 기본 API URL 가져오기
  /// 환경(debug/release)에 따라 다른 URL 반환
  static String _getDefaultApiUrl() {
    if (kDebugMode) {
      // 개발 환경
      return 'http://localhost:8000';
    } else {
      // 프로덕션 환경
      return 'https://api.production.com';
    }
  }

  /// 기본 WebSocket URL 가져오기
  /// 환경(debug/release)에 따라 다른 URL 반환
  static String _getDefaultWebSocketUrl() {
    if (kDebugMode) {
      // 개발 환경
      return 'ws://localhost:8000/ws';
    } else {
      // 프로덕션 환경
      return 'wss://api.production.com/ws';
    }
  }

  /// 환경 설정 리셋 (테스트용)
  @visibleForTesting
  static void reset() {
    _apiUrl = null;
    _webSocketUrl = null;
    _isInitialized = false;
  }
}
