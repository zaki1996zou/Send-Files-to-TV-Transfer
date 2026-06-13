import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class PickedFileInfo {
  const PickedFileInfo({
    required this.path,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.category,
    required this.mimeType,
  });

  final String path;
  final String name;
  final String extension;
  final int sizeBytes;
  final FileCategory category;
  final String? mimeType;

  double get sizeMb => sizeBytes / (1024 * 1024);
}

enum FileCategory { video, image, audio, document, other }

class FilePickException implements Exception {
  FilePickException(this.message);
  final String message;

  @override
  String toString() => message;
}

class FileService {
  static bool _pickInProgress = false;
  static const _pickTimeout = Duration(seconds: 45);

  /// Clears a stuck picker lock after hot reload or interrupted sessions.
  static void resetPickLock() => _pickInProgress = false;

  static Future<void> _recoverStuckPicker() async {
    _pickInProgress = false;
    try {
      await FilePicker.clearTemporaryFiles();
    } catch (_) {}
  }

  static const supportedByMethod = {
    'AirPlay': {'mp4', 'mov', 'm4v', 'mkv', 'mp3', 'm4a', 'jpg', 'jpeg', 'png', 'heic', 'pdf'},
    'Chromecast': {'mp4', 'webm', 'avi', 'mkv', 'mp3'},
    'DLNA': {'mp4', 'avi', 'mp3', 'mkv', 'jpeg', 'jpg', 'png'},
    'HDMI': {'mp4', 'mov', 'avi', 'mkv', 'mp3', 'jpg', 'jpeg', 'png'},
    'USB': {'mp4', 'avi', 'mkv', 'mp3', 'jpeg', 'jpg', 'png', 'pdf'},
    'Bluetooth': {'mp3', 'm4a', 'aac', 'wav', 'flac'},
    'Miracast': {'mp4', 'mov', 'mkv'},
    'WiFi Direct': {'mp4', 'pdf', 'jpg', 'jpeg', 'png', 'mov'},
  };

  Future<PickedFileInfo?> pickFile({
    FileType type = FileType.any,
    bool allowRetry = true,
  }) async {
    if (_pickInProgress) {
      if (allowRetry) {
        await _recoverStuckPicker();
      } else {
        throw FilePickException('File picker is already open. Please try again.');
      }
    }

    _pickInProgress = true;
    try {
      final file = await FilePicker.pickFile(
        type: type,
        dialogTitle: 'Choose a file',
      ).timeout(_pickTimeout);

      if (file == null) return null;

      final path = file.path;
      if (path == null || path.isEmpty) {
        throw FilePickException('Could not read the selected file path.');
      }

      return _infoFromPath(path, file.size);
    } on TimeoutException {
      await _recoverStuckPicker();
      throw FilePickException('File picker timed out. Tap Choose File to try again.');
    } on PlatformException catch (e) {
      if (e.code == 'multiple_request') {
        await _recoverStuckPicker();
        if (allowRetry) {
          return pickFile(type: type, allowRetry: false);
        }
        throw FilePickException('File picker is busy. Wait a moment, then try again.');
      }
      throw FilePickException(e.message ?? 'Could not open file picker.');
    } finally {
      _pickInProgress = false;
    }
  }

  Future<List<PickedFileInfo>> pickMultipleFiles() async {
    if (_pickInProgress) return [];

    _pickInProgress = true;
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      ).timeout(_pickTimeout);

      if (result == null) return [];

      return result.files
          .where((f) => f.path != null && f.path!.isNotEmpty)
          .map((f) => _infoFromPath(f.path!, f.size))
          .toList();
    } on PlatformException catch (e) {
      if (e.code == 'multiple_request') return [];
      rethrow;
    } on TimeoutException {
      return [];
    } finally {
      _pickInProgress = false;
    }
  }

  PickedFileInfo _infoFromPath(String path, int? size) {
    final name = p.basename(path);
    final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
    final fileSize = size ?? File(path).lengthSync();
    final mimeType = lookupMimeType(path);

    return PickedFileInfo(
      path: path,
      name: name,
      extension: extension,
      sizeBytes: fileSize,
      category: _categoryFromExtension(extension, mimeType),
      mimeType: mimeType,
    );
  }

  FileCategory _categoryFromExtension(String ext, String? mime) {
    if (['mp4', 'mov', 'm4v', 'avi', 'mkv', 'webm', 'ts', 'm3u8'].contains(ext)) {
      return FileCategory.video;
    }
    if (['jpg', 'jpeg', 'png', 'heic', 'gif', 'webp'].contains(ext)) {
      return FileCategory.image;
    }
    if (['mp3', 'm4a', 'aac', 'wav', 'flac'].contains(ext)) {
      return FileCategory.audio;
    }
    if (['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'].contains(ext)) {
      return FileCategory.document;
    }
    if (mime != null) {
      if (mime.startsWith('video/')) return FileCategory.video;
      if (mime.startsWith('image/')) return FileCategory.image;
      if (mime.startsWith('audio/')) return FileCategory.audio;
    }
    return FileCategory.other;
  }

  bool isCompatible(String method, String extension) {
    final supported = supportedByMethod[method] ?? {};
    return supported.contains(extension.toLowerCase());
  }

  Future<void> shareFile(String path, {String? text}) async {
    final file = XFile(path);
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        text: text,
      ),
    );
  }

  Future<void> shareFiles(List<String> paths, {String? text}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: paths.map(XFile.new).toList(),
        text: text,
      ),
    );
  }

  List<String> recommendedMethods(PickedFileInfo file) {
    final recommendations = <String>[];

    switch (file.category) {
      case FileCategory.video:
        recommendations.addAll(['AirPlay', 'Chromecast', 'DLNA', 'HDMI']);
      case FileCategory.image:
        recommendations.addAll(['AirPlay', 'DLNA', 'HDMI', 'USB']);
      case FileCategory.audio:
        recommendations.addAll(['AirPlay', 'Bluetooth', 'DLNA']);
      case FileCategory.document:
        recommendations.addAll(['AirPlay', 'USB', 'WiFi Direct']);
      case FileCategory.other:
        recommendations.addAll(['AirPlay', 'USB']);
    }

    return recommendations
        .where((method) => isCompatible(method, file.extension))
        .toSet()
        .toList();
  }
}
