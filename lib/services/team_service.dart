import 'dart:convert';
import '../models/standing_response.dart';
import '../models/translation_response.dart';
import '../models/fixture.dart';
import '../config/environment.dart';
import 'api_client.dart';

class TeamService {
  static Future<StandingResponse> fetchLeagueStanding(String leagueEnum) async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/api-football/standing', {'leagueEnum': leagueEnum})
          : Uri.http(AppConfig.apiBaseUrl, '/api-football/standing', {'leagueEnum': leagueEnum});

      final response = await ApiClient.get(uri);

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
          ? Uri.https(AppConfig.apiBaseUrl, '/league/translations')
          : Uri.http(AppConfig.apiBaseUrl, '/league/translations');

      final response = await ApiClient.get(uri);

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

  static Future<FixturesResponse> fetchUpcomingFixtures(String leagueEnum, int next) async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/api-football/fixtures/next', {
              'leagueEnum': leagueEnum,
              'next': next.toString(),
            })
          : Uri.http(AppConfig.apiBaseUrl, '/api-football/fixtures/next', {
              'leagueEnum': leagueEnum,
              'next': next.toString(),
            });

      final response = await ApiClient.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return FixturesResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load fixtures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fixtures: $e');
    }
  }

  static Future<FixturesResponse> fetchRecommendedList(String eventName) async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/api-football/fixtures/predefined', {
              'eventName': eventName,
            })
          : Uri.http(AppConfig.apiBaseUrl, '/api-football/fixtures/predefined', {
              'eventName': eventName,
            });

      final response = await ApiClient.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return FixturesResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load recommended list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommended list: $e');
    }
  }
}
