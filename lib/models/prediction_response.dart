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
      if (value is int) {
        parsedProbabilities[key] = value;
      } else {
        // Remove % sign if present and parse as int
        final stringValue = value.toString().replaceAll('%', '').trim();
        parsedProbabilities[key] = int.parse(stringValue);
      }
    });

    return PredictionResponse(
      matchDetails: MatchDetails.fromJson(json['matchDetails']),
      analysis: PredictionStats.fromJson(json['analysis']),
      probabilities: parsedProbabilities,
      justification: json['justification'] ?? 'No justification provided',
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
      date: json['date'] ?? 'N/A',
      competition: json['competition'] ?? 'N/A',
      venue: json['venue'] ?? 'N/A',
      homeTeam: json['homeTeam'] ?? 'Unknown',
      awayTeam: json['awayTeam'] ?? 'Unknown',
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
      recentFormAnalysis: json['recentFormAnalysis'] ?? 'No data available',
      xGAnalysis: json['xGAnalysis'] ?? 'No data available',
      headToHeadSummary: json['headToHeadSummary'] ?? 'No data available',
      keyNews: json['keyNews'] ?? 'No news available',
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
