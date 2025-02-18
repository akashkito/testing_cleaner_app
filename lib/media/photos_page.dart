// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class PhotosPage extends StatefulWidget {
//   @override
//   _PhotosPageState createState() => _PhotosPageState();
// }

// class _PhotosPageState extends State<PhotosPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');

//   @override
//   void initState() {
//     super.initState();
//     // requestPermissions();
//   }

//   // Future<void> requestPermissions() async {
//   //   // Request camera permission
//   //   var cameraStatus = await Permission.camera.request();
//   //   if (cameraStatus.isGranted) {
//   //     print('Camera Permission Granted');
//   //   } else {
//   //     print('Camera Permission Denied');
//   //   }

//   //   // Request storage permission
//   //   var storageStatus = await Permission.storage.request();
//   //   if (storageStatus.isGranted) {
//   //     print('Storage Permission Granted');
//   //   } else {
//   //     print('Storage Permission Denied');
//   //   }
//   // }

//   Future<List<String>> getPhotoFiles() async {
//   try {
//     final List<String> result = await platform.invokeMethod('getPhotoFiles');
//     print("Photo files: $result");
//     return result;
//   } on PlatformException catch (e) {
//     print("Error: ${e.message}");
//     return [];
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Photos'),
//       ),
//       body: FutureBuilder<List<String>>(
//         future: getPhotoFiles(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final photos = snapshot.data ?? [];

//           return ListView.builder(
//             itemCount: photos.length,
//             itemBuilder: (context, index) {
//               final photo = photos[index];
//               return ListTile(
//                 title: Text(photo),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotosPage extends StatefulWidget {
  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  bool _isPermissionGranted = false;
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // Check permission for storage to access photos
  Future<void> _checkPermission() async {
    try {
      final bool hasPermission = await platform.invokeMethod('checkStoragePermission');
      if (hasPermission) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getPhotoFiles();  // Get photo files if permission is granted
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
      }
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  // Request permission from the native side if denied
  Future<void> _requestPermission() async {
    try {
      final bool isPermissionGranted = await platform.invokeMethod('requestStoragePermission');
      if (isPermissionGranted) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getPhotoFiles();  // Get photos after permission is granted
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
        _showPermissionDeniedDialog();  // Show dialog if permission is still denied
      }
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  // Get the photo files from native code after permission is granted
  Future<void> _getPhotoFiles() async {
    try {
      final List<String> photos = await platform.invokeMethod('getPhotoFiles');
      setState(() {
        _photos = photos;
      });
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  // Show a dialog asking the user to grant permission
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('You need to grant storage permission to access photos.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'),
      ),
      body: Builder(
        builder: (context) {
          if (!_isPermissionGranted) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Storage permission is required to access photos.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          if (_photos.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return ListTile(
                title: Text(photo),
              );
            },
          );
        },
      ),
    );
  }
}
