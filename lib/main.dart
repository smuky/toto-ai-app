import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'services/admob_service.dart';
import 'services/revenue_cat_service.dart';
import 'pages/home_page.dart';
import 'pages/terms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Automatically determine environment from build-time constant
  // Use --dart-define=ENV=prod when building for production
  const envString = String.fromEnvironment('ENV', defaultValue: 'local');
  final environment = envString == 'prod' ? Environment.prod : Environment.local;
  
  await AppConfig.initialize(environment);
  
  AdMobService.initialize();
  
  // Initialize RevenueCat
  try {
    await RevenueCatService.initialize();
  } catch (e) {
    print('Failed to initialize RevenueCat: $e');
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
    return MaterialApp(
      title: '1X2-AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: hasAcceptedTerms ? const HomePage() : const TermsScreen(),
    );
  }
}
