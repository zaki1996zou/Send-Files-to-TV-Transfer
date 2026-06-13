import 'package:flutter/material.dart';

import '../../services/network_speed_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';

class NetworkSpeedScreen extends StatefulWidget {
  const NetworkSpeedScreen({super.key});

  @override
  State<NetworkSpeedScreen> createState() => _NetworkSpeedScreenState();
}

class _NetworkSpeedScreenState extends State<NetworkSpeedScreen> {
  final _service = NetworkSpeedService();
  NetworkSpeedResult? _result;
  bool _testing = false;

  Future<void> _runTest() async {
    setState(() {
      _testing = true;
      _result = null;
    });

    final result = await _service.runSpeedTest();
    if (mounted) {
      setState(() {
        _result = result;
        _testing = false;
      });
    }
  }

  String _speedLabel(double mbps) {
    if (mbps >= 100) return 'Excellent for 4K streaming';
    if (mbps >= 25) return 'Good for HD streaming';
    if (mbps >= 10) return 'Suitable for SD streaming';
    if (mbps >= 3) return 'May struggle with large files';
    return 'Slow — consider moving closer to router';
  }

  Color _speedColor(double mbps) {
    if (mbps >= 25) return AppColors.accentGreen;
    if (mbps >= 10) return AppColors.accentTeal;
    if (mbps >= 3) return AppColors.accentOrange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Network Speed Test', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Icon(
                    _testing ? Icons.speed : Icons.network_check,
                    size: 64,
                    color: AppColors.gradientBlue,
                  ),
                  const SizedBox(height: 16),
                  if (_testing)
                    const Text(
                      'Testing your connection...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  else if (_result != null && _result!.error == null) ...[
                    Text(
                      '${_result!.downloadMbps.toStringAsFixed(1)} Mbps',
                      style: TextStyle(
                        color: _speedColor(_result!.downloadMbps),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _speedLabel(_result!.downloadMbps),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ] else if (_result?.error != null)
                    Text(
                      _result!.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    )
                  else
                    const Text(
                      'Test your WiFi speed to find the best transfer method',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            if (_result != null && _result!.error == null) ...[
              const SizedBox(height: 16),
              _infoTile('Connection', _result!.connectionType.toUpperCase()),
              if (_result!.wifiName != null)
                _infoTile('WiFi Network', _result!.wifiName!),
              _infoTile('Data Downloaded',
                  '${(_result!.bytesDownloaded / 1024 / 1024).toStringAsFixed(2)} MB'),
              _infoTile('Test Duration', '${(_result!.durationMs / 1000).toStringAsFixed(1)}s'),
              _infoTile('Test Source', NetworkSpeedService.primaryTestUrl),
              const SizedBox(height: 12),
              _recommendationCard(_result!.downloadMbps),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _testing ? null : _runTest,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gradientBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(_testing ? Icons.hourglass_top : Icons.play_arrow),
                label: Text(_testing ? 'Testing...' : 'Start Speed Test'),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _recommendationCard(double mbps) {
    String method;
    String reason;
    if (mbps >= 25) {
      method = 'AirPlay or Chromecast';
      reason = 'Your network is fast enough for wireless HD/4K streaming.';
    } else if (mbps >= 10) {
      method = 'DLNA or Chromecast';
      reason = 'Good for HD content. Compress large files for faster transfers.';
    } else {
      method = 'HDMI or USB';
      reason = 'Wired connection recommended for reliable transfers on slower networks.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended Method', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(method, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text(reason, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
