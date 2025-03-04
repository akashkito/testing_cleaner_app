import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    print(video['thumbnail'] as String);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Optional: Padding to space out content
      leading: 
      
      (video['thumbnail'] as String).isNotEmpty
          ? Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6)
            ),
            child: Image.file(
                File(video['thumbnail'] as String),
                width: 60,
                height: 50,
                fit: BoxFit.cover,
                
              ),
          )
          : 
          
          const Icon(Icons.video_library),
      title: Text(
        video['name'] as String,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: GoogleFonts.montserrat(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      // subtitle: Text(
      //   '${formatFileSize(video['size'] as int)} - ${formatDate(video['date'] as int)}',
      // ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formatDate(video['date'] as int),
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 88, 88, 88),
                ),
              ),
              const SizedBox(width: 60),
              Text(
                formatFileSize(video['size'] as int),
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 88, 88, 88),
                ),
              ),
            ],
          ),
        ],
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
    // final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }
}

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:intl/intl.dart';

// class VideoItem extends StatelessWidget {
//   final Map<String, Object> video;
//   final bool isSelected;
//   final ValueChanged<bool?> onCheckboxChanged;
//   final VoidCallback onTap;

//   const VideoItem({
//     required this.video,
//     required this.isSelected,
//     required this.onCheckboxChanged,
//     required this.onTap,
//     super.key,
//   });

//   Future<Image> _loadImage(String imagePath) async {
//     // Load the image from the file
//     final File imageFile = File(imagePath);
//     final List<int> imageBytes = await imageFile.readAsBytes();

//     // Decode the image using the image package
//     img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

//     // Resize the image (resize to a smaller thumbnail, e.g., 100x100)
//     img.Image resizedImage = img.copyResize(decodedImage!, width: 100, height: 100);

//     // Convert back to Image widget
//     return Image.memory(Uint8List.fromList(img.encodeJpg(resizedImage)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Image>(
//       future: _loadImage(video['thumbnail'] as String),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator(); // Placeholder while loading
//         } else if (snapshot.hasError) {
//           return const Icon(Icons.video_library); // Fallback if an error occurs
//         } else {
//           return ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Optional: Padding to space out content
//             leading: snapshot.data!,
//             title: Text(video['name'] as String),
//             subtitle: Text(
//               '${formatFileSize(video['size'] as int)} - ${formatDate(video['date'] as int)}',
//             ),
//             trailing: Checkbox(
//               value: isSelected,
//               onChanged: onCheckboxChanged,
//             ),
//             onTap: onTap,
//           );
//         }
//       },
//     );
//   }

//   String formatFileSize(int bytes) {
//     if (bytes < 1024) {
//       return '$bytes B';
//     } else if (bytes < 1024 * 1024) {
//       return '${(bytes / 1024).toStringAsFixed(2)} KB';
//     } else if (bytes < 1024 * 1024 * 1024) {
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
//     } else {
//       return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
//     }
//   }

//   String formatDate(int timestamp) {
//     final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     final DateFormat formatter = DateFormat('dd-MM-yyyy');
//     return formatter.format(date);
//   }
// }



// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';

// class VideoListScreen extends StatefulWidget {
//   @override
//   _VideoListScreenState createState() => _VideoListScreenState();
// }

// class _VideoListScreenState extends State<VideoListScreen> {
//   bool _isLoading = true;
//   List<Map<String, Object>> videos = [];

//   @override
//   void initState() {
//     super.initState();
//     // Simulate loading video data (replace with actual data loading)
//     loadVideoData();
//   }

//   // Simulate loading video data (e.g., large list of video info)
//   Future<void> loadVideoData() async {
//     await Future.delayed(Duration(seconds: 3)); // Simulate a delay for data loading
//     setState(() {
//       // Example of video data (replace with real video list)
//       videos = List.generate(20, (index) {
//         return {
//           'thumbnail': '/path/to/video$index/thumbnail.jpg',
//           'name': 'Video $index',
//           'size': 1024 * 500,
//           'date': DateTime.now().millisecondsSinceEpoch ~/ 1000,
//         };
//       });
//       _isLoading = false; // Finished loading
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Videos List'),
//       ),
//       body: _isLoading
//           ? Center(child: const CircularProgressIndicator()) // Global progress indicator
//           : ListView.builder(
//               itemCount: videos.length,
//               itemBuilder: (context, index) {
//                 return VideoItem(
//                   video: videos[index],
//                   isSelected: false,
//                   onCheckboxChanged: (bool? value) {},
//                   onTap: () {},
//                 );
//               },
//             ),
//     );
//   }
// }

// class VideoItem extends StatelessWidget {
//   final Map<String, Object> video;
//   final bool isSelected;
//   final ValueChanged<bool?> onCheckboxChanged;
//   final VoidCallback onTap;

//   const VideoItem({
//     required this.video,
//     required this.isSelected,
//     required this.onCheckboxChanged,
//     required this.onTap,
//     super.key,
//   });

//   // Function to load and resize image asynchronously
//   Future<Image> _loadImage(String imagePath) async {
//     final File imageFile = File(imagePath);
//     final List<int> imageBytes = await imageFile.readAsBytes();

//     // Decode the image using the image package
//     img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

//     // Resize the image to a smaller size (thumbnail)
//     img.Image resizedImage = img.copyResize(decodedImage!, width: 100, height: 100);

//     // Convert back to Image widget
//     return Image.memory(Uint8List.fromList(img.encodeJpg(resizedImage)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Image>(
//       future: _loadImage(video['thumbnail'] as String),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//               leading: Container(
//                 width: 50.0,
//                 height: 50.0,
//                 color: Colors.grey, // Placeholder for the image
//               ),
//               title: Container(
//                 height: 16.0,
//                 color: Colors.grey,
//                 margin: const EdgeInsets.symmetric(vertical: 5.0),
//               ),
//               subtitle: Container(
//                 height: 14.0,
//                 color: Colors.grey,
//                 margin: const EdgeInsets.symmetric(vertical: 5.0),
//               ),
//               trailing: Checkbox(
//                 value: isSelected,
//                 onChanged: onCheckboxChanged,
//               ),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return const Icon(Icons.video_library); // Fallback if an error occurs
//         } else {
//           return ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//             leading: snapshot.data!,
//             title: Text(video['name'] as String),
//             subtitle: Text(
//               '${formatFileSize(video['size'] as int)} - ${formatDate(video['date'] as int)}',
//             ),
//             trailing: Checkbox(
//               value: isSelected,
//               onChanged: onCheckboxChanged,
//             ),
//             onTap: onTap,
//           );
//         }
//       },
//     );
//   }

//   // Format the file size into a readable format
//   String formatFileSize(int bytes) {
//     if (bytes < 1024) {
//       return '$bytes B';
//     } else if (bytes < 1024 * 1024) {
//       return '${(bytes / 1024).toStringAsFixed(2)} KB';
//     } else if (bytes < 1024 * 1024 * 1024) {
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
//     } else {
//       return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
//     }
//   }

//   // Format date to readable string
//   String formatDate(int timestamp) {
//     final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     final DateFormat formatter = DateFormat('dd-MM-yyyy');
//     return formatter.format(date);
//   }
// }