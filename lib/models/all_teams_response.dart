import 'team.dart';

class AllTeamsResponse {
  final List<Team> teams;
  final Map<String, String> leagueTranslations;

  const AllTeamsResponse({
    required this.teams,
    required this.leagueTranslations,
  });

  factory AllTeamsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> teamsList = json['teams'] as List<dynamic>;
    final Map<String, dynamic> translationsMap = json['leagueTranslations'] as Map<String, dynamic>;
    
    return AllTeamsResponse(
      teams: teamsList.map((teamJson) => Team.fromJson(teamJson)).toList(),
      leagueTranslations: translationsMap.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
