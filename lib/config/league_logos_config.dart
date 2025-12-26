class LeagueLogosConfig {
  static const Map<String, String> leagueLogos = {
    'PREMIER_LEAGUE': 'https://media.api-sports.io/football/leagues/39.png',
    'ENGLISH_CHAMPIONS_LEAGUE': 'https://media.api-sports.io/football/leagues/40.png',
    'ENGLISH_LEAGUE_ONE': 'https://media.api-sports.io/football/leagues/41.png',
    'LA_LIGA': 'https://media.api-sports.io/football/leagues/140.png',
    'ITALIAN_SERIE_A': 'https://media.api-sports.io/football/leagues/135.png',
    'BUNDESLIGA': 'https://media.api-sports.io/football/leagues/78.png',
    'FRANCE_LIGUE_1': 'https://media.api-sports.io/football/leagues/61.png',
    'ISRAEL_NATIONAL_LEAGUE': 'https://media.api-sports.io/football/leagues/382.png',
    'ISRAEL_WINNER': 'https://media.api-sports.io/football/leagues/383.png',
    'BELGIUM_JUPILER_PRO_LEAGUE': 'https://media.api-sports.io/football/leagues/144.png',
    'AFRICA_CUP_OF_NATIONS': 'https://media.api-sports.io/football/leagues/6.png',
    // Legacy mappings for backward compatibility
    'SERIE_A': 'https://media.api-sports.io/football/leagues/135.png',
    'LIGUE_1': 'https://media.api-sports.io/football/leagues/61.png',
    'EREDIVISIE': 'https://media.api-sports.io/football/leagues/88.png',
    'PRIMEIRA_LIGA': 'https://media.api-sports.io/football/leagues/94.png',
    'CHAMPIONSHIP': 'https://media.api-sports.io/football/leagues/40.png',
    'LIGA_LEUMIT': 'https://media.api-sports.io/football/leagues/382.png',
    'ISRAELI_PREMIER_LEAGUE': 'https://media.api-sports.io/football/leagues/383.png',
  };

  static String? getLeagueLogo(String leagueEnum) {
    return leagueLogos[leagueEnum];
  }
}
