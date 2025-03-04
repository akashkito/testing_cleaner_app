
import 'package:flutter/material.dart';

class CleanPage extends StatelessWidget {
  final int totalSizeCleared;
  final List<Map<String, dynamic>> deletedPhotos;

  const CleanPage({
    super.key,
    required this.totalSizeCleared,
    required this.deletedPhotos,
  });

  String formatFileSize(int size) {
    if (size < 1024) {
      return "$size B";
    } else if (size < 1024 * 1024) {
      return "${(size / 1024).toStringAsFixed(2)} KB";
    } else if (size < 1024 * 1024 * 1024) {
      return "${(size / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else {
      return "${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cleaned Photos')),
      body: Column(
        children: [
          // Show the total size cleared
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total space cleared: ${formatFileSize(totalSizeCleared)}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          // Display the deleted photos list (if any)
          Expanded(
            child: ListView.builder(
              itemCount: deletedPhotos.length,
              itemBuilder: (context, index) {
                final photo = deletedPhotos[index];
                return ListTile(
                  title: Text(photo['name'] ?? 'No Name'),
                  subtitle: Text(formatFileSize(photo['size'])),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
