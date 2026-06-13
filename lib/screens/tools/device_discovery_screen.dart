import 'dart:async';

import 'package:dart_cast/dart_cast.dart';
import 'package:flutter/material.dart';

import '../../services/app_cast_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';

class DeviceDiscoveryScreen extends StatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> {
  final _cast = AppCastService.instance;
  List<CastDevice> _devices = [];
  bool _scanning = false;
  StreamSubscription<List<CastDevice>>? _sub;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    setState(() {
      _scanning = true;
      _devices = [];
    });

    _sub?.cancel();
    _sub = _cast.discoverDevices(timeout: const Duration(seconds: 15)).listen(
      (devices) {
        if (mounted) setState(() => _devices = devices);
      },
      onDone: () {
        if (mounted) setState(() => _scanning = false);
      },
      onError: (_) {
        if (mounted) setState(() => _scanning = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _cast.stopDiscovery();
    super.dispose();
  }

  Map<CastProtocol, List<CastDevice>> _grouped() {
    final map = <CastProtocol, List<CastDevice>>{};
    for (final d in _devices) {
      map.putIfAbsent(d.protocol, () => []).add(d);
    }
    return map;
  }

  IconData _icon(CastProtocol p) {
    switch (p) {
      case CastProtocol.chromecast:
        return Icons.cast;
      case CastProtocol.airplay:
        return Icons.airplay;
      case CastProtocol.dlna:
        return Icons.devices;
    }
  }

  void _showDeviceInfo(CastDevice device) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(device.name, style: const TextStyle(color: Colors.white)),
        content: Text(
          'Protocol: ${device.protocol.name.toUpperCase()}\n'
          'Address: ${device.address.address}\n'
          'Port: ${device.port}\n\n'
          'This device was found on your local network. '
          'Use a transfer method screen to connect and cast.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Device Discovery', showBackButton: true),
      body: Column(
        children: [
          if (_scanning)
            const LinearProgressIndicator(color: AppColors.gradientCyan),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _scanning
                        ? 'Scanning local network for TVs...'
                        : 'Found ${_devices.length} device(s)',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _scanning ? null : _startScan,
                  icon: const Icon(Icons.radar, size: 18),
                  label: const Text('Scan'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accentTeal),
                ),
              ],
            ),
          ),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _scanning ? Icons.wifi_find : Icons.tv_off,
                          size: 72,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _scanning
                              ? 'Searching for Chromecast, AirPlay,\nand DLNA devices...'
                              : 'No devices found on your network.\nEnsure your TV is powered on and\nconnected to the same WiFi.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted, height: 1.5),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(_icon(entry.key), color: AppColors.gradientBlue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.gradientBlue,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${entry.value.length}',
                                    style: const TextStyle(
                                      color: AppColors.accentGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...entry.value.map((device) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: ListTile(
                                leading: Icon(_icon(device.protocol), color: AppColors.gradientCyan),
                                title: Text(
                                  device.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${device.address.address}:${device.port}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                                trailing: const Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
                                onTap: () => _showDeviceInfo(device),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
