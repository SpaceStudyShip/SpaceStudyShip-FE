import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:space_study_ship/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:space_study_ship/features/auth/data/models/check_nickname_response_model.dart';
import 'package:space_study_ship/features/auth/data/models/logout_request_model.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_request_model.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_response_model.dart';
import 'package:space_study_ship/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:space_study_ship/features/todo/data/datasources/local_todo_datasource.dart';

class _MockFirebase extends Mock implements FirebaseAuthDataSource {}

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockStorage extends Mock implements SecureTokenStorage {}

class _MockLocalTodo extends Mock implements LocalTodoDataSource {}

class _FakeUpdateReq extends Fake implements UpdateNicknameRequestModel {}

class _FakeLogoutReq extends Fake implements LogoutRequestModel {}

void main() {
  late _MockFirebase firebase;
  late _MockRemote remote;
  late _MockStorage storage;
  late _MockLocalTodo localTodo;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_FakeUpdateReq());
    registerFallbackValue(_FakeLogoutReq());
  });

  setUp(() {
    firebase = _MockFirebase();
    remote = _MockRemote();
    storage = _MockStorage();
    localTodo = _MockLocalTodo();
    repo = AuthRepositoryImpl(
      firebaseAuthDataSource: firebase,
      authRemoteDataSource: remote,
      tokenStorage: storage,
      localTodoDataSource: localTodo,
    );

    // Default stub: clearAll() 호출이 발생해도 기존 테스트들이 깨지지 않도록.
    when(() => localTodo.clearAll()).thenAnswer((_) async {});
  });

  group('updateNickname', () {
    test('성공 시 응답 닉네임 반환', () async {
      when(() => remote.updateNickname(any())).thenAnswer(
        (_) async => const UpdateNicknameResponseModel(nickname: '우주탐험가'),
      );

      final result = await repo.updateNickname('우주탐험가');

      expect(result, '우주탐험가');
      final captured =
          verify(() => remote.updateNickname(captureAny())).captured.single
              as UpdateNicknameRequestModel;
      expect(captured.nickname, '우주탐험가');
    });

    test('409 응답 → DuplicatedNicknameException', () async {
      final req = RequestOptions(path: '/api/auth/nickname');
      when(() => remote.updateNickname(any())).thenThrow(
        DioException(
          requestOptions: req,
          response: Response(
            requestOptions: req,
            statusCode: 409,
            data: {
              'code': 'DUPLICATED_NICKNAME',
              'message': '이미 사용 중인 닉네임입니다.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.updateNickname('우주탐험가'),
        throwsA(isA<DuplicatedNicknameException>()),
      );
    });
  });

  group('checkNickname', () {
    test('available: true 응답 → true 반환', () async {
      when(() => remote.checkNickname('우주탐험가')).thenAnswer(
        (_) async => const CheckNicknameResponseModel(available: true),
      );

      expect(await repo.checkNickname('우주탐험가'), isTrue);
    });

    test('available: false 응답 → false 반환', () async {
      when(() => remote.checkNickname('user')).thenAnswer(
        (_) async => const CheckNicknameResponseModel(available: false),
      );

      expect(await repo.checkNickname('user'), isFalse);
    });
  });

  group('withdraw', () {
    test('204 응답 시 Firebase signOut → clearTokens 순서로 호출', () async {
      when(() => remote.withdraw()).thenAnswer((_) async {});
      when(() => firebase.signOut()).thenAnswer((_) async {});
      when(() => storage.clearTokens()).thenAnswer((_) async {});

      await repo.withdraw();

      verifyInOrder([
        () => remote.withdraw(),
        () => firebase.signOut(),
        () => storage.clearTokens(),
      ]);
    });

    test('500 응답 시 토큰 유지 (clearTokens 미호출) 후 ServerException 전파', () async {
      final req = RequestOptions(path: '/api/auth/withdraw');
      when(() => remote.withdraw()).thenThrow(
        DioException(
          requestOptions: req,
          response: Response(
            requestOptions: req,
            statusCode: 500,
            data: {'code': 'INTERNAL_SERVER_ERROR', 'message': '서버 내부 오류'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(() => repo.withdraw(), throwsA(isA<ServerException>()));
      verifyNever(() => firebase.signOut());
      verifyNever(() => storage.clearTokens());
    });
  });

  group('Todo 캐시 정리', () {
    test('signOut 성공 시 LocalTodoDataSource.clearAll 호출', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'rt');
      when(() => remote.logout(any())).thenAnswer((_) async {});
      when(() => firebase.signOut()).thenAnswer((_) async {});
      when(() => storage.clearTokens()).thenAnswer((_) async {});
      when(() => localTodo.clearAll()).thenAnswer((_) async {});

      await repo.signOut();

      verify(() => localTodo.clearAll()).called(1);
    });

    test('withdraw 성공 시 LocalTodoDataSource.clearAll 호출', () async {
      when(() => remote.withdraw()).thenAnswer((_) async {});
      when(() => firebase.signOut()).thenAnswer((_) async {});
      when(() => storage.clearTokens()).thenAnswer((_) async {});
      when(() => localTodo.clearAll()).thenAnswer((_) async {});

      await repo.withdraw();

      verify(() => localTodo.clearAll()).called(1);
    });
  });
}
