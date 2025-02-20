import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PhotosPage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _checkPermission(); // Check permission on initialization
  }

  // Delete the selected photos with confirmation dialog
  Future<void> _deleteSelectedPhotos() async {
    // Show confirmation dialog
    bool? shouldDelete = await _showDeleteConfirmationDialog();

    if (shouldDelete == true) {
      for (var photo in _selectedPhotos) {
        try {
          final bool? result = await platform.invokeMethod('deletePhoto', {'path': photo['path']});
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
        content: const Text('Are you sure you want to delete the selected photos?'),
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
    final totalSize = _photos.fold(0, (sum, photo) => sum + (photo['size'] as int? ?? 0));
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
        _getPhotoFiles();
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
    try {
      final List<dynamic>? photos = await platform.invokeMethod('getPhotoFiles');
      if (photos != null && photos.isNotEmpty) {
        setState(() {
          _photos = photos.map((photo) {
            final photoMap = Map<String, dynamic>.from(photo);
            return {
              'path': photoMap['path'] as String,
              'name': photoMap['name'] as String,
              'size': photoMap['size'] as int,
              'date': photoMap['date'] as int,
            };
          }).toList();
        });
      } else {
        setState(() {
          _photos = [];
        });
        print("No photo files found");
      }
    } on PlatformException catch (e) {
      print("Error fetching photos: ${e.message}");
      setState(() {
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
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }

  // Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('You need to grant storage permission to access photos.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
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

  // Calculate the total size of selected photos
  int _getSelectedPhotosTotalSize() {
    return _selectedPhotos.fold(0, (sum, photo) => sum + (photo['size'] as int? ?? 0));
  }

  // Calculate the total number of selected photos
  int _getSelectedPhotosCount() {
    return _selectedPhotos.length;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          if (_selectedPhotos.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedPhotos,
            ),
          IconButton(
            icon: Icon(_selectAll ? Icons.select_all : Icons.select_all),
            onPressed: _toggleSelectAll,
          ),
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: _toggleSortOrder,
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
                  const Text('Storage permission is required to access photos.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestPermission, // Request permission
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          if (_photos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Total size and count of images
          final totalSize = _photos.fold(0, (sum, photo) => sum + (photo['size'] as int? ?? 0));
          final totalSizeFormatted = formatFileSize(totalSize);
          final totalCount = _photos.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total images: $totalCount | Total size: $totalSizeFormatted',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_selectAll)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Selected images: ${_getSelectedPhotosCount()} | Total size of selected: ${formatFileSize(_getSelectedPhotosTotalSize())}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    final size = formatFileSize(photo['size'] as int);
                    final date = formatDate(photo['date'] as int);

                    return ListTile(
                      leading: Image.file(
                        File(photo['path'] as String), // Use the 'path' from the map
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(photo['name'] as String),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Size: $size'),
                          Text('Date: $date'),
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
