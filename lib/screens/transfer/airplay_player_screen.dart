import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_to_airplay/flutter_to_airplay.dart';

import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';

class AirPlayPlayerScreen extends StatelessWidget {
  const AirPlayPlayerScreen({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  final String filePath;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    final isLocalFile = !filePath.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(title: 'AirPlay Player', showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap the AirPlay icon below to stream to your TV',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: AirPlayRoutePickerView(
                    tintColor: Colors.white,
                    activeTintColor: AppColors.gradientCyan,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLocalFile && File(filePath).existsSync()
                ? FlutterAVPlayerView(filePath: filePath)
                : FlutterAVPlayerView(urlString: filePath),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.cardBackground,
            child: const Text(
              'Use the native player controls to play, pause, and seek. '
              'Select your Apple TV or AirPlay-compatible TV from the AirPlay button above.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
