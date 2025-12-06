import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferenceService {
  static const String _languageKey = 'response_language';
  static const String _defaultLanguage = 'en';

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}
