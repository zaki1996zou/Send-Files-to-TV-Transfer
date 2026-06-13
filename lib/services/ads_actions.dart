import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multiads/multiads.dart';

import '../util/global.dart';

/// Helpers for showing ads only when [gAds] finished loading.
class AdsActions {
  static void registerCallbacks() {
    AdCallbacks.onInterstitialDismissed = () {
      isInterShowed = false;
    };
  }

  /// Shows an app-open ad during launch (on splash), then calls [onFinished].
  /// Skips if unavailable within [maxWaitToShow] — app always continues.
  static Future<void> showAppOpenOnLaunch({
    required VoidCallback onFinished,
    Duration maxWaitToShow = const Duration(seconds: 3),
  }) async {
    final ads = gAds;
    if (!gAdsReady || ads == null || !ads.hasAppOpen || appOpenShownThisSession) {
      onFinished();
      return;
    }

    appOpenShownThisSession = true;
    var finished = false;
    var adShown = false;

    void finish() {
      if (finished) return;
      finished = true;
      AdCallbacks.onAppOpenShown = null;
      AdCallbacks.onAppOpenDismissed = null;
      onFinished();
    }

    AdCallbacks.onAppOpenShown = () => adShown = true;
    AdCallbacks.onAppOpenDismissed = finish;

    final deadline = DateTime.now().add(maxWaitToShow);
    while (!adShown && DateTime.now().isBefore(deadline)) {
      ads.openAdsInstance.showAdIfAvailableOpenAds();
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (!adShown) {
      finish();
      return;
    }

    Timer(const Duration(seconds: 45), finish);
  }

  /// Runs [onContinue] after a rewarded ad, or immediately if unavailable.
  /// Never blocks app access when the ad cannot load.
  static void showRewardedThen(VoidCallback onContinue) {
    final ads = gAds;
    if (!pastSplash || !gAdsReady || ads == null || !ads.hasRewarded || isInterShowed) {
      onContinue();
      return;
    }

    ads.rewardInstance.showRewardAd((_) {
      isInterShowed = false;
      onContinue();
    });
  }

  /// Runs [onContinue] after an interstitial ad, or immediately if unavailable.
  static void showInterstitialThen(VoidCallback onContinue) {
    final ads = gAds;
    if (!pastSplash || !gAdsReady || ads == null || !ads.hasInterstitials || isInterShowed) {
      onContinue();
      return;
    }

    showInterstitial(onDismissed: onContinue);
  }

  static Future<void> showInterstitial({VoidCallback? onDismissed}) async {
    final ads = gAds;
    if (!gAdsReady || ads == null || !ads.hasInterstitials || isInterShowed) {
      onDismissed?.call();
      return;
    }

    isInterShowed = true;
    AdCallbacks.onInterstitialDismissed = () {
      isInterShowed = false;
      onDismissed?.call();
    };
    ads.interInstance.showInterstitialAd();
  }

  static Widget bannerOrEmpty(Key key) {
    final ads = gAds;
    if (!pastSplash || !gAdsReady || ads == null || !ads.hasBanners) {
      return const SizedBox.shrink();
    }
    return ads.bannerInstance.getBannerAdWidget(key);
  }

  static Future<void> loadBanner(Key key, {VoidCallback? onLoaded}) async {
    final ads = gAds;
    if (!pastSplash || !gAdsReady || ads == null || !ads.hasBanners) return;
    await ads.bannerInstance.loadBannerAd(onLoaded, key);
  }

  static Future<void> disposeBanner(Key key) async {
    final ads = gAds;
    if (!gAdsReady || ads == null || !ads.hasBanners) return;
    await ads.bannerInstance.disposeBanner(key);
  }

  static void pushRewarded(BuildContext context, Widget screen) {
    showRewardedThen(() {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    });
  }

  static void pushInterstitial(BuildContext context, Widget screen) {
    showInterstitialThen(() {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    });
  }

  static void popWithInterstitial(BuildContext context) {
    showInterstitialThen(() {
      if (!context.mounted) return;
      Navigator.of(context).pop();
    });
  }
}
