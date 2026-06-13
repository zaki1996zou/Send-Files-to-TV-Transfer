import 'package:flutter/material.dart';
import '../services/ads_actions.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';
import 'tools/device_discovery_screen.dart';
import 'tools/file_compressor_screen.dart';
import 'tools/format_converter_screen.dart';
import 'tools/network_speed_screen.dart';
import 'tools/security_guide_screen.dart';

class AdvancedToolsScreen extends StatelessWidget {
  const AdvancedToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(
        title: 'Advanced Tools',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _AdvancedToolTile(
              icon: Icons.network_check,
              title: 'Network Speed Test',
              description: 'Test your WiFi speed to determine the best transfer method',
              color: AppColors.gradientBlue,
              onTap: () => AdsActions.pushInterstitial(
                context,
                const NetworkSpeedScreen(),
              ),
            ),
            const SizedBox(height: 12),
            _AdvancedToolTile(
              icon: Icons.device_hub,
              title: 'Device Discovery',
              description: 'Scan your network for compatible TVs and media devices',
              color: AppColors.accentTeal,
              onTap: () => AdsActions.pushInterstitial(
                context,
                const DeviceDiscoveryScreen(),
              ),
            ),
            const SizedBox(height: 12),
            _AdvancedToolTile(
              icon: Icons.compress,
              title: 'File Compressor',
              description: 'Compress images for faster wireless transfers',
              color: AppColors.accentOrange,
              onTap: () => AdsActions.pushInterstitial(
                context,
                const FileCompressorScreen(),
              ),
            ),
            const SizedBox(height: 12),
            _AdvancedToolTile(
              icon: Icons.transform,
              title: 'Format Converter',
              description: 'Convert images to TV-compatible formats (JPG, PNG)',
              color: const Color(0xFF9C27B0),
              onTap: () => AdsActions.pushInterstitial(
                context,
                const FormatConverterScreen(),
              ),
            ),
            const SizedBox(height: 12),
            _AdvancedToolTile(
              icon: Icons.security,
              title: 'Transfer Security Guide',
              description: 'Best practices for secure file sharing over your network',
              color: AppColors.accentGreen,
              onTap: () => AdsActions.pushInterstitial(
                context,
                const SecurityGuideScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.white, size: 36),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Tools',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Working utilities for optimizing your file transfers',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedToolTile extends StatelessWidget {
  const _AdvancedToolTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
