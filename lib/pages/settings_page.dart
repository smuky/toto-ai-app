import 'package:flutter/material.dart';
import '../widgets/about_dialog.dart';
import '../widgets/language_selector_dialog.dart';
import '../services/language_preference_service.dart';
import '../services/review_service.dart';

class SettingsPage extends StatefulWidget {
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
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _reviewCount = 0;
  bool _reviewCompleted = false;
  DateTime? _lastReviewDate;

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    final count = await ReviewService.getResultCount();
    final completed = await ReviewService.hasCompletedReview();
    final date = await ReviewService.getLastReviewRequestDate();
    setState(() {
      _reviewCount = count;
      _reviewCompleted = completed;
      _lastReviewDate = date;
    });
  }

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
                subtitle: _getLanguageDisplayName(widget.selectedLanguage),
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
          const Divider(height: 1),
          _buildSettingsSection(
            context: context,
            title: 'Debug (Development Only)',
            items: [
              _buildDebugInfoTile(context),
              _buildResetReviewTile(context),
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

  Widget _buildDebugInfoTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.bug_report, color: Colors.orange.shade700),
      title: const Text(
        'Review Data',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Count: $_reviewCount | Completed: $_reviewCompleted${_lastReviewDate != null ? '\nLast request: ${_lastReviewDate!.toLocal()}' : ''}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      isThreeLine: _lastReviewDate != null,
    );
  }

  Widget _buildResetReviewTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.refresh, color: Colors.red.shade700),
      title: const Text(
        'Reset Review Counter',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Clear review data for testing',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _resetReviewData(context),
    );
  }

  Future<void> _resetReviewData(BuildContext context) async {
    await ReviewService.resetReviewData();
    await _loadReviewData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review data reset successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showLanguageSelectorDialog(
      context: context,
      selectedLanguage: widget.selectedLanguage,
      onLanguageSelected: (language) async {
        await LanguagePreferenceService.setLanguage(language);
        widget.onLanguageChanged(language);
      },
    );
  }

  void _showAbout(BuildContext context) {
    showAboutAppDialog(
      context: context,
      aboutText: widget.aboutText,
      appVersion: widget.appVersion,
      buildNumber: widget.buildNumber,
      language: widget.selectedLanguage,
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
