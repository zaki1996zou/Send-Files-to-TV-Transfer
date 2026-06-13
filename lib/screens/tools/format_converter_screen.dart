import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/file_service.dart';
import '../../services/image_tools_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';

class FormatConverterScreen extends StatefulWidget {
  const FormatConverterScreen({super.key});

  @override
  State<FormatConverterScreen> createState() => _FormatConverterScreenState();
}

class _FormatConverterScreenState extends State<FormatConverterScreen> {
  final _fileService = FileService();
  final _imageTools = ImageToolsService();

  PickedFileInfo? _inputFile;
  ImageProcessResult? _result;
  bool _processing = false;
  String _targetFormat = 'jpg';

  static const _formats = ['jpg', 'png'];

  Future<void> _pickImage() async {
    final file = await _fileService.pickFile(type: FileType.image);
    if (file != null && mounted) {
      setState(() {
        _inputFile = file;
        _result = null;
      });
    }
  }

  Future<void> _convert() async {
    if (_inputFile == null) return;

    setState(() {
      _processing = true;
      _result = null;
    });

    try {
      final result = await _imageTools.convertImage(
        inputPath: _inputFile!.path,
        targetFormat: _targetFormat,
      );
      if (mounted) {
        setState(() {
          _result = result;
          _processing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversion failed: $e')),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Format Converter', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.transform, size: 48, color: AppColors.accentOrange),
                    const SizedBox(height: 12),
                    Text(
                      _inputFile?.name ?? 'Select Image to Convert',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    if (_inputFile != null)
                      Text(
                        'Current format: ${_inputFile!.extension.toUpperCase()}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Convert To',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _formats.map((format) {
                final selected = _targetFormat == format;
                return ChoiceChip(
                  label: Text(format.toUpperCase()),
                  selected: selected,
                  selectedColor: AppColors.accentOrange,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _targetFormat = format),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Converts images to TV-compatible formats. For video files, use MP4 or MOV for best AirPlay and Chromecast support.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _inputFile == null || _processing ? null : _convert,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _processing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.swap_horiz),
              label: Text(_processing ? 'Converting...' : 'Convert to ${_targetFormat.toUpperCase()}'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Conversion Complete',
                      style: TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Output: ${_formatSize(_result!.outputSizeBytes)} • ${_result!.width}×${_result!.height}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => OpenFilex.open(_result!.outputPath),
                            icon: const Icon(Icons.visibility),
                            label: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(files: [XFile(_result!.outputPath)]),
                            ),
                            icon: const Icon(Icons.share),
                            label: const Text('Share to TV'),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.accentTeal),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
