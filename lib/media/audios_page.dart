import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudiosPage extends StatelessWidget {
  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Future<List<String>> getAudioFiles() async {
    try {
      final List<dynamic> audios = await platform.invokeMethod('getAudioFiles');
      return List<String>.from(audios);
    } on PlatformException catch (e) {
      print("Failed to get audios: ${e.message}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audios'),
      ),
      body: FutureBuilder<List<String>>(
        future: getAudioFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final audios = snapshot.data ?? [];

          return ListView.builder(
            itemCount: audios.length,
            itemBuilder: (context, index) {
              final audio = audios[index];
              return ListTile(
                title: Text(audio),
              );
            },
          );
        },
      ),
    );
  }
}
