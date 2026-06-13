import 'package:dart_cast/dart_cast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_airplay/flutter_to_airplay.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';

import '../../data/methods_data.dart';
import '../../models/sharing_method.dart';
import '../../services/app_cast_service.dart';
import '../../services/file_service.dart';
import '../../services/settings_service.dart';
import '../../services/transfer_history_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/info_badge.dart';
import 'airplay_player_screen.dart';
import 'device_picker_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, required this.method});

  final SharingMethod method;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> with WidgetsBindingObserver {
  final _fileService = FileService();
  final _history = TransferHistoryService();
  final _settings = SettingsService.instance;
  final _cast = AppCastService.instance;

  PickedFileInfo? _selectedFile;
  bool _busy = false;
  bool _pickingFile = false;
  String? _statusMessage;

  FileType get _preferredPickerType {
    return switch (widget.method.capability) {
      TransferCapability.networkCast => FileType.video,
      TransferCapability.nativeAirPlay => FileType.media,
      _ => FileType.any,
    };
  }

  String get _pickerHintText {
    return switch (widget.method.capability) {
      TransferCapability.networkCast => 'MP4, MOV, MKV, and other video files',
      TransferCapability.nativeAirPlay => 'Photos, videos, and media files',
      _ => 'Photos, videos, audio, PDFs, and documents',
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _history.load();
    _settings.loadSettings();
    FileService.resetPickLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FileService.resetPickLock();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_pickingFile) return;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted || !_pickingFile) return;
      FileService.resetPickLock();
      setState(() => _pickingFile = false);
    });
  }

  Future<void> _pickFile() async {
    if (_pickingFile || _busy) return;

    setState(() {
      _pickingFile = true;
      _statusMessage = null;
    });
    try {
      final file = await _fileService.pickFile(type: _preferredPickerType);
      if (!mounted) return;
      if (file != null) {
        setState(() {
          _selectedFile = file;
          _statusMessage = null;
        });
      }
    } on FilePickException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file picker: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  Future<void> _recordTransfer(String status, {String? deviceName}) async {
    if (_selectedFile == null) return;
    if (!_settings.settings.saveTransferHistory) return;
    await _history.addRecord(
      TransferRecord(
        id: const Uuid().v4(),
        fileName: _selectedFile!.name,
        method: widget.method.name,
        status: status,
        timestamp: DateTime.now(),
        fileSizeMb: _selectedFile!.sizeMb,
        deviceName: deviceName,
      ),
    );
  }

  String get _primaryButtonLabel {
    switch (widget.method.capability) {
      case TransferCapability.nativeAirPlay:
        return 'Open AirPlay Transfer';
      case TransferCapability.networkCast:
        return 'Discover Device & Cast Video';
      case TransferCapability.shareAndGuide:
        return 'Share File & View Guide';
      case TransferCapability.iosAlternativeOnly:
        return 'Use AirPlay Alternative';
    }
  }

  Future<bool> _confirmTransferIfNeeded() async {
    if (!_settings.settings.showCompatibilityWarning) return true;

    final file = _selectedFile!;
    String? warning;

    switch (widget.method.capability) {
      case TransferCapability.iosAlternativeOnly:
        warning =
            'Miracast is not supported on iPhone. This method shares your file and suggests AirPlay instead.';
      case TransferCapability.shareAndGuide:
        warning =
            'This method uses the iOS share sheet and setup steps. Direct TV playback is not guaranteed.';
      case TransferCapability.networkCast:
        if (file.category != FileCategory.video) {
          warning = '${widget.method.name} casts video files only.';
        } else if (!_fileService.isCompatible(widget.method.name, file.extension)) {
          warning =
              'This format may not play on ${widget.method.name}. MP4 is recommended for casting.';
        }
      case TransferCapability.nativeAirPlay:
        if (!_fileService.isCompatible(widget.method.name, file.extension)) {
          warning =
              'This file format may have limited support with ${widget.method.name}.';
        }
    }

    if (warning == null) return true;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Compatibility Warning', style: TextStyle(color: Colors.white)),
        content: Text(
          warning!,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.accentTeal),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return proceed ?? false;
  }

  Future<void> _startTransfer() async {
    if (_selectedFile == null) {
      setState(() => _statusMessage = 'Please select a file first.');
      return;
    }

    if (!await _confirmTransferIfNeeded()) return;

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      switch (widget.method.capability) {
        case TransferCapability.nativeAirPlay:
          await _transferAirPlay();
        case TransferCapability.networkCast:
          await _transferNetworkCast();
        case TransferCapability.shareAndGuide:
          await _transferViaShare(_shareGuideMessage());
        case TransferCapability.iosAlternativeOnly:
          await _transferMiracastAlternative();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Action failed: $e');
      }
      await _recordTransfer('Failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _shareGuideMessage() {
    return switch (widget.method.id) {
      'hdmi' =>
        'File shared. Connect your HDMI adapter, then open the file on your iPhone while mirrored to TV.',
      'usb' =>
        'File shared. Save to Files or copy to a USB drive, then play from your TV USB port.',
      'bluetooth' =>
        'File shared. Open in a music app and route audio to your paired Bluetooth device.',
      'wifi_direct' =>
        'File shared. For wireless TV playback, try AirPlay, Chromecast, or DLNA in this app.',
      _ => 'File shared via iOS. Follow the setup guide below for your TV.',
    };
  }

  Future<void> _transferAirPlay() async {
    final file = _selectedFile!;
    if (file.category == FileCategory.video) {
      await _recordTransfer('Started');
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AirPlayPlayerScreen(
            filePath: file.path,
            fileName: file.name,
          ),
        ),
      );
      await _recordTransfer('Completed');
    } else {
      await _fileService.shareFile(file.path);
      await _recordTransfer('Shared via iOS');
      if (mounted) {
        setState(() => _statusMessage =
            'File shared. Open it in a compatible app and use the system AirPlay button if available.');
      }
    }
  }

  Future<void> _transferNetworkCast() async {
    final file = _selectedFile!;
    if (file.category != FileCategory.video) {
      setState(() => _statusMessage =
          '${widget.method.name} casts video files. For this file type, use the share button or try AirPlay.');
      return;
    }

    if (!_fileService.isCompatible(widget.method.name, file.extension)) {
      setState(() => _statusMessage =
          'This format may not play on ${widget.method.name}. Try converting to MP4 first.');
      return;
    }

    final media = _cast.mediaFromFile(file.path, title: file.name);
    if (!mounted) return;

    final castSucceeded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DevicePickerScreen(
          media: media,
          protocols: {
            if (widget.method.id == 'chromecast') CastProtocol.chromecast,
            if (widget.method.id == 'dlna') CastProtocol.dlna,
          },
          methodName: widget.method.name,
        ),
      ),
    );

    if (castSucceeded == true) {
      await _recordTransfer('Cast playing');
    } else if (castSucceeded == false) {
      await _recordTransfer('Cast failed');
    }
  }

  Future<void> _transferMiracastAlternative() async {
    await _fileService.shareFile(_selectedFile!.path);
    await _recordTransfer('Shared — Miracast unavailable on iOS');
    if (mounted) {
      setState(() => _statusMessage =
          'Miracast is not supported on iPhone. File shared — use AirPlay from the button below or open the AirPlay method.');
    }
  }

  Future<void> _transferViaShare(String message) async {
    await _fileService.shareFile(_selectedFile!.path);
    await _recordTransfer('Shared via iOS');
    if (mounted) setState(() => _statusMessage = message);
  }

  Future<void> _shareWithoutFileCheck() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }
    await _fileService.shareFile(_selectedFile!.path);
    await _recordTransfer('Shared via iOS');
  }

  void _openAirPlayMethod() {
    final airplay = sharingMethods.firstWhere((m) => m.id == 'airplay');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TransferScreen(method: airplay)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compatible = _selectedFile != null
        ? _fileService.isCompatible(widget.method.name, _selectedFile!.extension)
        : null;
    final recommendations = _selectedFile != null
        ? _fileService.recommendedMethods(_selectedFile!)
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: widget.method.name,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMethodCard(),
              const SizedBox(height: 12),
              _buildCapabilityBanner(),
              if (_settings.settings.preferMp4ForCasting &&
                  widget.method.capability == TransferCapability.networkCast) ...[
                const SizedBox(height: 12),
                _buildMp4Recommendation(),
              ],
              const SizedBox(height: 16),
              _buildFilePicker(compatible),
              const SizedBox(height: 16),
              if (_selectedFile != null) ...[
                _buildFileDetails(recommendations),
                const SizedBox(height: 16),
              ],
              _buildActionButtons(),
              if (widget.method.capability == TransferCapability.nativeAirPlay ||
                  widget.method.capability == TransferCapability.iosAlternativeOnly) ...[
                const SizedBox(height: 16),
                _buildAirPlayPicker(),
              ],
              if (widget.method.capability == TransferCapability.iosAlternativeOnly) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _openAirPlayMethod,
                  icon: const Icon(Icons.airplay),
                  label: const Text('Switch to AirPlay Method'),
                ),
              ],
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                _buildStatusMessage(),
              ],
              const SizedBox(height: 24),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _capabilityIcon(),
            color: AppColors.gradientCyan,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.method.capabilityNote,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMp4Recommendation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gradientBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gradientBlue.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates_outlined, color: AppColors.gradientCyan, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'MP4 is recommended for the most reliable casting experience.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _capabilityIcon() {
    return switch (widget.method.capability) {
      TransferCapability.nativeAirPlay => Icons.airplay,
      TransferCapability.networkCast => Icons.cast,
      TransferCapability.shareAndGuide => Icons.ios_share,
      TransferCapability.iosAlternativeOnly => Icons.info_outline,
    };
  }

  Widget _buildMethodCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.method.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.method.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.method.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    InfoBadge(
                      icon: Icons.access_time,
                      label: widget.method.duration,
                      color: Colors.white,
                    ),
                    InfoBadge(
                      icon: Icons.check_circle_outline,
                      label: widget.method.difficulty,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(bool? compatible) {
    final enabled = !_busy && !_pickingFile;

    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? _pickFile : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: compatible == false ? Colors.orangeAccent : AppColors.cardBorder,
              width: compatible == false ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              if (_pickingFile)
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.gradientBlue,
                  ),
                )
              else
                Icon(
                  _selectedFile == null ? Icons.upload_file : Icons.insert_drive_file,
                  size: 48,
                  color: AppColors.gradientBlue,
                ),
              const SizedBox(height: 12),
              Text(
                _pickingFile
                    ? 'Opening file picker...'
                    : _selectedFile == null
                        ? 'Choose File'
                        : _selectedFile!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _selectedFile == null
                    ? _pickerHintText
                    : '${_selectedFile!.sizeMb.toStringAsFixed(2)} MB • ${_selectedFile!.extension.toUpperCase()} • ${_selectedFile!.category.name}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileDetails(List<String> recommendations) {
    final file = _selectedFile!;
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
          const Text('Selected File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _detailRow('Name', file.name),
          _detailRow('Type', file.category.name),
          _detailRow('Format', file.extension.toUpperCase()),
          _detailRow('Size', '${file.sizeMb.toStringAsFixed(2)} MB'),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Recommended methods',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: recommendations.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gradientBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(m, style: const TextStyle(color: AppColors.gradientCyan, fontSize: 11)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => OpenFilex.open(file.path),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Preview'),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _selectedFile = null),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _busy ? null : _startTransfer,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentTeal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.play_arrow),
          label: Text(
            _busy ? 'Working...' : _primaryButtonLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _busy ? null : _shareWithoutFileCheck,
          icon: const Icon(Icons.ios_share),
          label: const Text('Share via iOS Share Sheet'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gradientBlue,
            side: const BorderSide(color: AppColors.gradientBlue),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildAirPlayPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System AirPlay Picker',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Uses the native iOS AirPlay button',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        _statusMessage!,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontSize: 13),
      ),
    );
  }

  Widget _buildInstructions() {
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
          const Text(
            'Setup Guide',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...widget.method.steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.gradientBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: AppColors.gradientBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
