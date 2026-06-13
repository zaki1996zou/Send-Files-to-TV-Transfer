import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.preferMp4ForCasting,
    required this.showCompatibilityWarning,
    required this.saveTransferHistory,
  });

  final bool preferMp4ForCasting;
  final bool showCompatibilityWarning;
  final bool saveTransferHistory;

  static const defaults = AppSettings(
    preferMp4ForCasting: true,
    showCompatibilityWarning: true,
    saveTransferHistory: true,
  );

  AppSettings copyWith({
    bool? preferMp4ForCasting,
    bool? showCompatibilityWarning,
    bool? saveTransferHistory,
  }) {
    return AppSettings(
      preferMp4ForCasting: preferMp4ForCasting ?? this.preferMp4ForCasting,
      showCompatibilityWarning:
          showCompatibilityWarning ?? this.showCompatibilityWarning,
      saveTransferHistory: saveTransferHistory ?? this.saveTransferHistory,
    );
  }
}

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _keyPreferMp4 = 'prefer_mp4_for_casting';
  static const _keyCompatibilityWarning = 'show_compatibility_warning';
  static const _keySaveHistory = 'save_transfer_history';

  AppSettings _settings = AppSettings.defaults;
  bool _loaded = false;

  AppSettings get settings => _settings;
  bool get isLoaded => _loaded;

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = AppSettings(
      preferMp4ForCasting: prefs.getBool(_keyPreferMp4) ?? true,
      showCompatibilityWarning: prefs.getBool(_keyCompatibilityWarning) ?? true,
      saveTransferHistory: prefs.getBool(_keySaveHistory) ?? true,
    );
    _loaded = true;
    return _settings;
  }

  Future<void> updatePreferMp4ForCasting(bool value) async {
    _settings = _settings.copyWith(preferMp4ForCasting: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPreferMp4, value);
  }

  Future<void> updateShowCompatibilityWarning(bool value) async {
    _settings = _settings.copyWith(showCompatibilityWarning: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompatibilityWarning, value);
  }

  Future<void> updateSaveTransferHistory(bool value) async {
    _settings = _settings.copyWith(saveTransferHistory: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySaveHistory, value);
  }
}
