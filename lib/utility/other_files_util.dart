import 'package:flutter/services.dart';

class OtherFilesUtil {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  // Method to fetch other files (doc, excel, txt, apk) excluding mp3, mp4, png, jpg
  static Future<List<Map<String, dynamic>>> getOtherFiles() async {
    try {
      final List<dynamic> files = await platform.invokeMethod('getOtherFiles');
      return files.map((file) {
        return {
          'name': file['name'],
          'size': file['size'],
          'path': file['path'],
        };
      }).toList();
    } on PlatformException catch (e) {
      print("Error fetching files: ${e.message}");
      return [];
    }
  }

  // Method to delete a file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final bool success = await platform.invokeMethod('deleteOtherFile', {'filePath': filePath});
      return success;
    } on PlatformException catch (e) {
      print("Error deleting file: ${e.message}");
      return false;
    }
  }
}
