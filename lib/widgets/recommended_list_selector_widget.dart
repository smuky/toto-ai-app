import 'package:flutter/material.dart';
import '../models/translation_response.dart';
import '../utils/text_direction_helper.dart';

class RecommendedListSelectorWidget extends StatelessWidget {
  final String? selectedRecommendedList;
  final TranslationResponse? translations;
  final String selectedLanguage;
  final Function(String?) onListChanged;

  const RecommendedListSelectorWidget({
    super.key,
    required this.selectedRecommendedList,
    required this.translations,
    required this.selectedLanguage,
    required this.onListChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (translations == null || translations!.predefinedEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: const Center(
          child: Text(
            'No recommended lists available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final predefinedEvents = translations!.predefinedEvents;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12.0),
            child: Icon(Icons.star, color: Colors.amber, size: 28),
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirectionHelper.getTextDirection(selectedLanguage),
              child: DropdownButton<String>(
                value: selectedRecommendedList,
                hint: Align(
                  alignment: TextDirectionHelper.isRTL(selectedLanguage)
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    'Select Recommended List',
                    textAlign: TextDirectionHelper.getTextAlign(selectedLanguage),
                    textDirection: TextDirectionHelper.getTextDirection(selectedLanguage),
                  ),
                ),
                selectedItemBuilder: (BuildContext context) {
                  return predefinedEvents.map((event) {
                    return Align(
                      alignment: TextDirectionHelper.isRTL(selectedLanguage)
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        event.displayName,
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
                items: predefinedEvents.map((event) {
                  return DropdownMenuItem<String>(
                    value: event.key,
                    alignment: TextDirectionHelper.isRTL(selectedLanguage)
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: Text(
                      event.displayName,
                      textAlign: TextDirectionHelper.getTextAlign(selectedLanguage),
                      textDirection: TextDirectionHelper.getTextDirection(selectedLanguage),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onListChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
