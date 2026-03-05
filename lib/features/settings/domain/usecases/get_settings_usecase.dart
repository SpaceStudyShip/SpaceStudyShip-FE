import '../entities/app_settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  AppSettingsEntity execute() {
    return _repository.getSettings();
  }
}
