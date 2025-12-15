import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../config/environment.dart';
import '../models/fixture.dart';
import '../services/admob_service.dart';
import '../pages/results_page.dart';

class UpcomingGamesWidget extends StatefulWidget {
  final List<Fixture> upcomingFixtures;
  final bool isLoadingFixtures;
  final String selectedLanguage;
  final String drawText;
  final String selectedLeague;

  const UpcomingGamesWidget({
    super.key,
    required this.upcomingFixtures,
    required this.isLoadingFixtures,
    required this.selectedLanguage,
    required this.drawText,
    required this.selectedLeague,
  });

  @override
  State<UpcomingGamesWidget> createState() => _UpcomingGamesWidgetState();
}

class _UpcomingGamesWidgetState extends State<UpcomingGamesWidget> {
  int? _analyzingFixtureId;

  Future<void> _analyzeFixture(Fixture fixture) async {
    final home = fixture.effectiveHomeTeam;
    final away = fixture.effectiveAwayTeam;
    final league = widget.selectedLeague;

    setState(() {
      _analyzingFixtureId = fixture.fixtureId;
    });

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
                'home-team': home,
                'away-team': away,
                'league': league,
                'language': widget.selectedLanguage.toUpperCase(),
              },
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              AppConfig.apiPath,
              {
                'home-team': home,
                'away-team': away,
                'league': league,
                'language': widget.selectedLanguage.toUpperCase(),
              },
            );

      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        responseText = response.body;
        isError = false;
      } else {
        responseText = 'Server returned status ${response.statusCode}.\n\nBody:\n${response.body}';
        isError = true;
      }
    } catch (e) {
      if (!mounted) return;
      responseText = 'Failed to contact server:\n$e';
      isError = true;
    }

    hapticTimer.cancel();

    setState(() {
      _analyzingFixtureId = null;
    });

    if (!mounted) return;

    if (kReleaseMode && AdMobService.isInterstitialAdReady) {
      AdMobService.showInterstitialAd();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          homeTeam: home,
          awayTeam: away,
          response: responseText,
          isError: isError,
          language: widget.selectedLanguage,
          drawText: widget.drawText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingFixtures) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text(
                'Loading upcoming matches...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.upcomingFixtures.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Icon(Icons.sports_soccer, size: 48, color: Colors.white54),
            SizedBox(height: 12),
            Text(
              'No Upcoming Matches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No fixtures available for this league',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Upcoming Matches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.upcomingFixtures.map((fixture) => _buildFixtureCard(fixture)),
      ],
    );
  }

  Widget _buildFixtureCard(Fixture fixture) {
    final dateTime = fixture.date;
    final dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final isAnalyzing = _analyzingFixtureId == fixture.fixtureId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: fixture.homeTeamLogo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.sports_soccer,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fixture.effectiveHomeTeam,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fixture.status,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: fixture.awayTeamLogo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.sports_soccer,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fixture.effectiveAwayTeam,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isAnalyzing ? null : () => _analyzeFixture(fixture),
            icon: isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.analytics, size: 18),
            label: Text(isAnalyzing ? 'Analyzing...' : 'Analyze Match'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
