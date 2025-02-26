// import 'dart:io';
// import 'package:flutter/services.dart';

// class VideoManager {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');

//   Future<List<Map<String, Object>>> getVideoFiles(int currentPage, int pageSize) async {
//     try {
//       final List<dynamic>? videos = await platform.invokeMethod(
//         'getVideoFiles',
//         {'page': currentPage, 'pageSize': pageSize},
//       );

//       if (videos != null && videos.isNotEmpty) {
//         return videos.map((video) {
//           final videoMap = Map<String, dynamic>.from(video);
//           return {
//             'path': videoMap['path'] as String,
//             'name': videoMap['name'] as String,
//             'size': videoMap['size'] as int,
//             'date': videoMap['date'] as int,
//             'thumbnail': videoMap['thumbnail'] as String,
//           };
//         }).toList();
//       } else {
//         return [];
//       }
//     } on PlatformException catch (e) {
//       print("Error fetching videos: ${e.message}");
//       return [];
//     }
//   }

//   Future<bool> deleteVideo(String videoPath) async {
//     try {
//       final bool? result = await platform.invokeMethod('deleteVideo', {'path': videoPath});
//       return result ?? false;
//     } on PlatformException catch (e) {
//       print("Error deleting video: ${e.message}");
//       return false;
//     }
//   }

//   String formatFileSize(int bytes) {
//     if (bytes < 1024) {
//       return '$bytes B';
//     } else if (bytes < 1024 * 1024) {
//       return '${(bytes / 1024).toStringAsFixed(2)} KB';
//     } else if (bytes < 1024 * 1024 * 1024) {
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
//     } else {
//       return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
//     }
//   }

//   String calculateTotalSize(List<Map<String, Object>> videos) {
//     int totalSize = 0;
//     for (var video in videos) {
//       totalSize += video['size'] as int;
//     }
//     return formatFileSize(totalSize);
//   }
// }
