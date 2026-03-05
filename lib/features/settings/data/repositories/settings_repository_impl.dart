import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  AppSettingsEntity getSettings() {
    return AppSettingsEntity(
      starTwinkleEnabled: _dataSource.isStarTwinkleEnabled(),
    );
  }

  @override
  Future<void> setStarTwinkleEnabled({required bool isEnabled}) async {
    await _dataSource.setStarTwinkleEnabled(isEnabled: isEnabled);
  }
}
