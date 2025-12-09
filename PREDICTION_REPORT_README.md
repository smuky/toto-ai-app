# Prediction Report Widget

A professional, collapsible widget for displaying match prediction data with detailed analysis.

## Features

- **Match Header**: Displays competition, teams, date, and venue with a gradient background
- **Win Probabilities**: Visual progress bars showing home win, draw, and away win percentages
- **Prediction Justification**: Clear explanation of the prediction reasoning
- **Detailed Analysis**: Four collapsible sections:
  - Recent Form Analysis
  - Expected Goals (xG) Analysis
  - Head-to-Head Summary
  - Key News & Injuries
- **RTL Support**: Supports right-to-left languages (e.g., Hebrew)
- **Responsive Design**: Works on various screen sizes

## Files Created

1. **`lib/models/prediction_response.dart`** - Data models for the prediction response
2. **`lib/widgets/prediction_report_widget.dart`** - Main widget component
3. **`lib/widgets/prediction_report_usage_example.dart`** - Example usage with dialog

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'models/prediction_response.dart';
import 'widgets/prediction_report_widget.dart';

// Inside your widget build method
PredictionReportWidget(
  prediction: predictionResponse,
  language: 'en', // or 'he', 'es', etc.
)
```

### Show in Dialog

```dart
import 'widgets/prediction_report_usage_example.dart';

// When you receive JSON response from API
showPredictionReportDialog(
  context,
  jsonResponseString,
  'en', // current language
);
```

### Parse JSON Response

```dart
import 'dart:convert';
import 'models/prediction_response.dart';

final jsonData = jsonDecode(responseString);
final prediction = PredictionResponse.fromJson(jsonData);
```

## Integration Example

Replace your current response display with the prediction report:

```dart
// Instead of showing plain text response
Text(response)

// Use the prediction report widget
if (isPredictionResponse) {
  final prediction = PredictionResponse.fromJson(jsonDecode(response));
  PredictionReportWidget(
    prediction: prediction,
    language: _selectedLanguage,
  )
} else {
  Text(response) // fallback for other responses
}
```

## Customization

### Colors
Edit the colors in `prediction_report_widget.dart`:
- Match header gradient: `Colors.blue.shade700` to `Colors.blue.shade500`
- Probability bars: `Colors.green`, `Colors.orange`, `Colors.red`
- Analysis section icons: `Colors.blue`, `Colors.green`, `Colors.purple`, `Colors.red`

### Icons
Change icons in the `_buildAnalysisSection` method:
- Recent Form: `Icons.trending_up`
- xG Analysis: `Icons.sports_soccer`
- Head-to-Head: `Icons.history`
- Key News: `Icons.medical_services`

### Date Format
Modify the date format in `_buildMatchHeader`:
```dart
final formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
// Change to: DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
```

## Dependencies

- `intl: ^0.19.0` - For date formatting (already added to pubspec.yaml)

## Example JSON Response

```json
{
  "matchDetails": {
    "date": "2025-12-13T20:05:00Z",
    "competition": "France Ligue 1",
    "venue": "Stade Jean Bouin, Paris, France",
    "homeTeam": "Paris FC",
    "awayTeam": "Toulouse"
  },
  "analysis": {
    "recentFormAnalysis": "...",
    "xGAnalysis": "...",
    "headToHeadSummary": "...",
    "keyNews": "..."
  },
  "probabilities": {
    "1": 38,
    "2": 30,
    "X": 32
  },
  "justification": "..."
}
```

## Screenshots

The widget includes:
- 📊 Visual probability bars with percentages
- 🎯 Collapsible analysis sections (tap to expand/collapse)
- 📅 Formatted date and venue information
- 🌐 RTL language support
- 🎨 Professional card-based design with elevation and shadows
