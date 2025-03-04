import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../utility/audio_util.dart';
import 'view_image.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  bool _isPermissionGranted = false;
  List<Map<String, Object>> _photos = [];
  List<Map<String, Object>> _selectedPhotos = [];
  bool _selectAll = false;
  bool _isAscending = true;
  bool _isGridView = false; // New variable to toggle between grid and list view
  bool _isLoading = false; // Loader state
  int _currentPage = 0; // Page number for lazy loading
  final int _pageSize = 10; // Number of items to load per page

  @override
  void initState() {
    super.initState();
    _checkPermission(); // Check permission on initialization
  }

  // Method to open the 'All Files Access' settings page
  Future<void> _openAllFilesAccessSettings() async {
    try {
      await platform.invokeMethod('openAllFilesAccessSettings');
    } on PlatformException catch (e) {
      print("Failed to open settings: ${e.message}");
    }
  }

  // Delete the selected photos with confirmation dialog
  Future<void> _deleteSelectedPhotos() async {
    bool? shouldDelete = await _showDeleteConfirmationDialog();

    if (shouldDelete == true) {
      for (var photo in _selectedPhotos) {
        try {
          final bool? result = await platform
              .invokeMethod('deletePhoto', {'path': photo['path']});
          if (result == true) {
            setState(() {
              _photos.remove(photo); // Remove the photo from the list
            });
          } else {
            print("Failed to delete photo: ${photo['name']}");
          }
        } on PlatformException catch (e) {
          print("Error deleting photo: ${e.message}");
        }
      }

      // Clear the selected photos after deletion
      setState(() {
        _selectedPhotos.clear();
        _selectAll = false; // Unselect 'select all' if any deletion occurred
      });

      // Refresh total count and size after deletion
      _refreshTotalCountAndSize();
    }
  }

  // Show confirmation dialog to delete photos
  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photos'),
        content:
            const Text('Are you sure you want to delete the selected photos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Refresh total count and size after deletion
  void _refreshTotalCountAndSize() {
    final totalSize =
        _photos.fold(0, (sum, photo) => sum + (photo['size'] as int? ?? 0));
    final totalSizeFormatted = formatFileSize(totalSize);
    final totalCount = _photos.length;

    setState(() {
      // Update UI with the new total count and size
    });

    // Display updated info if necessary
    print("Updated total count: $totalCount, Total size: $totalSizeFormatted");
  }

  Future<void> _requestPermission() async {
    try {
      final bool? isPermissionGranted =
          await platform.invokeMethod('requestStoragePermission');
      if (isPermissionGranted ?? false) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getPhotoFiles(); // Fetch photos after permission is granted
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
        _showPermissionDeniedDialog(); // Show dialog if permission is still denied
      }
    } on PlatformException catch (e) {
      debugPrint("Error requesting permission: ${e.message}");
      _showPermissionDeniedDialog();
    }
  }

// Check for storage permission
  Future<void> _checkPermission() async {
    try {
      final bool? hasPermission =
          await platform.invokeMethod('checkStoragePermission');
      if (hasPermission ?? false) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getPhotoFiles(); // Start loading photos immediately
      } else {
        setState(() {
          _isPermissionGranted = false;
        });
      }
    } on PlatformException catch (e) {
      debugPrint("Error while checking permission: ${e.message}");
      _showPermissionDeniedDialog();
    }
  }

  // Fetch the photo files after permission is granted
  Future<void> _getPhotoFiles() async {
    setState(() {
      _isLoading = true; // Show loader while fetching
    });

    try {
      final List<dynamic>? photos = await platform.invokeMethod(
          'getPhotoFiles', {'page': _currentPage, 'pageSize': _pageSize});
      if (photos != null && photos.isNotEmpty) {
        setState(() {
          _photos.addAll(photos.map((photo) {
            final photoMap = Map<String, dynamic>.from(photo);
            return {
              'path': photoMap['path'] as String,
              'name': photoMap['name'] as String,
              'size': photoMap['size'] as int,
              'date': photoMap['date'] as int,
            };
          }).toList());
          _currentPage++; // Increment page number for next lazy loading
          _isLoading = false; // Hide loader after loading
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No photo files found");
      }
    } on PlatformException catch (e) {
      print("Error fetching photos: ${e.message}");
      setState(() {
        _isLoading = false;
        _photos = [];
      });
    }
  }

  // Format the file size from bytes to a human-readable format
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

  // Format the date into a readable string
  String formatDate(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat formatter =
        // DateFormat('yyyy-MM-dd hh:mm a'); // 12-hour format
        DateFormat('dd-MM-yyyy'); // 12-hour format
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(date);

    if (diff.inDays == 1) {
      return 'Yesterday at ${formatter.format(date)}';
    } else if (diff.inDays >= 2 && diff.inDays <= 7) {
      return DateFormat('EEEE').format(date); // Weekday name (Monday, etc.)
    } else {
      return DateFormat('dd-MM-yyyy')
          .format(date); // Full date and time
    }
  }

  // Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
            'You need to grant storage permission to access photos.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _openAllFilesAccessSettings();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Handle the selection of all photos
  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedPhotos = List.from(_photos); // Select all
      } else {
        _selectedPhotos.clear(); // Deselect all
      }
    });
  }

  // Toggle between ListView and GridView
  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  // Sort the photos based on the date (ascending or descending)
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _photos.sort((a, b) {
        final dateA = a['date'] as int;
        final dateB = b['date'] as int;
        return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  // Calculate the total number of selected photos
  int _getSelectedPhotosCount() {
    return _selectedPhotos.length;
  }

  // Calculate the total size of selected photos
  int _getSelectedPhotosTotalSize() {
    return _selectedPhotos.fold(
        0, (sum, photo) => sum + (photo['size'] as int? ?? 0));
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
          'Photos',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // if (_selectedPhotos.isNotEmpty)
          //   IconButton(
          //     icon: const Icon(Icons.delete),
          //     onPressed: _deleteSelectedPhotos,
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
                      'Storage permission is required to access photos.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestPermission, // Request permission
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          // Show a loader when photos are still being fetched
          if (_photos.isEmpty && _isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If there are no photos and no loading state, show a placeholder
          if (_photos.isEmpty && !_isLoading) {
            return const Center(
              child: Text("No photos found."),
            );
          }

          // Total size and count of images
          final totalSize = _photos.fold(
              0, (sum, photo) => sum + (photo['size'] as int? ?? 0));
          final totalSizeFormatted = formatFileSize(totalSize);
          final totalCount = _photos.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(left: 20.0),
              //   child: Text(
              //     '$totalCount Total ($totalSizeFormatted)',
              //     style: Theme.of(context).textTheme.titleMedium,
              //   ),
              // ),
              // // Show the count and size of selected photos if any are selected
              // if (_selectedPhotos.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Text(
              //       'Selected images: ${_getSelectedPhotosCount()} | Total size of selected: ${formatFileSize(_getSelectedPhotosTotalSize())}',
              //       style: Theme.of(context).textTheme.bodyMedium,
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
                              'Total $totalCount ($totalSizeFormatted)',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 99, 99, 99),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedPhotos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 188, 2, 2),
                                borderRadius: BorderRadius.circular(50)),
                            child: GestureDetector(
                              onTap: _deleteSelectedPhotos,
                              child: Row(
                                children: [
                                  Text(
                                    '${_selectedPhotos.length} selected (${FileUtils.formatFileSize(_getSelectedPhotosTotalSize())})',
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _photos.length + 1, // Add 1 for the loader
                          itemBuilder: (context, index) {
                            if (index == _photos.length) {
                              if (_isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return const SizedBox.shrink(); // Placeholder
                            }

                            final photo = _photos[index];
                            final size = formatFileSize(photo['size'] as int);
                            final date = formatDate(photo['date'] as int);

                            // Check if the photo is selected
                            final isSelected = _selectedPhotos.contains(photo);

                            return GridTile(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewerPage(
                                        photo: _photos[
                                            index], // Pass the selected photo
                                        photos:
                                            _photos, // Pass the list of all photos
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.file(
                                            File(photo['path'] as String),
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedPhotos.remove(photo);
                                            } else {
                                              _selectedPhotos.add(photo);
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                      _selectedPhotos
                                                          .add(photo);
                                                    } else {
                                                      _selectedPhotos
                                                          .remove(photo);
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
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
                        itemCount: _photos.length + 1, // Add 1 for the loader
                        itemBuilder: (context, index) {
                          if (index == _photos.length) {
                            if (_isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return const SizedBox.shrink(); // Placeholder
                          }

                          final photo = _photos[index];
                          final size = formatFileSize(photo['size'] as int);
                          final date = formatDate(photo['date'] as int);

                          return ListTile(
                            leading: Image.file(
                              File(photo['path'] as String),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              photo['name'] as String,
                              overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                            ),
                            // subtitle: Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text('Size: $size'),
                            //     Text('Date: $date'),
                            //   ],
                            // ),
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
                              value: _selectedPhotos.contains(photo),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedPhotos.add(photo);
                                  } else {
                                    _selectedPhotos.remove(photo);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageViewerPage(
                                    photo: _photos[
                                        index], // Pass the selected photo
                                    photos:
                                        _photos, // Pass the list of all photos
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
