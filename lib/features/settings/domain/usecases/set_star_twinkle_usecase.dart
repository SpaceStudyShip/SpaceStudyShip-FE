import '../repositories/settings_repository.dart';

class SetStarTwinkleUseCase {
  final SettingsRepository _repository;

  SetStarTwinkleUseCase(this._repository);

  Future<void> execute({required bool isEnabled}) {
    return _repository.setStarTwinkleEnabled(isEnabled: isEnabled);
  }
}
