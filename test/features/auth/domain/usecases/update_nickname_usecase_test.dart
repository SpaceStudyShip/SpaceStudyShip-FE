import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/domain/usecases/update_nickname_usecase.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late UpdateNicknameUseCase useCase;

  setUp(() {
    repo = _MockRepo();
    useCase = UpdateNicknameUseCase(repository: repo);
  });

  group('사전 정규식 검증', () {
    test('빈 문자열 → InvalidInputValueException', () {
      expect(
        () => useCase.execute(''),
        throwsA(isA<InvalidInputValueException>()),
      );
      verifyNever(() => repo.updateNickname(any()));
    });

    test('1자 (너무 짧음) → InvalidInputValueException', () {
      expect(
        () => useCase.execute('가'),
        throwsA(isA<InvalidInputValueException>()),
      );
    });

    test('11자 (너무 김) → InvalidInputValueException', () {
      expect(
        () => useCase.execute('우주탐험가1234567'),
        throwsA(isA<InvalidInputValueException>()),
      );
    });

    test('특수문자 포함 → InvalidInputValueException', () {
      expect(
        () => useCase.execute('우주!'),
        throwsA(isA<InvalidInputValueException>()),
      );
    });

    test('이모지 포함 → InvalidInputValueException', () {
      expect(
        () => useCase.execute('우주\u{1F680}'),
        throwsA(isA<InvalidInputValueException>()),
      );
    });

    test('공백 포함 → InvalidInputValueException', () {
      expect(
        () => useCase.execute('우주 탐험가'),
        throwsA(isA<InvalidInputValueException>()),
      );
    });
  });

  group('정규식 통과', () {
    test('한글 2-10자 → repository 호출', () async {
      when(() => repo.updateNickname('우주탐험가')).thenAnswer((_) async => '우주탐험가');

      final result = await useCase.execute('우주탐험가');

      expect(result, '우주탐험가');
      verify(() => repo.updateNickname('우주탐험가')).called(1);
    });

    test('영문+숫자 → repository 호출', () async {
      when(
        () => repo.updateNickname('user123'),
      ).thenAnswer((_) async => 'user123');

      expect(await useCase.execute('user123'), 'user123');
    });
  });
}
