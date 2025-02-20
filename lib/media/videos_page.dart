import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // To use File class for videos

class VideosPage extends StatelessWidget {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Future<List<Map<String, Object>>> getVideoFiles() async {
    try {
      final List<dynamic> videos = await platform.invokeMethod('getVideoFiles');
      return List<Map<String, Object>>.from(videos.map((video) {
        return {
          'path': video['path'] as String,
          'name': video['name'] as String,
          'size': video['size'] as int,
          'date': video['date'] as int,
        };
      }));
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
      body: FutureBuilder<List<Map<String, Object>>>(
        future: getVideoFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final videos = snapshot.data ?? [];

          if (videos.isEmpty) {
            return Center(child: Text('No videos found.'));
          }

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                leading: Icon(Icons.video_library, size: 50, color: Colors.blue),
                title: Text(video['name'] as String),
                subtitle: Text('Size: ${(video['size'] as int) / 1024} KB'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // You can add functionality here to play or open the video
                },
              );
            },
          );
        },
      ),
    );
  }
}
