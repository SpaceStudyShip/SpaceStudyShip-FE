import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  static const _keyStarTwinkle = 'settings_star_twinkle_enabled';

  final SharedPreferences _prefs;

  SettingsLocalDataSource(this._prefs);

  bool getStarTwinkleEnabled() {
    return _prefs.getBool(_keyStarTwinkle) ?? true;
  }

  Future<void> setStarTwinkleEnabled({required bool enabled}) async {
    await _prefs.setBool(_keyStarTwinkle, enabled);
  }
}
