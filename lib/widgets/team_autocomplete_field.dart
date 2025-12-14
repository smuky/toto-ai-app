import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/team.dart';

class TeamAutocompleteField extends StatelessWidget {
  final String label;
  final List<Team> availableTeams;
  final Team? selectedTeam;
  final ValueChanged<Team?> onTeamSelected;
  final bool enabled;

  const TeamAutocompleteField({
    super.key,
    required this.label,
    required this.availableTeams,
    required this.selectedTeam,
    required this.onTeamSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Team>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return availableTeams;
        }
        return availableTeams.where((Team team) {
          return team.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (Team team) => team.name,
      onSelected: (Team team) {
        onTeamSelected(team);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        if (selectedTeam != null && textEditingController.text.isEmpty) {
          textEditingController.text = selectedTeam!.name;
        } else if (selectedTeam == null && textEditingController.text.isNotEmpty) {
          textEditingController.clear();
        }

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          enabled: enabled,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            filled: true,
            fillColor: Colors.transparent,
            prefixIcon: selectedTeam != null
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CachedNetworkImage(
                      imageUrl: selectedTeam!.logo,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.sports_soccer,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                : null,
            suffixIcon: enabled
                ? (selectedTeam != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          textEditingController.clear();
                          onTeamSelected(null);
                        },
                      )
                    : const Icon(Icons.arrow_drop_down, color: Colors.white))
                : null,
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
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Team> onSelected,
        Iterable<Team> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Team team = options.elementAt(index);
                  return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: team.logo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.sports_soccer,
                        size: 40,
                      ),
                    ),
                    title: Text(team.name),
                    onTap: () {
                      onSelected(team);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
