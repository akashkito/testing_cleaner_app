import 'package:flutter/services.dart';

class CameraInfo {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  List<Map<String, String>> frontCameras = [];
  List<Map<String, String>> rearCameras = [];

  // Fetching camera info
  Future<void> fetchCameraInfo() async {
    try {
      final Map<String, dynamic> result = Map<String, dynamic>.from(await platform.invokeMethod('getCameraInfo'));

      // Check if there's an error message in the result
      if (result.containsKey('error')) {
        frontCameras = [];
        rearCameras = [];
        return;
      }

      List cameras = result['cameras'] ?? [];
      frontCameras = [];
      rearCameras = [];

      if (cameras.isEmpty) {
        frontCameras = [];
        rearCameras = [];
        return;
      }

      // Sort cameras into front and rear categories
      for (var camera in cameras) {
        if (camera['type'] == "Front") {
          frontCameras.add({
            'cameraId': camera['cameraId'] ?? "Unknown",
            'resolution': camera['resolution'] ?? "Unknown",
          });
        } else if (camera['type'] == "Rear") {
          rearCameras.add({
            'cameraId': camera['cameraId'] ?? "Unknown",
            'resolution': camera['resolution'] ?? "Unknown",
          });
        }
      }
    } on PlatformException catch (e) {
      frontCameras = [];
      rearCameras = [];
      print('Error fetching camera info: ${e.message}');
    }
  }

  String getCameraInfoString() {
    String cameraInfo = '';

    // Show Front Cameras
    if (frontCameras.isNotEmpty) {
      cameraInfo += 'Front Cameras:\n';
      frontCameras.forEach((camera) {
        cameraInfo += 'Camera ID: ${camera['cameraId']}\nResolution: ${camera['resolution']}\n\n';
      });
    } else {
      cameraInfo += 'No Front Camera Available\n';
    }

    // Show Rear Cameras
    if (rearCameras.isNotEmpty) {
      cameraInfo += 'Rear Cameras:\n';
      rearCameras.forEach((camera) {
        cameraInfo += 'Camera ID: ${camera['cameraId']}\nResolution: ${camera['resolution']}\n\n';
      });
    } else {
      cameraInfo += 'No Rear Camera Available\n';
    }

    return cameraInfo;
  }
}
