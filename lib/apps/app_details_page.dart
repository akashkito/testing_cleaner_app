import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

class AppDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> apps; // Full list of apps
  final int selectedIndex; // The index of the selected app

  const AppDetailsPage(
      {super.key, required this.apps, required this.selectedIndex});

  @override
  _AppDetailsPageState createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  late List<Map<String, dynamic>> sortedApps;
  int currentIndex = 0; // Store the current index of the selected app
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  late List<Map<String, dynamic>> usageStatsList = [];

  @override
  void initState() {
    super.initState();
    sortedApps = widget.apps; // Initialize with the sorted list of apps
    currentIndex = widget.selectedIndex; // Start with the passed index
    fetchUsageStats();
  }

  static const platform = MethodChannel('com.example.testing_cleaner_app');

  // Function to fetch screen time details
  Future<void> fetchUsageStats() async {
    List<Map<String, dynamic>> stats = await getAppUsageStats();
    setState(() {
      usageStatsList = stats;
    });
  }

  // Function to fetch screen time details
  Future<List<Map<String, dynamic>>> getAppUsageStats() async {
    try {
      final List<dynamic> stats =
          await platform.invokeMethod('getAppUsageStats');
      return stats.map((e) => Map<String, dynamic>.from(e)).toList();
    } on PlatformException catch (e) {
      print("Failed to get app usage stats: '${e.message}'.");
      return [];
    }
  }

  void sortApps(String sortOrder) {
    setState(() {
      if (sortOrder == 'asc') {
        // Sort by installDate in ascending order
        sortedApps.sort((a, b) {
          DateTime dateA =
              DateTime.tryParse(a["installDate"] ?? "") ?? DateTime(1970);
          DateTime dateB =
              DateTime.tryParse(b["installDate"] ?? "") ?? DateTime(1970);
          return dateA.compareTo(dateB);
        });
      } else {
        // Sort by installDate in descending order
        sortedApps.sort((a, b) {
          DateTime dateA =
              DateTime.tryParse(a["installDate"] ?? "") ?? DateTime(1970);
          DateTime dateB =
              DateTime.tryParse(b["installDate"] ?? "") ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
      }
    });
  }

  Widget tryDecodeBase64(String base64String) {
    try {
      base64String = base64String.replaceAll(RegExp(r'\s+'), '');
      int paddingLength = 4 - (base64String.length % 4);
      if (paddingLength != 4) {
        base64String = base64String + "=" * paddingLength;
      }

      final decodedBytes = base64Decode(base64String);
      return Image.memory(
        decodedBytes,
        width: 80, // Set the image width
        height: 80, // Set the image height
      );
    } catch (e) {
      return const Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the currently selected app
    final app = sortedApps[currentIndex];

    // Decode the app icon if it exists, otherwise use default icon
    String? appIconString = app['appIcon'];
    Widget appIcon = appIconString != null && appIconString.isNotEmpty
        ? tryDecodeBase64(appIconString)
        : const Icon(Icons.app_blocking);

    String formatSize(String sizeInBytes) {
      try {
        // Convert the size to an integer
        double size = double.parse(sizeInBytes);

        // Convert to KB, MB, or GB based on size
        if (size >= 1073741824) {
          // Greater than or equal to 1 GB
          return '${(size / 1073741824).toStringAsFixed(2)} GB';
        } else if (size >= 1048576) {
          // Greater than or equal to 1 MB
          return '${(size / 1048576).toStringAsFixed(2)} MB';
        } else if (size >= 1024) {
          // Greater than or equal to 1 KB
          return '${(size / 1024).toStringAsFixed(2)} KB';
        } else {
          // Less than 1 KB
          return '$size Bytes';
        }
      } catch (e) {
        return 'N/A'; // Return N/A in case of an error or invalid size
      }
    }
    

    String screenTime = 'N/A';
// Find the screen time data for the selected app
    final selectedUsageStats = usageStatsList.firstWhere(
        (element) => element['packageName'] == app['packageName'],
        orElse: () => {});
    if (selectedUsageStats.isNotEmpty) {
      screenTime = selectedUsageStats['totalTime'] ?? 'N/A';
    }

    String lastUsedTime = 'N/A';

    if (selectedUsageStats.isNotEmpty) {
      lastUsedTime = selectedUsageStats['lastUsed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(selectedUsageStats['lastUsed'])
              .toString()
          : 'N/A';
    }

             

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              sortApps(value); // Sort apps when option is selected
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'asc',
                  child: Text('Sort by Install Date (Ascending)')),
              const PopupMenuItem(
                  value: 'desc',
                  child: Text('Sort by Install Date (Descending)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Container to display details of the selected app

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4.0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app["appName"] ?? "Unknown App",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Display size in the appropriate unit
                    Text("Total Size: ${formatSize(app["appSize"] ?? '0')}"),
                    Text("Package Name: ${app["packageName"] ?? '0'}"),
                    Text("Version Name: ${app["versionName"] ?? '0'}"),
                    Text("Version Code: ${app["versionCode"] ?? '0'}"),
                    Text(
                        "Data Size: ${formatSize(app["userDataSize"] ?? '0')}"),
                    Text("Cache Size: ${formatSize(app["cacheSize"] ?? '0')}"),
                    Text("Install Date: ${app["installDate"] ?? 'N/A'}"),
                    Text("Last Update: ${app["lastUpdateDate"] ?? 'N/A'}"),
                    // Text("Screen Time: ${app['screenTime'] ?? 'N/A'}"),
                    Text("Screen Time: $screenTime"),
                    // You can then display the last used time in the UI
                    Text("Last Used: $lastUsedTime"),
                    //  Container(
                    //   height: 200,
                    //   width: 250,
                    //    child: BarChart(
                    //                  BarChartData(
                    //                gridData: FlGridData(show: true),
                    //                titlesData: FlTitlesData(show: true),
                    //                borderData: FlBorderData(show: true),
                    //                barGroups: _buildBarChartData(), // Data for the chart
                    //              ),
                    //                ),
                    //  ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Carousel of all apps
          Padding(
            padding: const EdgeInsets.all(20),
            child: CarouselSlider.builder(
              itemCount: sortedApps.length, // Total number of sorted apps
              itemBuilder: (context, index, realIndex) {
                final app = sortedApps[
                    index]; // Get the app details for each carousel item
                String? appIconString = app['appIcon'];

                // Preload the app icon before rendering
                if (appIconString != null && appIconString.isNotEmpty) {
                  // Decode the app icon and preload the image
                  precacheImage(
                    MemoryImage(base64Decode(
                        appIconString.replaceAll(RegExp(r'\s+'), ''))),
                    context,
                  );
                }

                // Decode the app icon into an image widget
                Widget appIcon =
                    appIconString != null && appIconString.isNotEmpty
                        ? tryDecodeBase64(appIconString)
                        : const Icon(Icons.app_blocking);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex =
                            index; // Update currentIndex when app icon is tapped
                      });
                      _carouselController.animateToPage(
                          index); // Move carousel to the selected index
                    },
                    child: Column(
                      children: [
                        appIcon,
                        Text(app["appName"] ?? "Unknown App",
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                enlargeCenterPage:
                    true, // Ensures the current page gets enlarged slightly
                autoPlay: false, // Disable auto-play
                aspectRatio: 2.0,
                viewportFraction: 0.4,
                initialPage: widget
                    .selectedIndex, // Start carousel at the selected index
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex =
                        index; // Update currentIndex based on carousel movement
                  });
                },
              ),
              carouselController:
                  _carouselController, // Set the controller here
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build data for the Bar Chart
  List<BarChartGroupData> _buildBarChartData() {
  return usageStatsList.map((app) {
    // Ensure totalTime is not null or invalid
    double totalTimeInSeconds = 0.0;
    if (app['totalTime'] != null) {
      try {
        // Convert milliseconds to seconds and ensure it's a valid number
        totalTimeInSeconds = (app['totalTime'] / 1000).toDouble();
      } catch (e) {
        print('Error parsing totalTime: $e');
      }
    }

    return BarChartGroupData(
      x: app['packageName'].hashCode, // Use package name's hashCode as x-value
      barRods: [
        BarChartRodData(
          toY: totalTimeInSeconds, // Pass valid value to Y-axis
          color: Colors.blue,
        ),
      ],
    );
  }).toList();
}

}
