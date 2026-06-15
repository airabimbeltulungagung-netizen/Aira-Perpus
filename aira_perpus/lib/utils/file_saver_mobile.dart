import 'dart:io';
import 'package:flutter/foundation.dart';

class FileSaver {
  static Future<void> saveAndDownloadFile(
      String fileName, List<int> bytes) async {
    try {
      final file = File(fileName);
      await file.writeAsBytes(bytes);
      debugPrint("File saved to ${file.absolute.path}");
    } catch (e) {
      debugPrint("Exception saving file natively: $e");
    }
  }
}
