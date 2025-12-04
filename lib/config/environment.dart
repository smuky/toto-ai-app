import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

enum Environment {
  local,
  prod,
}

class AppConfig {
  static Environment _environment = Environment.local;
  static Map<String, dynamic>? _config;
  static bool _isInitialized = false;

  static Future<void> initialize(Environment env) async {
    _environment = env;
    await _loadConfig();
    _isInitialized = true;
  }

  static Future<void> _loadConfig() async {
    final yamlString = await rootBundle.loadString('lib/config/app_config.yaml');
    final yamlMap = loadYaml(yamlString);
    
    final envKey = _environment == Environment.local ? 'local' : 'prod';
    _config = Map<String, dynamic>.from(yamlMap[envKey]);
  }

  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('AppConfig not initialized. Call AppConfig.initialize() first.');
    }
  }

  static Environment get environment {
    _ensureInitialized();
    return _environment;
  }

  static String get apiBaseUrl {
    _ensureInitialized();
    return _config!['api']['base-url'] as String;
  }

  static bool get isHttps {
    _ensureInitialized();
    return _config!['api']['use-https'] as bool;
  }

  static String get apiPath {
    _ensureInitialized();
    return _config!['api']['endpoints']['calculate-odds'] as String;
  }
}
