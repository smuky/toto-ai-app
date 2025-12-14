class LeagueLogosConfig {
  static const Map<String, String> leagueLogos = {
    'PREMIER_LEAGUE': 'https://media.api-sports.io/football/leagues/39.png',
    'LA_LIGA': 'https://media.api-sports.io/football/leagues/140.png',
    'SERIE_A': 'https://media.api-sports.io/football/leagues/135.png',
    'BUNDESLIGA': 'https://media.api-sports.io/football/leagues/78.png',
    'LIGUE_1': 'https://media.api-sports.io/football/leagues/61.png',
    'EREDIVISIE': 'https://media.api-sports.io/football/leagues/88.png',
    'PRIMEIRA_LIGA': 'https://media.api-sports.io/football/leagues/94.png',
    'CHAMPIONSHIP': 'https://media.api-sports.io/football/leagues/40.png',
    'LIGA_LEUMIT': 'https://media.api-sports.io/football/leagues/384.png',
    'ISRAELI_PREMIER_LEAGUE': 'https://media.api-sports.io/football/leagues/383.png',
  };

  static String? getLeagueLogo(String leagueEnum) {
    return leagueLogos[leagueEnum];
  }
}
