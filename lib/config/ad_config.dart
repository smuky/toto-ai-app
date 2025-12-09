import 'dart:io';

class AdConfig {
  // TODO: Replace these with your actual Ad Unit IDs from Google AdMob
  // Get your Ad Unit IDs from: https://apps.admob.com/
  
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Test ad unit for Android
      return 'ca-app-pub-3940256099942544/6300978111';
      // Production: return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      // Test ad unit for iOS
      return 'ca-app-pub-3940256099942544/2934735716';
      // Production: return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
