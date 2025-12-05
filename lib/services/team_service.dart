import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../config/environment.dart';

class TeamService {
  static Future<List<Team>> fetchAllTeams() async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/league/all')
          : Uri.http(AppConfig.apiBaseUrl, '/league/all');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Team.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }
}
