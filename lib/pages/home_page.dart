import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../config/environment.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/translation_response.dart';
import '../models/predictor.dart';
import '../services/team_service.dart';
import '../widgets/custom_match_widget.dart';
import '../widgets/upcoming_games_widget.dart';
import '../widgets/predictor_card_modal.dart';
import '../widgets/selection_mode_toggle_widget.dart';
import '../widgets/league_selector_widget.dart';
import '../widgets/recommended_list_selector_widget.dart';
import '../widgets/match_mode_toggle_widget.dart';
import '../widgets/pro_upgrade_overlay_widget.dart';
import '../services/language_preference_service.dart';
import '../services/league_preference_service.dart';
import '../services/admob_service.dart';
import '../services/revenue_cat_service.dart';
import '../pages/settings_page.dart';
import '../services/version_check_service.dart';
import '../widgets/update_required_dialog.dart';
import '../providers/predictor_provider.dart';

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
  String _selectionMode = 'league'; // 'league' or 'recommended'
  String? _selectedRecommendedList; // 'Winner16' or 'Winner16World'
  bool _isProUser = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _loadLanguagePreference();
    await _loadLeaguePreference();
    await _loadAppVersion();
    await _loadTranslations();
    await _checkAppVersion(); // Check version AFTER translations are loaded
    await _checkProStatus();
    
    // Load initial data based on default state
    if (_selectedLeague != null) {
      if (_matchMode == 'upcoming') {
        await _loadUpcomingFixtures(_selectedLeague!);
      } else {
        await _loadTeamsForLeague(_selectedLeague!);
      }
    }
  }

  Future<void> _checkProStatus() async {
    final isPro = await RevenueCatService.isProUser();
    if (mounted) {
      setState(() {
        _isProUser = isPro;
      });
      // Update AdMobService with the latest pro status
      AdMobService.updateProStatus(isPro);
      
      // If user is pro, dispose of any existing banner ad
      if (isPro && _bannerAd != null) {
        _bannerAd?.dispose();
        _bannerAd = null;
        setState(() {
          _isBannerAdLoaded = false;
        });
      }
    }
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _checkAppVersion() async {
    try {
      print('HomePage: Checking app version: $_appVersion');
      final isSupported = await VersionCheckService.isVersionSupported(_appVersion);
      print('HomePage: Version supported: $isSupported');
      
      if (!isSupported && mounted && _translations != null) {
        // Get minimum version for the dialog
        final minVersion = await VersionCheckService.getMinimumVersion();
        print('HomePage: Showing update dialog - Current: $_appVersion, Min: $minVersion');
        
        // Show update required dialog with translations
        showUpdateRequiredDialog(
          context: context,
          currentVersion: _appVersion,
          minimumVersion: minVersion ?? 'Unknown',
          upgradeMessages: _translations!.upgradeMessages,
        );
      }
    } catch (e) {
      print('HomePage: Error checking app version: $e');
      // Continue with app initialization on error
    }
  }

  void _loadBannerAd() {
    final bannerAd = AdMobService.createBannerAd(
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
    
    if (bannerAd != null) {
      _bannerAd = bannerAd;
      _bannerAd!.load();
    }
  }

  Future<void> _loadLanguagePreference() async {
    final language = await LanguagePreferenceService.getLanguage();
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _loadLeaguePreference() async {
    final savedLeague = await LeaguePreferenceService.getLeague();
    setState(() {
      // If no saved league, default to ISRAEL_WINNER
      _selectedLeague = savedLeague ?? 'ISRAEL_WINNER';
    });
    
    // Save the default league if this is first time
    if (savedLeague == null && _selectedLeague != null) {
      await LeaguePreferenceService.setLeague(_selectedLeague!);
    }
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
      final response = await TeamService.fetchUpcomingFixtures(leagueEnum, 30);
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

  Future<void> _loadRecommendedList(String listType) async {
    setState(() {
      _isLoadingFixtures = true;
      _loadError = null;
    });

    try {
      final response = await TeamService.fetchRecommendedList(listType);
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

  void _handleSelectionModeChanged(String mode) {
    setState(() {
      _selectionMode = mode;
      if (mode == 'league') {
        _matchMode = 'upcoming';
        if (_selectedLeague != null) {
          _loadUpcomingFixtures(_selectedLeague!);
        }
      } else {
        if (_selectedRecommendedList == null && _translations != null && _translations!.predefinedEvents.isNotEmpty) {
          _selectedRecommendedList = _translations!.predefinedEvents.first.key;
        }
        if (_selectedRecommendedList != null) {
          _loadRecommendedList(_selectedRecommendedList!);
        }
      }
    });
  }

  void _handleLeagueChanged(String? newValue) async {
    setState(() {
      _selectedLeague = newValue;
      _leagueTeams = [];
      _upcomingFixtures = [];
    });
    if (newValue != null) {
      await LeaguePreferenceService.setLeague(newValue);
      _loadTeamsForLeague(newValue);
      if (_matchMode == 'upcoming') {
        _loadUpcomingFixtures(newValue);
      }
    }
  }

  void _handleRecommendedListChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedRecommendedList = newValue;
      });
      _loadRecommendedList(newValue);
    }
  }

  void _handleMatchModeChanged(String mode) {
    setState(() {
      _matchMode = mode;
    });
    if (mode == 'custom' && _selectedLeague != null && _leagueTeams.isEmpty) {
      _loadTeamsForLeague(_selectedLeague!);
    } else if (mode == 'upcoming' && _selectedLeague != null && _upcomingFixtures.isEmpty) {
      _loadUpcomingFixtures(_selectedLeague!);
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          selectedLanguage: _selectedLanguage,
          aboutText: _aboutText,
          appVersion: _appVersion,
          buildNumber: _buildNumber,
          onLanguageChanged: (language) async {
            setState(() {
              _selectedLanguage = language;
            });
            await _loadTranslations();
            if (_selectedLeague != null) {
              if (_matchMode == 'upcoming') {
                _loadUpcomingFixtures(_selectedLeague!);
              } else {
                _loadTeamsForLeague(_selectedLeague!);
              }
            }
          },
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
        Consumer<PredictorProvider>(
          builder: (context, predictorProvider, _) {
            final predictor = predictorProvider.selectedPredictor;
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const PredictorCardModal(),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade100,
                  child: ClipOval(
                    child: Image.asset(
                      predictor.image,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          predictor.icon,
                          size: 20,
                          color: predictor.primaryColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
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
    return ProUpgradeOverlayWidget(
      showOverlay: _selectionMode == 'recommended' && !_isProUser,
      premiumBadgeMessages: _translations?.premiumBadgeMessages,
      onBackToLeague: () async {
        // Refresh pro status in case user just upgraded
        await _checkProStatus();
        setState(() {
          _selectionMode = 'league';
        });
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selection Mode Toggle (League vs Recommended Lists)
              SelectionModeToggleWidget(
                selectionMode: _selectionMode,
                translations: _translations,
                onModeChanged: _handleSelectionModeChanged,
                selectedLanguage: _selectedLanguage,
              ),
              const SizedBox(height: 24),
              // Conditional selector based on mode
              if (_selectionMode == 'league')
                LeagueSelectorWidget(
                  selectedLeague: _selectedLeague,
                  availableLeagues: _availableLeagues,
                  leagueTranslations: _leagueTranslations,
                  selectedLanguage: _selectedLanguage,
                  selectLeagueText: _selectLeagueText,
                  onLeagueChanged: _handleLeagueChanged,
                )
              else
                RecommendedListSelectorWidget(
                  selectedRecommendedList: _selectedRecommendedList,
                  translations: _translations,
                  selectedLanguage: _selectedLanguage,
                  onListChanged: _handleRecommendedListChanged,
                ),
              // Show match mode toggle only in league mode
              if (_selectionMode == 'league' && _selectedLeague != null) ...[
                const SizedBox(height: 24),
                MatchModeToggleWidget(
                  matchMode: _matchMode,
                  customMatchText: _customMatchText,
                  upcomingGamesText: _upcomingGamesText,
                  onModeChanged: _handleMatchModeChanged,
                ),
              ],
              const SizedBox(height: 24),
              // Content area
              if (_selectionMode == 'league' && _matchMode == 'custom' && _translations != null)
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
                  selectedLeague: _selectedLeague ?? _selectedRecommendedList ?? '',
                  translations: _translations!,
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget? _buildBottomNavigationBar() {
    if (!_isProUser && _isBannerAdLoaded && _bannerAd != null) {
      return Container(
        height: _bannerAd!.size.height.toDouble(),
        color: Colors.transparent,
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }
}
