// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class PermissionService {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   static bool _isPermissionGranted = false;

//   // Static method to check if permission is granted
//   static bool isPermissionGranted() {
//     return _isPermissionGranted;
//   }

//   // Request permission and return the status
//   static Future<bool> requestPermission() async {
//     try {
//       // Simulate requesting permission via platform channels or other methods
//       final bool? permissionStatus = await platform.invokeMethod('requestStoragePermission');
//       _isPermissionGranted = permissionStatus ?? false;
//       return _isPermissionGranted;
//     } catch (e) {
//       debugPrint("Error requesting permission: $e");
//       return false;
//     }
//   }

//   // Set the permission status (for internal use or testing)
//   static void setPermissionStatus(bool isGranted) {
//     _isPermissionGranted = isGranted;
//   }
// }
