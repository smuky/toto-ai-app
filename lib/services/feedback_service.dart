import 'dart:convert';
import '../config/environment.dart';
import 'api_client.dart';

class FeedbackService {
  /// Submits user feedback to the server
  /// 
  /// Parameters:
  /// - message: User's feedback message (required)
  /// - userEmail: User's email address (optional)
  /// - appVersion: App version from package info
  /// - buildNumber: Build number from package info
  /// - deviceModel: Device model information
  /// - operatingSystem: OS name and version
  /// - locale: User's locale
  /// - timezone: User's timezone
  static Future<void> submitFeedback({
    required String message,
    String? userEmail,
    required String appVersion,
    required String buildNumber,
    required String deviceModel,
    required String operatingSystem,
    required String locale,
    required String timezone,
  }) async {
    try {
      // Construct the feedback endpoint
      final uri = AppConfig.isHttps
          ? Uri.https(
              AppConfig.apiBaseUrl,
              '/feedback',
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              '/feedback',
            );

      // Prepare the request body
      final body = {
        'message': message,
        'userEmail': userEmail,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'deviceModel': deviceModel,
        'operatingSystem': operatingSystem,
        'locale': locale,
        'timezone': timezone,
      };

      final response = await ApiClient.post(uri, body: jsonEncode(body));

      // Check response status
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned status ${response.statusCode}: ${response.body}');
      }

      print('FeedbackService: Feedback submitted successfully');
    } catch (e) {
      print('FeedbackService: Failed to submit feedback: $e');
      rethrow;
    }
  }
}
