import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  final SharedPreferences _prefs;

  SettingsProvider(this._prefs);

  static const String _themeKey = 'is_dark_mode';

  bool? getThemeMode() {
    return _prefs.getBool(_themeKey);
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    await _prefs.setBool(_themeKey, isDarkMode);
  }
}
