import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing_cleaner_app/test/settings_page.dart';

import '../../utility/audio_util.dart';
import 'audio_delete_page.dart';
import 'audio_player_page.dart';

class AudiosPage extends StatefulWidget {
  const AudiosPage({super.key});

  @override
  _AudiosPageState createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  bool _isPermissionGranted = false;
  final List<Map<String, Object>> _audios = [];
  List<Map<String, Object>> _selectedAudios = [];
  bool _selectAll = false;
  bool _isAscending = true;
  bool _isGridView = false;
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  late FileUtils fileutils;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // Check and request permission
  Future<void> _checkPermission() async {
    try {
      final bool? hasPermission =
          await platform.invokeMethod('checkStoragePermission');
      if (hasPermission ?? false) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getAudioFiles();
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
      }
    } on PlatformException catch (e) {
      print("Error checking permission: ${e.message}");
    }
  }

  // Request permission
  Future<void> _requestPermission() async {
    try {
      final bool? isPermissionGranted =
          await platform.invokeMethod('requestStoragePermission');
      if (isPermissionGranted ?? false) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getAudioFiles();
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
        _showPermissionDeniedDialog();
      }
    } on PlatformException catch (e) {
      print("Error requesting permission: ${e.message}");
      _showPermissionDeniedDialog();
    }
  }

  // Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
            'You need to grant storage permission to access audio files.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermission();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  // Fetch audio files with pagination
  Future<void> _getAudioFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic>? audios = await platform.invokeMethod(
        'getAudioFiles',
        {'page': _currentPage, 'pageSize': _pageSize},
      );

      if (audios != null && audios.isNotEmpty) {
        setState(() {
          _audios.addAll(audios.map((audio) {
            final audioMap = Map<String, dynamic>.from(audio);

            return {
              'path': audioMap['path'] as String,
              'name': audioMap['name'] as String,
              'size': audioMap['size'] as int,
              'date': audioMap['date'] as int,
            };
          }).toList());
          _currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No audio files found");
      }
    } on PlatformException catch (e) {
      print("Error fetching audios: ${e.message}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete audio method
  Future<void> _deleteAudio(String path) async {
    try {
      final bool? result =
          await platform.invokeMethod('deleteAudio', {'path': path});
      if (result == true) {
        setState(() {
          _audios.removeWhere((audio) => audio['path'] == path);
          _selectedAudios.removeWhere((audio) => audio['path'] == path);
        });
      }
    } on PlatformException catch (e) {
      print("Error deleting audio: ${e.message}");
    }
  }

  // Calculate total size of all audios
  int _getTotalSize() {
    return _audios.fold(0, (sum, audio) => sum + (audio['size'] as int));
  }

  // Calculate total size of selected audios
  int _getSelectedSize() {
    return _selectedAudios.fold(
        0, (sum, audio) => sum + (audio['size'] as int));
  }

  // Handle selection of all audios
  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedAudios = List.from(_audios);
      } else {
        _selectedAudios.clear();
      }
    });
  }

  // Toggle between ListView and GridView
  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  // Toggle sorting order (ascending/descending)
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _audios.sort((a, b) {
        final dateA = a['date'] as int;
        final dateB = b['date'] as int;
        return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  // Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Audios',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text('Are you sure you want to delete the selected audios?',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }

  Future<List<AudioTrack>> _fetchAudioDataWithDuration() async {
    List<AudioTrack> audioTracks = [];
    for (var audio in _audios) {
      String url = audio['path'] as String;
      String title = audio['name'] as String? ?? 'Unknown Title';
      String artist = audio['name'] as String? ??
          'Unknown Artist'; // Assuming 'artist' key exists
      String album = audio['name'] as String? ??
          'Unknown Album'; // Assuming 'album' key exists

      // Fetch the duration asynchronously
      String duration = await FileUtils.getAudioDuration(url);

      // Create an AudioTrack object and add it to the list
      audioTracks.add(AudioTrack(
        url: url,
        title: title,
        artist: artist,
        album: album,
        duration: duration, // Add the fetched duration
      ));
    }
    return audioTracks; // Return the list of audio tracks
  }

  Future<void> _deleteSelectedAudios() async {
    final List<Map<String, Object>> deletedAudios = [];
    final bool? confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      for (final audio in _selectedAudios) {
        deletedAudios.add({
          'name': audio['name'] as String,
          'size': audio['size'] as int,
        });
        await _deleteAudio(audio['path'] as String);
      }
      setState(() {
        _selectedAudios.clear();
      });

      // After deletion, navigate to the DeletedItemsPage and pass the deleted items
      if (deletedAudios.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeletedItemsPage(deletedItems: deletedAudios),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(
                context); // This pops the current screen and navigates back
          },
        ),
        title: Text(
          'Audio',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // if (_selectedAudios.isNotEmpty)
          //   IconButton(
          //     icon: const Icon(Icons.delete),
          //     onPressed: _deleteSelectedAudios,
          //   ),
          // IconButton(
          //   icon: Icon(_selectAll ? Icons.select_all : Icons.select_all),
          //   onPressed: _toggleSelectAll,
          // ),
          IconButton(
            icon: Icon(_isAscending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded),
            onPressed: _toggleSortOrder,
          ),
          IconButton(
            icon: Icon(
                _isGridView ? Icons.list_alt_rounded : Icons.grid_view_rounded),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (!_isPermissionGranted) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Storage permission is required to access audio files.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          if (_audios.isEmpty && _isLoading) {
            return const SafeArea(
                child: Center(child: CircularProgressIndicator()));
          }

          if (_audios.isEmpty && !_isLoading) {
            return const SafeArea(
                child: Center(child: Text("No audio files found.")));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: 2, color: Colors.grey.withOpacity(0.2)),
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 10),
                child: SizedBox(
                  // color: Colors.blue,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          children: [
                            IconButton(
                              color: _selectAll ? Colors.blue : Colors.grey,
                              icon: Icon(
                                _selectAll
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank_rounded,
                              ),
                              onPressed: _toggleSelectAll,
                            ),
                            Text(
                              'Total ${_audios.length} (${FileUtils.formatFileSize(_getTotalSize())})',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 99, 99, 99),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedAudios.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 188, 2, 2),
                                borderRadius: BorderRadius.circular(50)),
                            child: GestureDetector(
                              onTap: _deleteSelectedAudios,
                              child: Row(
                                children: [
                                  Text(
                                    '${_selectedAudios.length} selected (${FileUtils.formatFileSize(_getSelectedSize())})',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Divider(height: 2, color: Colors.grey.withOpacity(0.2)),
              Expanded(
                child: _isGridView
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _audios.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _audios.length) {
                              if (_isLoading) {
                                return const SafeArea(
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              return const SizedBox.shrink();
                            }
                            final audio = _audios[index];
                            final size =
                                FileUtils.formatFileSize(audio['size'] as int);
                            final isSelected = _selectedAudios.contains(audio);

                            return GridTile(
                              child: GestureDetector(
                                onTap: () {
                                  // Modify the navigation to pass the duration
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        // We map the audios and include the duration fetching logic
                                        return SafeArea(
                                          child:
                                              FutureBuilder<List<AudioTrack>>(
                                            future:
                                                _fetchAudioDataWithDuration(), // Call a function that fetches the list of AudioTrack objects with duration
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SafeArea(
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ); // Show loading spinner while data is being fetched
                                              }
                                              if (snapshot.hasError) {
                                                return SafeArea(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'),
                                                ); // Error handling
                                              }
                                              if (snapshot.hasData) {
                                                var audioListWithDurations =
                                                    snapshot.data!;
                                                return CarouselAudioPlayerPage(
                                                  audioList:
                                                      audioListWithDurations,
                                                  initialIndex: index,
                                                );
                                              } else {
                                                return const SafeArea(
                                                  child:
                                                      Text('No Data Available'),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  // Apply a border only if the item is selected
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? const Color.fromARGB(
                                            255, 224, 241, 255)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color.fromARGB(
                                              255, 87, 176, 248)
                                          : Colors
                                              .transparent, // Border color based on selection
                                      width: 1, // Adjust border width as needed
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.295, // 30% of screen width
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3, // 30% of screen width
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 198, 226, 238),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                width: 0.5,
                                                color: const Color.fromARGB(
                                                    255, 224, 224, 224))),

                                        alignment: Alignment
                                            .center, // Ensures the icon is centered inside the container
                                        child: const Icon(
                                          Icons.audiotrack,
                                          size: 30,
                                          color: Color.fromARGB(255, 52, 163,
                                              253), // Optional: Set the icon color to white or any color you prefer
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  size,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: isSelected,
                                                  onChanged: (bool? selected) {
                                                    setState(() {
                                                      if (selected == true) {
                                                        _selectedAudios
                                                            .add(audio);
                                                      } else {
                                                        _selectedAudios
                                                            .remove(audio);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : ListView.builder(
                        itemCount: _audios.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _audios.length) {
                            if (_isLoading) {
                              return const SafeArea(
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final audio = _audios[index];
                          final size =
                              FileUtils.formatFileSize(audio['size'] as int);
                          final date =
                              FileUtils.formatDate(audio['date'] as int);

                          bool isSelected = _selectedAudios.contains(audio);

                          return Container(
                            color: isSelected
                                ? Colors.grey.withOpacity(0.1)
                                : Colors
                                    .transparent, // Background color when selected
                            child: ListTile(
                              onTap: () {
                                // Modify the navigation to pass the duration
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      // We map the audios and include the duration fetching logic
                                      return FutureBuilder<List<AudioTrack>>(
                                        future:
                                            _fetchAudioDataWithDuration(), // Call a function that fetches the list of AudioTrack objects with duration
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SafeArea(
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator())); // Show loading spinner while data is being fetched
                                          }
                                          if (snapshot.hasError) {
                                            return SafeArea(
                                              child: Text(
                                                  'Error: ${snapshot.error}'),
                                            ); // Error handling
                                          }
                                          if (snapshot.hasData) {
                                            var audioListWithDurations =
                                                snapshot.data!;
                                            return CarouselAudioPlayerPage(
                                              audioList: audioListWithDurations,
                                              initialIndex: index,
                                            );
                                          } else {
                                            return const SafeArea(
                                              child: Text(
                                                  'No Data Available'),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                );
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) =>
                                //           const SettingsPage(),
                                //     ));
                              },
                              leading: const Icon(Icons.audiotrack),
                              title: Text(
                                audio['name'] as String,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        date,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromARGB(
                                              255, 88, 88, 88),
                                        ),
                                      ),
                                      const SizedBox(width: 60),
                                      Text(
                                        size,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromARGB(
                                              255, 88, 88, 88),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                activeColor: Colors.blue,
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedAudios.add(audio);
                                    } else {
                                      _selectedAudios.remove(audio);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
