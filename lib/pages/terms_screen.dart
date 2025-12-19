import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';
import '../services/language_preference_service.dart';
import '../services/team_service.dart';
import '../config/language_config.dart';
import '../models/translation_response.dart';
import '../utils/text_direction_helper.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  static const String _termsAcceptedKey = 'is_terms_accepted';

  static Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  TranslationResponse? _translations;
  bool _isLoading = true;
  String _currentLanguage = 'en';

  static const String _privacyPolicyBaseUrl = 'https://smuky.github.io/ai-football-predictor-privacy.html';

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    try {
      final languageCode = await LanguagePreferenceService.getLanguage();
      final translations = await TeamService.fetchTranslations(languageCode);
      setState(() {
        _translations = translations;
        _currentLanguage = languageCode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final languageCode = await LanguagePreferenceService.getLanguage();
    final languageName = LanguageConfig.getLanguageName(languageCode).toLowerCase();
    final url = '$_privacyPolicyBaseUrl#$languageName';
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _acceptTerms(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TermsScreen._termsAcceptedKey, true);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  String _getTranslatedText(String Function(TranslationResponse) getter, String fallback) {
    if (_translations != null) {
      return getter(_translations!);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Text(
                    _getTranslatedText(
                      (t) => t.termsOfUseTitle,
                      'Welcome to 1X2-AI',
                    ),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const SizedBox.shrink()
                else
                  Text(
                    _getTranslatedText(
                      (t) => t.termsOfUseHeader,
                      'Before we start, please read and accept the following:',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTermItem(
                                  icon: Icons.info_outline,
                                  text: _getTranslatedText(
                                    (t) => t.termsOfUseStatisticalInfo,
                                    'This app provides statistical information only.',
                                  ),
                                  iconColor: Colors.blue,
                                ),
                                const SizedBox(height: 20),
                                _buildTermItem(
                                  icon: Icons.block,
                                  text: _getTranslatedText(
                                    (t) => t.termsOfUseNotGambling,
                                    'This is NOT a gambling application.',
                                  ),
                                  iconColor: Colors.red,
                                ),
                                const SizedBox(height: 20),
                                _buildTermItem(
                                  icon: Icons.person_outline,
                                  text: _getTranslatedText(
                                    (t) => t.termsOfUseAgeRequirement,
                                    'You must be 18+ years old to use this app.',
                                  ),
                            iconColor: Colors.orange,
                          ),
                                const SizedBox(height: 20),
                                _buildTermItem(
                                  icon: Icons.warning_amber_outlined,
                                  text: _getTranslatedText(
                                    (t) => t.termsOfUseNoResponsibility,
                                    'We are not responsible for any financial losses.',
                                  ),
                                  iconColor: Colors.amber,
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: TextButton.icon(
                                    onPressed: _launchPrivacyPolicy,
                                    icon: const Icon(Icons.open_in_new),
                                    label: Text(
                                      _getTranslatedText(
                                        (t) => t.termsOfUseReadPolicy,
                                        'Read full Privacy Policy & Terms',
                                      ),
                                    ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _acceptTerms(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _getTranslatedText(
                        (t) => t.termsOfUseAgreeContinue,
                        'I Agree & Continue',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermItem({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    final isRTL = TextDirectionHelper.isRTL(_currentLanguage);
    
    final iconWidget = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    );
    
    final textWidget = Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.black87,
        ),
        textAlign: TextDirectionHelper.getTextAlign(_currentLanguage),
        textDirection: TextDirectionHelper.getTextDirection(_currentLanguage),
      ),
    );
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isRTL
          ? [
              textWidget,
              const SizedBox(width: 16),
              iconWidget,
            ]
          : [
              iconWidget,
              const SizedBox(width: 16),
              textWidget,
            ],
    );
  }
}
