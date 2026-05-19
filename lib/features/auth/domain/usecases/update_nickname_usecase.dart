import '../../../../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';

/// 닉네임 변경 UseCase
///
/// **사전 검증** (api-docs.json 닉네임 규칙):
/// - 길이: 2 ~ 10 자
/// - 허용 문자: 한글, 영문 대소문자, 숫자
/// - 정규식: `^[가-힣a-zA-Z0-9]+$`
///
/// 클라이언트 검증 실패 시 즉시 [InvalidInputValueException] throw.
/// 서버측 race(동시에 다른 사용자가 같은 닉네임 점유) 는 repository 에서 처리.
class UpdateNicknameUseCase {
  static final RegExp _pattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
  static const int _minLength = 2;
  static const int _maxLength = 10;

  final AuthRepository _repository;

  UpdateNicknameUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<String> execute(String nickname) async {
    if (nickname.length < _minLength || nickname.length > _maxLength) {
      throw const InvalidInputValueException(
          message: '닉네임은 2자 이상 10자 이하여야 합니다.');
    }
    if (!_pattern.hasMatch(nickname)) {
      throw const InvalidInputValueException(
          message: '닉네임은 한글, 영문, 숫자만 사용할 수 있습니다.');
    }
    return _repository.updateNickname(nickname);
  }
}
