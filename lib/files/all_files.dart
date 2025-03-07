import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_cleaner_app/utility/audio_util.dart';

class FolderAccessPage extends StatefulWidget {
  const FolderAccessPage({super.key});

  @override
  _FolderAccessPageState createState() => _FolderAccessPageState();
}

class _FolderAccessPageState extends State<FolderAccessPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  
  // A map to store files per directory
  final Map<String, List<FileItem>> _directoryFiles = {};
  final Map<String, bool> _directoryFilesLoaded = {}; // Track loading state of files for each directory
  final List<FileItem> _selectedFiles = [];
  bool isLoading = false;
  int offset = 0;
  final int limit = 60; // Number of items per page

  // Directory options
  final List<Map<String, String>> directories = [
    {'name': 'Download', 'path': '/storage/emulated/0/Download'},
    {'name': 'Visible Cache', 'path': '/data/data/com.example.testing_cleaner_app/cache'},
    {'name': 'Hidden Cache', 'path': '/data/data/com.example.testing_cleaner_app/.cache'},
    {'name': 'APKs', 'path': '/data/app'},
    {'name': 'Thumbnails', 'path': '/storage/emulated/0/.thumbnails'},
    {'name': 'App Data', 'path': '/data/data/com.example.testing_cleaner_app'},
    {'name': 'Temporary Files', 'path': '/data/data/com.example.testing_cleaner_app/files/temporary'},
    {'name': 'Large Files', 'path': '/storage/emulated/0/'},  // Large files directory
  ];

  // Fetch files for a given directory only when the user expands the directory
  Future<void> _getFilesInDirectory(String directoryPath) async {
    if (_directoryFilesLoaded[directoryPath] == true) return; // Skip if already loaded

    setState(() {
      isLoading = true;
    });

    try {
      final List<dynamic> files = await platform.invokeMethod(
        'getFilesInDirectory',
        {
          'directoryPath': directoryPath,
          'offset': offset,
        },
      );

      setState(() {
        final directoryFiles = files.map((file) {
          return FileItem(
            name: file['name'],
            size: file['size'],
            icon: file['icon'],
            path: file['path'],
          );
        }).toList();
        
        // Store the files per directory in the map
        _directoryFiles[directoryPath] = directoryFiles;
        _directoryFilesLoaded[directoryPath] = true; // Mark as loaded
        offset += limit; // Increase offset for the next page
        isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching files: ${e.message}");
    }
  }

  // Helper function to calculate total size and item count in a directory
  Map<String, dynamic> _calculateFolderStats(List<FileItem> files) {
    int totalSize = 0;
    int itemCount = files.length;
    for (var file in files) {
      totalSize += file.size;
    }
    return {
      'totalSize': totalSize,
      'itemCount': itemCount,
    };
  }

  // Delete a file with confirmation
  void _deleteFile(FileItem fileItem) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: Text('Are you sure you want to delete ${fileItem.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirm ?? false) {
      try {
        await platform.invokeMethod('deleteFile', {'filePath': fileItem.path});
        setState(() {
          // Remove the file from the corresponding directory list
          _directoryFiles[fileItem.path]?.remove(fileItem);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${fileItem.name} deleted successfully'),
        ));
      } on PlatformException catch (e) {
        print("Error deleting file: ${e.message}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Folders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: directories.map((directory) {
            return ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(directory['name']!),
                  // Show total size and item count for each directory
                  FutureBuilder(
                    future: platform.invokeMethod('getFilesInDirectory', {'directoryPath': directory['path']}), // Use a new method
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasData) {
                        final files = List<FileItem>.from(
                          snapshot.data!.map((file) => FileItem(
                            name: file['name'],
                            size: file['size'],
                            icon: file['icon'],
                            path: file['path'],
                          ))).toList();
                        final stats = _calculateFolderStats(files);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Items: ${stats['itemCount']}'),
                            Text('Total size: ${FileUtils.formatFileSize(stats['totalSize'])}'),
                          ],
                        );
                      } else {
                        return const Text('No data');
                      }
                    },
                  ),
                ],
              ),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  // Load files when expanded
                  _getFilesInDirectory(directory['path']!);
                }
              },
              children: [
                _directoryFilesLoaded[directory['path']] == true
                    ? SingleChildScrollView( // Make the content scrollable inside the tile
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _directoryFiles[directory['path']]?.length ?? 0,
                          itemBuilder: (context, index) {
                            FileItem fileItem = _directoryFiles[directory['path']]![index];
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(
                                fileItem.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('Size: ${FileUtils.formatFileSize(fileItem.size)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteFile(fileItem),
                              ),
                              onTap: () {
                                _toggleFileSelection(fileItem, !_selectedFiles.contains(fileItem));
                              },
                              selected: _selectedFiles.contains(fileItem),
                            );
                          },
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _toggleFileSelection(FileItem fileItem, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedFiles.add(fileItem);
      } else {
        _selectedFiles.remove(fileItem);
      }
    });
  }
}

// FileItem class
class FileItem {
  final String name;
  final int size; // Size in bytes
  final String icon;
  final String path;

  FileItem({
    required this.name,
    required this.size,
    required this.icon,
    required this.path,
  });
}
