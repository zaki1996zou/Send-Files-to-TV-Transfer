import 'dart:async';

import 'package:dart_cast/dart_cast.dart';
import 'package:flutter/material.dart';

import '../../services/app_cast_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import 'cast_remote_screen.dart';

class DevicePickerScreen extends StatefulWidget {
  const DevicePickerScreen({
    super.key,
    required this.media,
    required this.protocols,
    required this.methodName,
  });

  final CastMedia media;
  final Set<CastProtocol> protocols;
  final String methodName;

  @override
  State<DevicePickerScreen> createState() => _DevicePickerScreenState();
}

class _DevicePickerScreenState extends State<DevicePickerScreen> {
  final _cast = AppCastService.instance;
  List<CastDevice> _devices = [];
  bool _discovering = true;
  String? _error;
  StreamSubscription<List<CastDevice>>? _sub;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void _startDiscovery() {
    setState(() {
      _discovering = true;
      _devices = [];
      _error = null;
    });

    _sub?.cancel();
    _sub = _cast
        .discoverDevices(protocols: widget.protocols, timeout: const Duration(seconds: 15))
        .listen(
      (devices) {
        if (mounted) {
          setState(() {
            _devices = devices
                .where((d) => widget.protocols.contains(d.protocol))
                .toList();
          });
        }
      },
      onDone: () {
        if (mounted) setState(() => _discovering = false);
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _discovering = false;
            _error = e.toString();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _cast.stopDiscovery();
    super.dispose();
  }

  Future<void> _connect(CastDevice device) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.gradientCyan),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'Connecting to ${device.name}...',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final session = await _cast.connectDevice(device);

      if (!mounted) return;
      Navigator.pop(context);

      final castSucceeded = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CastRemoteScreen(
            session: session,
            device: device,
            media: widget.media,
          ),
        ),
      );

      if (mounted) Navigator.pop(context, castSucceeded == true);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    }
  }

  IconData _iconFor(CastProtocol protocol) {
    switch (protocol) {
      case CastProtocol.chromecast:
        return Icons.cast;
      case CastProtocol.airplay:
        return Icons.airplay;
      case CastProtocol.dlna:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Select ${widget.methodName} Device',
        showBackButton: true,
      ),
      body: Column(
        children: [
          if (_discovering)
            const LinearProgressIndicator(
              color: AppColors.gradientCyan,
              backgroundColor: AppColors.cardBorder,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _discovering
                        ? 'Searching for devices on your network...'
                        : '${_devices.length} device(s) found',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton.icon(
                  onPressed: _startDiscovery,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Scan Again'),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _discovering ? Icons.wifi_find : Icons.devices_other,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _discovering
                                ? 'Looking for TVs and cast devices...'
                                : 'No devices found.\nMake sure your TV is on the same WiFi network.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textMuted, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return Material(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.cardBorder),
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.gradientBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_iconFor(device.protocol), color: AppColors.gradientBlue),
                          ),
                          title: Text(
                            device.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${device.protocol.name.toUpperCase()} • ${device.address.address}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          onTap: () => _connect(device),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
