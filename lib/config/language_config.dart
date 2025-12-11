class LanguageConfig {
  static const String defaultLanguage = 'en';
  
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'it': 'Italian',
    'es': 'Spanish',
    'de': 'German',
    'he': 'Hebrew',
    'fr': 'French',
  };
  
  static List<String> get languageCodes => supportedLanguages.keys.toList();
  
  static bool isSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }
  
  static String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? supportedLanguages[defaultLanguage]!;
  }
}
