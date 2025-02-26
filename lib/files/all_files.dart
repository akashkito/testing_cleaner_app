// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class FolderAccessPage extends StatefulWidget {
//   @override
//   _FolderAccessPageState createState() => _FolderAccessPageState();
// }

// class _FolderAccessPageState extends State<FolderAccessPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   List<String> _filePaths = [];
//   bool isLoading = false;

//   // Fetch the files from a directory
//   Future<void> _getFilesInDirectory(String directoryPath) async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final List<dynamic> files = await platform.invokeMethod(
//         'getFilesInDirectory',
//         {'directoryPath': directoryPath},
//       );
//       setState(() {
//         _filePaths = List<String>.from(files);
//         isLoading = false;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error fetching files: ${e.message}");
//     }
//   }

//   // Method to display the directory options
//   Widget _buildDirectoryButton(String directoryName, String directoryPath) {
//     return ElevatedButton(
//       onPressed: () {
//         _getFilesInDirectory(directoryPath);
//       },
//       child: Text("Get Files from $directoryName Folder"),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Access Folders'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header for the available folders
//             Text(
//               'Choose a folder to explore:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             // Directory buttons
//             _buildDirectoryButton("Download", "/storage/emulated/0/Download"),
//             _buildDirectoryButton("Visible Cache", "/data/data/com.example.your_app_name/cache"),
//             _buildDirectoryButton("Hidden Cache", "/data/data/com.example.your_app_name/.cache"),
//             _buildDirectoryButton("APKs", "/data/app"),
//             _buildDirectoryButton("Thumbnails", "/storage/emulated/0/.thumbnails"),
//             _buildDirectoryButton("App Data", "/data/data/com.example.your_app_name"),
//             _buildDirectoryButton("Temporary Files", "/data/data/com.example.your_app_name/files/temporary"),
//             _buildDirectoryButton("Large Files", "/storage/emulated/0/"),
//             _buildDirectoryButton("Empty Folders", "/storage/emulated/0/"),

//             SizedBox(height: 20),
//             // Loading indicator while fetching data
//             if (isLoading) 
//               Center(child: CircularProgressIndicator()),

//             // Display the file paths
//             if (!isLoading && _filePaths.isNotEmpty) 
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _filePaths.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(_filePaths[index]),
//                     );
//                   },
//                 ),
//               ),
//             // If no files found, display a message
//             if (!isLoading && _filePaths.isEmpty) 
//               Center(child: Text('No files found in this folder.')),
//           ],
//         ),
//       ),
//     );
//   }
// }


// -- testing 2 ----
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class FolderAccessPage extends StatefulWidget {
//   @override
//   _FolderAccessPageState createState() => _FolderAccessPageState();
// }

// class _FolderAccessPageState extends State<FolderAccessPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   List<String> _filePaths = [];
//   List<String> _selectedFiles = [];
//   bool isLoading = false;

//   String? _selectedDirectory;

//   // Directory options
//   final List<Map<String, String>> directories = [
//     {'name': 'Download', 'path': '/storage/emulated/0/Download'},
//     {'name': 'Visible Cache', 'path': '/data/data/com.example.your_app_name/cache'},
//     {'name': 'Hidden Cache', 'path': '/data/data/com.example.your_app_name/.cache'},
//     {'name': 'APKs', 'path': '/data/app'},
//     {'name': 'Thumbnails', 'path': '/storage/emulated/0/.thumbnails'},
//     {'name': 'App Data', 'path': '/data/data/com.example.your_app_name'},
//     {'name': 'Temporary Files', 'path': '/data/data/com.example.your_app_name/files/temporary'},
//     {'name': 'Large Files', 'path': '/storage/emulated/0/'},
//     {'name': 'Empty Folders', 'path': '/storage/emulated/0/'},
//   ];

//   // Fetch the files from a directory
//   Future<void> _getFilesInDirectory(String directoryPath) async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final List<dynamic> files = await platform.invokeMethod(
//         'getFilesInDirectory',
//         {'directoryPath': directoryPath},
//       );
//       setState(() {
//         _filePaths = List<String>.from(files);
//         isLoading = false;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error fetching files: ${e.message}");
//     }
//   }

//   // Checkbox on the files list
//   void _toggleFileSelection(String filePath, bool isSelected) {
//     setState(() {
//       if (isSelected) {
//         _selectedFiles.add(filePath);
//       } else {
//         _selectedFiles.remove(filePath);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Access Folders'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Choose a folder to explore:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             // Directory Dropdown
//             DropdownButton<String>(
//               hint: Text('Select Directory'),
//               value: _selectedDirectory,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedDirectory = newValue;
//                 });
//                 if (newValue != null) {
//                   // Fetch the files from the selected directory
//                   final directory = directories.firstWhere(
//                       (dir) => dir['name'] == newValue,
//                       orElse: () => {'name': '', 'path': ''});
//                   _getFilesInDirectory(directory['path']!);
//                 }
//               },
//               items: directories.map((directory) {
//                 return DropdownMenuItem<String>(
//                   value: directory['name'],
//                   child: Text(directory['name']!),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),

//             // Loading indicator while fetching data
//             if (isLoading) 
//               Center(child: CircularProgressIndicator()),

//             // Display files in a list with checkboxes
//             if (!isLoading && _filePaths.isNotEmpty) 
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _filePaths.length,
//                   itemBuilder: (context, index) {
//                     return CheckboxListTile(
//                       title: Text(_filePaths[index]),
//                       value: _selectedFiles.contains(_filePaths[index]),
//                       onChanged: (bool? isSelected) {
//                         if (isSelected != null) {
//                           _toggleFileSelection(_filePaths[index], isSelected);
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ),
//             // If no files found, display a message
//             if (!isLoading && _filePaths.isEmpty)
//               Center(child: Text('No files found in this folder.')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ------ testing 3------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FolderAccessPage extends StatefulWidget {
  @override
  _FolderAccessPageState createState() => _FolderAccessPageState();
}

class _FolderAccessPageState extends State<FolderAccessPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  List<FileItem> _fileItems = [];
  List<FileItem> _selectedFiles = [];
  bool isLoading = false;

  String? _selectedDirectory;

  // Directory options (now includes special folders and large files)
  final List<Map<String, String>> directories = [
    {'name': 'Download', 'path': '/storage/emulated/0/Download'},
    {'name': 'Visible Cache', 'path': '/data/data/com.example.testing_cleaner_app/cache'},
    {'name': 'Hidden Cache', 'path': '/data/data/com.example.testing_cleaner_app/.cache'},
    {'name': 'APKs', 'path': '/data/app'},
    {'name': 'Thumbnails', 'path': '/storage/emulated/0/.thumbnails'},
    {'name': 'App Data', 'path': '/data/data/com.example.testing_cleaner_app'},
    {'name': 'Temporary Files', 'path': '/data/data/com.example.testing_cleaner_app/files/temporary'},
    {'name': 'Large Files', 'path': '/storage/emulated/0/'},  // Include large files directory
    {'name': 'Empty Folders', 'path': '/storage/emulated/0/'},  // Include empty folders directory
  ];

  // Fetch files for a given directory
  Future<void> _getFilesInDirectory(String directoryPath) async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<dynamic> files = await platform.invokeMethod(
        'getFilesInDirectory',
        {'directoryPath': directoryPath},
      );

      setState(() {
        _fileItems = files.map((file) {
          return FileItem(
            name: file['name'],
            size: file['size'],
            icon: file['icon'],
            path: file['path'],
          );
        }).toList();
        isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching files: ${e.message}");
    }
  }

  // Helper function to format file size
  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes >= 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (sizeInBytes >= 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (sizeInBytes >= 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$sizeInBytes bytes';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Folders'),
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
                    future: platform.invokeMethod('getFilesInDirectory', {'directoryPath': directory['path']}),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
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
                            Text('Total size: ${_formatFileSize(stats['totalSize'])}'),
                          ],
                        );
                      } else {
                        return Text('No data');
                      }
                    },
                  ),
                ],
              ),
              children: [
                FutureBuilder(
                  future: platform.invokeMethod('getFilesInDirectory', {'directoryPath': directory['path']}),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      final files = List<FileItem>.from(
                        snapshot.data!.map((file) => FileItem(
                          name: file['name'],
                          size: file['size'],
                          icon: file['icon'],
                          path: file['path'],
                        ))).toList();
                      return ListView.builder(
                        shrinkWrap: true, // Prevent overflow in scrollable views
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          FileItem fileItem = files[index];
                          return CheckboxListTile(
                            title: Row(
                              children: [
                                Icon(Icons.insert_drive_file),  // Default icon
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fileItem.name,
                                    overflow: TextOverflow.ellipsis,  // Ellipsis for overflow
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text('Size: ${_formatFileSize(fileItem.size)}'),  // Size in KB/MB/GB
                            value: _selectedFiles.contains(fileItem),
                            onChanged: (bool? isSelected) {
                              if (isSelected != null) {
                                _toggleFileSelection(fileItem, isSelected);
                              }
                            },
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('No files found in this folder.'));
                    }
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Method to toggle file selection
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class FolderAccessPage extends StatefulWidget {
//   @override
//   _FolderAccessPageState createState() => _FolderAccessPageState();
// }

// class _FolderAccessPageState extends State<FolderAccessPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   List<FileItem> _fileItems = [];
//   List<FileItem> _selectedFiles = [];
//   bool isLoading = false;

//   String? _selectedDirectory;

//   // Directory options
//   final List<Map<String, String>> directories = [
//     {'name': 'Download', 'path': '/storage/emulated/0/Download'},
//     {'name': 'Visible Cache', 'path': '/data/data/com.example.testing_cleaner_app/cache'},
//     {'name': 'Hidden Cache', 'path': '/data/data/com.example.testing_cleaner_app/.cache'},
//     {'name': 'APKs', 'path': '/data/app'},
//     {'name': 'Thumbnails', 'path': '/storage/emulated/0/.thumbnails'},
//     {'name': 'App Data', 'path': '/data/data/com.example.testing_cleaner_app'},
//     {'name': 'Temporary Files', 'path': '/data/data/com.example.testing_cleaner_app/files/temporary'},
//     {'name': 'Large Files', 'path': '/storage/emulated/0/'},
//     {'name': 'Empty Folders', 'path': '/storage/emulated/0/'},
//   ];

//   // Fetch the files from a directory
//   Future<void> _getFilesInDirectory(String directoryPath) async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final List<dynamic> files = await platform.invokeMethod(
//         'getFilesInDirectory',
//         {'directoryPath': directoryPath},
//       );

//       setState(() {
//         _fileItems = files.map((file) {
//           return FileItem(
//             name: file['name'],
//             size: file['size'],
//             icon: file['icon'],
//             path: file['path'],
//           );
//         }).toList();
//         isLoading = false;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error fetching files: ${e.message}");
//     }
//   }

//   // Your existing method for toggling file selection
//   void _toggleFileSelection(FileItem fileItem, bool isSelected) {
//     setState(() {
//       if (isSelected) {
//         _selectedFiles.add(fileItem);
//       } else {
//         _selectedFiles.remove(fileItem);
//       }
//     });
//   }

//   // Helper function to format file size in KB, MB, or GB
//   String _formatFileSize(int sizeInBytes) {
//     if (sizeInBytes >= 1024 * 1024 * 1024) {
//       return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
//     } else if (sizeInBytes >= 1024 * 1024) {
//       return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
//     } else if (sizeInBytes >= 1024) {
//       return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
//     } else {
//       return '$sizeInBytes bytes';
//     }
//   }

//   // Helper function to calculate total size and item count in a directory
//   Map<String, dynamic> _calculateFolderStats(List<FileItem> files) {
//     int totalSize = 0;
//     int itemCount = files.length;
//     for (var file in files) {
//       totalSize += file.size;
//     }
//     return {
//       'totalSize': totalSize,
//       'itemCount': itemCount,
//     };
//   }

//   // Function to toggle select/deselect all files in the directory
//   void _toggleSelectAll(bool isSelected, List<FileItem> files) {
//     setState(() {
//       if (isSelected) {
//         _selectedFiles.addAll(files);
//       } else {
//         _selectedFiles.removeWhere((file) => files.contains(file));
//       }
//     });
//   }

//   // Function to delete selected files (Assuming a delete method exists)
//   Future<void> _deleteSelectedFiles() async {
//     try {
//       for (var file in _selectedFiles) {
//         // Replace with actual delete logic (using platform method or API)
//         await platform.invokeMethod('deleteFile', {'filePath': file.path});
//       }
//       setState(() {
//         _selectedFiles.clear(); // Clear selected files after deletion
//       });
//     } catch (e) {
//       print("Error deleting files: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Access Folders'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: _deleteSelectedFiles, // Trigger file deletion
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: directories.map((directory) {
//             return ExpansionTile(
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(directory['name']!),
//                   FutureBuilder(
//                     future: platform.invokeMethod('getFilesInDirectory', {'directoryPath': directory['path']}),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return CircularProgressIndicator();
//                       }
//                       if (snapshot.hasData) {
//                         final files = List<FileItem>.from(
//                           snapshot.data!.map((file) => FileItem(
//                             name: file['name'],
//                             size: file['size'],
//                             icon: file['icon'],
//                             path: file['path'],
//                           )),
//                         );
//                         final stats = _calculateFolderStats(files);
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text('Items: ${stats['itemCount']}'),
//                             Text('Total size: ${_formatFileSize(stats['totalSize'])}'),
//                           ],
//                         );
//                       } else {
//                         return Text('No data');
//                       }
//                     },
//                   ),
//                 ],
//               ),
//               children: [
//                 FutureBuilder(
//                   future: platform.invokeMethod('getFilesInDirectory', {'directoryPath': directory['path']}),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     if (snapshot.hasData) {
//                       final files = List<FileItem>.from(
//                         snapshot.data!.map((file) => FileItem(
//                           name: file['name'],
//                           size: file['size'],
//                           icon: file['icon'],
//                           path: file['path'],
//                         )),
//                       );

//                       return Column(
//                         children: [
//                           CheckboxListTile(
//                             title: Text("Select/Deselect All"),
//                             value: _selectedFiles.length == files.length,
//                             onChanged: (bool? isSelected) {
//                               _toggleSelectAll(isSelected ?? false, files);
//                             },
//                           ),
//                           ListView.builder(
//                             shrinkWrap: true, // Prevent overflow in scrollable views
//                             itemCount: files.length,
//                             itemBuilder: (context, index) {
//                               FileItem fileItem = files[index];
//                               return CheckboxListTile(
//                                 title: Row(
//                                   children: [
//                                     Icon(Icons.insert_drive_file), // Default icon
//                                     SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         fileItem.name,
//                                         overflow: TextOverflow.ellipsis, // Ellipsis for overflow
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 subtitle: Text('Size: ${_formatFileSize(fileItem.size)}'), // Size in KB/MB/GB
//                                 value: _selectedFiles.contains(fileItem),
//                                 onChanged: (bool? isSelected) {
//                                   if (isSelected != null) {
//                                     _toggleFileSelection(fileItem, isSelected);
//                                   }
//                                 },
//                               );
//                             },
//                           ),
//                         ],
//                       );
//                     } else {
//                       return Center(child: Text('No files found in this folder.'));
//                     }
//                   },
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// // FileItem class
// class FileItem {
//   final String name;
//   final int size; // Size in bytes
//   final String icon;
//   final String path;

//   FileItem({
//     required this.name,
//     required this.size,
//     required this.icon,
//     required this.path,
//   });
// }
