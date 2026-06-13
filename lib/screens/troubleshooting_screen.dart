import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';

class TroubleshootingScreen extends StatelessWidget {
  const TroubleshootingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(
        title: 'Troubleshooting',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _IssueCard(
              icon: Icons.tv_off_outlined,
              title: 'TV not found',
              tips: [
                'Make sure your iPhone and TV are on the same Wi-Fi network.',
                'Enable local network permission when iOS asks for it.',
                'Restart your TV and router, then try discovery again.',
                'Some guest or hotel networks block device discovery.',
              ],
            ),
            SizedBox(height: 12),
            _IssueCard(
              icon: Icons.wifi_off,
              title: 'Local network permission denied',
              tips: [
                'Open iOS Settings → Send Files to TV Transfer → Local Network.',
                'Turn Local Network on, then return to the app and retry.',
                'Discovery needs this permission for Chromecast, DLNA, and AirPlay scanning.',
              ],
            ),
            SizedBox(height: 12),
            _IssueCard(
              icon: Icons.cast_connected,
              title: 'Chromecast fails to load video',
              tips: [
                'Use MP4 when possible — it has the best compatibility.',
                'Keep your iPhone awake while casting.',
                'Stay on the same Wi-Fi network as the Chromecast.',
                'This app uses network casting, not the official Google Cast SDK.',
              ],
            ),
            SizedBox(height: 12),
            _IssueCard(
              icon: Icons.perm_device_information_outlined,
              title: 'DLNA unsupported format',
              tips: [
                'Try converting the file to MP4 or MP3.',
                'Not all DLNA TVs support every container or codec.',
                'Use a smaller file if playback stalls on older TVs.',
              ],
            ),
            SizedBox(height: 12),
            _IssueCard(
              icon: Icons.airplay,
              title: 'AirPlay device not appearing',
              tips: [
                'Confirm the TV or Apple TV supports AirPlay.',
                'Disable VPNs and confirm both devices share the same network.',
                'Use the system AirPlay picker from the transfer screen.',
                'For non-video files, share to a compatible app first, then use AirPlay.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.icon,
    required this.title,
    required this.tips,
  });

  final IconData icon;
  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gradientCyan, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: AppColors.gradientBlue, fontSize: 14),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
