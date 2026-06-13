import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/file_service.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

import 'util/global.dart';
import 'package:http/http.dart' as http;
import 'package:multiads/multiads.dart';
import 'services/ads_actions.dart';
import 'widgets/ad_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var url = Uri.parse(
    "https://drive.google.com/uc?export=download&id=12e77kZ3hu7afWZvFX-grmZnTdpLGVjzx",
  );
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      gAds = MultiAds(
        response.body,
        config: MultiAdsConfig(
          admobTestDeviceIds: ['79738754EC81FA5F64972928128B2FFF'],
          facebookTestingId: 'd1a0df1f-2528-4e41-a4d3-1b401ba14f7d',
          enableLogs: true, // set false before release
        ),
      );
      gAdsReady = true;
      await gAds!.init();
      await gAds!.loadAds();
      AdsActions.registerCallbacks();
    }
  } catch (_) {
    // Ads config unavailable; app still launches without ads.
  }

  FileService.resetPickLock();
  await SettingsService.instance.loadSettings();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SendFilesToTvApp());
}

class SendFilesToTvApp extends StatelessWidget {
  const SendFilesToTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send Files to TV Transfer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gradientBlue,
          secondary: AppColors.gradientCyan,
          surface: AppColors.cardBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: hideBottomBanner,
          builder: (context, hidden, _) {
            return ColoredBox(
              color: AppColors.background,
              child: Column(
                children: [
                  Expanded(child: child ?? const SizedBox.shrink()),
                  if (pastSplash && !hidden)
                    const AdBannerWidget(placement: 'app'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
