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

  PredefinedEvent? get _selectedEvent {
    if (selectedRecommendedList == null || translations == null) {
      return null;
    }
    try {
      return translations!.predefinedEvents.firstWhere(
        (event) => event.key == selectedRecommendedList,
      );
    } catch (e) {
      return null;
    }
  }

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Autocomplete<PredefinedEvent>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return predefinedEvents;
          }
          final query = textEditingValue.text.toLowerCase();
          return predefinedEvents.where((event) {
            return event.displayName.toLowerCase().contains(query);
          });
        },
        displayStringForOption: (PredefinedEvent event) => event.displayName,
        onSelected: (PredefinedEvent event) {
          onListChanged(event.key);
        },
        fieldViewBuilder:
            (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              // Update text controller when selectedRecommendedList changes (e.g., language change)
              final selectedEvent = _selectedEvent;
              if (selectedEvent != null) {
                if (textEditingController.text != selectedEvent.displayName) {
                  textEditingController.text = selectedEvent.displayName;
                }
              } else if (textEditingController.text.isNotEmpty) {
                textEditingController.clear();
              }

              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: selectedEvent != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            textEditingController.clear();
                            onListChanged(null);
                          },
                        )
                      : const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
                onTap: () {
                  if (textEditingController.selection ==
                      TextSelection.fromPosition(
                        TextPosition(offset: textEditingController.text.length),
                      )) {
                    textEditingController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: textEditingController.text.length,
                    );
                  }
                },
              );
            },
        optionsViewBuilder:
            (
              BuildContext context,
              AutocompleteOnSelected<PredefinedEvent> onSelected,
              Iterable<PredefinedEvent> options,
            ) {
              final isRtl = TextDirectionHelper.isRTL(selectedLanguage);
              return Align(
                alignment: isRtl ? Alignment.topRight : Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  child: Directionality(
                    textDirection: TextDirectionHelper.getTextDirection(
                      selectedLanguage,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PredefinedEvent event = options.elementAt(
                            index,
                          );
                          return ListTile(
                            title: Text(
                              event.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              onSelected(event);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
      ),
    );
  }
}
