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

  static const Predictor gptPredictor = Predictor(
    id: 'gpt',
    name: 'GPT',
    image: 'assets/gpt.png',
    description: 'I’m a football analyst of the AI age — young, sharp, and '
        'focused on turning numbers into meaningful match stories.',
    apiEndpoint: 'calculate-odds',
    icon: Icons.graphic_eq, // The "voice" or "frequency" look is very OpenAI
    primaryColor: Color(0xFF10A37F), // The official "ChatGPT Green"
    shadowColor: Color(0xFF0D6853), // A darker shade for depth
  );

  static const Predictor perplexityPredictor = Predictor(
    id: 'perplexity',
    name: 'Perplexity',
    image: 'assets/perplexity.png',
    description: 'Unlike my colleagues, I fetch live data, blending analytics '
        'with global passion for unbeatable commentary. Ready for your next game query!',
    apiEndpoint: 'calculate-odds',
    icon: Icons.saved_search, // Or Icons.travel_explore - represents "Search"
    primaryColor: Color(0xFF22B8CF), // "Perplexity Turquoise" (Cyan 600/700 vibe)
    shadowColor: Color(0xFF0B7285), // Darker cyan/teal
  );

  static const Predictor geminiPredictor = Predictor(
    id: 'gemini',
    name: 'Gemini',
    image: 'assets/gemini.png',
    description: 'Powered by Google\'s vast legacy, I leverage decades of football history and real-time data to deliver precise, winning predictions',
    apiEndpoint: 'calculate-odds',
    icon: Icons.auto_awesome, // The classic "Sparkles" are the literal Gemini logo
    primaryColor: Color(0xFF4285F4), // "Google Blue" - The core of the brand
// OR if you want the "Advanced" look: Color(0xFF5145CD) (Deep Violet-Blue)
    shadowColor: Color(0xFF1A237E), // Deep Indigo
  );

  static const List<Predictor> all = [gptPredictor, perplexityPredictor, geminiPredictor];

  static Predictor? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
