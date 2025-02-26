// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'video_item.dart'; // Import the separate widget

// class VideosPage extends StatefulWidget {
//   const VideosPage({super.key});

//   @override
//   _VideosPageState createState() => _VideosPageState();
// }

// class _VideosPageState extends State<VideosPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   bool _isPermissionGranted = false;
//   List<Map<String, Object>> _videos = [];
//   List<Map<String, Object>> _selectedVideos = [];
//   bool _selectAll = false;
//   bool _isAscending = true;
//   bool _isGridView = false;
//   bool _isLoading = false;
//   int _currentPage = 0;
//   final int _pageSize = 20;
//   ScrollController _scrollController = ScrollController();
//   bool _isProgressVisible = true; // To show progress bar initially
//   double _progress = 0.0; // Track progress (0 to 100)

//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     super.dispose();
//   }

//   Future<void> _checkPermission() async {
//     try {
//       final bool? hasPermission =
//           await platform.invokeMethod('checkStoragePermission');
//       if (hasPermission ?? false) {
//         setState(() {
//           _isPermissionGranted = true;
//         });
//         _getVideoFiles();
//       } else {
//         setState(() {
//           _isPermissionGranted = false;
//         });
//       }
//     } on PlatformException catch (e) {
//       print("Error checking permission: ${e.message}");
//     }
//   }

//   // Future<void> _getVideoFiles() async {
//   //   if (_isLoading) return;

//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     final List<dynamic>? videos = await platform.invokeMethod(
//   //       'getVideoFiles',
//   //       {'page': _currentPage, 'pageSize': _pageSize},
//   //     );

//   //     if (videos != null && videos.isNotEmpty) {
//   //       int totalVideos = videos.length;
//   //       int videosFetched = 0;

//   //       // Update progress as we load videos
//   //       for (var video in videos) {
//   //         final videoMap = Map<String, dynamic>.from(video);
//   //         final videoPath = videoMap['path'] as String;
//   //         final videoExists = _videos
//   //             .any((existingVideo) => existingVideo['path'] == videoPath);

//   //         if (!videoExists) {
//   //           _videos.add({
//   //             'path': videoPath,
//   //             'name': videoMap['name'] as String,
//   //             'size': videoMap['size'] as int,
//   //             'date': videoMap['date'] as int,
//   //             'thumbnail': videoMap['thumbnail'] as String,
//   //           });
//   //         }

//   //         // Update progress
//   //         videosFetched++;
//   //         double progress = (videosFetched / totalVideos) * 100;
//   //         setState(() {
//   //           _progress = progress;
//   //         });
//   //       }

//   //       setState(() {
//   //         _currentPage++;
//   //         _isLoading = false;
//   //         _isProgressVisible = false; // Hide progress bar once videos are loaded
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });
//   //       print("No video files found");
//   //     }
//   //   } on PlatformException catch (e) {
//   //     print("Error fetching videos: ${e.message}");
//   //     setState(() {
//   //       _isLoading = false;
//   //       _isProgressVisible = false; // Hide progress bar on error as well
//   //     });
//   //   }
//   // }

// Future<void> _getVideoFiles() async {
//   if (_isLoading) return;

//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     final List<dynamic>? videos = await platform.invokeMethod(
//       'getVideoFiles',
//       {'page': _currentPage, 'pageSize': _pageSize},
//     );

//     if (videos != null && videos.isNotEmpty) {
//       List<Map<String, Object>> newVideos = [];
//       // int totalVideos = videos.length;

//       for (var video in videos) {
//         final videoMap = Map<String, dynamic>.from(video);
//         final videoPath = videoMap['path'] as String;
//         final videoExists = _videos
//             .any((existingVideo) => existingVideo['path'] == videoPath);

//         if (!videoExists) {
//           newVideos.add({
//             'path': videoPath,
//             'name': videoMap['name'] as String,
//             'size': videoMap['size'] as int,
//             'date': videoMap['date'] as int,
//             'thumbnail': videoMap['thumbnail'] as String,
//           });
//         }
//       }

//       setState(() {
//         _videos.addAll(newVideos);
//         _currentPage++;
//         _isLoading = false;
//         _isProgressVisible = false; // Hide progress bar once videos are loaded
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//         _isProgressVisible = false;
//       });
//     }
//   } on PlatformException catch (e) {
//     print("Error fetching videos: ${e.message}");
//     setState(() {
//       _isLoading = false;
//       _isProgressVisible = false;
//     });
//   }
// }


//   String formatDate(int timestamp) {
//     final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
//     return formatter.format(date);
//   }

//   Future<void> _deleteSelectedVideos() async {
//     if (_selectedVideos.isEmpty) return;

//     bool? shouldDelete = await _showDeleteConfirmationDialog();

//     if (shouldDelete == true) {
//       setState(() {
//         _isLoading = true;
//       });

//       for (var video in _selectedVideos) {
//         try {
//           final String videoPath = video['path'] as String;

//           final bool? result =
//               await platform.invokeMethod('deleteVideo', {'path': videoPath});
//           if (result == true) {
//             setState(() {
//               _videos.removeWhere((v) => v['path'] == videoPath);
//               _selectedVideos.clear(); // Clear selected videos after deletion
//               _selectAll = false; // Reset select all checkbox
//             });
//           }
//         } on PlatformException catch (e) {
//           print("Error deleting video: ${e.message}");
//         }
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<bool?> _showDeleteConfirmationDialog() async {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Videos'),
//         content:
//             const Text('Are you sure you want to delete the selected videos?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
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

//   void _toggleSelectAll() {
//     setState(() {
//       _selectAll = !_selectAll;
//       if (_selectAll) {
//         _selectedVideos = List.from(_videos);
//       } else {
//         _selectedVideos.clear();
//       }
//     });
//   }

//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }

//   void _toggleSortOrder() {
//     setState(() {
//       _isAscending = !_isAscending;
//       _videos.sort((a, b) {
//         final dateA = a['date'] as int;
//         final dateB = b['date'] as int;
//         return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
//       });
//     });
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent &&
//         !_isLoading) {
//       _getVideoFiles();
//     }
//   }

//   Future<void> _requestPermission() async {
//     try {
//       final bool? isPermissionGranted =
//           await platform.invokeMethod('requestStoragePermission');
//       if (isPermissionGranted ?? false) {
//         setState(() {
//           _isPermissionGranted = true;
//         });
//         _getVideoFiles();
//       } else {
//         setState(() {
//           _isPermissionGranted = false;
//         });
//         _showPermissionDeniedDialog();
//       }
//     } on PlatformException catch (e) {
//       debugPrint("Error requesting permission: ${e.message}");
//       _showPermissionDeniedDialog();
//     }
//   }

//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Permission Denied'),
//         content: const Text(
//             'You need to grant storage permission to access videos.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _requestPermission();
//             },
//             child: const Text('Grant Permission'),
//           ),
//         ],
//       ),
//     );
//   }

//   String calculateTotalSize() {
//     int totalSize = 0;
//     for (var video in _selectedVideos) {
//       totalSize += video['size'] as int;
//     }
//     return formatFileSize(totalSize);
//   }

//   String calculateTotalSizeOfAllVideos() {
//     int totalSize = 0;
//     for (var video in _videos) {
//       totalSize += video['size'] as int;
//     }
//     return formatFileSize(totalSize);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Videos'),
//         actions: [
//           if (_selectedVideos.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: _deleteSelectedVideos,
//             ),
//           IconButton(
//             icon: Icon(_selectAll ? Icons.select_all : Icons.select_all),
//             onPressed: _toggleSelectAll,
//           ),
//           IconButton(
//             icon:
//                 Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
//             onPressed: _toggleSortOrder,
//           ),
//           IconButton(
//             icon: Icon(_isGridView ? Icons.list : Icons.grid_on),
//             onPressed: _toggleView,
//           ),
//         ],
//       ),
//       body: Builder(
//         builder: (context) {
//           if (!_isPermissionGranted) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                       'Storage permission is required to access videos.'),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _requestPermission,
//                     child: const Text('Grant Permission'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (_isProgressVisible) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(
//                     value: _progress / 100,
//                   ),
//                   const SizedBox(height: 20),
//                   Text('${_progress.toStringAsFixed(0)}%'),
//                 ],
//               ),
//             );
//           }

//           if (_videos.isEmpty && !_isLoading) {
//             return const Center(child: Text("No videos found."));
//           }

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 20.0),
//                 child: Text(
//                   '${_videos.length} Total',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 10.0, horizontal: 20.0),
//                 child: Text(
//                   'Total Size: ${calculateTotalSizeOfAllVideos()}',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ),
//               if (_selectedVideos.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 10.0, horizontal: 20.0),
//                   child: Text(
//                     'Selected: ${_selectedVideos.length} videos, Total Size: ${calculateTotalSize()}',
//                   ),
//                 ),
//               Expanded(
//                 child: _isGridView
//                     ? GridView.builder(
//                         controller: _scrollController,
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                         ),
//                         itemCount: _videos.length,
//                         itemBuilder: (context, index) {
//                           final video = _videos[index];
//                           final isSelected = _selectedVideos
//                               .contains(video); // Check if the video is selected

//                           return GestureDetector(
//                             child: GridTile(
//                               child: Column(
//                                 children: [
//                                   Expanded(
//                                     child: video['thumbnail'] != null &&
//                                             (video['thumbnail'] as String)
//                                                 .isNotEmpty
//                                         ? Image.file(
//                                             File(video['thumbnail'] as String),
//                                             fit: BoxFit.cover,
//                                           )
//                                         : const Icon(Icons.video_library,
//                                             size: 50),
//                                   ),
//                                   Text(formatFileSize(video['size'] as int)),
//                                   Checkbox(
//                                     value: isSelected, // Track if the video is selected
//                                     onChanged: (bool? selected) {
//                                       setState(() {
//                                         if (selected == true) {
//                                           _selectedVideos.add(video); // Add video to selection
//                                         } else {
//                                           _selectedVideos.remove(video); // Remove video from selection
//                                         }
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             onTap: () {
//                               // Handle tap if needed (e.g., navigate to a detailed view or player)
//                             },
//                           );
//                         },
//                       )
//                     : ListView.builder(
//                         controller: _scrollController,
//                         itemCount: _videos.length,
//                         itemBuilder: (context, index) {
//                           final video = _videos[index];
//                           final isSelected = _selectedVideos.contains(video);

//                           return VideoItem(
//                             video: video,
//                             isSelected: isSelected,
//                             onCheckboxChanged: (bool? selected) {
//                               setState(() {
//                                 if (selected == true) {
//                                   _selectedVideos.add(video);
//                                 } else {
//                                   _selectedVideos.remove(video);
//                                 }
//                               });
//                             },
//                             onTap: () {
//                               // Navigate to video player page
//                             },
//                           );
//                         },
//                       ),
//               ),
//               if (_isLoading)
//                 const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }


// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'video_item.dart'; // Import the separate widget

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
          final videoPath = videoMap['path'] as String;
          final videoExists = _videos.any((existingVideo) => existingVideo['path'] == videoPath);

          if (!videoExists) {
            newVideos.add({
              'path': videoPath,
              'name': videoMap['name'] as String,
              'size': videoMap['size'] as int,
              'date': videoMap['date'] as int,
              'thumbnail': videoMap['thumbnail'] as String,
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

  String formatDate(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
    return formatter.format(date);
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
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
        title: const Text('Videos'),
        actions: [
          if (_selectedVideos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedVideos,
            ),
          IconButton(
            icon: Icon(_selectAll ? Icons.select_all : Icons.select_all),
            onPressed: _toggleSelectAll,
          ),
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: _toggleSortOrder,
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_on),
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
                  const Text('Storage permission is required to access videos.'),
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
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '${_videos.length} Total',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Text(
                  'Total Size: ${calculateTotalSizeOfAllVideos()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_selectedVideos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    'Selected: ${_selectedVideos.length} videos, Total Size: ${calculateTotalSize()}',
                  ),
                ),
              Expanded(
                child: _isGridView
                    ? GridView.builder(
                        controller: _scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          final video = _videos[index];
                          final isSelected = _selectedVideos
                              .contains(video); // Check if the video is selected

                          return GestureDetector(
                            child: GridTile(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: video['thumbnail'] != null &&
                                            (video['thumbnail'] as String)
                                                .isNotEmpty
                                        ? Image.file(
                                            File(video['thumbnail'] as String),
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.video_library,
                                            size: 50),
                                  ),
                                  Text(formatFileSize(video['size'] as int)),
                                  Checkbox(
                                    value: isSelected, // Track if the video is selected
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedVideos.add(video); // Add video to selection
                                        } else {
                                          _selectedVideos.remove(video); // Remove video from selection
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              // Handle tap if needed (e.g., navigate to a detailed view or player)
                            },
                          );
                        },
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
                              // Navigate to video player page
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

