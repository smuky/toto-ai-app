import 'package:flutter/material.dart';
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
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: enabled
                ? (selectedTeam != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          textEditingController.clear();
                          onTeamSelected(null);
                        },
                      )
                    : const Icon(Icons.arrow_drop_down))
                : null,
            helperText: enabled ? 'Start typing to search' : null,
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
