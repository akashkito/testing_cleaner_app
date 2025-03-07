import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoPath;

  const VideoPlayerPage({super.key, required this.videoPath});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  final double _volume = 1.0; // Default volume (full volume)
  final double _rotationAngle = 0.0; // Rotation angle in degrees
  bool _isFullScreen = false; // Full-screen state
  double _currentPosition = 0.0;
  double _duration = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    print("Video path: ${widget.videoPath}");

    File file = File(widget.videoPath);
    if (file.existsSync()) {
      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _duration = _controller.value.duration.inMilliseconds.toDouble();
            });
          }
        }).catchError((e) {
          print("Error initializing video: $e");
        });

      _controller.addListener(() {
        if (!_isDragging) {
          setState(() {
            _currentPosition = _controller.value.position.inMilliseconds.toDouble();
          });
        }
      });
    } else {
      print("Video file not found at path: ${widget.videoPath}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  String _formatDuration(double milliseconds) {
    final Duration duration = Duration(milliseconds: milliseconds.toInt());
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: _isFullScreen
          ? null // Hide app bar in full-screen mode
          : AppBar(
              title: const Text("Video Player"),
              actions: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
      body: GestureDetector(
        onTap: _toggleControls, // Tap to toggle controls visibility (if any)
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Black background behind video
              Container(
                color: Colors.black.withOpacity(0.7),
                child: _controller.value.isInitialized
                    ? Transform.rotate(
                        angle: _rotationAngle * 3.14159 / 180, // Rotate video
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),

              // Play/Pause button in the center
              Positioned(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 40,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),

              // Video Timeline (Progress Bar) with time labels on both ends
              Positioned(
                bottom: 10,
                left: 15,
                right: 15,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Display start time (0:00)
                        Text(
                          _formatDuration(_currentPosition),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            inactiveColor: Colors.white70,
                            activeColor: Colors.cyan,
                            value: _isDragging
                                ? _currentPosition
                                : _controller.value.position.inMilliseconds.toDouble(),
                            min: 0.0,
                            max: _duration,
                            onChangeStart: (_) => setState(() => _isDragging = true),
                            onChanged: (value) {
                              setState(() {
                                _currentPosition = value;
                              });
                            },
                            onChangeEnd: (_) {
                              setState(() {
                                _isDragging = false;
                              });
                              _controller.seekTo(Duration(milliseconds: _currentPosition.toInt()));
                            },
                          ),
                        ),
                        // Display end time (total video time)
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Full-screen exit button (only visible in full-screen mode)
              if (_isFullScreen)
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _toggleFullScreen, // Toggle back to normal screen
                    child: const Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Toggle play/pause state
  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  // Toggle full-screen mode
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); // Hide system UI (status bar and navigation bar)
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Show system UI
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  // Toggle visibility of controls (optional)
  void _toggleControls() {
    setState(() {
      // Toggle control visibility (e.g., Play/Pause, Volume, etc.)
    });
  }
}
