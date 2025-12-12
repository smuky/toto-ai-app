import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/environment.dart';
import 'config/language_config.dart';
import 'models/team.dart';
import 'models/prediction_response.dart';
import 'widgets/team_autocomplete_field.dart';
import 'widgets/prediction_report_widget.dart';
import 'services/team_service.dart';
import 'services/language_preference_service.dart';
import 'services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Automatically determine environment from build-time constant
  // Use --dart-define=ENV=prod when building for production
  const envString = String.fromEnvironment('ENV', defaultValue: 'local');
  final environment = envString == 'prod' ? Environment.prod : Environment.local;
  
  await AppConfig.initialize(environment);
  
  AdMobService.initialize();
  
  runApp(const TotoAIApp());
}

class TotoAIApp extends StatelessWidget {
  const TotoAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Football Predictor',
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
  String _selectedLanguage = 'en';
  String? _selectedLeague;
  Map<String, String> _leagueTranslations = {};
  String _aboutText = '';
  String _selectLeagueText = 'Select League';
  String _settingsText = 'Settings';
  String _appVersion = '';
  String _buildNumber = '';
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _loadLanguagePreference();
    await _loadAppVersion();
    await _loadTeams();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
      },
    );
    _bannerAd?.load();
  }

  void _loadInterstitialAd() {
    AdMobService.loadInterstitialAd(
      onAdLoaded: () {},
      onAdFailedToLoad: (error) {},
    );
  }

  Future<void> _loadLanguagePreference() async {
    final language = await LanguagePreferenceService.getLanguage();
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoadingTeams = true;
      _loadError = null;
    });

    try {
      final response = await TeamService.fetchAllTeams(_selectedLanguage);
      setState(() {
        _allTeams = response.teams;
        _leagueTranslations = response.translations.leagueTranslations;
        _aboutText = response.translations.about;
        _selectLeagueText = response.translations.selectLeague;
        _settingsText = response.translations.settings;
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
      _selectedLeague != null &&
      _selectedHomeTeam != null &&
      _selectedAwayTeam != null &&
      !_isLoading;

  List<String> get _availableLeagues {
    final leagues = _allTeams.map((team) => team.leagueEnum).toSet().toList();
    leagues.sort();
    return leagues;
  }

  List<Team> get _availableHomeTeams {
    if (_selectedLeague == null) {
      return [];
    }
    final teams = _allTeams
        .where((team) => team.leagueEnum == _selectedLeague)
        .toList();
    teams.sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }

  List<Team> get _availableAwayTeams {
    if (_selectedLeague == null || _selectedHomeTeam == null) {
      return [];
    }
    final teams = _allTeams
        .where((team) =>
            team.leagueEnum == _selectedLeague &&
            team != _selectedHomeTeam)
        .toList();
    teams.sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('About', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text('$_aboutText\n\nVersion: $_appVersion ($_buildNumber)',
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
          title: const Row(
            children: [
              Icon(Icons.language, color: Colors.blue),
              SizedBox(width: 8),
              Text('Select Language', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageConfig.supportedLanguages.entries.map((entry) {
              return ListTile(
                title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                leading: Radio<String>(
                  value: entry.key,
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) async {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                      await LanguagePreferenceService.setLanguage(value);
                      Navigator.of(context).pop();
                      _loadTeams();
                    }
                  },
                ),
                onTap: () async {
                  setState(() {
                    _selectedLanguage = entry.key;
                  });
                  await LanguagePreferenceService.setLanguage(entry.key);
                  Navigator.of(context).pop();
                  _loadTeams();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

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
                'language': _selectedLanguage.toUpperCase(),
              },
            )
          : Uri.http(
              AppConfig.apiBaseUrl,
              AppConfig.apiPath,
              {
                'home-team': home,
                'away-team': away,
                'league': league,
                'language': _selectedLanguage.toUpperCase(),
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

    hapticTimer?.cancel();

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (kReleaseMode && AdMobService.isInterstitialAdReady) {
      AdMobService.showInterstitialAd();
      _loadInterstitialAd();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          homeTeam: home,
          awayTeam: away,
          response: responseText,
          isError: isError,
          language: _selectedLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Text(
                'AI Football Predictor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
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
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                onPressed: _showLanguageMenu,
                tooltip: 'Language',
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: _showAboutDialog,
                tooltip: 'About',
              ),
            ),
          ],
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
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sports_soccer, color: Colors.blue, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButton<String>(
                                value: _selectedLeague,
                                hint: Text(_selectLeagueText),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: _availableLeagues.map((league) {
                                  final translatedName = _leagueTranslations[league] ?? league;
                                  return DropdownMenuItem<String>(
                                    value: league,
                                    child: Text(
                                      translatedName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedLeague = newValue;
                                    _selectedHomeTeam = null;
                                    _selectedAwayTeam = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TeamAutocompleteField(
                        key: ValueKey('home_$_selectedLeague'),
                        label: "Home Team",
                        availableTeams: _availableHomeTeams,
                        selectedTeam: _selectedHomeTeam,
                        onTeamSelected: (team) {
                          setState(() {
                            _selectedHomeTeam = team;
                            _selectedAwayTeam = null;
                          });
                        },
                        enabled: _selectedLeague != null,
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
                        key: ValueKey('away_${_selectedLeague}_${_selectedHomeTeam?.name}'),
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
              ),
        bottomNavigationBar: _isBannerAdLoaded && _bannerAd != null
            ? Container(
                height: _bannerAd!.size.height.toDouble(),
                color: Colors.transparent,
                child: AdWidget(ad: _bannerAd!),
              )
            : null,
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String response;
  final bool isError;
  final String language;

  const ResultsPage({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.response,
    required this.isError,
    required this.language,
  });

  Widget _buildResponseContent() {
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
      );
    } catch (e) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            response,
            textAlign: language == 'he' ? TextAlign.right : TextAlign.left,
            textDirection: language == 'he' ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    homeTeam,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'VS',
                    style: TextStyle(
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
                    textAlign: TextAlign.left,
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
              child: _buildResponseContent(),
            ),
          ),
        ],
      ),
    );
  }
}
