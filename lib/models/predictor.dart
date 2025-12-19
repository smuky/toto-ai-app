import 'package:flutter/material.dart';

class Predictor {
  final String id;
  final String name;
  final String image;
  final String description;
  final String apiEndpoint;
  final IconData icon;
  final Color primaryColor;
  final Color shadowColor;

  const Predictor({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.apiEndpoint,
    required this.icon,
    required this.primaryColor,
    required this.shadowColor,
  });

  Color get buttonColor => primaryColor;
  Color get glowColor => primaryColor.withOpacity(0.5);
  Color get shadowColorWithAlpha => shadowColor;

  static const Predictor classic = Predictor(
    id: 'classic',
    name: 'Classic Predictor',
    image: 'assets/predictor_classic.png',
    description: 'Traditional statistical analysis based on team standings, form, and historical performance. Reliable and time-tested approach.',
    apiEndpoint: 'calculate-odds',
    icon: Icons.analytics,
    primaryColor: Color(0xFF1976D2),
    shadowColor: Color(0xFF0D47A1),
  );

  static const Predictor advanced = Predictor(
    id: 'advanced',
    name: 'Advanced Predictor',
    image: 'assets/predictor_advanced.png',
    description: 'Next-generation AI model using fixture-specific data, recent match statistics, and advanced analytics for enhanced predictions.',
    apiEndpoint: 'prediction-from-fixture',
    icon: Icons.auto_awesome,
    primaryColor: Color(0xFF7B1FA2),
    shadowColor: Color(0xFF4A148C),
  );

  static const List<Predictor> all = [classic, advanced];

  static Predictor? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
