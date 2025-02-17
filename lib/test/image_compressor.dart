// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// class ImageCompressorApp extends StatefulWidget {
//   @override
//   _ImageCompressorAppState createState() => _ImageCompressorAppState();
// }

// class _ImageCompressorAppState extends State<ImageCompressorApp> {
//   File? _image;
//   final picker = ImagePicker();

//   // Function to pick and compress image
//   Future<void> _pickAndCompressImage() async {
//     // Pick an image
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       final imagePath = pickedFile.path;
//       final result = await FlutterImageCompress.compressWithFile(
//         imagePath,
//         minWidth: 600,
//         minHeight: 600,
//         quality: 80,
//       );

//       // Save the compressed image
//       if (result != null) {
//         setState(() {
//           _image = File(pickedFile.path)..writeAsBytesSync(result);
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Image Compressor')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _pickAndCompressImage,
//               child: Text('Pick and Compress Image'),
//             ),
//             if (_image != null)
//               Image.file(_image!), // Display compressed image
//           ],
//         ),
//       ),
//     );
//   }
// }

