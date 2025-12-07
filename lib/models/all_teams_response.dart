import 'team.dart';
import 'translation_response.dart';

class AllTeamsResponse {
  final List<Team> teams;
  final TranslationResponse translations;

  const AllTeamsResponse({
    required this.teams,
    required this.translations,
  });

  factory AllTeamsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> teamsList = json['teams'] as List<dynamic>;
    final Map<String, dynamic> translationsJson = json['translations'] as Map<String, dynamic>? ?? {};
    
    return AllTeamsResponse(
      teams: teamsList.map((teamJson) => Team.fromJson(teamJson)).toList(),
      translations: TranslationResponse.fromJson(translationsJson),
    );
  }
}
