import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/environment.dart';
import '../config/league_logos_config.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/translation_response.dart';
import '../services/team_service.dart';
import '../utils/text_direction_helper.dart';
import '../widgets/custom_match_widget.dart';
import '../widgets/upcoming_games_widget.dart';
import '../services/language_preference_service.dart';
import '../services/admob_service.dart';
import '../widgets/about_dialog.dart';
import '../widgets/language_selector_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Team> _leagueTeams = [];
  bool _isLoadingTeams = false;
  String? _loadError;
  String _selectedLanguage = 'en';
  String? _selectedLeague = 'ISRAEL_WINNER';
  TranslationResponse? _translations;
  Map<String, String> _leagueTranslations = {};
  String _aboutText = '';
  String _selectLeagueText = 'Select League';
  String _customMatchText = 'Custom Match';
  String _upcomingGamesText = 'Upcoming Games';
  String _appVersion = '';
  String _buildNumber = '';
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  String _matchMode = 'upcoming'; // 'custom' or 'upcoming'
  List<Fixture> _upcomingFixtures = [];
  bool _isLoadingFixtures = false;

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
    
    // Load initial data based on default state
    if (_selectedLeague != null) {
      if (_matchMode == 'upcoming') {
        await _loadUpcomingFixtures(_selectedLeague!);
      } else {
        await _loadTeamsForLeague(_selectedLeague!);
      }
    }
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
        _translations = translations;
        _leagueTranslations = translations.leagueTranslations;
        _aboutText = translations.about;
        _selectLeagueText = translations.selectLeague;
        _customMatchText = translations.customMatch;
        _upcomingGamesText = translations.upcomingGames;
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

  Future<void> _loadUpcomingFixtures(String leagueEnum) async {
    setState(() {
      _isLoadingFixtures = true;
      _loadError = null;
    });

    try {
      final response = await TeamService.fetchUpcomingFixtures(leagueEnum, 20);
      setState(() {
        _upcomingFixtures = response.fixtures;
        _isLoadingFixtures = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoadingFixtures = false;
      });
    }
  }

  List<String> get _availableLeagues {
    final leagues = _leagueTranslations.keys.toList();
    leagues.sort();
    return leagues;
  }

  void _showAboutDialog() {
    showAboutAppDialog(
      context: context,
      aboutText: _aboutText,
      appVersion: _appVersion,
      buildNumber: _buildNumber,
      language: _selectedLanguage,
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
            '1X2-AI',
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
            if (_selectedLeague != null) ...[
              const SizedBox(height: 24),
              _buildModeSelector(),
            ],
            const SizedBox(height: 24),
            if (_matchMode == 'custom' && _translations != null)
              CustomMatchWidget(
                leagueTeams: _leagueTeams,
                selectedLeague: _selectedLeague,
                isLoadingTeams: _isLoadingTeams,
                selectedLanguage: _selectedLanguage,
                translations: _translations!,
              )
            else if (_translations != null)
              UpcomingGamesWidget(
                upcomingFixtures: _upcomingFixtures,
                isLoadingFixtures: _isLoadingFixtures,
                selectedLanguage: _selectedLanguage,
                selectedLeague: _selectedLeague ?? '',
                translations: _translations!,
              ),
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
            child: Directionality(
              textDirection: TextDirectionHelper.getTextDirection(_selectedLanguage),
              child: DropdownButton<String>(
                value: _selectedLeague,
                hint: Text(
                  _selectLeagueText,
                  textAlign: TextDirectionHelper.getTextAlign(_selectedLanguage),
                  textDirection: TextDirectionHelper.getTextDirection(_selectedLanguage),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                items: _availableLeagues.map((league) {
                  final translatedName = _leagueTranslations[league] ?? league;
                  return DropdownMenuItem<String>(
                    value: league,
                    alignment: TextDirectionHelper.isRTL(_selectedLanguage) 
                        ? AlignmentDirectional.centerEnd 
                        : AlignmentDirectional.centerStart,
                    child: Text(
                      translatedName,
                      textAlign: TextDirectionHelper.getTextAlign(_selectedLanguage),
                      textDirection: TextDirectionHelper.getTextDirection(_selectedLanguage),
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
                    _leagueTeams = [];
                    _upcomingFixtures = [];
                  });
                  if (newValue != null) {
                    _loadTeamsForLeague(newValue);
                    if (_matchMode == 'upcoming') {
                      _loadUpcomingFixtures(newValue);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _matchMode = 'custom';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _matchMode == 'custom'
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _matchMode == 'custom'
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _customMatchText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _matchMode == 'custom'
                        ? Colors.blue.shade700
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _matchMode = 'upcoming';
                });
                if (_selectedLeague != null && _upcomingFixtures.isEmpty) {
                  _loadUpcomingFixtures(_selectedLeague!);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _matchMode == 'upcoming'
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _matchMode == 'upcoming'
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _upcomingGamesText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _matchMode == 'upcoming'
                        ? Colors.blue.shade700
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
