import 'file_saver_unsupported.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_mobile.dart';

class FileSaverUtils {
  static Future<void> saveAndDownload(String fileName, List<int> bytes) async {
    await FileSaver.saveAndDownloadFile(fileName, bytes);
  }
}
