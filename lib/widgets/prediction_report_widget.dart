import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../models/prediction_response.dart';
import '../models/translation_response.dart';
import '../utils/text_direction_helper.dart';

class PredictionReportWidget extends StatelessWidget {
  final PredictionResponse prediction;
  final String language;
  final TranslationResponse translations;

  const PredictionReportWidget({
    super.key,
    required this.prediction,
    this.language = 'en',
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = language == 'he';
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMatchHeader(isRtl),
            const SizedBox(height: 16),
            _buildProbabilitiesCard(isRtl),
            const SizedBox(height: 16),
            _buildJustificationCard(isRtl),
            const SizedBox(height: 16),
            _buildAnalysisSection(isRtl),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader(bool isRtl) {
    String formattedDate = '';
    try {
      final dateTime = DateTime.parse(prediction.matchDetails.date);
      formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    } catch (e) {
      // If date parsing fails, leave formattedDate empty
      formattedDate = '';
    }

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prediction.matchDetails.competition,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    prediction.matchDetails.homeTeam,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    translations.vs,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    prediction.matchDetails.awayTeam,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            if (formattedDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    prediction.matchDetails.venue,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilitiesCard(bool isRtl) {
    final homeWin = prediction.probabilities['1'] ?? 0;
    final draw = prediction.probabilities['X'] ?? 0;
    final awayWin = prediction.probabilities['2'] ?? 0;

    // Determine which team has higher probability for top position
    final String topTeam;
    final int topPercentage;
    final String bottomTeam;
    final int bottomPercentage;

    if (homeWin >= awayWin) {
      topTeam = prediction.matchDetails.homeTeam;
      topPercentage = homeWin;
      bottomTeam = prediction.matchDetails.awayTeam;
      bottomPercentage = awayWin;
    } else {
      topTeam = prediction.matchDetails.awayTeam;
      topPercentage = awayWin;
      bottomTeam = prediction.matchDetails.homeTeam;
      bottomPercentage = homeWin;
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirectionHelper.getTextDirection(language),
              children: [
                Icon(Icons.analytics, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translations.winProbabilities,
                    textAlign: TextDirectionHelper.getTextAlign(language),
                    textDirection: TextDirectionHelper.getTextDirection(language),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProbabilityBar(topTeam, topPercentage, Colors.green),
            const SizedBox(height: 12),
            _buildProbabilityBar(translations.draw, draw, Colors.orange),
            const SizedBox(height: 12),
            _buildProbabilityBar(bottomTeam, bottomPercentage, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityBar(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildJustificationCard(bool isRtl) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirectionHelper.getTextDirection(language),
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translations.predictionJustification,
                    textAlign: TextDirectionHelper.getTextAlign(language),
                    textDirection: TextDirectionHelper.getTextDirection(language),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prediction.justification,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          translations.detailedAnalysis,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
          textAlign: TextDirectionHelper.getTextAlign(language),
          textDirection: TextDirectionHelper.getTextDirection(language),
        ),
        const SizedBox(height: 12),
        _buildExpandableCard(
          translations.recentFormAnalysis,
          prediction.analysis.recentFormAnalysis,
          Icons.trending_up,
          Colors.blue,
          isRtl,
          false,
        ),
        const SizedBox(height: 8),
        _buildExpandableCard(
          translations.expectedGoalsAnalysis,
          prediction.analysis.xGAnalysis,
          Icons.sports_soccer,
          Colors.green,
          isRtl,
          false,
        ),
        const SizedBox(height: 8),
        _buildExpandableCard(
          translations.headToHeadSummary,
          prediction.analysis.headToHeadSummary,
          Icons.history,
          Colors.purple,
          isRtl,
          false,
        ),
        const SizedBox(height: 8),
        _buildExpandableCard(
          translations.keyNewsInjuries,
          prediction.analysis.keyNews,
          Icons.medical_services,
          Colors.red,
          isRtl,
          false,
        ),
      ],
    );
  }

  Widget _buildExpandableCard(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isRtl,
    bool initiallyExpanded,
  ) {
    return _ExpandableCardWidget(
      title: title,
      content: content,
      icon: icon,
      color: color,
      isRtl: isRtl,
      initiallyExpanded: initiallyExpanded,
    );
  }
}

class _ExpandableCardWidget extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final bool isRtl;
  final bool initiallyExpanded;

  const _ExpandableCardWidget({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    required this.isRtl,
    this.initiallyExpanded = false,
  });

  @override
  State<_ExpandableCardWidget> createState() => _ExpandableCardWidgetState();
}

class _ExpandableCardWidgetState extends State<_ExpandableCardWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
                      textDirection: widget.isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
                textDirection: widget.isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              ),
            ),
        ],
      ),
    );
  }
}
