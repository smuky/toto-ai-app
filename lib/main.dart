import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toto_ai/services/user_permission_service.dart';
import 'config/environment.dart';
import 'services/admob_service.dart';
import 'services/revenue_cat_service.dart';
import 'services/auth_service.dart';
import 'pages/home_page.dart';
import 'pages/terms_screen.dart';
import 'providers/predictor_provider.dart';
import 'services/language_preference_service.dart';
import 'utils/text_direction_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Automatically determine environment from build-time constant
  // Use --dart-define=ENV=prod when building for production
  const envString = String.fromEnvironment('ENV', defaultValue: 'local');
  final environment = envString == 'prod'
      ? Environment.prod
      : Environment.local;

  await AppConfig.initialize(environment);

  // Check if user has accepted terms (this is fast, no network calls)
  final hasAcceptedTerms = await TermsScreen.hasAcceptedTerms();

  // Start the app immediately - don't wait for services
  runApp(TotoAIApp(hasAcceptedTerms: hasAcceptedTerms));

  // Initialize services in the background (non-blocking)
  _initializeServicesInBackground();
}

// Initialize all services in the background so they don't block app startup
void _initializeServicesInBackground() {
  // Initialize Firebase and sign in anonymously
  AuthService()
      .initialize()
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Firebase initialization timeout - continuing anyway');
        },
      )
      .catchError((e) {
        print('Failed to initialize Firebase Auth: $e');
      });

  // Initialize AdMob (non-blocking)
  AdMobService.initialize();
  AdMobService.loadInterstitialAd();

  // Initialize RevenueCat
  RevenueCatService.initialize()
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('RevenueCat initialization timeout - continuing anyway');
        },
      )
      .catchError((e) {
        print('Failed to initialize RevenueCat: $e');
      });

  // Initialize UserPermissionService with aggressive timeout
  UserPermissionService.initialize()
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(
            'UserPermissionService initialization timeout - continuing anyway',
          );
        },
      )
      .catchError((e) {
        print('Failed to initialize UserPermissionService: $e');
      });
}

class TotoAIApp extends StatefulWidget {
  final bool hasAcceptedTerms;

  const TotoAIApp({super.key, required this.hasAcceptedTerms});

  @override
  State<TotoAIApp> createState() => _TotoAIAppState();
}

class _TotoAIAppState extends State<TotoAIApp> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final language = await LanguagePreferenceService.getLanguage();
    if (mounted) {
      setState(() {
        _currentLanguage = language;
      });
    }
  }

  void _onLanguageChanged(String language) {
    setState(() {
      _currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PredictorProvider(),
      child: MaterialApp(
        title: '1X2-AI',
        theme: ThemeData(primarySwatch: Colors.blue),
        builder: (context, child) {
          // Apply Directionality to all routes based on current language
          return Directionality(
            textDirection: TextDirectionHelper.getTextDirection(
              _currentLanguage,
            ),
            child: child!,
          );
        },
        home: widget.hasAcceptedTerms
            ? HomePage(onLanguageChanged: _onLanguageChanged)
            : TermsScreen(onLanguageChanged: _onLanguageChanged),
      ),
    );
  }
}
