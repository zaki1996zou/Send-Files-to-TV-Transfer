import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TransferRecord {
  TransferRecord({
    required this.id,
    required this.fileName,
    required this.method,
    required this.status,
    required this.timestamp,
    this.fileSizeMb,
    this.deviceName,
  });

  final String id;
  final String fileName;
  final String method;
  final String status;
  final DateTime timestamp;
  final double? fileSizeMb;
  final String? deviceName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'method': method,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        'fileSizeMb': fileSizeMb,
        'deviceName': deviceName,
      };

  factory TransferRecord.fromJson(Map<String, dynamic> json) => TransferRecord(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        method: json['method'] as String,
        status: json['status'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        fileSizeMb: (json['fileSizeMb'] as num?)?.toDouble(),
        deviceName: json['deviceName'] as String?,
      );
}

class TransferHistoryService {
  static const _fileName = 'transfer_history.json';
  List<TransferRecord> _records = [];

  Future<void> load() async {
    try {
      final file = await _historyFile();
      if (!await file.exists()) {
        _records = [];
        return;
      }
      final content = await file.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      _records = list
          .map((e) => TransferRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _records = [];
    }
  }

  List<TransferRecord> get records => List.unmodifiable(_records);

  Future<void> addRecord(TransferRecord record) async {
    _records.insert(0, record);
    if (_records.length > 50) {
      _records = _records.take(50).toList();
    }
    await _save();
  }

  Future<void> clear() async {
    _records = [];
    await _save();
  }

  Future<File> _historyFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _save() async {
    final file = await _historyFile();
    final jsonList = _records.map((r) => r.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
