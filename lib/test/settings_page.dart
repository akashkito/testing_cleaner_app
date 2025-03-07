// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   bool _isPermissionGranted = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionStatus();
//   }

//   // Check if permission is granted when the settings page is loaded
//   void _checkPermissionStatus() {
//     setState(() {
//       // You can implement the actual check for permission status here.
//       // For now, we assume it's false (denied).
//       _isPermissionGranted = false; // Replace with actual logic to check the permission
//     });
//   }

//   // Request permission if not granted
//   Future<void> _requestPermission() async {
//     try {
//       final bool? isPermissionGranted = await _requestStoragePermission();
//       if (isPermissionGranted ?? false) {
//         setState(() {
//           _isPermissionGranted = true;
//         });
//         // Proceed with the operation (e.g., load data)
//       } else {
//         setState(() {
//           _isPermissionGranted = false;
//         });
//         _showPermissionDeniedDialog();
//       }
//     } catch (e) {
//       debugPrint("Error requesting permission: ${e.toString()}");
//       _showPermissionDeniedDialog();
//     }
//   }

//   // Method to request permission (simulating platform-specific logic)
//   Future<bool?> _requestStoragePermission() async {
//     await Future.delayed(const Duration(seconds: 1)); // Simulating network delay
//     return true; // Return true if granted, false otherwise
//   }

//   // Show permission denied dialog
//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Permission Denied'),
//         content: const Text('You need to grant storage permission to access media.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               _openAllFilesAccessSettings();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Method to open the 'All Files Access' settings page
//   Future<void> _openAllFilesAccessSettings() async {
//     try {
//       await platform.invokeMethod('openAllFilesAccessSettings');
//     } on PlatformException catch (e) {
//       print("Failed to open settings: ${e.message}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Settings"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context); // Navigate back
//           },
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Storage Permission',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             SwitchListTile(
//               title: const Text('Permission Granted'),
//               value: _isPermissionGranted,
//               onChanged: (bool value) {
//                 if (value) {
//                   _requestPermission();
//                 } else {
//                   setState(() {
//                     _isPermissionGranted = false;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _requestPermission,
//               child: const Text('Grant Permission'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _openAllFilesAccessSettings();
//               },
//               child: const Text('Open Settings'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus(); // Check the permission status when the page loads
  }

  // Check if permission is granted when the settings page is loaded
  void _checkPermissionStatus() async {
    try {
      final bool? permissionStatus = await _getPermissionStatus();
      setState(() {
        _isPermissionGranted = permissionStatus ?? false;
      });
    } catch (e) {
      debugPrint("Error checking permission status: ${e.toString()}");
    }
  }

  // Method to get permission status
  Future<bool?> _getPermissionStatus() async {
    try {
      final bool? status = await platform.invokeMethod('getStoragePermissionStatus');
      return status ?? false; // Return true if permission is granted, false otherwise
    } on PlatformException catch (e) {
      debugPrint("Failed to get permission status: ${e.message}");
      return false;
    }
  }

  // Request permission if not granted
  Future<void> _requestPermission() async {
    try {
      final bool? isPermissionGranted = await _requestStoragePermission();
      setState(() {
        _isPermissionGranted = isPermissionGranted ?? false;
      });

      if (!(isPermissionGranted ?? false)) {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      debugPrint("Error requesting permission: ${e.toString()}");
      _showPermissionDeniedDialog();
    }
  }

  // Method to request storage permission
  Future<bool?> _requestStoragePermission() async {
    try {
      final bool? granted = await platform.invokeMethod('requestStoragePermission');
      return granted ?? false; // Return true if permission granted, false otherwise
    } on PlatformException catch (e) {
      debugPrint("Failed to request permission: ${e.message}");
      return false;
    }
  }

  // Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('You need to grant storage permission to access media.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _openAllFilesAccessSettings();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Method to open the 'All Files Access' settings page
  Future<void> _openAllFilesAccessSettings() async {
    try {
      await platform.invokeMethod('openAllFilesAccessSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to open settings: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Storage Permission',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Permission Granted'),
              value: _isPermissionGranted,
              onChanged: (bool value) {
                setState(() {
                  _isPermissionGranted = value; // Update the switch state
                });

                if (value) {
                  // If the switch is turned on, request permission and navigate to settings
                  _requestPermission();
                  _openAllFilesAccessSettings(); // Open settings for enabling permission
                } else {
                  // If the switch is turned off, revoke permission
                  _requestPermission(); // Revoke permission if applicable
                  _openAllFilesAccessSettings(); // Open settings for disabling permission
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Grant Permission'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _openAllFilesAccessSettings(); // Open the settings if needed
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}


