import 'package:flutter/material.dart';
import '../utils/text_direction_helper.dart';

void showAboutAppDialog({
  required BuildContext context,
  required String aboutText,
  required String appVersion,
  required String buildNumber,
  required String language,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('About', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          '$aboutText\n\nVersion: $appVersion',
          textAlign: TextDirectionHelper.getTextAlign(language),
          textDirection: TextDirectionHelper.getTextDirection(language),
          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}
