# How to Add a New Predictor

All predictor logic is now centralized in the `Predictor` model. To add a new predictor, simply add it to `/lib/models/predictor.dart`:

```dart
static const Predictor expert = Predictor(
  id: 'expert',
  name: 'Expert Predictor',
  image: 'assets/predictor_expert.png',
  description: 'Premium AI model with deep learning algorithms and real-time data analysis for the most accurate predictions.',
  apiEndpoint: 'expert-prediction',  // Your new API endpoint
  icon: Icons.stars,                  // Choose any Material icon
  primaryColor: Color(0xFFFF6F00),   // Orange color
  shadowColor: Color(0xFFE65100),    // Darker orange
);
```

Then add it to the list:

```dart
static const List<Predictor> all = [classic, advanced, expert];
```

That's it! The entire app will automatically:
- Show the new predictor in the selection modal
- Use the correct icon and colors in all buttons
- Route to the correct API endpoint
- Display the predictor's image and description

No other code changes needed anywhere in the app!

## Properties Reference

- **id**: Unique identifier (lowercase, no spaces)
- **name**: Display name shown to users
- **image**: Asset path for predictor image
- **description**: Detailed description shown in modal
- **apiEndpoint**: Backend API endpoint path
- **icon**: Material Icons icon (e.g., Icons.analytics, Icons.auto_awesome, Icons.stars)
- **primaryColor**: Main button color
- **shadowColor**: Shadow/glow color for buttons

## Available Color Properties

The Predictor model provides these computed properties:
- `buttonColor` - Primary button background color
- `glowColor` - Glow effect with 50% opacity
- `shadowColorWithAlpha` - Shadow color for elevation
