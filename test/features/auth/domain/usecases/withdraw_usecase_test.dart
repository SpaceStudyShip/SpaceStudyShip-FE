import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_study_ship/features/auth/domain/repositories/auth_repository.dart';
import 'package:space_study_ship/features/auth/domain/usecases/withdraw_usecase.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  test('execute() 는 repository.withdraw() 를 1회 호출한다', () async {
    final repo = _MockRepo();
    final useCase = WithdrawUseCase(repository: repo);

    when(() => repo.withdraw()).thenAnswer((_) async {});

    await useCase.execute();

    verify(() => repo.withdraw()).called(1);
  });
}
