import '../repositories/auth_repository.dart';

/// 회원 탈퇴 UseCase
///
/// `DELETE /api/auth/withdraw` 호출. 토큰 삭제 + Firebase signOut 은
/// Repository 내부에서 트랜잭션 단위로 처리.
class WithdrawUseCase {
  final AuthRepository _repository;

  WithdrawUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<void> execute() => _repository.withdraw();
}
