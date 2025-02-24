// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clean_photo_page.dart';

// Assuming the formatFileSize and formatDate functions are already defined.
String formatFileSize(int size) {
  if (size < 1024) {
    return "$size B";
  } else if (size < 1024 * 1024) {
    return "${(size / 1024).toStringAsFixed(2)} KB";
  } else if (size < 1024 * 1024 * 1024) {
    return "${(size / (1024 * 1024)).toStringAsFixed(2)} MB";
  } else {
    return "${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
  }
}

String formatDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day}/${date.month}/${date.year} | ${date.hour}:${date.minute}";
}

class ImageViewerPage extends StatefulWidget {
  final Map<String, dynamic> photo;
  final List<Map<String, dynamic>> photos; // List of all photos

  const ImageViewerPage({super.key, required this.photo, required this.photos});

  @override
  _ImageViewerPageState createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _pageController;
  final Set<int> _selectedIndices = {}; // Set to track selected image indices
  late Map<String, dynamic> _currentPhoto;
  bool _selectAll = false; // Variable to track select all state

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.photos
          .indexOf(widget.photo), // Set the initial page to the selected photo
    );
    _currentPhoto = widget.photo; // Initialize with the first photo
  }

  static const platform = MethodChannel('com.example.testing_cleaner_app');

  // Delete the selected photos with confirmation dialog
  // Future<void> _deleteSelectedPhotos() async {
  //   bool? shouldDelete = await _showDeleteConfirmationDialog();

  //   if (shouldDelete == true) {
  //     for (var index in _selectedIndices) {
  //       var photo = widget.photos[index];
  //       try {
  //         final bool? result = await platform
  //             .invokeMethod('deletePhoto', {'path': photo['path']});
  //         if (result == true) {
  //           setState(() {
  //             widget.photos.remove(photo); // Remove the photo from the list
  //           });
  //         } else {
  //           print("Failed to delete photo: ${photo['name']}");
  //         }
  //       } on PlatformException catch (e) {
  //         print("Error deleting photo: ${e.message}");
  //       }
  //     }

  //     // Clear the selected photos after deletion
  //     setState(() {
  //       _selectedIndices.clear();
  //       _selectAll = false; // Unselect 'select all' if any deletion occurred
  //     });

  //     // Refresh total count and size after deletion
  //     // _refreshTotalCountAndSize();
  //   }
  // }

  // Delete the selected photos with confirmation dialog
  // Update your method to pass the total size and deleted photos to CleanPage
Future<void> _deleteSelectedPhotos() async {
  bool? shouldDelete = await _showDeleteConfirmationDialog();

  if (shouldDelete == true) {
    List<Map<String, dynamic>> deletedPhotos = [];
    int totalSizeCleared = 0;

    for (var index in _selectedIndices) {
      var photo = widget.photos[index];
      try {
        print("Deleting photo: ${photo['name']}"); // Debug print
        final bool? result = await platform.invokeMethod('deletePhoto', {'path': photo['path']});
        if (result == true) {
          setState(() {
            widget.photos.remove(photo); // Remove the photo from the list
            deletedPhotos.add(photo); // Add to deleted photos
            totalSizeCleared += photo['size'] as int; // Calculate total size cleared
          });
          print("Deleted photo: ${photo['name']}"); // Debug print
        }
      } catch (e) {
        print("Error deleting photo: $e");
      }
    }

    // Clear the selected photos after deletion
    setState(() {
      _selectedIndices.clear();
      _selectAll = false; // Unselect 'select all' if any deletion occurred
    });

    // Navigate to CleanPage to show the space cleared
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanPage(
          totalSizeCleared: totalSizeCleared,  // Pass the total cleared size here
          deletedPhotos: deletedPhotos,  // Pass the list of deleted photos
        ),
      ),
    );
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

  // Function to calculate the total size of selected photos
  int _getSelectedPhotosTotalSize() {
    int totalSize = 0;
    for (var index in _selectedIndices) {
      totalSize += widget.photos[index]['size'] as int;
    }
    return totalSize;
  }

  // Function to calculate the total size of all photos
  int _getTotalPhotosSize() {
    int totalSize = 0;
    for (var photo in widget.photos) {
      totalSize += photo['size'] as int;
    }
    return totalSize;
  }

  @override
  Widget build(BuildContext context) {
    final size = formatFileSize(_currentPhoto['size'] as int);
    final date = formatDate(_currentPhoto['date'] as int);
    final index = widget.photos
        .indexOf(_currentPhoto); // Get the index of the selected photo

    final totalImages = widget.photos.length;
    final totalSize = _getTotalPhotosSize();

    // Handle the selected image
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actionsPadding: const EdgeInsets.symmetric(
            horizontal: 10), // Adjust the padding between actions
        title: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // This will space out leading, title, and actions evenly
          children: [
            // Back button in leading section
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(00),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded, // Back icon
                  size: 20,
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                _currentPhoto['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            if (_selectedIndices
                .isNotEmpty) // Show delete button only if something is selected
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteSelectedPhotos,
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display total images' info (count and total size)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors
                            .black, // Default text color (for the text before the number)
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text:
                              "Total Images: ", // Regular text before the number
                          style: TextStyle(
                              color: Colors.grey, // Keep this part black
                              fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: "$totalImages", // The variable text
                          style: const TextStyle(
                              color: Colors
                                  .black, // Light grey color for totalImages
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatFileSize(totalSize),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Full-screen image viewer
            Stack(
              children: [
                // Existing container with PageView
                Positioned(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      clipBehavior: Clip.antiAlias,
                      height: 460, // Set a fixed height for the image
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.photos.length,
                        itemBuilder: (context, pageIndex) {
                          final photo = widget.photos[pageIndex];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentPhoto =
                                    photo; // Set current photo to the tapped image
                                _pageController.jumpToPage(
                                    pageIndex); // Change image in the carousel
                              });
                            },
                            child: Image.file(
                              File(photo['path'] as String),
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Container with gradient or opacity
                Positioned(
                  top: 0, // Position at the top
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(8.0),
                      height: 460, // Same height as the image container
                      decoration: BoxDecoration(
                        // Linear gradient from top to bottom
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent, // End with transparent
                            Colors.transparent, // End with transparent
                            Colors.transparent, // End with transparent
                            Colors.black.withOpacity(
                                0.2), // Start with black with opacity
                          ],
                          begin: Alignment
                              .topCenter, // Start gradient from the top
                          end: Alignment
                              .bottomCenter, // End gradient at the bottom
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  left: 20,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Display image info: Name, Size, and Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${_currentPhoto['name']}",
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  overflow: TextOverflow
                                      .ellipsis, // This will make the text truncate with "..."
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            Text(size,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white))
                          ],
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 20),
            // Display selected images' info (count and total size)
            _selectedIndices.isNotEmpty
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0, bottom: 5, top: 5),
                    child: Text(
                      "Selected: ${_selectedIndices.length} of ${formatFileSize(_getSelectedPhotosTotalSize())}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Container(padding: const EdgeInsets.all(15)),

            Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
              ),
              child: SizedBox(
                height: 200, // Set height for horizontal scroll container
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    final otherPhoto = widget.photos[index];
                    final isSelected = _selectedIndices
                        .contains(index); // Check if the photo is selected

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIndices
                                .remove(index); // Deselect if already selected
                          } else {
                            _currentPhoto =
                                otherPhoto; // Update the current image
                            _pageController.jumpToPage(
                                index); // Change image in the carousel
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            // Stack for overlaying a rectangle
                            Stack(
                              alignment: Alignment
                                  .center, // Align the checkbox inside the rectangle
                              children: [
                                // Circular container for the image
                                Container(
                                  width: 140,
                                  height: 140,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Image.file(
                                    File(otherPhoto['path'] as String),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Rectangle overlay on top of the image
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedIndices.remove(
                                              index); // Deselect if already selected
                                        } else {
                                          _selectedIndices
                                              .add(index); // Select the photo
                                          _currentPhoto =
                                              otherPhoto; // Update the current image
                                          _pageController.jumpToPage(
                                              index); // Change image in the carousel
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue.withOpacity(0.8)
                                              : Colors.blue
                                                  .withValues(alpha: 0.5),
                                          width: isSelected ? 2 : 2,
                                        ),
                                        color: isSelected
                                            ? Colors.blue.withOpacity(0.8)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: isSelected
                                            ? const Icon(Icons.check,
                                                color: Colors.white, size: 18)
                                            : const SizedBox
                                                .shrink(), // Show checkmark when selected
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
