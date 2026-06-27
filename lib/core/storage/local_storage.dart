import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';

class LocalStorageHelper {
  final SharedPreferences _prefs;

  LocalStorageHelper(this._prefs);

  // Theme
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppConstants.themeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.themeKey) ?? 'system';
  }

  // Language
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(AppConstants.languageKey, language);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  // First Launch
  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(AppConstants.firstLaunchKey, false);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(AppConstants.firstLaunchKey) ?? true;
  }

  // Generic Methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
