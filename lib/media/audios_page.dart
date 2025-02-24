import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'audio/audio_player_page.dart';

class AudiosPage extends StatefulWidget {
  const AudiosPage({super.key});

  @override
  _AudiosPageState createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  bool _isPermissionGranted = false;
  List<Map<String, Object>> _audios = [];
  List<Map<String, Object>> _selectedAudios = [];
  bool _selectAll = false;
  bool _isAscending = true;
  bool _isGridView = false;
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 10;

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
      final bool? result = await platform.invokeMethod('deleteAudio', {'path': path});
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
    return _selectedAudios.fold(0, (sum, audio) => sum + (audio['size'] as int));
  }

  // Format file size
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

  // Format the date
  String formatDate(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
    return formatter.format(date);
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
        title: const Text('Delete Audios'),
        content:
            const Text('Are you sure you want to delete the selected audios?'),
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

  // Delete selected audios
  Future<void> _deleteSelectedAudios() async {
    final bool? confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      for (final audio in _selectedAudios) {
        await _deleteAudio(audio['path'] as String);
      }
      setState(() {
        _selectedAudios.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audios'),
        actions: [
          if (_selectedAudios.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedAudios,
            ),
          IconButton(
            icon: Icon(_selectAll ? Icons.select_all : Icons.select_all),
            onPressed: _toggleSelectAll,
          ),
          IconButton(
            icon:
                Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (_audios.isEmpty && !_isLoading) {
            return const Center(child: Text("No audio files found."));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '${_audios.length} Total | Total Size: ${formatFileSize(_getTotalSize())}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_selectedAudios.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    '${_selectedAudios.length} Selected | Size: ${formatFileSize(_getSelectedSize())}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              Expanded(
                child: _isGridView
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: _audios.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _audios.length) {
                            if (_isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return const SizedBox.shrink();
                          }
                          final audio = _audios[index];
                          final size = formatFileSize(audio['size'] as int);
                          final date = formatDate(audio['date'] as int);
                          final isSelected = _selectedAudios.contains(audio);

                          return GestureDetector(
                            child: GridTile(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Icon(Icons.audiotrack, size: 50),
                                  ),
                                  Text(audio['name'] as String),
                                  Checkbox(
                                    value: isSelected,
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
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: _audios.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _audios.length) {
                            if (_isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return const SizedBox.shrink();
                          }

                          final audio = _audios[index];
                          final size = formatFileSize(audio['size'] as int);
                          final date = formatDate(audio['date'] as int);

                          return ListTile(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => AudioPlayerPage(
                              //         audioPath: audio['path'] as String),
                              //   ),
                              // );
                            },
                            leading: const Icon(Icons.audiotrack),
                            title: Text(audio['name'] as String),
                            subtitle: Text('Size: $size\nDate: $date'),
                            trailing: Checkbox(
                              value: _selectedAudios.contains(audio),
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
