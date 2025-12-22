import 'package:flutter/material.dart';
import '../models/translation_response.dart';
import '../utils/text_direction_helper.dart';

class SelectionModeToggleWidget extends StatelessWidget {
  final String selectionMode;
  final TranslationResponse? translations;
  final Function(String) onModeChanged;
  final String selectedLanguage;

  const SelectionModeToggleWidget({
    super.key,
    required this.selectionMode,
    required this.translations,
    required this.onModeChanged,
    required this.selectedLanguage,
  });

  Widget _buildButton({
    required String mode,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.blue.shade700 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = TextDirectionHelper.isRTL(selectedLanguage);
    
    final leagueButton = _buildButton(
      mode: 'league',
      label: translations?.selectLeagueMode ?? 'Select League',
      isSelected: selectionMode == 'league',
    );
    
    final recommendedButton = _buildButton(
      mode: 'recommended',
      label: translations?.recommendedListsMode ?? 'Recommended Lists',
      isSelected: selectionMode == 'recommended',
    );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: isRTL 
            ? [recommendedButton, leagueButton]
            : [leagueButton, recommendedButton],
      ),
    );
  }
}
