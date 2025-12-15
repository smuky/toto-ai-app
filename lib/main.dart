import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'services/admob_service.dart';
import 'pages/home_page.dart';

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
      title: '1X2-AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
