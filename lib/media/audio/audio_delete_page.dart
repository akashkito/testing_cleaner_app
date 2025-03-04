import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utility/audio_util.dart';

class DeletedItemsPage extends StatelessWidget {
  final List<Map<String, Object>> deletedItems;

  const DeletedItemsPage({super.key, required this.deletedItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Deleted Items',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: deletedItems.isEmpty
          ? const Center(child: Text('No items were deleted.'))
          : ListView.builder(
              itemCount: deletedItems.length,
              itemBuilder: (context, index) {
                final audio = deletedItems[index];
                final name = audio['name'] as String;
                final size = FileUtils.formatFileSize(audio['size'] as int);

                return ListTile(
                  title: Text(name),
                  subtitle: Text(size),
                );
              },
            ),
    );
  }
}
