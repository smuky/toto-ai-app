class Team {
  final int id;
  final String name;
  final String? displayName;
  final String logo;
  final String leagueEnum;
  final int rank;
  final int points;
  final int goalsDiff;
  final String form;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;

  const Team({
    required this.id,
    required this.name,
    this.displayName,
    required this.logo,
    required this.leagueEnum,
    this.rank = 0,
    this.points = 0,
    this.goalsDiff = 0,
    this.form = '',
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  factory Team.fromStandingJson(Map<String, dynamic> json, String leagueEnum) {
    final teamData = json['team'] as Map<String, dynamic>;
    final allStats = json['all'] as Map<String, dynamic>;
    final goals = allStats['goals'] as Map<String, dynamic>;
    
    return Team(
      id: teamData['id'] as int,
      name: teamData['name'] as String,
      displayName: teamData['displayName'] as String?,
      logo: teamData['logo'] as String,
      leagueEnum: leagueEnum,
      rank: json['rank'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      goalsDiff: json['goalsDiff'] as int? ?? 0,
      form: json['form'] as String? ?? '',
      played: allStats['play'] as int? ?? 0,
      won: allStats['win'] as int? ?? 0,
      drawn: allStats['draw'] as int? ?? 0,
      lost: allStats['lose'] as int? ?? 0,
      goalsFor: goals['for'] as int? ?? 0,
      goalsAgainst: goals['against'] as int? ?? 0,
    );
  }

  String get effectiveName => displayName ?? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          leagueEnum == other.leagueEnum;

  @override
  int get hashCode => id.hashCode ^ leagueEnum.hashCode;
}

