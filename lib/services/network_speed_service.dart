import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

class NetworkSpeedResult {
  const NetworkSpeedResult({
    required this.downloadMbps,
    required this.bytesDownloaded,
    required this.durationMs,
    required this.wifiName,
    required this.connectionType,
    this.error,
  });

  final double downloadMbps;
  final int bytesDownloaded;
  final int durationMs;
  final String? wifiName;
  final String connectionType;
  final String? error;
}

class NetworkSpeedService {
  static const primaryTestUrl = 'https://speed.cloudflare.com/__down?bytes=5000000';
  static const fallbackTestUrl = 'https://proof.ovh.net/files/1Mb.dat';

  static const _testUrls = [primaryTestUrl, fallbackTestUrl];

  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<NetworkSpeedResult> runSpeedTest() async {
    final connectivity = await _connectivity.checkConnectivity();
    final connectionType = connectivity.isNotEmpty
        ? connectivity.first.toString().split('.').last
        : 'unknown';
    final wifiName = await _networkInfo.getWifiName();

    try {
      final stopwatch = Stopwatch()..start();
      var totalBytes = 0;

      for (final url in _testUrls) {
        try {
          final request = http.Request('GET', Uri.parse(url));
          final streamed = await http.Client().send(request).timeout(
            const Duration(seconds: 20),
          );
          await for (final chunk in streamed.stream) {
            totalBytes += chunk.length;
            if (stopwatch.elapsedMilliseconds > 8000) break;
          }
          if (totalBytes > 500000) break;
        } catch (_) {
          continue;
        }
      }

      stopwatch.stop();
      if (totalBytes == 0 || stopwatch.elapsedMilliseconds == 0) {
        return NetworkSpeedResult(
          downloadMbps: 0,
          bytesDownloaded: 0,
          durationMs: stopwatch.elapsedMilliseconds,
          wifiName: wifiName,
          connectionType: connectionType,
          error: 'Could not complete speed test. Check your internet connection.',
        );
      }

      final seconds = stopwatch.elapsedMilliseconds / 1000;
      final bitsPerSecond = (totalBytes * 8) / seconds;
      final mbps = bitsPerSecond / 1000000;

      return NetworkSpeedResult(
        downloadMbps: mbps,
        bytesDownloaded: totalBytes,
        durationMs: stopwatch.elapsedMilliseconds,
        wifiName: wifiName,
        connectionType: connectionType,
      );
    } catch (e) {
      return NetworkSpeedResult(
        downloadMbps: 0,
        bytesDownloaded: 0,
        durationMs: 0,
        wifiName: wifiName,
        connectionType: connectionType,
        error: e.toString(),
      );
    }
  }
}
