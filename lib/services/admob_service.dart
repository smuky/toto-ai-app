import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
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
    if (Platform.isAndroid) {
      return _isDebugMode ? _testAndroidBannerAdUnitId : _prodAndroidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _isDebugMode ? _testIosBannerAdUnitId : _prodIosBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
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

  static BannerAd createBannerAd({
    required AdSize adSize,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
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
    required void Function() onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          onAdLoaded();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  static bool get isInterstitialAdReady => _isInterstitialAdReady;

  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
