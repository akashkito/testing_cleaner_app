import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utility/audio_util.dart';
import 'video_item.dart';
import 'video_player_page.dart'; // Import the separate widget

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  bool _isPermissionGranted = false;
  final List<Map<String, Object>> _videos = [];
  List<Map<String, Object>> _selectedVideos = [];
  bool _selectAll = false;
  bool _isAscending = true;
  bool _isGridView = false;
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 20; // Adjust page size as needed
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _checkPermission() async {
    try {
      final bool? hasPermission =
          await platform.invokeMethod('checkStoragePermission');
      if (hasPermission ?? false) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getVideoFiles(); // Fetch only first 20 videos
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
      }
    } on PlatformException catch (e) {
      debugPrint("Error checking permission: ${e.message}");
    }
  }

  Future<void> _getVideoFiles() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic>? videos = await platform.invokeMethod(
        'getVideoFiles',
        {'page': _currentPage, 'pageSize': _pageSize},
      );

      if (videos != null && videos.isNotEmpty) {
        List<Map<String, Object>> newVideos = [];

        for (var video in videos) {
          final videoMap = Map<String, dynamic>.from(video);
          final videoPath = videoMap['path'] as String?;

          // Check if path is null before using it
          if (videoPath == null) {
            continue; // Skip the video if path is null
          }

          final videoExists = _videos
              .any((existingVideo) => existingVideo['path'] == videoPath);

          if (!videoExists) {
            newVideos.add({
              'path': videoPath,
              'name': videoMap['name'] as String,
              'size': videoMap['size'] as int,
              'date': videoMap['date'] as int,
              // 'thumbnail': videoMap['thumbnail'] as String,
            });
          }
        }

        setState(() {
          _videos.addAll(newVideos);
          _currentPage++; // Increment current page for future fetching
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      print("Error fetching videos: ${e.message}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSelectedVideos() async {
    if (_selectedVideos.isEmpty) return;

    bool? shouldDelete = await _showDeleteConfirmationDialog();

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });

      for (var video in _selectedVideos) {
        try {
          final String videoPath = video['path'] as String;

          final bool? result =
              await platform.invokeMethod('deleteVideo', {'path': videoPath});
          if (result == true) {
            setState(() {
              _videos.removeWhere((v) => v['path'] == videoPath);
              _selectedVideos.clear(); // Clear selected videos after deletion
              _selectAll = false; // Reset select all checkbox
            });
          }
        } on PlatformException catch (e) {
          debugPrint("Error deleting video: ${e.message}");
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Videos'),
        content:
            const Text('Are you sure you want to delete the selected videos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedVideos = List.from(_videos);
      } else {
        _selectedVideos.clear();
      }
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _videos.sort((a, b) {
        final dateA = a['date'] as int;
        final dateB = b['date'] as int;
        return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _getVideoFiles();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
            'You need to grant storage permission to access videos.'),
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

  Future<void> _requestPermission() async {
    try {
      final bool? isPermissionGranted =
          await platform.invokeMethod('requestStoragePermission');
      if (isPermissionGranted ?? false) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getVideoFiles(); // Fetch only first 20 videos
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
        _showPermissionDeniedDialog();
      }
    } on PlatformException catch (e) {
      debugPrint("Error requesting permission: ${e.message}");
      _showPermissionDeniedDialog();
    }
  }

  String calculateTotalSizeOfAllVideos() {
    int totalSize = 0;
    for (var video in _videos) {
      totalSize += video['size'] as int;
    }
    return formatFileSize(totalSize);
  }

  String calculateTotalSize() {
    int totalSize = 0;
    for (var video in _selectedVideos) {
      totalSize += video['size'] as int;
    }
    return formatFileSize(totalSize);
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
          'Videos',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // if (_selectedVideos.isNotEmpty)
          //   IconButton(
          //     icon: const Icon(Icons.delete),
          //     onPressed: _deleteSelectedVideos,
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
                      'Storage permission is required to access videos.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          if (_videos.isEmpty && !_isLoading) {
            return const Center(child: Text("No videos found."));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(left: 20.0),
              //   child: Text(
              //     '${_videos.length} Total',
              //     style: Theme.of(context).textTheme.titleMedium,
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //       vertical: 10.0, horizontal: 20.0),
              //   child: Text(
              //     'Total Size: ${calculateTotalSizeOfAllVideos()}',
              //     style: Theme.of(context).textTheme.titleMedium,
              //   ),
              // ),
              // if (_selectedVideos.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(
              //         vertical: 10.0, horizontal: 20.0),
              //     child: Text(
              //       'Selected: ${_selectedVideos.length} videos, Total Size: ${calculateTotalSize()}',
              //     ),
              //   ),
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
                              'Total ${_videos.length} (${calculateTotalSizeOfAllVideos()})',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 99, 99, 99),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedVideos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 188, 2, 2),
                                borderRadius: BorderRadius.circular(50)),
                            child: GestureDetector(
                              onTap: _deleteSelectedVideos,
                              child: Row(
                                children: [
                                  Text(
                                    '${_selectedVideos.length} selected (${calculateTotalSize()})',
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
              Expanded(
                child: _isGridView
                    ? Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8
                          ),
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            final isSelected = _selectedVideos.contains(video);
                      
                            return GestureDetector(
                                child: GridTile(
                              child: GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.lightBlueAccent.withOpacity(0.3)
                                        : Colors
                                            .transparent, // Light blue background when selected
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors
                                              .transparent, // Blue border when selected
                                      width: 0.5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        8), // Optional: Adds rounded corners
                                  ),
                                  child: Column(
                                    children: [
                                      // Expanded(
                                      //   child: 
                                      //   // video['thumbnail'] != null &&
                                      //   //         (video['thumbnail'] as String)
                                      //   //             .isNotEmpty
                                      //   //     ? Image.file(
                                      //   //         File(
                                      //   //             video['thumbnail'] as String),
                                      //   //         fit: BoxFit.cover,
                                      //   //       )
                                      //   //     : 
                                            
                                      //       const Icon(Icons.video_library,
                                      //           size: 40),
                                      // ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.22, // 30% of screen width
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
                                          Icons.video_library,
                                          size: 30,
                                          color: Color.fromARGB(255, 52, 163,
                                              253), // Optional: Set the icon color to white or any color you prefer
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formatFileSize(
                                                  video['size'] as int),
                                              overflow: TextOverflow.ellipsis,
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
                                                    _selectedVideos.add(video);
                                                  } else {
                                                    _selectedVideos.remove(video);
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  // Navigate to the VideoPlayerPage when a video is tapped
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerPage(
                                        videoPath: video['path'] as String,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ));
                          }),
                    )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          final video = _videos[index];
                          final isSelected = _selectedVideos.contains(video);

                          return VideoItem(
                            video: video,
                            isSelected: isSelected,
                            onCheckboxChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedVideos.add(video);
                                } else {
                                  _selectedVideos.remove(video);
                                }
                              });
                            },
                            onTap: () {
                              // Navigate to the VideoPlayerPage when a video is tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerPage(
                                    videoPath: video['path'] as String,
                                  ),
                                ),
                              );
                            },
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
