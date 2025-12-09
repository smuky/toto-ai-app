# Google AdMob Setup Guide

## 1. Get Your AdMob App ID

1. Go to [Google AdMob Console](https://apps.admob.com/)
2. Create a new app or select your existing app
3. Get your App ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

## 2. Configure Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Add this meta-data tag inside <application> -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

## 3. Configure iOS (if needed)

Edit `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

Also add this for iOS 14+ tracking:

```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

## 4. Get Your Ad Unit IDs

1. In AdMob Console, go to "Apps" → Your App → "Ad units"
2. Create a new Banner ad unit
3. Copy the Ad Unit ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)
4. Update `lib/config/ad_config.dart` with your production Ad Unit IDs

## 5. Testing

The app currently uses **test ad unit IDs**:
- Android: `ca-app-pub-3940256099942544/6300978111`
- iOS: `ca-app-pub-3940256099942544/2934735716`

These will show test ads. Replace them with your real Ad Unit IDs in production.

## 6. Update Ad Unit IDs for Production

Edit `lib/config/ad_config.dart`:

```dart
static String get bannerAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your Android Ad Unit ID
  } else if (Platform.isIOS) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your iOS Ad Unit ID
  }
}
```

## 7. Install Dependencies

Run:
```bash
flutter pub get
```

## 8. Important Notes

- **Never use test ad unit IDs in production apps** - your AdMob account may be suspended
- Test ads will show "Test Ad" label
- Real ads will only show after your app is approved by AdMob
- It may take a few hours for ads to start showing after setup

## 9. Ad Placement

The banner ad is currently placed at the bottom of the home screen using `bottomNavigationBar`. This ensures it stays visible and doesn't interfere with content.

## 10. Troubleshooting

If ads don't show:
1. Check that you've added the App ID to AndroidManifest.xml
2. Verify internet connection
3. Check console logs for error messages
4. Make sure you're using test ad unit IDs during development
5. Wait a few minutes after first setup - ads may take time to load

## Additional Ad Types

You can add more ad types:
- **Interstitial Ads**: Full-screen ads between pages
- **Rewarded Ads**: Users watch ads for rewards
- **Native Ads**: Ads that match your app's design

See the [google_mobile_ads documentation](https://pub.dev/packages/google_mobile_ads) for more details.
