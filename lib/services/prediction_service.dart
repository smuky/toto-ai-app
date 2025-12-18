import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/translation_response.dart';
import '../pages/results_page.dart';
import '../services/admob_service.dart';
import '../services/review_service.dart';

class PredictionService {
  /// Fetches prediction from the API and navigates to ResultsPage
  /// 
  /// Parameters:
  /// - context: BuildContext for navigation
  /// - homeTeam: Home team name (should use displayName if available)
  /// - awayTeam: Away team name (should use displayName if available)
  /// - league: League enum string
  /// - language: Selected language code
  /// - translations: Translation response object
  /// - onLoadingChanged: Callback to update loading state in the calling widget
  static Future<void> fetchPredictionAndNavigate({
    required BuildContext context,
    required String homeTeam,
    required String awayTeam,
    required String league,
    required String language,
    required TranslationResponse translations,
    required Function(bool) onLoadingChanged,
  }) async {
    // Start loading
    onLoadingChanged(true);

    // Start haptic feedback
    Timer? hapticTimer;
    hapticTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      HapticFeedback.lightImpact();
    });

    String responseText;
    bool isError;

    try {
      final uri = AppConfig.isHttps
          ? Uri.https(
              AppConfig.apiBaseUrl,
              AppConfig.apiPath,
              {
                'home-team': homeTeam,
                'away-team': awayTeam,
                'league': league,
                'language': language.toUpperCase(),
              },
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              AppConfig.apiPath,
              {
                'home-team': homeTeam,
                'away-team': awayTeam,
                'league': league,
                'language': language.toUpperCase(),
              },
            );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        responseText = response.body;
        isError = false;
      } else {
        responseText = 'Server returned status ${response.statusCode}.\n\nBody:\n${response.body}';
        isError = true;
      }
    } catch (e) {
      responseText = 'Failed to contact server:\n$e';
      isError = true;
    }

    // Stop haptic feedback
    hapticTimer.cancel();

    // Stop loading
    onLoadingChanged(false);

    // Check if context is still mounted before navigation
    if (!context.mounted) return;

    // Increment review counter if result was successful (not an error)
    if (!isError) {
      await ReviewService.onResultReceived();
    }

    // Show interstitial ad if available
    if (kReleaseMode && AdMobService.isInterstitialAdReady) {
      AdMobService.showInterstitialAd();
    }

    // Navigate to results page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          response: responseText,
          isError: isError,
          language: language,
          translations: translations,
        ),
      ),
    );
  }

  static Future<void> fetchPredictionFromFixtureAndNavigate({
    required BuildContext context,
    required int fixtureId,
    required String homeTeam,
    required String awayTeam,
    required String language,
    required TranslationResponse translations,
    required Function(bool) onLoadingChanged,
  }) async {
    onLoadingChanged(true);

    Timer? hapticTimer;
    hapticTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      HapticFeedback.lightImpact();
    });

    String responseText;
    bool isError;

    try {
      final uri = AppConfig.isHttps
          ? Uri.https(
              AppConfig.apiBaseUrl,
              AppConfig.predictionFromFixturePath,
              {
                'fixtureId': fixtureId.toString(),
                'home-team': homeTeam,
                'away-team': awayTeam,
              },
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              AppConfig.predictionFromFixturePath,
              {
                'fixtureId': fixtureId.toString(),
                'home-team': homeTeam,
                'away-team': awayTeam,
              },
            );

      final response = await http.get(
        uri,
        headers: {
          'Accept-Language': language.toUpperCase(),
        },
      );

      if (response.statusCode == 200) {
        responseText = response.body;
        isError = false;
      } else {
        responseText = 'Server returned status ${response.statusCode}.\n\nBody:\n${response.body}';
        isError = true;
      }
    } catch (e) {
      responseText = 'Failed to contact server:\n$e';
      isError = true;
    }

    hapticTimer.cancel();
    onLoadingChanged(false);

    if (!context.mounted) return;

    if (!isError) {
      await ReviewService.onResultReceived();
    }

    if (kReleaseMode && AdMobService.isInterstitialAdReady) {
      AdMobService.showInterstitialAd();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          response: responseText,
          isError: isError,
          language: language,
          translations: translations,
        ),
      ),
    );
  }
}
