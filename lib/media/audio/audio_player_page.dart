import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:shimmer/shimmer.dart';
import 'package:testing_cleaner_app/utility/audio_util.dart';

class CarouselAudioPlayerPage extends StatefulWidget {
  final List<AudioTrack> audioList;
  final int initialIndex;

  const CarouselAudioPlayerPage({
    super.key,
    required this.audioList,
    required this.initialIndex,
  });

  @override
  _CarouselAudioPlayerPageState createState() =>
      _CarouselAudioPlayerPageState();
}

class _CarouselAudioPlayerPageState extends State<CarouselAudioPlayerPage> {
  late just_audio.AudioPlayer _audioPlayer;
  late AudioTrack _currentTrack;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _currentPosition = 0.0;
  late Duration _duration;
  late Duration _position;

  @override
  void initState() {
    super.initState();
    _audioPlayer = just_audio.AudioPlayer();
    _currentTrack = widget.audioList[widget.initialIndex];
    _loadAudio();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  // Future<void> _loadAudio() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     // Start playing the audio
  //     await _audioPlayer.setUrl(_currentTrack.url);
  //     _audioPlayer.durationStream.listen((duration) {
  //       setState(() {
  //         _duration = duration!;
  //       });
  //     });

  //     _audioPlayer.positionStream.listen((position) {
  //       setState(() {
  //         _position = position;
  //         _currentPosition = position.inSeconds.toDouble();
  //       });
  //     });

  //     // Once the audio is loaded, start it immediately
  //     await _audioPlayer
  //         .setAudioSource(AudioSource.uri(Uri.parse(_currentTrack.url)));
  //     setState(() {
  //       _isPlaying = true;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     print('Error loading audio: $e');
  //   }
  // }

Future<void> _loadAudio() async {
  setState(() {
    _isLoading = true;
  });
  try {
    await _audioPlayer.setUrl(_currentTrack.url);
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration!;
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
        _currentPosition = position.inSeconds.toDouble();
      });
    });

    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(_currentTrack.url)));
    setState(() {
      _isPlaying = true;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    print('Error loading audio: $e');
    _showErrorDialog('Failed to load audio. Please try again later.');
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}



  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.play();
    } else {
      _audioPlayer.pause();
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTrack.title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: _isLoading
          ? SafeArea(
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        // Icon for the audio track (the audio icon can be a circular shape)
                        Container(
                          height: MediaQuery.of(context).size.width * 1,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Audio track name
                        Container(
                          width: 150,
                          height: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 50),

                        Container(
                          width: 250,
                          height: 4,
                          color: Colors.white,
                        ),

                        const SizedBox(
                          height: 20,
                        ), // Play/Pause button (a circle button for play/pause)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 1,
                      width: MediaQuery.of(context).size.width * 0.9,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 229, 239, 248),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                              width: 0.5,
                              color: const Color.fromARGB(255, 224, 224, 224))),
                      child: const Icon(
                        Icons.audiotrack,
                        size: 100,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      _currentTrack.title,
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(FileUtils.formatDuration(_position)),
                      Expanded(
                        child: Slider(
                          min: 0.0,
                          max: _duration.inSeconds.toDouble(),
                          value: _currentPosition,
                          onChanged: (value) {
                            setState(() {
                              _currentPosition = value;
                            });
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Text(FileUtils.formatDuration(_duration)),
                    ],
                  ),
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 30,
                        ),
                        onPressed: () {
                          int prevIndex =
                              widget.audioList.indexOf(_currentTrack) - 1;
                          if (prevIndex >= 0) {
                            setState(() {
                              _currentTrack = widget.audioList[prevIndex];
                            });
                            _loadAudio();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying
                              ? Icons.play_circle_fill
                              : Icons.pause_circle_filled,
                          size: 60,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          size: 30,
                        ),
                        onPressed: () {
                          int nextIndex =
                              widget.audioList.indexOf(_currentTrack) + 1;
                          if (nextIndex < widget.audioList.length) {
                            setState(() {
                              _currentTrack = widget.audioList[nextIndex];
                            });
                            _loadAudio();
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}

class AudioTrack {
  final String url;
  final String title;
  final String artist;
  final String album;
  final String duration;

  AudioTrack({
    required this.url,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
  });
}
