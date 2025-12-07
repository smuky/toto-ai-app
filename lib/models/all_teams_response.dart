import 'team.dart';

class AllTeamsResponse {
  final List<Team> teams;
  final Map<String, String> leagueTranslations;
  final String about;
  final String selectLeague;
  final String settings;

  const AllTeamsResponse({
    required this.teams,
    required this.leagueTranslations,
    required this.about,
    required this.selectLeague,
    required this.settings,
  });

  factory AllTeamsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> teamsList = json['teams'] as List<dynamic>;
    final Map<String, dynamic> translationsMap = json['leagueTranslations'] as Map<String, dynamic>;
    final String aboutText = json['about'] as String? ?? '';
    final String selectLeagueText = json['selectLeague'] as String? ?? 'Select League';
    final String settingsText = json['settings'] as String? ?? 'Settings';
    
    return AllTeamsResponse(
      teams: teamsList.map((teamJson) => Team.fromJson(teamJson)).toList(),
      leagueTranslations: translationsMap.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      about: aboutText,
      selectLeague: selectLeagueText,
      settings: settingsText,
    );
  }
}
