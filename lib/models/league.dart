import '../config/league_logos_config.dart';

class League {
  final String enumValue; // e.g., 'PREMIER_LEAGUE', 'ISRAEL_WINNER'
  final String name; // Translated name
  final String country; // Country name
  final String? logo; // Logo URL

  const League({
    required this.enumValue,
    required this.name,
    required this.country,
    this.logo,
  });

  // Get logo from config, fallback to null
  String? get effectiveLogo => logo ?? LeagueLogosConfig.getLeagueLogo(enumValue);

  // For autocomplete search - search in both name and country
  String get searchText => '$name $country'.toLowerCase();

  // Display string for autocomplete
  String get displayName => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is League &&
          runtimeType == other.runtimeType &&
          enumValue == other.enumValue;

  @override
  int get hashCode => enumValue.hashCode;
}
