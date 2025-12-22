class PredefinedEvent {
  final String key;
  final String displayName;

  const PredefinedEvent({
    required this.key,
    required this.displayName,
  });

  factory PredefinedEvent.fromJson(Map<String, dynamic> json) {
    return PredefinedEvent(
      key: json['key'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
    );
  }
}

class UpgradeMessages {
  final String header;
  final String body;
  final String currentVersion;
  final String requiredVersion;
  final String button;

  const UpgradeMessages({
    required this.header,
    required this.body,
    required this.currentVersion,
    required this.requiredVersion,
    required this.button,
  });

  factory UpgradeMessages.fromJson(Map<String, dynamic> json) {
    return UpgradeMessages(
      header: json['header'] as String? ?? 'Mandatory Update',
      body: json['body'] as String? ?? 'To continue using the app and enjoy the latest features, please update to the most recent version.',
      currentVersion: json['currentVersion'] as String? ?? 'Current version:',
      requiredVersion: json['requiredVersion'] as String? ?? 'Required version:',
      button: json['button'] as String? ?? 'Update Now',
    );
  }
}

class PremiumBadgeMessages {
  final String title;
  final String body;
  final String button;
  final String back;

  const PremiumBadgeMessages({
    required this.title,
    required this.body,
    required this.button,
    required this.back,
  });

  factory PremiumBadgeMessages.fromJson(Map<String, dynamic> json) {
    return PremiumBadgeMessages(
      title: json['title'] as String? ?? 'This service is for PRO subscribers only',
      body: json['body'] as String? ?? 'All your ticket matches, organized in one place – no manual searching required. To unlock these curated lists and access exclusive features, upgrade to PRO and start betting smarter.',
      button: json['button'] as String? ?? 'Upgrade to PRO',
      back: json['back'] as String? ?? 'Back to Select League',
    );
  }
}

class TranslationResponse {
  final Map<String, String> leagueTranslations;
  final Map<String, String> languageTranslations;
  final List<PredefinedEvent> predefinedEvents;
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
  final String analyzing;
  final String analyzeMatch;
  final String selectLeagueMode;
  final String recommendedListsMode;
  final String termsOfUseTitle;
  final String termsOfUseHeader;
  final String termsOfUseStatisticalInfo;
  final String termsOfUseNotGambling;
  final String termsOfUseAgeRequirement;
  final String termsOfUseNoResponsibility;
  final String termsOfUseReadPolicy;
  final String termsOfUseAgreeContinue;
  final UpgradeMessages upgradeMessages;
  final PremiumBadgeMessages premiumBadgeMessages;

  const TranslationResponse({
    required this.leagueTranslations,
    required this.languageTranslations,
    required this.predefinedEvents,
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
    required this.analyzing,
    required this.analyzeMatch,
    required this.selectLeagueMode,
    required this.recommendedListsMode,
    required this.termsOfUseTitle,
    required this.termsOfUseHeader,
    required this.termsOfUseStatisticalInfo,
    required this.termsOfUseNotGambling,
    required this.termsOfUseAgeRequirement,
    required this.termsOfUseNoResponsibility,
    required this.termsOfUseReadPolicy,
    required this.termsOfUseAgreeContinue,
    required this.upgradeMessages,
    required this.premiumBadgeMessages,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> leagueTransMap = json['leagueTranslations'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> langTransMap = json['languageTranslations'] as Map<String, dynamic>? ?? {};
    final List<dynamic> predefinedEventsList = json['predefinedEvents'] as List<dynamic>? ?? [];
    
    return TranslationResponse(
      leagueTranslations: leagueTransMap.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      languageTranslations: langTransMap.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      predefinedEvents: predefinedEventsList
          .map((e) => PredefinedEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      analyzing: json['analyzing'] as String? ?? 'Analyzing...',
      analyzeMatch: json['analyzeMatch'] as String? ?? 'Analyze Match',
      selectLeagueMode: json['selectLeagueMode'] as String? ?? 'Select League',
      recommendedListsMode: json['recommendedListsMode'] as String? ?? 'Recommended Lists',
      termsOfUseTitle: json['termsOfUseTitle'] as String? ?? 'Welcome to 1X2-AI',
      termsOfUseHeader: json['termsOfUseHeader'] as String? ?? 'Before we start, please read and accept the following:',
      termsOfUseStatisticalInfo: json['termsOfUseStatisticalInfo'] as String? ?? 'This app provides statistical information only.',
      termsOfUseNotGambling: json['termsOfUseNotGambling'] as String? ?? 'This is NOT a gambling application.',
      termsOfUseAgeRequirement: json['termsOfUseAgeRequirement'] as String? ?? 'You must be 18+ years old to use this app.',
      termsOfUseNoResponsibility: json['termsOfUseNoResponsibility'] as String? ?? 'We are not responsible for any financial losses.',
      termsOfUseReadPolicy: json['termsOfUseReadPolicy'] as String? ?? 'Read full Privacy Policy & Terms',
      termsOfUseAgreeContinue: json['termsOfUseAgreeContinue'] as String? ?? 'I Agree & Continue',
      upgradeMessages: json['upgradeMessages'] != null
          ? UpgradeMessages.fromJson(json['upgradeMessages'] as Map<String, dynamic>)
          : const UpgradeMessages(
              header: 'Mandatory Update',
              body: 'To continue using the app and enjoy the latest features, please update to the most recent version.',
              currentVersion: 'Current version:',
              requiredVersion: 'Required version:',
              button: 'Update Now',
            ),
      premiumBadgeMessages: json['premiumBadgeMessages'] != null
          ? PremiumBadgeMessages.fromJson(json['premiumBadgeMessages'] as Map<String, dynamic>)
          : const PremiumBadgeMessages(
              title: 'This service is for PRO subscribers only',
              body: 'All your ticket matches, organized in one place – no manual searching required. To unlock these curated lists and access exclusive features, upgrade to PRO and start betting smarter.',
              button: 'Upgrade to PRO',
              back: 'Back to Select League',
            ),
    );
  }
}
