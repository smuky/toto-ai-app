import 'team.dart';

class StandingResponse {
  final List<Team> teams;
  final String leagueEnum;

  const StandingResponse({
    required this.teams,
    required this.leagueEnum,
  });

  factory StandingResponse.fromJson(Map<String, dynamic> json, String leagueEnum) {
    final leagueData = json['league'] as Map<String, dynamic>;
    final standingsArray = leagueData['standings'] as List<dynamic>;
    
    // The standings is a nested array, get the first array
    final firstStandings = standingsArray.isNotEmpty ? standingsArray[0] as List<dynamic> : [];
    
    final teams = firstStandings
        .map((standing) => Team.fromStandingJson(standing as Map<String, dynamic>, leagueEnum))
        .toList();

    return StandingResponse(
      teams: teams,
      leagueEnum: leagueEnum,
    );
  }
}
