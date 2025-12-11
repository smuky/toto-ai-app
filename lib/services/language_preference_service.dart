import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/language_config.dart';

class LanguagePreferenceService {
  static const String _languageKey = 'response_language';
  static const String _hasInitializedKey = 'language_initialized';

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    
    final hasInitialized = prefs.getBool(_hasInitializedKey) ?? false;
    
    if (!hasInitialized) {
      final deviceLocale = _getDeviceLocale();
      final languageCode = _mapLocaleToSupportedLanguage(deviceLocale);
      
      await prefs.setString(_languageKey, languageCode);
      await prefs.setBool(_hasInitializedKey, true);
      
      return languageCode;
    }
    
    return prefs.getString(_languageKey) ?? LanguageConfig.defaultLanguage;
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    await prefs.setBool(_hasInitializedKey, true);
  }
  
  static String _getDeviceLocale() {
    final locale = ui.PlatformDispatcher.instance.locale;
    return locale.languageCode;
  }
  
  static String _mapLocaleToSupportedLanguage(String localeCode) {
    if (LanguageConfig.isSupported(localeCode)) {
      return localeCode;
    }
    return LanguageConfig.defaultLanguage;
  }
}
