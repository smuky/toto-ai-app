import 'package:flutter/material.dart';
import '../config/language_config.dart';

void showLanguageSelectorDialog({
  required BuildContext context,
  required String selectedLanguage,
  required Function(String) onLanguageSelected,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
        title: const Row(
          children: [
            Icon(Icons.language, color: Colors.blue),
            SizedBox(width: 8),
            Text('Select Language', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageConfig.supportedLanguages.entries.map((entry) {
            return ListTile(
              title: Text(entry.value, style: const TextStyle(color: Colors.white)),
              leading: Radio<String>(
                value: entry.key,
                groupValue: selectedLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    Navigator.of(context).pop();
                    onLanguageSelected(value);
                  }
                },
              ),
              onTap: () {
                Navigator.of(context).pop();
                onLanguageSelected(entry.key);
              },
            );
          }).toList(),
        ),
      );
    },
  );
}
