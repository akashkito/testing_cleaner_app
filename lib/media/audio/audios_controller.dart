// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:just_audio/just_audio.dart';

// class AudiosController {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   bool _isPermissionGranted = false;
//   bool _isLoading = false;
//   int _currentPage = 0;
//   final int _pageSize = 10;
//   List<Map<String, Object>> _audios = [];
//   List<Map<String, Object>> _selectedAudios = [];

//   bool get isLoading => _isLoading;
//   List<Map<String, Object>> get audios => _audios;
//   List<Map<String, Object>> get selectedAudios => _selectedAudios;
//   bool get isPermissionGranted => _isPermissionGranted;

//   // Check and request permission
//   Future<void> checkPermission() async {
//     try {
//       final bool? hasPermission = await platform.invokeMethod('checkStoragePermission');
//       if (hasPermission ?? false) {
//         _isPermissionGranted = true;
//         await _getAudioFiles();
//       } else {
//         _isPermissionGranted = false;
//       }
//     } on PlatformException catch (e) {
//       print("Error checking permission: ${e.message}");
//     }
//   }

//   // Request permission
//   Future<void> requestPermission() async {
//     try {
//       final bool? isPermissionGranted = await platform.invokeMethod('requestStoragePermission');
//       if (isPermissionGranted ?? false) {
//         _isPermissionGranted = true;
//         await _getAudioFiles();
//       } else {
//         _isPermissionGranted = false;
//       }
//     } on PlatformException catch (e) {
//       print("Error requesting permission: ${e.message}");
//     }
//   }

//   // Fetch audio files with pagination
//   Future<void> _getAudioFiles() async {
//     _isLoading = true;

//     try {
//       final List<dynamic>? audios = await platform.invokeMethod(
//         'getAudioFiles',
//         {'page': _currentPage, 'pageSize': _pageSize},
//       );

//       if (audios != null && audios.isNotEmpty) {
//         _audios.addAll(audios.map((audio) {
//           final audioMap = Map<String, dynamic>.from(audio);
//           return {
//             'path': audioMap['path'] as String,
//             'name': audioMap['name'] as String,
//             'size': audioMap['size'] as int,
//             'date': audioMap['date'] as int,
//           };
//         }).toList());
//         _currentPage++;
//       } else {
//         print("No audio files found");
//       }
//       _isLoading = false;
//     } on PlatformException catch (e) {
//       print("Error fetching audios: ${e.message}");
//       _isLoading = false;
//     }
//   }

//   // Modify the _getAudioDuration method to fetch the duration from Kotlin
//   Future<String> getAudioDuration(String path) async {
//     try {
//       final String? duration = await platform.invokeMethod('getAudioDuration', {'path': path});
//       return duration ?? 'Unknown';
//     } catch (e) {
//       print('Error loading audio duration: $e');
//       return 'Unknown';
//     }
//   }

//   // Delete audio method
//   Future<void> deleteAudio(String path) async {
//     try {
//       final bool? result = await platform.invokeMethod('deleteAudio', {'path': path});
//       if (result == true) {
//         _audios.removeWhere((audio) => audio['path'] == path);
//         _selectedAudios.removeWhere((audio) => audio['path'] == path);
//       }
//     } on PlatformException catch (e) {
//       print("Error deleting audio: ${e.message}");
//     }
//   }

//   // Format file size
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

//   // Format the date
//   String formatDate(int timestamp) {
//     final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
//     return formatter.format(date);
//   }

//   // Delete selected audios
//   Future<void> deleteSelectedAudios() async {
//     for (final audio in _selectedAudios) {
//       await deleteAudio(audio['path'] as String);
//     }
//     _selectedAudios.clear();
//   }
// }
