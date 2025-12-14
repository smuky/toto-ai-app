import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/environment.dart';
import '../config/league_logos_config.dart';
import '../models/team.dart';
import '../widgets/team_autocomplete_field.dart';
import '../services/team_service.dart';
import '../services/language_preference_service.dart';
import '../services/admob_service.dart';
import '../widgets/about_dialog.dart';
import '../widgets/language_selector_dialog.dart';
import 'results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Team? _selectedHomeTeam;
  Team? _selectedAwayTeam;
  bool _isLoading = false;
  List<Team> _leagueTeams = [];
  bool _isLoadingTeams = false;
  String? _loadError;
  String _selectedLanguage = 'en';
  String? _selectedLeague;
  Map<String, String> _leagueTranslations = {};
  String _aboutText = '';
  String _selectLeagueText = 'Select League';
  String _drawText = 'Draw';
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
    await _loadTranslations();
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

  Future<void> _loadTranslations() async {
    try {
      final translations = await TeamService.fetchTranslations(_selectedLanguage);
      setState(() {
        _leagueTranslations = translations.leagueTranslations;
        _aboutText = translations.about;
        _selectLeagueText = translations.selectLeague;
        _drawText = translations.draw;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
      });
    }
  }

  Future<void> _loadTeamsForLeague(String leagueEnum) async {
    setState(() {
      _isLoadingTeams = true;
      _loadError = null;
    });

    try {
      final response = await TeamService.fetchLeagueStanding(leagueEnum);
      setState(() {
        _leagueTeams = response.teams;
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
    final leagues = _leagueTranslations.keys.toList();
    leagues.sort();
    return leagues;
  }

  List<Team> get _availableHomeTeams {
    if (_selectedLeague == null || _leagueTeams.isEmpty) {
      return [];
    }
    final teams = List<Team>.from(_leagueTeams);
    teams.sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }

  List<Team> get _availableAwayTeams {
    if (_selectedLeague == null || _selectedHomeTeam == null || _leagueTeams.isEmpty) {
      return [];
    }
    final teams = _leagueTeams
        .where((team) => team != _selectedHomeTeam)
        .toList();
    teams.sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }

  void _showAboutDialog() {
    showAboutAppDialog(
      context: context,
      aboutText: _aboutText,
      appVersion: _appVersion,
      buildNumber: _buildNumber,
    );
  }

  void _showLanguageMenu() {
    showLanguageSelectorDialog(
      context: context,
      selectedLanguage: _selectedLanguage,
      onLanguageSelected: (language) async {
        setState(() {
          _selectedLanguage = language;
        });
        await LanguagePreferenceService.setLanguage(language);
        _loadTranslations();
        if (_selectedLeague != null) {
          _loadTeamsForLeague(_selectedLeague!);
        }
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
          drawText: _drawText,
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
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildBody() {
    if (_loadError != null && _selectedLeague == null) {
      return _buildErrorView();
    }
    return _buildMainContent();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load translations',
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
            onPressed: _loadTranslations,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLeagueSelector(),
            const SizedBox(height: 24),
            if (_isLoadingTeams)
              _buildLoadingIndicator()
            else
              _buildTeamSelectors(),
            const SizedBox(height: 32),
            _buildGoButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          if (_selectedLeague != null && LeagueLogosConfig.getLeagueLogo(_selectedLeague!) != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CachedNetworkImage(
                imageUrl: LeagueLogosConfig.getLeagueLogo(_selectedLeague!)!,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.sports_soccer,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.sports_soccer, color: Colors.blue, size: 28),
            ),
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
                  _leagueTeams = [];
                });
                if (newValue != null) {
                  _loadTeamsForLeague(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
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

  Widget _buildTeamSelectors() {
    return Column(
      children: [
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
          enabled: _selectedLeague != null && !_isLoadingTeams,
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
          enabled: _selectedHomeTeam != null && !_isLoadingTeams,
        ),
      ],
    );
  }

  Widget _buildGoButton() {
    return AnimatedContainer(
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
    );
  }

  Widget? _buildBottomNavigationBar() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        height: _bannerAd!.size.height.toDouble(),
        color: Colors.transparent,
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }
}
