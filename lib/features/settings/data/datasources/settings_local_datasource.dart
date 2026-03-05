import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  static const _keyStarTwinkle = 'settings_star_twinkle_enabled';

  final SharedPreferences _prefs;

  SettingsLocalDataSource(this._prefs);

  bool isStarTwinkleEnabled() {
    return _prefs.getBool(_keyStarTwinkle) ?? true;
  }

  Future<void> setStarTwinkleEnabled({required bool isEnabled}) async {
    final isSaved = await _prefs.setBool(_keyStarTwinkle, isEnabled);
    if (!isSaved) {
      throw Exception('SharedPreferences 저장 실패: $_keyStarTwinkle');
    }
  }
}
