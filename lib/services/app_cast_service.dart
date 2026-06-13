import 'dart:async';

import 'package:dart_cast/dart_cast.dart';

class AppCastService {
  AppCastService._();
  static final AppCastService instance = AppCastService._();

  final CastService castService = CastService(
    discoveryProviders: [
      ChromecastDiscoveryProvider(),
      AirPlayDiscoveryProvider(),
      DlnaDiscoveryProvider(),
    ],
    sessionFactory: (device) {
      switch (device.protocol) {
        case CastProtocol.chromecast:
          return ChromecastSession(device: device);
        case CastProtocol.airplay:
          return AirPlaySession(device);
        case CastProtocol.dlna:
          throw StateError('Use connectDevice for DLNA sessions.');
      }
    },
  );

  StreamSubscription<List<CastDevice>>? _discoverySub;

  Stream<List<CastDevice>> discoverDevices({
    Set<CastProtocol>? protocols,
    Duration timeout = const Duration(seconds: 15),
  }) {
    return castService.startDiscovery(protocols: protocols, timeout: timeout);
  }

  void stopDiscovery() {
    _discoverySub?.cancel();
    _discoverySub = null;
    castService.stopDiscovery();
  }

  Future<CastSession> connectDevice(CastDevice device) async {
    if (device.protocol == CastProtocol.dlna) {
      final session = DlnaSession.fromDevice(device);
      await session.connect();
      return session;
    }
    return castService.connect(device);
  }

  CastMediaType detectMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.m3u8')) return CastMediaType.hls;
    if (lower.endsWith('.ts')) return CastMediaType.mpegTs;
    if (lower.endsWith('.mkv')) return CastMediaType.mkv;
    return CastMediaType.mp4;
  }

  CastMedia mediaFromFile(String filePath, {String? title}) {
    return CastMedia.file(
      filePath: filePath,
      type: detectMediaType(filePath),
      title: title ?? filePath.split('/').last,
    );
  }

  void dispose() {
    stopDiscovery();
    castService.dispose();
  }
}
