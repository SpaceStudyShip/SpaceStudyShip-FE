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
    response: Response(requestOptions: req, statusCode: statusCode, data: data),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('DioExceptionHandler code-based mapping', () {
    test('409 DUPLICATED_NICKNAME → DuplicatedNicknameException', () {
      final e = _exception(
        statusCode: 409,
        data: {'code': 'DUPLICATED_NICKNAME', 'message': '이미 사용 중인 닉네임입니다.'},
      );

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<DuplicatedNicknameException>());
      expect(result.code, 'DUPLICATED_NICKNAME');
      expect(result.message, '이미 사용 중인 닉네임입니다.');
    });

    test('401 SOCIAL_LOGIN_FAILED → SocialLoginFailedException', () {
      final e = _exception(
        statusCode: 401,
        data: {'code': 'SOCIAL_LOGIN_FAILED', 'message': '소셜 로그인에 실패하였습니다.'},
      );

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<SocialLoginFailedException>());
    });

    test('400 UNSUPPORTED_SOCIAL_TYPE → UnsupportedSocialTypeException', () {
      final e = _exception(
        statusCode: 400,
        data: {
          'code': 'UNSUPPORTED_SOCIAL_TYPE',
          'message': '지원하지 않는 소셜 로그인 방식입니다.',
        },
      );

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<UnsupportedSocialTypeException>());
    });

    test('401 UNAUTHENTICATED_REQUEST → UnauthenticatedRequestException', () {
      final e = _exception(
        statusCode: 401,
        data: {'code': 'UNAUTHENTICATED_REQUEST', 'message': '로그인이 필요합니다.'},
      );

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<UnauthenticatedRequestException>());
    });

    test('400 INVALID_INPUT_VALUE → InvalidInputValueException', () {
      final e = _exception(
        statusCode: 400,
        data: {
          'code': 'INVALID_INPUT_VALUE',
          'message': 'nickname: 닉네임은 2자 이상 10자 이하여야 합니다.',
        },
      );

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<InvalidInputValueException>());
      expect(result.message, 'nickname: 닉네임은 2자 이상 10자 이하여야 합니다.');
    });

    test('500 INTERNAL_SERVER_ERROR → ServerException', () {
      final e = _exception(
        statusCode: 500,
        data: {'code': 'INTERNAL_SERVER_ERROR', 'message': '서버 내부 오류가 발생했습니다.'},
      );

      final result = DioExceptionHandler.handle(e);

      expect(result, isA<ServerException>());
    });

    test('TODO_NOT_FOUND code → TodoNotFoundException', () {
      final req = RequestOptions(path: '/api/todos/abc');
      final exc = DioExceptionHandler.handle(
        DioException(
          requestOptions: req,
          response: Response(
            requestOptions: req,
            statusCode: 404,
            data: {
              'code': 'TODO_NOT_FOUND',
              'message': '해당 할 일을 찾을 수 없습니다.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(exc, isA<TodoNotFoundException>());
      expect(exc.code, 'TODO_NOT_FOUND');
    });

    test('TODO_ALREADY_EXISTS code → TodoAlreadyExistsException', () {
      final req = RequestOptions(path: '/api/todos');
      final exc = DioExceptionHandler.handle(
        DioException(
          requestOptions: req,
          response: Response(
            requestOptions: req,
            statusCode: 409,
            data: {
              'code': 'TODO_ALREADY_EXISTS',
              'message': '동일 ID의 할 일이 이미 존재합니다.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(exc, isA<TodoAlreadyExistsException>());
    });

    test('CATEGORY_NOT_FOUND code → CategoryNotFoundException', () {
      final req = RequestOptions(path: '/api/todo-categories/abc');
      final exc = DioExceptionHandler.handle(
        DioException(
          requestOptions: req,
          response: Response(
            requestOptions: req,
            statusCode: 404,
            data: {
              'code': 'CATEGORY_NOT_FOUND',
              'message': '해당 카테고리를 찾을 수 없습니다.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(exc, isA<CategoryNotFoundException>());
    });

    test('CATEGORY_ALREADY_EXISTS code → CategoryAlreadyExistsException', () {
      final req = RequestOptions(path: '/api/todo-categories');
      final exc = DioExceptionHandler.handle(
        DioException(
          requestOptions: req,
          response: Response(
            requestOptions: req,
            statusCode: 409,
            data: {
              'code': 'CATEGORY_ALREADY_EXISTS',
              'message': '동일 ID의 카테고리가 이미 존재합니다.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(exc, isA<CategoryAlreadyExistsException>());
    });

    test('알 수 없는 code + 401 → 기본 AuthException', () {
      final e = _exception(
        statusCode: 401,
        data: {'code': 'UNKNOWN_CODE', 'message': '뭐 이상한 거'},
      );

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
