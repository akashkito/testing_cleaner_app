import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VideoItem extends StatelessWidget {
  final Map<String, Object> video;
  final bool isSelected;
  final ValueChanged<bool?> onCheckboxChanged;
  final VoidCallback onTap;

  const VideoItem({
    required this.video,
    required this.isSelected,
    required this.onCheckboxChanged,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Optional: Padding to space out content
      leading: (video['thumbnail'] as String).isNotEmpty
          ? Image.file(File(video['thumbnail'] as String),
              width: 50, height: 50, fit: BoxFit.cover)
          : const Icon(Icons.video_library),
      title: Text(video['name'] as String),
      subtitle: Text(
        '${formatFileSize(video['size'] as int)} - ${formatDate(video['date'] as int)}',
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: onCheckboxChanged,
      ),
      onTap: onTap,
    );
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String formatDate(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
    return formatter.format(date);
  }
}
