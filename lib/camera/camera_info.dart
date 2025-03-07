// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class CameraInfo {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');

//   List<Map<String, String>> frontCameras = [];
//   List<Map<String, String>> rearCameras = [];

//   // Fetching camera info
//   Future<void> fetchCameraInfo() async {
//     try {
//       final Map<String, dynamic> result = Map<String, dynamic>.from(
//           await platform.invokeMethod('getCameraInfo'));

//       // Check if there's an error message in the result
//       if (result.containsKey('error')) {
//         frontCameras = [];
//         rearCameras = [];
//         return;
//       }

//       List cameras = result['cameras'] ?? [];
//       frontCameras = [];
//       rearCameras = [];

//       if (cameras.isEmpty) {
//         frontCameras = [];
//         rearCameras = [];
//         return;
//       }

//       // Sort cameras into front and rear categories
//       for (var camera in cameras) {
//         if (camera['type'] == "Front") {
//           frontCameras.add({
//             'cameraId': camera['cameraId'] ?? "Unknown",
//             'resolution': camera['resolution'] ?? "Unknown",
//           });
//         } else if (camera['type'] == "Rear") {
//           rearCameras.add({
//             'cameraId': camera['cameraId'] ?? "Unknown",
//             'resolution': camera['resolution'] ?? "Unknown",
//           });
//         }
//       }
//     } on PlatformException catch (e) {
//       frontCameras = [];
//       rearCameras = [];
//       debugPrint('Error fetching camera info: ${e.message}');
//     }
//   }

//   String getCameraInfoString() {
//     String cameraInfo = '';

//     // Show Front Cameras
//     if (frontCameras.isNotEmpty) {
//       cameraInfo += 'Front Cameras:\n';
//       for (var camera in frontCameras) {
//         cameraInfo +=
//             'Camera ID: ${camera['cameraId']}\nResolution: ${camera['resolution']}\n\n';
//       }
//     } else {
//       cameraInfo += 'No Front Camera Available\n';
//     }

//     // Show Rear Cameras
//     if (rearCameras.isNotEmpty) {
//       cameraInfo += 'Rear Cameras:\n';
//       for (var camera in rearCameras) {
//         cameraInfo +=
//             'Camera ID: ${camera['cameraId']}\nResolution: ${camera['resolution']}\n\n';
//       }
//     } else {
//       cameraInfo += 'No Rear Camera Available\n';
//     }

//     return cameraInfo;
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraInfo {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  List<Map<String, String>> frontCameras = [];
  List<Map<String, String>> rearCameras = [];

  // Fetching camera info
  Future<void> fetchCameraInfo() async {
    try {
      final Map<String, dynamic> result = Map<String, dynamic>.from(
          await platform.invokeMethod('getCameraInfo'));

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
      debugPrint('Error fetching camera info: ${e.message}');
    }
  }

  Widget getStyledCameraInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Front Cameras Section
        if (frontCameras.isNotEmpty) ...[
          Text(
            'Front Cameras:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 8),
          for (var camera in frontCameras) ...[
            _buildCameraInfo(camera),
          ],
        ] else ...[
          Text(
            'No Front Camera Available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.red,
            ),
          ),
        ],

        // SizedBox(height: 20),

        // Rear Cameras Section
        if (rearCameras.isNotEmpty) ...[
          // Text(
          //   'Rear Cameras:',
          //   style: GoogleFonts.poppins(
          //     fontSize: 14,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.blueAccent,
          //   ),
          // ),
          SizedBox(height: 8),
          for (var camera in rearCameras) ...[
            _buildCameraInfo(camera),
          ],
        ] else ...[
          Text(
            'No Rear Camera Available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  // Helper method to build individual camera info
  Widget _buildCameraInfo(Map<String, String> camera) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Camera ID
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'Camera ID: ',
                  style: GoogleFonts.poppins( 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  camera['cameraId'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        // SizedBox(height: 4),

        // Camera Resolution
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'Resolution: ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  camera['resolution'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
