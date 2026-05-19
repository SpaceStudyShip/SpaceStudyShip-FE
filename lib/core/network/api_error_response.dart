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
