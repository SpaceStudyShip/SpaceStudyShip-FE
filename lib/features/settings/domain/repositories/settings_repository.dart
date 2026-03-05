import '../entities/app_settings_entity.dart';

abstract class SettingsRepository {
  AppSettingsEntity getSettings();
  Future<void> setStarTwinkleEnabled({required bool isEnabled});
}
