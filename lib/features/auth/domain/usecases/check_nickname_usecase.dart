import '../../../../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';

/// 닉네임 중복 확인 UseCase
///
/// 사전 검증 규칙은 [UpdateNicknameUseCase] 와 동일.
/// 통과 시 repository 호출하여 서버 응답의 `available` 그대로 반환.
class CheckNicknameUseCase {
  static final RegExp _pattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
  static const int _minLength = 2;
  static const int _maxLength = 10;

  final AuthRepository _repository;

  CheckNicknameUseCase({required AuthRepository repository})
    : _repository = repository;

  Future<bool> execute(String nickname) async {
    if (nickname.length < _minLength || nickname.length > _maxLength) {
      throw const InvalidInputValueException(
        message: '닉네임은 2자 이상 10자 이하여야 합니다.',
      );
    }
    if (!_pattern.hasMatch(nickname)) {
      throw const InvalidInputValueException(
        message: '닉네임은 한글, 영문, 숫자만 사용할 수 있습니다.',
      );
    }
    return _repository.checkNickname(nickname);
  }
}
