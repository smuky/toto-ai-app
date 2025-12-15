import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/team.dart';
import '../models/translation_response.dart';
import '../services/admob_service.dart';
import '../pages/results_page.dart';
import 'team_autocomplete_field.dart';

class CustomMatchWidget extends StatefulWidget {
  final List<Team> leagueTeams;
  final String? selectedLeague;
  final bool isLoadingTeams;
  final String selectedLanguage;
  final TranslationResponse translations;

  const CustomMatchWidget({
    super.key,
    required this.leagueTeams,
    required this.selectedLeague,
    required this.isLoadingTeams,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<CustomMatchWidget> createState() => _CustomMatchWidgetState();
}

class _CustomMatchWidgetState extends State<CustomMatchWidget> {
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;
  bool _isLoading = false;

  List<Team> get _availableHomeTeams {
    if (widget.selectedLeague == null || widget.leagueTeams.isEmpty) {
      return [];
    }
    final teams = List<Team>.from(widget.leagueTeams);
    teams.sort((a, b) => a.effectiveName.compareTo(b.effectiveName));
    return teams;
  }

  List<Team> get _availableAwayTeams {
    if (widget.selectedLeague == null || _selectedHomeTeam == null || widget.leagueTeams.isEmpty) {
      return [];
    }
    final teams = widget.leagueTeams
        .where((team) => team != _selectedHomeTeam)
        .toList();
    teams.sort((a, b) => a.effectiveName.compareTo(b.effectiveName));
    return teams;
  }

  bool get isValid =>
      widget.selectedLeague != null &&
      _selectedHomeTeam != null &&
      _selectedAwayTeam != null &&
      !_isLoading;

  Future<void> _onGoPressed() async {
    if (_selectedHomeTeam == null || _selectedAwayTeam == null) return;
    
    final home = _selectedHomeTeam!.name;
    final away = _selectedAwayTeam!.name;
    final league = _selectedHomeTeam!.leagueEnum;

    setState(() {
      _isLoading = true;
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
      _isLoading = false;
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
          translations: widget.translations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingTeams) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text(
                'Loading teams...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        TeamAutocompleteField(
          key: ValueKey('home_${widget.selectedLeague}'),
          label: "Home Team",
          availableTeams: _availableHomeTeams,
          selectedTeam: _selectedHomeTeam,
          onTeamSelected: (team) {
            setState(() {
              _selectedHomeTeam = team;
              _selectedAwayTeam = null;
            });
          },
          enabled: widget.selectedLeague != null && !widget.isLoadingTeams,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "VS",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        TeamAutocompleteField(
          key: ValueKey('away_${widget.selectedLeague}_${_selectedHomeTeam?.effectiveName}'),
          label: "Away Team",
          availableTeams: _availableAwayTeams,
          selectedTeam: _selectedAwayTeam,
          onTeamSelected: (team) {
            setState(() {
              _selectedAwayTeam = team;
            });
          },
          enabled: _selectedHomeTeam != null && !widget.isLoadingTeams,
        ),
        const SizedBox(height: 32),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isValid
                ? [
                    BoxShadow(
                      color: Colors.blue.withAlpha(100),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: isValid ? _onGoPressed : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              backgroundColor: isValid ? Colors.blue.shade700 : null,
              foregroundColor: Colors.white,
              elevation: isValid ? 8 : 0,
              shadowColor: Colors.blue.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "GO",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
