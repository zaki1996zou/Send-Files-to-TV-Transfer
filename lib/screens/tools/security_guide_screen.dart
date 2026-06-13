import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';

class SecurityGuideScreen extends StatelessWidget {
  const SecurityGuideScreen({super.key});

  static const _sections = [
    _GuideSection(
      icon: Icons.wifi_lock,
      title: 'Secure Your Home Network',
      points: [
        'Use WPA3 or WPA2 encryption on your WiFi router.',
        'Change the default router admin password.',
        'Create a separate guest network for visitors.',
        'Keep your router firmware updated.',
      ],
    ),
    _GuideSection(
      icon: Icons.devices,
      title: 'Device Safety',
      points: [
        'Only connect to TVs and devices you recognize on your network.',
        'Disable unused casting services on smart TVs.',
        'Update your TV firmware regularly for security patches.',
        'Review which apps have network access on your TV.',
      ],
    ),
    _GuideSection(
      icon: Icons.folder_shared,
      title: 'File Transfer Best Practices',
      points: [
        'Avoid transferring sensitive documents over public WiFi.',
        'Use wired HDMI/USB for confidential business files.',
        'Delete transferred files from shared USB drives after use.',
        'Compress files only on your own device before sharing.',
      ],
    ),
    _GuideSection(
      icon: Icons.privacy_tip,
      title: 'Privacy on Smart TVs',
      points: [
        'Review your TV\'s privacy settings and disable data collection if desired.',
        'Turn off the TV microphone and camera when not in use.',
        'Disconnect casting sessions when finished watching.',
      ],
    ),
    _GuideSection(
      icon: Icons.shield,
      title: 'AirPlay & Cast Security',
      points: [
        'Enable AirPlay access restrictions on Apple TV (Settings → AirPlay).',
        'Only cast to devices on your home network, not public hotspots.',
        'Verify the device name matches your TV before connecting.',
        'Stop casting and disconnect when you leave the room.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Transfer Security Guide', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentGreen, Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.white, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay Safe While Transferring',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Follow these guidelines to protect your files and network',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._sections.map((section) => _SectionCard(section: section)),
        ],
      ),
    );
  }
}

class _GuideSection {
  const _GuideSection({
    required this.icon,
    required this.title,
    required this.points,
  });

  final IconData icon;
  final String title;
  final List<String> points;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _GuideSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
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
              Icon(section.icon, color: AppColors.accentGreen, size: 22),
              const SizedBox(width: 10),
              Text(
                section.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...section.points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: AppColors.accentGreen, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
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
