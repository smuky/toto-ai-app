# AdMob Setup Guide

This app automatically switches between **test ads** (debug mode) and **production ads** (release mode) to prevent AdMob policy violations and account bans.

## How It Works

### Debug Mode (Development)
- Uses Google's official test ad unit IDs
- Safe to click on ads during testing
- No risk of policy violations

### Release Mode (Production)
- Uses your real AdMob ad unit IDs
- Shows real ads to users
- Generates actual revenue

## Configuration Steps

### 1. Get Your AdMob IDs

1. Go to [AdMob Console](https://admob.google.com)
2. Create/select your app
3. Get the following IDs:
   - **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)
   - **Banner Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)
   - **Interstitial Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)

### 2. Update Android Configuration

**File: `android/app/build.gradle.kts`**

Replace line 68:
```kotlin
manifestPlaceholders["admobAppId"] = "YOUR_PRODUCTION_ADMOB_APP_ID"
```

With your Android App ID:
```kotlin
manifestPlaceholders["admobAppId"] = "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"
```

### 3. Update iOS Configuration

**File: `ios/Flutter/Release.xcconfig`**

Replace line 3:
```
ADMOB_APP_ID = YOUR_PRODUCTION_IOS_ADMOB_APP_ID
```

With your iOS App ID:
```
ADMOB_APP_ID = ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
```

### 4. Update Ad Unit IDs

**File: `lib/services/admob_service.dart`**

Replace lines 6-9 with your actual ad unit IDs:

```dart
static const String _prodAndroidBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _prodIosBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _prodAndroidInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _prodIosInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

## Testing

### Test in Debug Mode
```bash
# Android
flutter run

# iOS
flutter run
```
✅ You'll see test ads - safe to click!

### Test in Release Mode
```bash
# Android
flutter run --release

# iOS
flutter run --release
```
⚠️ You'll see real ads - **DO NOT CLICK** on your own ads!

## Build for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Important Notes

⚠️ **Never click on your own production ads** - this can get your AdMob account banned!

✅ **Always test with debug builds** during development

✅ The app automatically uses test ads in debug mode - no configuration needed

✅ Production ads only show in release builds

## Verification

To verify which ads are showing:

1. **Debug build**: Look for "Test Ad" label on ads
2. **Release build**: Real ads won't have the test label

## Ad Placement

- **Banner Ad**: Bottom of home screen
- **Interstitial Ad**: Shown before prediction results page

## Troubleshooting

### Ads not showing?
1. Check internet connection
2. Verify Ad Unit IDs are correct
3. Wait a few hours after creating new ad units (AdMob needs time to activate)
4. Check AdMob console for any account issues

### Still seeing test ads in release?
1. Verify you're building with `--release` flag
2. Check that production IDs are correctly set in config files
3. Uninstall and reinstall the app

## Support

For AdMob-specific issues, visit:
- [AdMob Help Center](https://support.google.com/admob)
- [AdMob Policy Center](https://support.google.com/admob/answer/6128543)
