class Team {
  final String name;
  final String leagueEnum;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;
  final String form;

  const Team({
    required this.name,
    required this.leagueEnum,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.goalDifference = 0,
    this.points = 0,
    this.form = '',
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['team'] as String,
      leagueEnum: json['leagueEnum'] as String,
      played: json['played'] as int? ?? 0,
      won: json['won'] as int? ?? 0,
      drawn: json['drawn'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      goalsFor: json['goalsFor'] as int? ?? 0,
      goalsAgainst: json['goalsAgainst'] as int? ?? 0,
      goalDifference: json['goalDifference'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      form: json['form'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          leagueEnum == other.leagueEnum;

  @override
  int get hashCode => name.hashCode ^ leagueEnum.hashCode;
}

