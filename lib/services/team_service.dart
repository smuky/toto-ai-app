import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/all_teams_response.dart';
import '../config/environment.dart';

class TeamService {
  static Future<AllTeamsResponse> fetchAllTeams(String language) async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/league/all', {'language': language})
          : Uri.http(AppConfig.apiBaseUrl, '/league/all', {'language': language});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return AllTeamsResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }
}
