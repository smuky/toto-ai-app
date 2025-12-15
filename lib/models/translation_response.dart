class TranslationResponse {
  final Map<String, String> leagueTranslations;
  final Map<String, String> languageTranslations;
  final String selectLeague;
  final String settings;
  final String about;
  final String draw;
  final String vs;
  final String winProbabilities;
  final String predictionJustification;
  final String detailedAnalysis;
  final String recentFormAnalysis;
  final String expectedGoalsAnalysis;
  final String headToHeadSummary;
  final String keyNewsInjuries;
  final String results;
  final String customMatch;
  final String upcomingGames;

  const TranslationResponse({
    required this.leagueTranslations,
    required this.languageTranslations,
    required this.selectLeague,
    required this.settings,
    required this.about,
    required this.draw,
    required this.vs,
    required this.winProbabilities,
    required this.predictionJustification,
    required this.detailedAnalysis,
    required this.recentFormAnalysis,
    required this.expectedGoalsAnalysis,
    required this.headToHeadSummary,
    required this.keyNewsInjuries,
    required this.results,
    required this.customMatch,
    required this.upcomingGames,
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
      draw: json['draw'] as String? ?? 'Draw',
      vs: json['vs'] as String? ?? 'VS',
      winProbabilities: json['winProbabilities'] as String? ?? 'Win Probabilities',
      predictionJustification: json['predictionJustification'] as String? ?? 'Prediction Justification',
      detailedAnalysis: json['detailedAnalysis'] as String? ?? 'Detailed Analysis',
      recentFormAnalysis: json['recentFormAnalysis'] as String? ?? 'Recent Form Analysis',
      expectedGoalsAnalysis: json['expectedGoalsAnalysis'] as String? ?? 'Expected Goals (xG) Analysis',
      headToHeadSummary: json['headToHeadSummary'] as String? ?? 'Head-to-Head Summary',
      keyNewsInjuries: json['keyNewsInjuries'] as String? ?? 'Key News & Injuries',
      results: json['results'] as String? ?? 'Results',
      customMatch: json['customMatch'] as String? ?? 'Custom Match',
      upcomingGames: json['upcomingGames'] as String? ?? 'Upcoming Games',
    );
  }
}
