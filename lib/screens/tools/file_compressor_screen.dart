import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/file_service.dart';
import '../../services/image_tools_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';

class FileCompressorScreen extends StatefulWidget {
  const FileCompressorScreen({super.key});

  @override
  State<FileCompressorScreen> createState() => _FileCompressorScreenState();
}

class _FileCompressorScreenState extends State<FileCompressorScreen> {
  final _fileService = FileService();
  final _imageTools = ImageToolsService();

  PickedFileInfo? _inputFile;
  ImageProcessResult? _result;
  bool _processing = false;
  double _quality = 75;
  int _maxWidth = 1920;

  Future<void> _pickImage() async {
    final file = await _fileService.pickFile(type: FileType.image);
    if (file != null && mounted) {
      setState(() {
        _inputFile = file;
        _result = null;
      });
    }
  }

  Future<void> _compress() async {
    if (_inputFile == null) return;

    setState(() {
      _processing = true;
      _result = null;
    });

    try {
      final result = await _imageTools.compressImage(
        inputPath: _inputFile!.path,
        quality: _quality.round(),
        maxWidth: _maxWidth,
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
          SnackBar(content: Text('Compression failed: $e')),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'File Compressor', showBackButton: true),
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
                    const Icon(Icons.image, size: 48, color: AppColors.gradientBlue),
                    const SizedBox(height: 12),
                    Text(
                      _inputFile?.name ?? 'Select Image to Compress',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    if (_inputFile != null)
                      Text(
                        'Original: ${_formatSize(_inputFile!.sizeBytes)}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _sliderControl('Quality', _quality, 30, 95, (v) => setState(() => _quality = v)),
            _sliderControl(
              'Max Width',
              _maxWidth.toDouble(),
              640,
              3840,
              (v) => setState(() => _maxWidth = v.round()),
              suffix: '${_maxWidth}px',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _inputFile == null || _processing ? null : _compress,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gradientBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _processing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.compress),
              label: Text(_processing ? 'Compressing...' : 'Compress Image'),
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
                    Text(
                      'Saved ${((1 - _result!.compressionRatio) * 100).toStringAsFixed(0)}% space',
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatSize(_result!.originalSizeBytes)} → ${_formatSize(_result!.outputSizeBytes)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${_result!.width} × ${_result!.height}px',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
                            label: const Text('Share'),
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

  Widget _sliderControl(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            Text(
              suffix ?? value.round().toString(),
              style: const TextStyle(color: AppColors.gradientCyan),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.gradientCyan,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
