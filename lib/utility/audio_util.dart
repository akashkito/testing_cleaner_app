import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FileUtils {

  static const platform = MethodChannel('com.example.testing_cleaner_app');
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // Format the date
  static String formatDate(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    // final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Modify the _getAudioDuration method to fetch the duration from Kotlin
  static Future<String> getAudioDuration(String path) async {
    try {
      final String? duration =
          await platform.invokeMethod('getAudioDuration', {'path': path});
      return duration ?? 'Unknown';
    } catch (e) {
      debugPrint('Error loading audio duration: $e');
      return 'Unknown';
    }
  }
}
