import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/environment.dart';
import '../models/prediction_response.dart';
import '../models/translation_response.dart';
import '../models/predictor.dart';
import '../widgets/prediction_report_widget.dart';

class ResultsPage extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String response;
  final bool isError;
  final String language;
  final TranslationResponse translations;
  final Predictor? predictor;

  const ResultsPage({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.response,
    required this.isError,
    required this.language,
    required this.translations,
    this.predictor,
  });

  Widget _buildResponseContent(BuildContext context) {
    if (isError) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            response,
            textAlign: language == 'he' ? TextAlign.right : TextAlign.left,
            textDirection: language == 'he' ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade900,
            ),
          ),
        ),
      );
    }

    try {
      final jsonData = jsonDecode(response);
      final prediction = PredictionResponse.fromJson(jsonData);
      return PredictionReportWidget(
        prediction: prediction,
        language: language,
        translations: translations,
        predictor: predictor,
      );
    } catch (e, stackTrace) {
      // Log detailed error information for debugging
      print('═══════════════════════════════════════════════════════');
      print('ERROR: Failed to parse prediction response');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack Trace: $stackTrace');
      print('Raw Response Length: ${response.length} characters');
      print('Raw Response: $response');
      print('═══════════════════════════════════════════════════════');
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_soccer,
                size: 80,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                '⚽ That was a difficult one!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Our AI had trouble analyzing this match.\nLet\'s try again later or pick a different match.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (AppConfig.environment != Environment.prod) ...[
                const Divider(),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text(
                    'Debug Info (Dev Only)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error: $e',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade900,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Raw Response:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            response,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppConfig.environment == Environment.prod
                ? Colors.green
                : Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            AppConfig.environment == Environment.prod ? 'LIVE' : 'LOCAL',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: predictor?.primaryColor.withOpacity(0.1) ?? Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(
                  color: predictor?.primaryColor.withOpacity(0.3) ?? Colors.blue.shade200,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: language == 'he' ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Flexible(
                  child: Text(
                    homeTeam,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: language == 'he' ? TextDirection.rtl : TextDirection.ltr,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    translations.vs,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    awayTeam,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: language == 'he' ? TextDirection.rtl : TextDirection.ltr,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: isError ? Colors.red.shade50 : Colors.white,
              child: _buildResponseContent(context),
            ),
          ),
        ],
      ),
    );
  }
}
