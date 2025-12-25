import 'dart:convert';

import '../config/environment.dart';
import 'api_client.dart';

class UserPermissionService {
  static String? _cachedPermission;
  static bool _isInitialized = false;

  static String? get currentPermission => _cachedPermission;
  static bool get isPro => _cachedPermission != null && _cachedPermission !=
      'FREE';

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final uri = AppConfig.isHttps
          ? Uri.https(AppConfig.apiBaseUrl, '/api/permissions')
          : Uri.http(AppConfig.apiBaseUrl, '/api/permissions');

      final response = await ApiClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedPermission = data['permission'] as String? ?? 'FREE';
      } else {
        _cachedPermission = 'FREE';
      }
      print('User Permission Service: $_cachedPermission');
    } catch (e) {
      print('Error checking permissions: $e');
      _cachedPermission = 'FREE';
    } finally {
      _isInitialized = true;
    }
  }
}