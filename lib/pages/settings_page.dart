import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/about_dialog.dart';
import '../widgets/language_selector_dialog.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/subscription_status_widget.dart';
import '../services/language_preference_service.dart';
import '../services/revenue_cat_service.dart';
import '../pages/customer_center_page.dart';

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
  late String _currentLanguage;
  bool _isPro = false;
  bool _isLoadingProStatus = true;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.selectedLanguage;
    _checkProStatus();
  }

  Future<void> _checkProStatus() async {
    final isPro = await RevenueCatService.isProUser();
    if (mounted) {
      setState(() {
        _isPro = isPro;
        _isLoadingProStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          if (_isPro && !_isLoadingProStatus)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoadingProStatus
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Show large subscription card only for free users
                if (!_isPro) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SubscriptionStatusWidget(
                      onStatusChanged: () {
                        _checkProStatus();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                ],
                // Show Restore Purchases section only for free users
                if (!_isPro) ...[
                  _buildSettingsSection(
                    context: context,
                    title: 'Subscription',
                    items: [const RestorePurchasesButton()],
                  ),
                  const Divider(height: 1),
                ],
                _buildSettingsSection(
                  context: context,
                  title: 'General',
                  items: [
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: _getLanguageDisplayName(_currentLanguage),
                      onTap: () => _showLanguageSelector(context),
                    ),
                  ],
                ),
                const Divider(height: 1),
                _buildSettingsSection(
                  context: context,
                  title: 'Support',
                  items: [
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      subtitle: 'Share your ideas or report issues',
                      onTap: () => _showFeedback(context),
                    ),
                    // Add Manage Subscription for Pro users in Support section
                    if (_isPro) const ManageSubscriptionButton(),
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
                      subtitle: '',
                      onTap: () => _showAbout(context),
                    ),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Terms of Use & Privacy Policy',
                      subtitle: '',
                      onTap: () => _launchPrivacyPolicy(context),
                    ),
                  ],
                ),
                const Divider(height: 1),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showLanguageSelectorDialog(
      context: context,
      selectedLanguage: _currentLanguage,
      onLanguageSelected: (language) async {
        await LanguagePreferenceService.setLanguage(language);
        setState(() {
          _currentLanguage = language;
        });
        widget.onLanguageChanged(language);
      },
    );
  }

  void _showFeedback(BuildContext context) {
    showFeedbackDialog(context);
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

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final languageCode = await LanguagePreferenceService.getLanguage();
    final languageName = _getLanguageDisplayName(
      languageCode,
    ).split(' ').first.toLowerCase();
    final url =
        'https://smuky.github.io/ai-football-predictor-privacy.html#$languageName';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
