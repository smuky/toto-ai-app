import 'package:http/http.dart' as http;
import 'package:toto_ai/services/auth_service.dart';
import 'language_preference_service.dart';

class ApiClient {
  static final _authService = AuthService();
  static const Duration _timeout = Duration(seconds: 10);

  static Future<Map<String, String>> _getHeaders() async {
    final language = await LanguagePreferenceService.getLanguage();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept-Language': language,
    };

    try {
      // Add auth headers with timeout to prevent blocking
      final authHeaders = await _authService.getAuthHeaders().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Warning: Auth headers timeout - continuing without auth');
          return <String, String>{};
        },
      );
      headers.addAll(authHeaders);
    } catch (e) {
      print('Warning: Could not add auth headers: $e');
    }

    return headers;
  }

  static Future<http.Response> get(Uri uri) async {
    final headers = await _getHeaders();
    print('Making GET request to: $uri');
    return http
        .get(uri, headers: headers)
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception('Request timeout: $uri');
          },
        );
  }

  static Future<http.Response> post(Uri uri, {Object? body}) async {
    final headers = await _getHeaders();
    print('Making POST request to: $uri');
    return http
        .post(uri, headers: headers, body: body)
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception('Request timeout: $uri');
          },
        );
  }
}
