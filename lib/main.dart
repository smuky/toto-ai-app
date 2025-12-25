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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Automatically determine environment from build-time constant
  // Use --dart-define=ENV=prod when building for production
  const envString = String.fromEnvironment('ENV', defaultValue: 'local');
  final environment = envString == 'prod' ? Environment.prod : Environment.local;
  
  await AppConfig.initialize(environment);
  
  // Initialize Firebase and sign in anonymously
  try {
    await AuthService().initialize();
  } catch (e) {
    print('Failed to initialize Firebase Auth: $e');
  }
  
  AdMobService.initialize();
  AdMobService.loadInterstitialAd();
  
  // Initialize RevenueCat
  try {
    await RevenueCatService.initialize();
  } catch (e) {
    print('Failed to initialize RevenueCat: $e');
  }

  try {
    await UserPermissionService.initialize();
  } catch (e) {
    print('Failed to initialize UserPermissionService: $e');
  }
  
  // Check if user has accepted terms
  final hasAcceptedTerms = await TermsScreen.hasAcceptedTerms();
  
  runApp(TotoAIApp(hasAcceptedTerms: hasAcceptedTerms));
}

class TotoAIApp extends StatelessWidget {
  final bool hasAcceptedTerms;

  const TotoAIApp({super.key, required this.hasAcceptedTerms});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PredictorProvider(),
      child: MaterialApp(
        title: '1X2-AI',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: hasAcceptedTerms ? const HomePage() : const TermsScreen(),
      ),
    );
  }
}
