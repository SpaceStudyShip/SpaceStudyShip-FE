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
