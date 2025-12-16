import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class VersionCheckService {
  /// Fetches the minimum required app version from the server
  /// 
  /// Returns the minimum version string (e.g., "1.0.0") or null if unavailable
  static Future<String?> getMinimumVersion() async {
    try {
      final uri = AppConfig.isHttps
          ? Uri.https(
              AppConfig.apiBaseUrl,
              '/version',
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              '/version',
            );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final appMinVersion = data['appMinVersion'] as String?;
        print('VersionCheckService: Received appMinVersion: $appMinVersion');
        return appMinVersion;
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      print('VersionCheckService: Failed to fetch version: $e');
      // Return null on error - app will continue to work
      return null;
    }
  }

  /// Checks if the current app version meets the minimum requirement
  /// 
  /// Returns:
  /// - true: App version is acceptable
  /// - false: App version is too old, update required
  static Future<bool> isVersionSupported(String currentVersion) async {
    try {
      final minVersion = await getMinimumVersion();
      
      if (minVersion == null || minVersion.isEmpty) {
        // If server doesn't return minimum version, allow app to continue
        print('VersionCheckService: No minimum version requirement, allowing app to continue');
        return true;
      }

      final isSupported = _compareVersions(currentVersion, minVersion) >= 0;
      
      print('VersionCheckService: Current: $currentVersion, Min: $minVersion, Supported: $isSupported');
      
      return isSupported;
    } catch (e) {
      print('VersionCheckService: Error checking version support: $e');
      // On error, allow app to continue
      return true;
    }
  }

  /// Compares two version strings with optional build numbers
  /// 
  /// Supports formats: "1.2.3" or "1.2.3+24"
  /// 
  /// Returns:
  /// - Positive number: version1 > version2
  /// - Zero: version1 == version2
  /// - Negative number: version1 < version2
  /// 
  /// Example: _compareVersions("1.2.3+25", "1.2.3+24") returns 1
  static int _compareVersions(String version1, String version2) {
    // Split version and build number (format: 1.2.3+24)
    final v1Split = version1.split('+');
    final v2Split = version2.split('+');
    
    final v1Version = v1Split[0];
    final v2Version = v2Split[0];
    
    final v1Build = v1Split.length > 1 ? int.parse(v1Split[1]) : 0;
    final v2Build = v2Split.length > 1 ? int.parse(v2Split[1]) : 0;
    
    // Parse version parts (1.2.3)
    final v1Parts = v1Version.split('.').map(int.parse).toList();
    final v2Parts = v2Version.split('.').map(int.parse).toList();

    // Pad shorter version with zeros
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }

    // Compare each version part
    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] != v2Parts[i]) {
        return v1Parts[i] - v2Parts[i];
      }
    }

    // If versions are equal, compare build numbers
    return v1Build - v2Build;
  }
}
