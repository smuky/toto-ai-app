import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/standing_response.dart';
import '../models/translation_response.dart';
import '../config/environment.dart';

class TeamService {
  static Future<StandingResponse> fetchLeagueStanding(String leagueEnum) async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/api-football/standing', {'leagueEnum': leagueEnum})
          : Uri.http(AppConfig.apiBaseUrl, '/api-football/standing', {'leagueEnum': leagueEnum});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return StandingResponse.fromJson(jsonResponse, leagueEnum);
      } else {
        throw Exception('Failed to load standing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching standing: $e');
    }
  }

  static Future<TranslationResponse> fetchTranslations(String language) async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/league/translations', {'language': language})
          : Uri.http(AppConfig.apiBaseUrl, '/league/translations', {'language': language});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TranslationResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load translations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching translations: $e');
    }
  }
}
