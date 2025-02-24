// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';

// class AudioPlayerPage extends StatefulWidget {
//   final String audioPath;

//   const AudioPlayerPage({super.key, required this.audioPath});

//   @override
//   _AudioPlayerPageState createState() => _AudioPlayerPageState();
// }

// class _AudioPlayerPageState extends State<AudioPlayerPage> {
//   late AudioPlayer _audioPlayer;
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _audioPlayer = AudioPlayer();

//     _audioPlayer.onDurationChanged.listen((duration) {
//       setState(() {
//         _duration = duration;
//       });
//     });

//     _audioPlayer.onPositionChanged.listen((position) {
//       setState(() {
//         _position = position;
//       });
//     });

//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       setState(() {
//         _isPlaying = state == PlayerState.playing;
//       });
//     });

//     _audioPlayer.setSourceUrl(widget.audioPath); // Load the local audio file
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _audioPlayer.dispose();
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       _audioPlayer.pause();
//     } else {
//       _audioPlayer.resume();
//     }
//   }

//   void _seekTo(Duration position) {
//     _audioPlayer.seek(position);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio Player'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Playing: ${widget.audioPath.split('/').last}', // Display audio file name
//             // style: Theme.of(context).textTheme.headline6,
//           ),
//           const SizedBox(height: 20),
//           IconButton(
//             icon: Icon(
//               _isPlaying ? Icons.pause : Icons.play_arrow,
//               size: 50,
//             ),
//             onPressed: _togglePlayPause,
//           ),
//           const SizedBox(height: 20),
//           Slider(
//             min: 0.0,
//             max: _duration.inSeconds.toDouble(),
//             value: _position.inSeconds.toDouble(),
//             onChanged: (value) {
//               _seekTo(Duration(seconds: value.toInt()));
//             },
//           ),
//           Text(
//             '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
//             // style: Theme.of(context).textTheme.bodyText1,
//           ),
//         ],
//       ),
//     );
//   }
// }
