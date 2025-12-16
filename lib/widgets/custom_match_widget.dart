import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/translation_response.dart';
import '../services/prediction_service.dart';
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
    
    await PredictionService.fetchPredictionAndNavigate(
      context: context,
      homeTeam: _selectedHomeTeam!.effectiveName,
      awayTeam: _selectedAwayTeam!.effectiveName,
      league: _selectedHomeTeam!.leagueEnum,
      language: widget.selectedLanguage,
      translations: widget.translations,
      onLoadingChanged: (isLoading) {
        if (mounted) {
          setState(() {
            _isLoading = isLoading;
          });
        }
      },
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
