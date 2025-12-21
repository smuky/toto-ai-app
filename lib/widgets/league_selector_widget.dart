import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/league_logos_config.dart';
import '../utils/text_direction_helper.dart';

class LeagueSelectorWidget extends StatelessWidget {
  final String? selectedLeague;
  final List<String> availableLeagues;
  final Map<String, String> leagueTranslations;
  final String selectedLanguage;
  final String selectLeagueText;
  final Function(String?) onLeagueChanged;

  const LeagueSelectorWidget({
    super.key,
    required this.selectedLeague,
    required this.availableLeagues,
    required this.leagueTranslations,
    required this.selectedLanguage,
    required this.selectLeagueText,
    required this.onLeagueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          if (selectedLeague != null && LeagueLogosConfig.getLeagueLogo(selectedLeague!) != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CachedNetworkImage(
                imageUrl: LeagueLogosConfig.getLeagueLogo(selectedLeague!)!,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.sports_soccer,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.sports_soccer, color: Colors.blue, size: 28),
            ),
          Expanded(
            child: Directionality(
              textDirection: TextDirectionHelper.getTextDirection(selectedLanguage),
              child: DropdownButton<String>(
                value: selectedLeague,
                hint: Align(
                  alignment: TextDirectionHelper.isRTL(selectedLanguage)
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    selectLeagueText,
                    textAlign: TextDirectionHelper.getTextAlign(selectedLanguage),
                    textDirection: TextDirectionHelper.getTextDirection(selectedLanguage),
                  ),
                ),
                selectedItemBuilder: (BuildContext context) {
                  return availableLeagues.map((league) {
                    final translatedName = leagueTranslations[league] ?? league;
                    return Align(
                      alignment: TextDirectionHelper.isRTL(selectedLanguage)
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        translatedName,
                        textAlign: TextDirectionHelper.getTextAlign(selectedLanguage),
                        textDirection: TextDirectionHelper.getTextDirection(selectedLanguage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                underline: const SizedBox(),
                items: availableLeagues.map((league) {
                  final translatedName = leagueTranslations[league] ?? league;
                  return DropdownMenuItem<String>(
                    value: league,
                    alignment: TextDirectionHelper.isRTL(selectedLanguage) 
                        ? AlignmentDirectional.centerEnd 
                        : AlignmentDirectional.centerStart,
                    child: Text(
                      translatedName,
                      textAlign: TextDirectionHelper.getTextAlign(selectedLanguage),
                      textDirection: TextDirectionHelper.getTextDirection(selectedLanguage),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
              }).toList(),
                onChanged: onLeagueChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
