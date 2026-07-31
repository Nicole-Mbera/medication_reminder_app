import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String keyLanguage = 'pref_language';
  static const String keyFontSize = 'pref_font_size';
  static const String keyNotificationSounds = 'pref_notification_sounds';
  static const String keyOfflineMode = 'pref_offline_mode';

  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  static Future<SharedPrefsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsService(prefs);
  }

  // Language (default: 'English')
  String get language => _prefs.getString(keyLanguage) ?? 'English';
  Future<bool> setLanguage(String lang) => _prefs.setString(keyLanguage, lang);

  // Font Size (default: 'Normal') - 'Normal' | 'Large' | 'Extra Large'
  String get fontSize => _prefs.getString(keyFontSize) ?? 'Normal';
  Future<bool> setFontSize(String size) => _prefs.setString(keyFontSize, size);

  // Notification Sounds toggle (default: true)
  bool get notificationSounds => _prefs.getBool(keyNotificationSounds) ?? true;
  Future<bool> setNotificationSounds(bool enabled) =>
      _prefs.setBool(keyNotificationSounds, enabled);

  // Offline Mode indicator (default: false)
  bool get offlineMode => _prefs.getBool(keyOfflineMode) ?? false;
  Future<bool> setOfflineMode(bool enabled) =>
      _prefs.setBool(keyOfflineMode, enabled);
}
