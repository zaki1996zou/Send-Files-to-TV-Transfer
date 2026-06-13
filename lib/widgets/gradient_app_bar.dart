import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ads_actions.dart';
import '../theme/app_colors.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showInterstitialOnBack = true,
    this.centerTitle = true,
    this.titleFontSize = 18,
    this.actions,
  });

  final String title;
  final bool showBackButton;
  final bool showInterstitialOnBack;
  final bool centerTitle;
  final double titleFontSize;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () {
                if (showInterstitialOnBack) {
                  AdsActions.popWithInterstitial(context);
                } else {
                  Navigator.of(context).pop();
                }
              },
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: titleFontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
