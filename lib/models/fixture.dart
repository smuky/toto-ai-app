class Fixture {
  final int fixtureId;
  final String homeTeam;
  final String? homeTeamDisplayName;
  final String awayTeam;
  final String? awayTeamDisplayName;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final DateTime date;
  final String status;
  final String venue;

  Fixture({
    required this.fixtureId,
    required this.homeTeam,
    this.homeTeamDisplayName,
    required this.awayTeam,
    this.awayTeamDisplayName,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.date,
    required this.status,
    required this.venue,
  });

  String get effectiveHomeTeam => homeTeamDisplayName ?? homeTeam;
  String get effectiveAwayTeam => awayTeamDisplayName ?? awayTeam;

  factory Fixture.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>? ?? {};
    final teams = json['teams'] as Map<String, dynamic>? ?? {};
    final home = teams['home'] as Map<String, dynamic>? ?? {};
    final away = teams['away'] as Map<String, dynamic>? ?? {};
    final venueData = fixture['venue'] as Map<String, dynamic>? ?? {};
    final statusData = fixture['status'] as Map<String, dynamic>? ?? {};

    return Fixture(
      fixtureId: fixture['id'] ?? 0,
      homeTeam: home['name'] ?? '',
      homeTeamDisplayName: home['displayName'] as String?,
      awayTeam: away['name'] ?? '',
      awayTeamDisplayName: away['displayName'] as String?,
      homeTeamLogo: home['logo'] ?? '',
      awayTeamLogo: away['logo'] ?? '',
      date: DateTime.parse(fixture['date'] ?? DateTime.now().toIso8601String()),
      status: statusData['long'] ?? 'Scheduled',
      venue: venueData['name'] ?? '',
    );
  }
}

class FixturesResponse {
  final List<Fixture> fixtures;

  FixturesResponse({required this.fixtures});

  factory FixturesResponse.fromJson(List<dynamic> jsonList) {
    return FixturesResponse(
      fixtures: jsonList.map((f) => Fixture.fromJson(f as Map<String, dynamic>)).toList(),
    );
  }
}
