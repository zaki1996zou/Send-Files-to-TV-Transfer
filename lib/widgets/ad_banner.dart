import 'package:flutter/material.dart';

import '../services/ads_actions.dart';
import '../theme/app_colors.dart';
import '../util/global.dart';

/// Bottom banner ad that loads once and stays visible across navigation.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({
    super.key,
    this.placement = 'app',
  });

  final String placement;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  late final Key _bannerKey;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _bannerKey = ValueKey('banner_${widget.placement}');
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (!pastSplash || !gAdsReady) return;

    await AdsActions.loadBanner(
      _bannerKey,
      onLoaded: () {
        if (mounted) setState(() => _visible = true);
      },
    );
  }

  @override
  void dispose() {
    AdsActions.disposeBanner(_bannerKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!gAdsReady || !_visible) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        color: AppColors.cardBackground,
        alignment: Alignment.center,
        child: AdsActions.bannerOrEmpty(_bannerKey),
      ),
    );
  }
}
