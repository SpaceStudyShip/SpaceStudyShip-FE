import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/core/errors/app_exception.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/domain/usecases/check_nickname_usecase.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late CheckNicknameUseCase useCase;

  setUp(() {
    repo = _MockRepo();
    useCase = CheckNicknameUseCase(repository: repo);
  });

  test('형식 불일치 → InvalidInputValueException', () {
    expect(() => useCase.execute('a'),
        throwsA(isA<InvalidInputValueException>()));
    verifyNever(() => repo.checkNickname(any()));
  });

  test('형식 통과 + available=true → true', () async {
    when(() => repo.checkNickname('우주탐험가')).thenAnswer((_) async => true);
    expect(await useCase.execute('우주탐험가'), isTrue);
  });

  test('형식 통과 + available=false → false', () async {
    when(() => repo.checkNickname('taken')).thenAnswer((_) async => false);
    expect(await useCase.execute('taken'), isFalse);
  });
}
