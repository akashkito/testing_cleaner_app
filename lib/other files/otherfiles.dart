// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:testing_cleaner_app/utility/other_files_util.dart';
// import 'other_file_model.dart';

// class OtherFilesPage extends StatefulWidget {
//   const OtherFilesPage({super.key});

//   @override
//   _OtherFilesPageState createState() => _OtherFilesPageState();
// }

// class _OtherFilesPageState extends State<OtherFilesPage> {
//   List<FileItem> _fileItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadOtherFiles();
//   }

//   // Calling the method from OtherFilesUtil to fetch files
//   Future<void> _loadOtherFiles() async {
//     try {
//       final List<Map<String, dynamic>> files = await OtherFilesUtil.getOtherFiles();
//       print("Fetched files: $files"); // Add this for debugging

//       setState(() {
//         _fileItems = files.map((file) {
//           print("File: ${file['name']}, Size: ${file['size']}, Path: ${file['path']}"); // Print individual file details
//           return FileItem(
//             name: file['name'],
//             size: file['size'],
//             path: file['path'],
//           );
//         }).toList();
//       });

//     } on PlatformException catch (e) {
//       print("Error fetching files: ${e.message}");
//     }
//   }

//   // Calling the method from OtherFilesUtil to delete a file
//   Future<void> _deleteFile(FileItem fileItem) async {
//     bool? confirm = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete File'),
//           content: Text('Are you sure you want to delete ${fileItem.name}?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // Confirm
//               },
//               child: const Text('Yes'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false); // Cancel
//               },
//               child: const Text('No'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm ?? false) {
//       try {
//         bool success = await OtherFilesUtil.deleteFile(fileItem.path); // Use the utility method
//         if (success) {
//           setState(() {
//             _fileItems.remove(fileItem); // Remove the file from the list
//           });
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('${fileItem.name} deleted successfully'),
//           ));
//           print("File ${fileItem.name} deleted successfully.");
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Failed to delete ${fileItem.name}'),
//           ));
//           print("Failed to delete ${fileItem.name}.");
//         }
//       } on PlatformException catch (e) {
//         print("Error deleting file: ${e.message}");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Other Files'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           width: 100,
//           height: 500,
//           child: ListView.builder(
//             itemCount: _fileItems.length,
//             itemBuilder: (context, index) {
//               FileItem fileItem = _fileItems[index];
//               return ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: Text(fileItem.name),
//                 subtitle: Text('Size: ${fileItem.size} bytes'),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete),
//                   onPressed: () => _deleteFile(fileItem),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
