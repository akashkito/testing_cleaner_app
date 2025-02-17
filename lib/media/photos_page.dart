import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotosPage extends StatefulWidget {
  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  @override
  void initState() {
    super.initState();
    // requestPermissions();
  }

  // Future<void> requestPermissions() async {
  //   // Request camera permission
  //   var cameraStatus = await Permission.camera.request();
  //   if (cameraStatus.isGranted) {
  //     print('Camera Permission Granted');
  //   } else {
  //     print('Camera Permission Denied');
  //   }

  //   // Request storage permission
  //   var storageStatus = await Permission.storage.request();
  //   if (storageStatus.isGranted) {
  //     print('Storage Permission Granted');
  //   } else {
  //     print('Storage Permission Denied');
  //   }
  // }

  Future<List<String>> getPhotoFiles() async {
  try {
    final List<String> result = await platform.invokeMethod('getPhotoFiles');
    print("Photo files: $result");
    return result;
  } on PlatformException catch (e) {
    print("Error: ${e.message}");
    return [];
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'),
      ),
      body: FutureBuilder<List<String>>(
        future: getPhotoFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final photos = snapshot.data ?? [];

          return ListView.builder(
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
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
