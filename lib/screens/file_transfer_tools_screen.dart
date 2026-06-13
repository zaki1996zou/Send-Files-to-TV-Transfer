import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';

class FileTransferToolsScreen extends StatefulWidget {
  const FileTransferToolsScreen({super.key});

  @override
  State<FileTransferToolsScreen> createState() => _FileTransferToolsScreenState();
}

class _FileTransferToolsScreenState extends State<FileTransferToolsScreen> {
  final TextEditingController _filenameController = TextEditingController();
  final TextEditingController _fileSizeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _resolutionController = TextEditingController();

  String? _compatibilityResult;
  String? _transferTimeResult;
  String? _videoSizeResult;

  static const _methodNames = ['AirPlay', 'Chromecast', 'DLNA', 'HDMI', 'USB'];

  static const Map<String, Set<String>> _supportedExtensions = {
    'AirPlay': {'mp4', 'mov', 'm4v', 'hevc', 'mkv', 'mp3', 'm4a'},
    'Chromecast': {'mp4', 'webm', 'avi', 'mkv', 'mp3'},
    'DLNA': {'mp4', 'avi', 'mp3', 'jpeg', 'jpg', 'png'},
    'HDMI': {'mp4', 'mov', 'avi', 'mkv', 'mp3'},
    'USB': {'mp4', 'avi', 'mkv', 'mp3', 'jpeg', 'jpg'},
  };

  static const Map<String, double> _transferSpeedMbps = {
    'AirPlay': 25,
    'Chromecast': 20,
    'DLNA': 15,
    'HDMI': 1000,
    'USB': 60,
  };

  @override
  void dispose() {
    _filenameController.dispose();
    _fileSizeController.dispose();
    _durationController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  void _checkCompatibility(String method) {
    final filename = _filenameController.text.trim();
    if (filename.isEmpty) {
      setState(() => _compatibilityResult = 'Please enter a filename.');
      return;
    }

    final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    final supported = _supportedExtensions[method] ?? {};
    final isCompatible = supported.contains(ext);

    setState(() {
      _compatibilityResult = isCompatible
          ? '✓ $filename is compatible with $method'
          : '✗ $filename may not be compatible with $method (supported: ${supported.join(", ")})';
    });
  }

  void _calculateTransferTime(String method) {
    final sizeText = _fileSizeController.text.trim();
    final sizeMb = double.tryParse(sizeText);
    if (sizeMb == null || sizeMb <= 0) {
      setState(() => _transferTimeResult = 'Please enter a valid file size in MB.');
      return;
    }

    final speedMbps = _transferSpeedMbps[method] ?? 10;
    final seconds = (sizeMb * 8) / speedMbps;
    final minutes = seconds ~/ 60;
    final remainingSeconds = (seconds % 60).round();

    setState(() {
      _transferTimeResult = minutes > 0
          ? 'Estimated transfer time via $method: ~$minutes min $remainingSeconds sec'
          : 'Estimated transfer time via $method: ~$remainingSeconds sec';
    });
  }

  void _calculateVideoSize() {
    final durationMin = double.tryParse(_durationController.text.trim());
    final resolution = _resolutionController.text.trim().toLowerCase();

    if (durationMin == null || durationMin <= 0) {
      setState(() => _videoSizeResult = 'Please enter a valid duration in minutes.');
      return;
    }

    final bitrateMap = {
      '480p': 1.5,
      '720p': 3.0,
      '1080p': 6.0,
      '4k': 15.0,
    };

    double bitrate = 3.0;
    for (final entry in bitrateMap.entries) {
      if (resolution.contains(entry.key)) {
        bitrate = entry.value;
        break;
      }
    }

    final sizeMb = (durationMin * 60 * bitrate) / 8;
    setState(() {
      _videoSizeResult =
          'Estimated video size: ${sizeMb.toStringAsFixed(1)} MB (${resolution.isEmpty ? "720p default" : resolution})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(
        title: 'File Transfer Tools',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Estimates and compatibility checks are based on file extensions — not a guarantee of TV playback.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
              ),
            ),
            _ToolCard(
              title: 'File Compatibility Checker',
              icon: Icons.check_circle,
              iconColor: AppColors.gradientBlue,
              buttonColor: AppColors.gradientBlue,
              inputHint: 'Enter filename (e.g., video.mp4)',
              controller: _filenameController,
              methods: _methodNames,
              result: _compatibilityResult,
              onMethodTap: _checkCompatibility,
            ),
            const SizedBox(height: 16),
            _ToolCard(
              title: 'Transfer Time Calculator',
              icon: Icons.timer,
              iconColor: AppColors.accentTeal,
              buttonColor: AppColors.accentTeal,
              inputHint: 'File size in MB',
              controller: _fileSizeController,
              methods: _methodNames,
              result: _transferTimeResult,
              onMethodTap: _calculateTransferTime,
            ),
            const SizedBox(height: 16),
            _VideoSizeCard(
              durationController: _durationController,
              resolutionController: _resolutionController,
              result: _videoSizeResult,
              onCalculate: _calculateVideoSize,
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
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.build, color: Colors.white, size: 36),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File Transfer Tools',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Real utilities to help you transfer files efficiently',
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

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.buttonColor,
    required this.inputHint,
    required this.controller,
    required this.methods,
    required this.onMethodTap,
    this.result,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color buttonColor;
  final String inputHint;
  final TextEditingController controller;
  final List<String> methods;
  final String? result;
  final void Function(String method) onMethodTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: inputHint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: iconColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: methods.map((method) {
              return GestureDetector(
                onTap: () => onMethodTap(method),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    method,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (result != null) ...[
            const SizedBox(height: 12),
            Text(
              result!,
              style: TextStyle(
                color: result!.startsWith('✓')
                    ? AppColors.accentGreen
                    : result!.startsWith('✗')
                        ? Colors.redAccent
                        : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoSizeCard extends StatelessWidget {
  const _VideoSizeCard({
    required this.durationController,
    required this.resolutionController,
    required this.onCalculate,
    this.result,
  });

  final TextEditingController durationController;
  final TextEditingController resolutionController;
  final VoidCallback onCalculate;
  final String? result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.videocam, color: AppColors.accentOrange, size: 22),
              SizedBox(width: 8),
              Text(
                'Video Size Calculator',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('Duration in minutes'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: resolutionController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('Resolution (e.g., 1080p, 4K)'),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onCalculate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Calculate Size',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 12),
            Text(
              result!,
              style: const TextStyle(color: AppColors.accentGreen, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accentOrange),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
