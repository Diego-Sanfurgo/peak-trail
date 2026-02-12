import 'package:saltamontes/data/providers/settings_provider.dart';

class SettingsRepository {
  final SettingsProvider _settingsProvider;

  SettingsRepository(this._settingsProvider);

  bool isDarkMode() {
    return _settingsProvider.getThemeMode() ?? false;
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await _settingsProvider.setThemeMode(isDarkMode);
  }
}
