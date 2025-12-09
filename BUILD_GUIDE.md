# Build & Environment Guide

## How It Works

The app now **automatically selects the environment** based on how you build it:
- **Default (Development)**: Uses `local` environment
- **Production Builds**: Uses `prod` environment when you specify `--dart-define=ENV=prod`

You **never need to touch the code** anymore! 🎉

## Development (Local Environment)

Just run normally - it defaults to local:

```bash
# Run on emulator/device (uses LOCAL by default)
flutter run

# Hot reload works as usual
# Press 'r' to hot reload
# Press 'R' to hot restart
```

## Production Builds

### Android APK (Production)
```bash
# Build production APK
flutter build apk --dart-define=ENV=prod --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Production)
```bash
# Build production App Bundle (for Google Play)
flutter build appbundle --dart-define=ENV=prod --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Production)
```bash
# Build production iOS
flutter build ios --dart-define=ENV=prod --release
```

## Testing Production Environment Locally

If you want to test the production API on your local device/emulator:

```bash
# Run in debug mode with production environment
flutter run --dart-define=ENV=prod

# Run in profile mode with production environment
flutter run --dart-define=ENV=prod --profile
```

## VS Code Launch Configurations

Add this to `.vscode/launch.json` for easy switching:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Local)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart"
    },
    {
      "name": "Flutter (Production)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENV=prod"
      ]
    }
  ]
}
```

## Android Studio / IntelliJ

1. Go to **Run** → **Edit Configurations**
2. Select your Flutter configuration
3. Add to **Additional run args**: `--dart-define=ENV=prod`
4. Create separate configurations for local and prod

## Environment Indicator

The app shows the current environment in the app bar:
- 🟠 **LOCAL** - Orange badge (local environment)
- 🟢 **LIVE** - Green badge (production environment)

## Build Scripts (Optional)

Create helper scripts for common builds:

### `scripts/build_prod_apk.sh`
```bash
#!/bin/bash
flutter build apk --dart-define=ENV=prod --release
echo "✅ Production APK built: build/app/outputs/flutter-apk/app-release.apk"
```

### `scripts/build_prod_bundle.sh`
```bash
#!/bin/bash
flutter build appbundle --dart-define=ENV=prod --release
echo "✅ Production Bundle built: build/app/outputs/bundle/release/app-release.aab"
```

Make them executable:
```bash
chmod +x scripts/*.sh
```

## CI/CD Integration

For GitHub Actions, GitLab CI, etc.:

```yaml
# Example GitHub Actions
- name: Build Production APK
  run: flutter build apk --dart-define=ENV=prod --release

- name: Build Production Bundle
  run: flutter build appbundle --dart-define=ENV=prod --release
```

## Safety Features

✅ **Default is LOCAL** - You can't accidentally release with local config  
✅ **No code changes needed** - Environment is set at build time  
✅ **Visual indicator** - Always see which environment you're using  
✅ **Build-time constant** - Can't be changed at runtime  

## Quick Reference

| Command | Environment | Use Case |
|---------|-------------|----------|
| `flutter run` | Local | Daily development |
| `flutter run --dart-define=ENV=prod` | Production | Test prod API locally |
| `flutter build apk --dart-define=ENV=prod --release` | Production | Release APK |
| `flutter build appbundle --dart-define=ENV=prod --release` | Production | Google Play release |

## Troubleshooting

**Q: How do I know which environment I'm using?**  
A: Check the badge in the app bar (LIVE = prod, LOCAL = local)

**Q: Can I add more environments (staging, dev, etc.)?**  
A: Yes! Modify the code to support more values:
```dart
final environment = switch (envString) {
  'prod' => Environment.prod,
  'staging' => Environment.staging,
  _ => Environment.local,
};
```

**Q: Does hot reload work with dart-define?**  
A: Yes! Once you start with a dart-define, hot reload preserves it.
