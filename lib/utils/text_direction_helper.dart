import 'package:flutter/material.dart';

/// Helper class for handling text direction and alignment based on language
class TextDirectionHelper {
  /// Returns true if the language is RTL (Right-to-Left)
  static bool isRTL(String language) {
    return language == 'he' || language == 'ar';
  }

  /// Returns the appropriate TextDirection for the given language
  static TextDirection getTextDirection(String language) {
    return isRTL(language) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Returns the appropriate TextAlign for the given language
  static TextAlign getTextAlign(String language) {
    return isRTL(language) ? TextAlign.right : TextAlign.left;
  }

  /// Returns the appropriate TextAlign for center-aligned text
  /// (always center regardless of language)
  static TextAlign getCenterAlign() {
    return TextAlign.center;
  }

  /// Wraps a widget with Directionality based on language
  static Widget wrapWithDirectionality({
    required String language,
    required Widget child,
  }) {
    return Directionality(
      textDirection: getTextDirection(language),
      child: child,
    );
  }
}
