import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/fixture.dart';
import '../models/translation_response.dart';
import '../services/prediction_service.dart';
import '../utils/text_direction_helper.dart';
import '../providers/predictor_provider.dart';

class UpcomingGamesWidget extends StatefulWidget {
  final List<Fixture> upcomingFixtures;
  final bool isLoadingFixtures;
  final String selectedLanguage;
  final String selectedLeague;
  final TranslationResponse translations;

  const UpcomingGamesWidget({
    super.key,
    required this.upcomingFixtures,
    required this.isLoadingFixtures,
    required this.selectedLanguage,
    required this.selectedLeague,
    required this.translations,
  });

  @override
  State<UpcomingGamesWidget> createState() => _UpcomingGamesWidgetState();
}

class _UpcomingGamesWidgetState extends State<UpcomingGamesWidget> {
  int? _loadingFixtureId;

  Future<void> _analyzeFixture(Fixture fixture) async {
    final predictor = Provider.of<PredictorProvider>(context, listen: false).selectedPredictor;
    
    setState(() {
      _loadingFixtureId = fixture.fixtureId;
    });

    await PredictionService.fetchPredictionWithPredictor(
      context: context,
      predictor: predictor,
      homeTeam: fixture.effectiveHomeTeam,
      awayTeam: fixture.effectiveAwayTeam,
      league: widget.selectedLeague,
      language: widget.selectedLanguage,
      translations: widget.translations,
      fixtureId: fixture.fixtureId,
      onLoadingChanged: (isLoading) {
        if (mounted) {
          setState(() {
            _loadingFixtureId = isLoading ? fixture.fixtureId : null;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingFixtures) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text(
                'Loading upcoming matches...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.upcomingFixtures.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Icon(Icons.sports_soccer, size: 48, color: Colors.white54),
            SizedBox(height: 12),
            Text(
              'No Upcoming Matches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No fixtures available for this league',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...widget.upcomingFixtures.map((fixture) => _buildFixtureCard(fixture)),
      ],
    );
  }

  Widget _buildFixtureCard(Fixture fixture) {
    final dateTime = fixture.date;
    final dayNameKey = DateFormat('EEEE').format(dateTime).toLowerCase();
    final dayName = widget.translations.days[dayNameKey] ?? dayNameKey;
    final dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: TextDirectionHelper.isRTL(widget.selectedLanguage)
                ? [
                    // RTL: Away team on left
                    Expanded(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: fixture.awayTeamLogo,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fixture.effectiveAwayTeam,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: fixture.fixtureId.toString()));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fixture ID ${fixture.fixtureId} copied to clipboard'),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // RTL: Home team on right
                    Expanded(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: fixture.homeTeamLogo,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fixture.effectiveHomeTeam,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ]
                : [
                    // LTR: Home team on left
                    Expanded(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: fixture.homeTeamLogo,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fixture.effectiveHomeTeam,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: fixture.fixtureId.toString()));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fixture ID ${fixture.fixtureId} copied to clipboard'),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // LTR: Away team on right
                    Expanded(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: fixture.awayTeamLogo,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fixture.effectiveAwayTeam,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<PredictorProvider>(
            builder: (context, predictorProvider, _) {
              final predictor = predictorProvider.selectedPredictor;
              final isLoading = _loadingFixtureId == fixture.fixtureId;
              
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _analyzeFixture(fixture),
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          predictor.icon,
                          size: 20,
                        ),
                  label: Text(
                    isLoading 
                        ? widget.translations.analyzing 
                        : widget.translations.analyzeMatch,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: predictor.buttonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

