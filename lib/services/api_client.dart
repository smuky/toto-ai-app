import 'package:http/http.dart' as http;
import 'language_preference_service.dart';

class ApiClient {
  static Future<Map<String, String>> _getHeaders() async {
    final language = await LanguagePreferenceService.getLanguage();
    return {
      'Content-Type': 'application/json',
      'Accept-Language': language,
    };
  }

  static Future<http.Response> get(Uri uri) async {
    final headers = await _getHeaders();
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> post(Uri uri, {Object? body}) async {
    final headers = await _getHeaders();
    return http.post(uri, headers: headers, body: body);
  }
}
