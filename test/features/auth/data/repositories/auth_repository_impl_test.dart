import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/core/storage/secure_token_storage.dart';
import 'package:space_study_ship/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:space_study_ship/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:space_study_ship/features/auth/data/models/check_nickname_response_model.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_request_model.dart';
import 'package:space_study_ship/features/auth/data/models/update_nickname_response_model.dart';
import 'package:space_study_ship/features/auth/data/repositories/auth_repository_impl.dart';

class _MockFirebase extends Mock implements FirebaseAuthDataSource {}

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockStorage extends Mock implements SecureTokenStorage {}

class _FakeUpdateReq extends Fake implements UpdateNicknameRequestModel {}

void main() {
  late _MockFirebase firebase;
  late _MockRemote remote;
  late _MockStorage storage;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_FakeUpdateReq());
  });

  setUp(() {
    firebase = _MockFirebase();
    remote = _MockRemote();
    storage = _MockStorage();
    repo = AuthRepositoryImpl(
      firebaseAuthDataSource: firebase,
      authRemoteDataSource: remote,
      tokenStorage: storage,
    );
  });

  group('updateNickname', () {
    test('성공 시 응답 닉네임 반환', () async {
      when(() => remote.updateNickname(any())).thenAnswer(
          (_) async => const UpdateNicknameResponseModel(nickname: '우주탐험가'));

      final result = await repo.updateNickname('우주탐험가');

      expect(result, '우주탐험가');
      final captured =
          verify(() => remote.updateNickname(captureAny())).captured.single
              as UpdateNicknameRequestModel;
      expect(captured.nickname, '우주탐험가');
    });

    test('409 응답 → DuplicatedNicknameException', () async {
      final req = RequestOptions(path: '/api/auth/nickname');
      when(() => remote.updateNickname(any())).thenThrow(DioException(
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
      ));

      expect(() => repo.updateNickname('우주탐험가'),
          throwsA(isA<DuplicatedNicknameException>()));
    });
  });

  group('checkNickname', () {
    test('available: true 응답 → true 반환', () async {
      when(() => remote.checkNickname('우주탐험가')).thenAnswer(
          (_) async => const CheckNicknameResponseModel(available: true));

      expect(await repo.checkNickname('우주탐험가'), isTrue);
    });

    test('available: false 응답 → false 반환', () async {
      when(() => remote.checkNickname('user')).thenAnswer(
          (_) async => const CheckNicknameResponseModel(available: false));

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
      when(() => remote.withdraw()).thenThrow(DioException(
        requestOptions: req,
        response: Response(
          requestOptions: req,
          statusCode: 500,
          data: {
            'code': 'INTERNAL_SERVER_ERROR',
            'message': '서버 내부 오류',
          },
        ),
        type: DioExceptionType.badResponse,
      ));

      expect(() => repo.withdraw(), throwsA(isA<ServerException>()));
      verifyNever(() => firebase.signOut());
      verifyNever(() => storage.clearTokens());
    });
  });
}
