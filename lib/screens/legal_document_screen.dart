import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';

enum LegalDocumentType { privacyPolicy, termsOfUse }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    final title = type == LegalDocumentType.privacyPolicy
        ? 'Privacy Policy'
        : 'Terms of Use';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: title, showBackButton: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: type == LegalDocumentType.privacyPolicy
              ? _privacySections()
              : _termsSections(),
        ),
      ),
    );
  }

  List<Widget> _privacySections() {
    return const [
      _Section(
        title: 'Overview',
        body:
            'Send Files to TV Transfer helps you select files on your iPhone and share or cast '
            'them to supported TVs and devices. This policy explains what the app accesses and '
            'how your information is handled.',
      ),
      _Section(
        title: 'Files You Select',
        body:
            'The app only accesses photos, videos, audio, PDFs, and documents when you tap '
            'Choose File or use a file tool. Files remain on your device unless you share or '
            'cast them. We do not upload your files to our servers.',
      ),
      _Section(
        title: 'Local Network',
        body:
            'To discover Chromecast, DLNA, and AirPlay devices, the app scans your local Wi-Fi '
            'network. This happens only when you use casting or device discovery features.',
      ),
      _Section(
        title: 'Transfer History',
        body:
            'If enabled in Settings, recent transfer activity is stored locally on your device '
            'in a JSON file. You can turn this off or clear history at any time.',
      ),
      _Section(
        title: 'Network Speed Test',
        body:
            'The optional speed test downloads a small amount of data from configured public '
            'test URLs (such as Cloudflare or OVH) to estimate your connection speed.',
      ),
      _Section(
        title: 'Accounts & Tracking',
        body:
            'No account or sign-in is required. The app does not use advertising SDKs or '
            'cross-app tracking. Settings preferences are stored locally with SharedPreferences.',
      ),
      _Section(
        title: 'Contact',
        body:
            'For privacy questions, use Contact Support in Settings.',
      ),
    ];
  }

  List<Widget> _termsSections() {
    return const [
      _Section(
        title: 'Acceptance',
        body:
            'By using Send Files to TV Transfer, you agree to these terms. If you do not agree, '
            'please do not use the app.',
      ),
      _Section(
        title: 'App Purpose',
        body:
            'This app provides iOS-compatible options to share and cast files to TVs and devices. '
            'Supported methods include AirPlay, Chromecast-style casting, DLNA streaming, and '
            'iOS share-sheet workflows with setup guides.',
      ),
      _Section(
        title: 'No Guarantee of Compatibility',
        body:
            'Playback and transfer depend on your TV model, file format, Wi-Fi network, and '
            'installed apps. The app does not guarantee that every TV or every file will work. '
            'MP4 is recommended for casting where available.',
      ),
      _Section(
        title: 'iOS Limitations',
        body:
            'Some methods shown in the app are guides only on iPhone. Miracast and WiFi Direct '
            'file transfer are not natively supported on iOS. HDMI, USB, and Bluetooth flows '
            'use the system share sheet and user-guided steps.',
      ),
      _Section(
        title: 'Your Responsibility',
        body:
            'You are responsible for the files you choose to share or cast. Only transfer content '
            'you have the right to use. Use secure networks for sensitive files.',
      ),
      _Section(
        title: 'Third-Party Services',
        body:
            'Casting may use network protocols compatible with third-party TVs and devices. '
            'Chromecast casting in this app does not use the official Google Cast SDK and '
            'compatibility may vary by device.',
      ),
      _Section(
        title: 'Changes',
        body:
            'These terms may be updated as the app evolves. Continued use of the app after '
            'changes constitutes acceptance of the updated terms.',
      ),
    ];
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
