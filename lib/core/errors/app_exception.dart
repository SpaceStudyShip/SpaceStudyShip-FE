/// 앱 전역 예외 클래스
/// App Global Exception Class
///
/// 모든 커스텀 예외의 부모 클래스입니다.
/// Parent class for all custom exceptions.
abstract class AppException implements Exception {
  /// 에러 메시지
  /// Error message
  final String message;

  /// 에러 코드 (선택사항)
  /// Error code (optional)
  final String? code;

  /// 원인이 된 예외 (선택사항)
  /// Original exception (optional)
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
/// Network related exception
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 인증 관련 예외
/// Authentication related exception
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

/// 검증 관련 예외
/// Validation related exception
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 입력값 유효성 오류 (400 INVALID_INPUT_VALUE) — 모든 도메인 공용
class InvalidInputValueException extends ValidationException {
  const InvalidInputValueException(
      {String? message, super.originalException})
      : super(
          message: message ?? '입력값이 올바르지 않습니다.',
          code: 'INVALID_INPUT_VALUE',
        );
}

/// 서버 관련 예외
/// Server related exception
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 데이터베이스 관련 예외
/// Database related exception
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// WebSocket 관련 예외
/// WebSocket related exception
class WebSocketException extends AppException {
  const WebSocketException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 위치 서비스 관련 예외
/// Location service related exception
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// 게임 로직 관련 예외
/// Game logic related exception
class GameException extends AppException {
  const GameException({
    required super.message,
    super.code,
    super.originalException,
  });
}
