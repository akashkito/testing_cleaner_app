// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class VideoPlayerPage extends StatefulWidget {
//   final String videoPath;

//   const VideoPlayerPage({Key? key, required this.videoPath}) : super(key: key);

//   @override
//   _VideoPlayerPageState createState() => _VideoPlayerPageState();
// }

// class _VideoPlayerPageState extends State<VideoPlayerPage> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();

//     print("Video path: ${widget.videoPath}");

//     File file = File(widget.videoPath);
//     if (file.existsSync()) {
//       _controller = VideoPlayerController.file(file)
//         ..initialize().then((_) {
//           if (mounted) {
//             setState(() {});
//           }
//         }).catchError((e) {
//           print("Error initializing video: $e");
//         });
//     } else {
//       print("Video file not found at path: ${widget.videoPath}");
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Video Player"),
//         actions: [
//           IconButton(
//             icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//             onPressed: () {
//               setState(() {
//                 if (_isPlaying) {
//                   _controller.pause();
//                 } else {
//                   _controller.play();
//                 }
//                 _isPlaying = !_isPlaying;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               )
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }


