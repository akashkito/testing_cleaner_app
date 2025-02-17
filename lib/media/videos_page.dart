import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideosPage extends StatelessWidget {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Future<List<String>> getVideoFiles() async {
    try {
      final List<dynamic> videos = await platform.invokeMethod('getVideoFiles');
      return List<String>.from(videos);
    } on PlatformException catch (e) {
      print("Failed to get videos: ${e.message}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: FutureBuilder<List<String>>(
        future: getVideoFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final videos = snapshot.data ?? [];

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                title: Text(video),
              );
            },
          );
        },
      ),
    );
  }
}
