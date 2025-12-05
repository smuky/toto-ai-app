import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/environment.dart';
import 'models/team.dart';
import 'widgets/team_autocomplete_field.dart';
import 'services/team_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set environment here: Environment.local or Environment.prod
  // This will load configuration from lib/config/app_config.yaml
  await AppConfig.initialize(Environment.local);
  
  runApp(const TotoAIApp());
}

class TotoAIApp extends StatelessWidget {
  const TotoAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toto AI ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TotoHome(),
    );
  }
}

class TotoHome extends StatefulWidget {
  const TotoHome({super.key});

  @override
  State<TotoHome> createState() => _TotoHomeState();
}

class _TotoHomeState extends State<TotoHome> {
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;
  bool _isLoading = false;
  List<Team> _allTeams = [];
  bool _isLoadingTeams = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoadingTeams = true;
      _loadError = null;
    });

    try {
      final teams = await TeamService.fetchAllTeams();
      setState(() {
        _allTeams = teams;
        _isLoadingTeams = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoadingTeams = false;
      });
    }
  }

  bool get isValid =>
      _selectedHomeTeam != null &&
      _selectedAwayTeam != null &&
      !_isLoading;

  List<Team> get _availableAwayTeams {
    if (_selectedHomeTeam == null) {
      return [];
    }
    return _allTeams
        .where((team) =>
            team.leagueEnum == _selectedHomeTeam!.leagueEnum &&
            team != _selectedHomeTeam)
        .toList();
  }

  Future<void> _onGoPressed() async {
    if (_selectedHomeTeam == null || _selectedAwayTeam == null) return;
    
    final home = _selectedHomeTeam!.name;
    final away = _selectedAwayTeam!.name;

    setState(() {
      _isLoading = true;
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
              },
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              AppConfig.apiPath,
              {
                'home-team': home,
                'away-team': away,
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

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          homeTeam: home,
          awayTeam: away,
          response: responseText,
          isError: isError,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Toto AI'),
            const SizedBox(width: 8),
            Container(
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
          ],
        ),
      ),
      body: _isLoadingTeams
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading teams...'),
                ],
              ),
            )
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load teams',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _loadError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadTeams,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TeamAutocompleteField(
                        label: "Home Team",
                        availableTeams: _allTeams,
                        selectedTeam: _selectedHomeTeam,
                        onTeamSelected: (team) {
                          setState(() {
                            _selectedHomeTeam = team;
                            if (team == null || 
                                _selectedAwayTeam == null || 
                                _selectedAwayTeam!.leagueEnum != team.leagueEnum) {
                              _selectedAwayTeam = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "VS",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TeamAutocompleteField(
                        label: "Away Team",
                        availableTeams: _availableAwayTeams,
                        selectedTeam: _selectedAwayTeam,
                        onTeamSelected: (team) {
                          setState(() {
                            _selectedAwayTeam = team;
                          });
                        },
                        enabled: _selectedHomeTeam != null,
                      ),
                      const SizedBox(height: 32),

                      // GO Button
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
                  ),
                ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String response;
  final bool isError;

  const ResultsPage({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.response,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Results'),
            const SizedBox(width: 8),
            Container(
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
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200, width: 2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  homeTeam,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  awayTeam,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: isError ? Colors.red.shade50 : Colors.white,
              child: SingleChildScrollView(
                child: Text(
                  response,
                  style: TextStyle(
                    fontSize: 14,
                    color: isError ? Colors.red.shade900 : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'New Game',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
