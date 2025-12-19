import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/translation_response.dart';
import '../models/predictor.dart';
import '../pages/results_page.dart';
import '../services/admob_service.dart';
import '../services/review_service.dart';

class PredictionService {
  /// Unified prediction method that uses the selected predictor
  static Future<void> fetchPredictionWithPredictor({
    required BuildContext context,
    required Predictor predictor,
    required String homeTeam,
    required String awayTeam,
    required String league,
    required String language,
    required TranslationResponse translations,
    required Function(bool) onLoadingChanged,
    int? fixtureId,
  }) async {
    await fetchPredictionFromFixtureAndNavigate(
      context: context,
      predictorId: predictor.id,
      fixtureId: fixtureId ?? 0,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      league: league,
      language: language,
      translations: translations,
      onLoadingChanged: onLoadingChanged,
    );
  }

  static Future<void> fetchPredictionFromFixtureAndNavigate({
    required BuildContext context,
    required String predictorId,
    required int fixtureId,
    required String homeTeam,
    required String awayTeam,
    required String league,
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
              AppConfig.apiPath,
              {
                'predictorId': predictorId,
                'fixtureId': fixtureId.toString(),
                'home-team': homeTeam,
                'away-team': awayTeam,
                'league': league,
              },
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              AppConfig.apiPath,
              {
                'predictorId': predictorId,
                'fixtureId': fixtureId.toString(),
                'home-team': homeTeam,
                'away-team': awayTeam,
                'league': league,
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
