import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageProcessResult {
  const ImageProcessResult({
    required this.outputPath,
    required this.originalSizeBytes,
    required this.outputSizeBytes,
    required this.width,
    required this.height,
  });

  final String outputPath;
  final int originalSizeBytes;
  final int outputSizeBytes;
  final int width;
  final int height;

  double get compressionRatio =>
      originalSizeBytes == 0 ? 0 : outputSizeBytes / originalSizeBytes;
}

class ImageToolsService {
  Future<ImageProcessResult> compressImage({
    required String inputPath,
    int quality = 75,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final bytes = await File(inputPath).readAsBytes();
    final originalSize = bytes.length;
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not decode image file.');
    }

    var processed = decoded;
    if (maxWidth != null || maxHeight != null) {
      processed = img.copyResize(
        decoded,
        width: maxWidth,
        height: maxHeight,
        maintainAspect: true,
      );
    }

    final ext = p.extension(inputPath).toLowerCase();
    final outputDir = await getTemporaryDirectory();
    final outputName =
        '${p.basenameWithoutExtension(inputPath)}_compressed_${DateTime.now().millisecondsSinceEpoch}$ext';
    final outputPath = p.join(outputDir.path, outputName);

    List<int> encoded;
    if (ext == '.png') {
      encoded = img.encodePng(processed, level: 6);
    } else if (ext == '.webp') {
      encoded = img.encodeJpg(processed, quality: quality);
    } else {
      encoded = img.encodeJpg(processed, quality: quality);
    }

    await File(outputPath).writeAsBytes(encoded);

    return ImageProcessResult(
      outputPath: outputPath,
      originalSizeBytes: originalSize,
      outputSizeBytes: encoded.length,
      width: processed.width,
      height: processed.height,
    );
  }

  Future<ImageProcessResult> convertImage({
    required String inputPath,
    required String targetFormat,
    int quality = 85,
  }) async {
    final bytes = await File(inputPath).readAsBytes();
    final originalSize = bytes.length;
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not decode image file.');
    }

    final format = targetFormat.toLowerCase().replaceAll('.', '');
    final outputDir = await getTemporaryDirectory();
    final outputName =
        '${p.basenameWithoutExtension(inputPath)}_converted_${DateTime.now().millisecondsSinceEpoch}.$format';
    final outputPath = p.join(outputDir.path, outputName);

    List<int> encoded;
    switch (format) {
      case 'png':
        encoded = img.encodePng(decoded);
      case 'jpg':
      case 'jpeg':
        encoded = img.encodeJpg(decoded, quality: quality);
      case 'webp':
        encoded = img.encodeJpg(decoded, quality: quality);
      default:
        throw Exception('Unsupported output format: $targetFormat');
    }

    await File(outputPath).writeAsBytes(encoded);

    return ImageProcessResult(
      outputPath: outputPath,
      originalSizeBytes: originalSize,
      outputSizeBytes: encoded.length,
      width: decoded.width,
      height: decoded.height,
    );
  }
}
