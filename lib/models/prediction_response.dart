class PredictionResponse {
  final MatchDetails matchDetails;
  final PredictionStats analysis;
  final Map<String, int> probabilities;
  final String justification;

  PredictionResponse({
    required this.matchDetails,
    required this.analysis,
    required this.probabilities,
    required this.justification,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    // Parse probabilities with type conversion to handle both int and string
    final Map<String, int> parsedProbabilities = {};
    final probsMap = json['probabilities'] as Map<String, dynamic>;
    probsMap.forEach((key, value) {
      parsedProbabilities[key] = value is int ? value : int.parse(value.toString());
    });

    return PredictionResponse(
      matchDetails: MatchDetails.fromJson(json['matchDetails']),
      analysis: PredictionStats.fromJson(json['analysis']),
      probabilities: parsedProbabilities,
      justification: json['justification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchDetails': matchDetails.toJson(),
      'analysis': analysis.toJson(),
      'probabilities': probabilities,
      'justification': justification,
    };
  }
}

class MatchDetails {
  final String date;
  final String competition;
  final String venue;
  final String homeTeam;
  final String awayTeam;

  MatchDetails({
    required this.date,
    required this.competition,
    required this.venue,
    required this.homeTeam,
    required this.awayTeam,
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    return MatchDetails(
      date: json['date'],
      competition: json['competition'],
      venue: json['venue'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'competition': competition,
      'venue': venue,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
    };
  }
}

class PredictionStats {
  final String recentFormAnalysis;
  final String xGAnalysis;
  final String headToHeadSummary;
  final String keyNews;

  PredictionStats({
    required this.recentFormAnalysis,
    required this.xGAnalysis,
    required this.headToHeadSummary,
    required this.keyNews,
  });

  factory PredictionStats.fromJson(Map<String, dynamic> json) {
    return PredictionStats(
      recentFormAnalysis: json['recentFormAnalysis'],
      xGAnalysis: json['xGAnalysis'],
      headToHeadSummary: json['headToHeadSummary'],
      keyNews: json['keyNews'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recentFormAnalysis': recentFormAnalysis,
      'xGAnalysis': xGAnalysis,
      'headToHeadSummary': headToHeadSummary,
      'keyNews': keyNews,
    };
  }
}
