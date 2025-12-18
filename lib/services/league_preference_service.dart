import 'package:shared_preferences/shared_preferences.dart';

class LeaguePreferenceService {
  static const String _leagueKey = 'selected_league';

  static Future<String?> getLeague() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_leagueKey);
  }

  static Future<void> setLeague(String leagueEnum) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_leagueKey, leagueEnum);
  }

  static Future<void> clearLeague() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_leagueKey);
  }
}
