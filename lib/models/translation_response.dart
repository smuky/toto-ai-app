class TranslationResponse {
  final Map<String, String> leagueTranslations;
  final Map<String, String> languageTranslations;
  final String selectLeague;
  final String settings;
  final String about;

  const TranslationResponse({
    required this.leagueTranslations,
    required this.languageTranslations,
    required this.selectLeague,
    required this.settings,
    required this.about,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> leagueTransMap = json['leagueTranslations'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> langTransMap = json['languageTranslations'] as Map<String, dynamic>? ?? {};
    
    return TranslationResponse(
      leagueTranslations: leagueTransMap.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      languageTranslations: langTransMap.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      selectLeague: json['selectLeague'] as String? ?? 'Select League',
      settings: json['settings'] as String? ?? 'Settings',
      about: json['about'] as String? ?? '',
    );
  }
}
