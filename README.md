# toto_ai

A Flutter mobile application for calculating European football odds using AI.

## Environment Configuration

The app supports multiple environments similar to Spring Boot profiles:

### Available Environments

- **local**: Development environment (HTTP, 10.0.2.2:8080 for Android emulator)
- **prod**: Production environment (HTTPS, toto-ai-backend.onrender.com)

### Switching Environments

Edit `lib/main.dart` and change the environment in the `main()` function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // For local development
  await AppConfig.initialize(Environment.local);
  
  // For production
  // await AppConfig.initialize(Environment.prod);
  
  runApp(const TotoAIApp());
}
```

### Configuration Files

- **`lib/config/app_config.yaml`** - YAML configuration file (Spring Boot style)
  - Contains all environment-specific settings
  - Automatically loaded based on selected environment
  
- **`lib/config/environment.dart`** - Configuration loader
  - Reads and parses the YAML file
  - Provides type-safe access to configuration values

The current environment is displayed as a badge in the app bar:
- 🟢 **PROD** (green) - Production environment
- 🟠 **LOCAL** (orange) - Local development environment

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Set your environment in `lib/main.dart`

3. Run the app:
   ```bash
   flutter run
   ```
