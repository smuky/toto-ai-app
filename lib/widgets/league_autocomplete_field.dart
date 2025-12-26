import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/league.dart';
import '../utils/text_direction_helper.dart';

class LeagueAutocompleteField extends StatelessWidget {
  final String label;
  final List<League> availableLeagues;
  final League? selectedLeague;
  final ValueChanged<League?> onLeagueSelected;
  final String selectedLanguage;

  const LeagueAutocompleteField({
    super.key,
    required this.label,
    required this.availableLeagues,
    required this.selectedLeague,
    required this.onLeagueSelected,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Autocomplete<League>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return availableLeagues;
          }
          final query = textEditingValue.text.toLowerCase();
          return availableLeagues.where((League league) {
            return league.searchText.contains(query);
          });
        },
        displayStringForOption: (League league) => league.displayName,
        onSelected: (League league) {
          onLeagueSelected(league);
        },
        fieldViewBuilder:
            (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              // Update text controller when selectedLeague changes (e.g., language change)
              if (selectedLeague != null) {
                if (textEditingController.text != selectedLeague!.displayName) {
                  textEditingController.text = selectedLeague!.displayName;
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
                  labelText: label,
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
                  prefixIcon:
                      selectedLeague != null &&
                          selectedLeague!.effectiveLogo != null
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CachedNetworkImage(
                            imageUrl: selectedLeague!.effectiveLogo!,
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
                      : const Padding(
                          padding: EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Icon(
                            Icons.sports_soccer,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                  suffixIcon: selectedLeague != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            textEditingController.clear();
                            onLeagueSelected(null);
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
              AutocompleteOnSelected<League> onSelected,
              Iterable<League> options,
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
                          final League league = options.elementAt(index);
                          return ListTile(
                            leading: league.effectiveLogo != null
                                ? CachedNetworkImage(
                                    imageUrl: league.effectiveLogo!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) =>
                                        const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) {
                                      print(
                                        'Error loading league logo for ${league.name}: $url',
                                      );
                                      print('Error: $error');
                                      return const Icon(
                                        Icons.sports_soccer,
                                        size: 40,
                                        color: Colors.blue,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.sports_soccer,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                            title: Text(
                              league.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              league.country,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            onTap: () {
                              onSelected(league);
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
