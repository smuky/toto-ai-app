import 'package:flutter/material.dart';
import '../widgets/about_dialog.dart';
import '../widgets/language_selector_dialog.dart';
import '../services/language_preference_service.dart';

class SettingsPage extends StatelessWidget {
  final String selectedLanguage;
  final String aboutText;
  final String appVersion;
  final String buildNumber;
  final Function(String) onLanguageChanged;

  const SettingsPage({
    super.key,
    required this.selectedLanguage,
    required this.aboutText,
    required this.appVersion,
    required this.buildNumber,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            context: context,
            title: 'General',
            items: [
              _buildSettingsTile(
                context: context,
                icon: Icons.language,
                title: 'Language',
                subtitle: _getLanguageDisplayName(selectedLanguage),
                onTap: () => _showLanguageSelector(context),
              ),
            ],
          ),
          const Divider(height: 1),
          _buildSettingsSection(
            context: context,
            title: 'Information',
            items: [
              _buildSettingsTile(
                context: context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App information and version',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showLanguageSelectorDialog(
      context: context,
      selectedLanguage: selectedLanguage,
      onLanguageSelected: (language) async {
        await LanguagePreferenceService.setLanguage(language);
        onLanguageChanged(language);
      },
    );
  }

  void _showAbout(BuildContext context) {
    showAboutAppDialog(
      context: context,
      aboutText: aboutText,
      appVersion: appVersion,
      buildNumber: buildNumber,
      language: selectedLanguage,
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'he':
        return 'עברית (Hebrew)';
      case 'es':
        return 'Español (Spanish)';
      case 'fr':
        return 'Français (French)';
      case 'de':
        return 'Deutsch (German)';
      case 'it':
        return 'Italiano (Italian)';
      default:
        return languageCode;
    }
  }
}
