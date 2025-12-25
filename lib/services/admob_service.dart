import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static bool _isProUser = false;
  
  // Call this method when the app starts and when the user's pro status changes
  static void updateProStatus(bool isPro) {
    _isProUser = isPro;
    if (isPro) {
      // If user becomes pro, dispose of any loaded ads
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    }
  }
  static const String _prodAndroidBannerAdUnitId = 'ca-app-pub-3174197364390991/5036467502';
  static const String _prodIosBannerAdUnitId = 'ca-app-pub-3174197364390991/5036467502';
  static const String _prodAndroidInterstitialAdUnitId = 'ca-app-pub-3174197364390991/1362985800';
  static const String _prodIosInterstitialAdUnitId = 'ca-app-pub-3174197364390991/1362985800';

  static const String _testAndroidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testAndroidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';

  static bool get _isDebugMode => kDebugMode;

  static String get bannerAdUnitId {
    if (_isProUser) return ''; // Return empty string for pro users
    if (Platform.isAndroid) {
      return _isDebugMode ? _testAndroidBannerAdUnitId : _prodAndroidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _isDebugMode ? _testIosBannerAdUnitId : _prodIosBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (_isProUser) return ''; // Return empty string for pro users
    if (Platform.isAndroid) {
      return _isDebugMode ? _testAndroidInterstitialAdUnitId : _prodAndroidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _isDebugMode ? _testIosInterstitialAdUnitId : _prodIosInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static void initialize() {
    MobileAds.instance.initialize();
  }

  static BannerAd? createBannerAd({
    AdSize adSize = AdSize.banner,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
    void Function(Ad)? onAdLoaded,
  }) {
    if (_isProUser) {
      return null; // Don't create ad for pro users
    }
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;

  static void loadInterstitialAd({
    void Function()? onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
  }) {
    if (_isProUser) {
      return; // Don't load ads for pro users
    }
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          onAdLoaded?.call();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_isProUser || !_isInterstitialAdReady || _interstitialAd == null) {
      return; // Don't show ads for pro users or if ad isn't ready
    }
    _interstitialAd!.show();
  }

  static bool get isInterstitialAdReady => !_isProUser && _isInterstitialAdReady;

  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
