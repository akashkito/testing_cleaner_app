import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_details_page.dart';

// ------ final working --------------
class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  _AppsPageState createState() => _AppsPageState();
}

// // Search Delegate for searching apps
class AppSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> apps;
  AppSearchDelegate(this.apps);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = apps.where((app) {
      final appName = app["appName"]?.toLowerCase() ?? "";
      return appName.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final app = results[index];
        return ListTile(
          title: Text(app["appName"] ?? "Unknown App"),
          subtitle: Text(app["packageName"] ?? ""),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = apps.where((app) {
      final appName = app["appName"]?.toLowerCase() ?? "";
      return appName.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final app = suggestions[index];
        return ListTile(
          title: Text(app["appName"] ?? "Unknown App"),
          subtitle: Text(app["packageName"] ?? ""),
        );
      },
    );
  }
}

class _AppsPageState extends State<AppsPage>
    with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  List<Map<String, String>> apps = [];
  List<Map<String, String>> filteredApps = [];
  String searchQuery = '';
  String sortOrder = 'desc'; // 'asc' for ascending, 'desc' for descending
  List<bool> selectedApps = []; // Track selected apps with a list of booleans
  late TabController _tabController; // TabController for managing tabs

  Future<Map<String, int>> _getAppUsageStats() async {
    final Map<String, int> usageStatsMap = {};

    try {
      final List<dynamic> usageStats =
          await platform.invokeMethod('getAppUsageStats');
      for (var stat in usageStats) {
        final String packageName = stat["packageName"];
        final int screenTime = stat["screenTime"] ?? 0;
        usageStatsMap[packageName] = screenTime;
      }
    } catch (e) {
      print("Failed to fetch usage stats: ${e.toString()}");
    }

    return usageStatsMap;
  }

  Future<void> getInstalledApps() async {
    try {
      // Check if permission is granted before fetching app data
      final bool isPermissionGranted =
          await platform.invokeMethod('isUsagePermissionGranted');

      if (isPermissionGranted) {
        // Fetch the list of installed apps, including hidden, system, and disabled
        final List<dynamic> appsList =
            await platform.invokeMethod('getInstalledApps');

        // Fetch app usage stats (e.g., screen time, total usage)
        final Map<String, int> appUsageStats =
            await _getAppUsageStats(); // Assuming _getAppUsageStats() gets the usage stats

        setState(() {
          apps = appsList.map<Map<String, String>>((app) {
            final String packageName = app["packageName"]?.toString() ?? "";
            final String screenTime = appUsageStats[packageName]?.toString() ??
                "0"; // Screen time for the app

            // Return app details as a map
            return {
              "appName": app["appName"]?.toString() ?? "Unknown App",
              "packageName": packageName,
              "versionName":
                  app["versionName"]?.toString() ?? "Unknown Version",
              "versionCode": app["versionCode"]?.toString() ?? "Unknown Code",
              "appSize":
                  app["storage"]["app"]?.toString() ?? "0", // App size in bytes
              "userDataSize":
                  app["storage"]["data"]?.toString() ?? "0", // User data size
              "cacheSize":
                  app["storage"]["cache"]?.toString() ?? "0", // Cache size
              "installDate": app["installDate"]?.toString() ?? "Unknown Date",
              "lastUpdateDate":
                  app["lastUpdateDate"]?.toString() ?? "Unknown Date",
              "appIcon": app["appIcon"]?.toString() ?? "", // App icon (Base64)
              "uninstallIntent": app["uninstallIntent"]?.toString() ?? "",
              "screenTime": screenTime, // Screen time for the app
              "isSystemApp":
                  app["isSystemApp"]?.toString() ?? "false", // System app check
              "isDisabled": app["isDisabled"]?.toString() ??
                  "false", // Disabled app check
              "isHidden":
                  app["isHidden"]?.toString() ?? "false", // Hidden app check
            };
          }).toList();

          // Initially set the filteredApps as all apps
          filteredApps = apps;

          // Initialize the selectedApps list (all false initially)
          selectedApps = List.generate(apps.length, (_) => false);
        });
      } else {
        // Show permission dialog if permission is not granted
        _showPermissionDialog();
      }
    } on PlatformException catch (e) {
      print("Failed to get apps: ${e.message}");
    }
  }

  List<String> appsToUninstall = [];
  // Uninstall app method
  void uninstallSelectedApps() async {
    try {
      for (var package in appsToUninstall) {
        await platform.invokeMethod('uninstallApp', {"packageName": package});
      }
      setState(() {
        // Clear the selected apps list after uninstalling
        appsToUninstall.clear();
        selectedApps = List.generate(filteredApps.length, (_) => false);
      });
      _showSuccessDialog("Uninstall Successful");
    } catch (e) {
      print("Error uninstalling apps: $e");
      _showErrorDialog("Error uninstalling apps");
    }
  }

// Show a success dialog after uninstalling
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show an error dialog if something goes wrong
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Calculate the total size of all apps (app size + user data + cache)
  double calculateTotalSizeInGB() {
    double totalSizeInBytes = 0;

    // Sum the app sizes, user data, and cache sizes in bytes
    for (var app in filteredApps) {
      double appSize = double.tryParse(app["appSize"] ?? "0") ?? 0.0;
      double userDataSize = double.tryParse(app["userDataSize"] ?? "0") ?? 0.0;
      double cacheSize = double.tryParse(app["cacheSize"] ?? "0") ?? 0.0;

      totalSizeInBytes += (appSize + userDataSize + cacheSize);
    }

    // Convert total size to GB (1 GB = 1024 * 1024 * 1024 bytes)
    return totalSizeInBytes / (1024 * 1024 * 1024);
  }

  // Calculate the total size of selected apps (app size + user data + cache)
  double calculateSelectedAppsSizeInGB() {
    double totalSizeInBytes = 0;

    // Sum the app sizes, user data, and cache sizes in bytes for selected apps
    for (int i = 0; i < filteredApps.length; i++) {
      if (selectedApps[i]) {
        double appSize =
            double.tryParse(filteredApps[i]["appSize"] ?? "0") ?? 0.0;
        double userDataSize =
            double.tryParse(filteredApps[i]["userDataSize"] ?? "0") ?? 0.0;
        double cacheSize =
            double.tryParse(filteredApps[i]["cacheSize"] ?? "0") ?? 0.0;

        totalSizeInBytes += (appSize + userDataSize + cacheSize);
      }
    }

    // Convert total size to GB
    return totalSizeInBytes / (1024 * 1024 * 1024);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Now 5 tabs
    getInstalledApps();
    filterApps(0);
  }

  // Filter based on selected tab
  void filterApps(int index) {
    setState(() {
      if (index == 0) {
        filteredApps = apps; // Show all apps (including system and hidden)
      } else if (index == 1) {
        filteredApps = apps
            .where((app) => app["isSystemApp"] == "false")
            .toList(); // Show only installed apps
      } else if (index == 2) {
        filteredApps = apps
            .where((app) => app["isSystemApp"] == "true")
            .toList(); // System apps
      } else if (index == 3) {
        filteredApps = apps
            .where((app) => app["isDisabled"] == "true")
            .toList(); // Disabled apps
      } else if (index == 4) {
        filteredApps = apps
            .where((app) => app["isHidden"] == "true")
            .toList(); // Hidden apps
      }
    });
  }

  // Sort apps by install date
  void sortApps() {
    setState(() {
      filteredApps.sort((a, b) {
        final dateA =
            DateTime.tryParse(a["installDate"] ?? "") ?? DateTime(2000);
        final dateB =
            DateTime.tryParse(b["installDate"] ?? "") ?? DateTime(2000);
        return sortOrder == 'asc'
            ? dateA.compareTo(dateB)
            : dateB.compareTo(dateA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalSizeGB = calculateTotalSizeInGB();
    double selectedAppsSizeGB = calculateSelectedAppsSizeInGB();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Apps'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            filterApps(index); // Update apps list when switching tabs
          },
          tabs: const [
            Tab(text: 'All Apps'),
            Tab(text: 'Installed Apps'), // Added tab for All Apps
            Tab(text: 'System Apps'),
            Tab(text: 'Disabled Apps'),
            Tab(text: 'Hidden Apps'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: AppSearchDelegate(filteredApps),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              setState(() {
                bool selectAll = selectedApps.contains(false);
                selectedApps =
                    List.generate(filteredApps.length, (_) => selectAll);
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortOrder = value;
                sortApps();
              });
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
          // Only show the delete button if any app is selected
          // Inside the AppBar actions (where you handle the uninstall button)
          if (appsToUninstall.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showUninstallDialog();
              },
            ),
        ],
      ),
      body: filteredApps.isEmpty
                ? Center(child: Text("No apps found")) // Show message if no apps match the filter
                : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Apps: ${filteredApps.length}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Total Size: ${totalSizeGB.toStringAsFixed(2)} GB', // Display total size in GB
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Selected Size: ${selectedAppsSizeGB.toStringAsFixed(2)} GB', // Display selected apps' size in GB
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      String? appIconString = app['appIcon'];

                      Widget appIcon =
                          appIconString != null && appIconString.isNotEmpty
                              ? tryDecodeBase64(appIconString)
                              : const Icon(
                                  Icons.apps_rounded,
                                  size: 25,
                                );
                      double appSizeInMB =
                          (double.tryParse(app["appSize"].toString()) ?? 0) /
                              (1024 * 1024);
                      String appSizeFormatted = appSizeInMB
                          .toStringAsFixed(2); // Format to 2 decimal places

                      return ListTile(
                        leading: appIcon,
                        title: Text(app["appName"] ?? "Unknown App"),
                        subtitle: Text("${appSizeFormatted.toString()} MB"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppDetailsPage(
                                apps: filteredApps,
                                selectedIndex: index,
                              ),
                            ),
                          );
                        },
                        trailing: Checkbox(
                          value: selectedApps[index],
                          onChanged: (value) {
                            setState(() {
                              selectedApps[index] = value!;
                              if (value) {
                                appsToUninstall.add(app['packageName']!);
                              } else {
                                appsToUninstall.remove(app['packageName']);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
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
        width: 25,
        height: 25,
      );
    } catch (e) {
      return const Icon(Icons.error);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please enable Usage Access Permission to view installed apps.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                platform.invokeMethod('openUsageAccessSettings');
                Navigator.of(context).pop();
              },
              child: const Text('Go to Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showUninstallDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uninstall Selected Apps'),
          content: Text(
              'Are you sure you want to uninstall ${appsToUninstall.length} app(s)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                uninstallSelectedApps(); // Call the method to uninstall
              },
              child: const Text('Uninstall'),
            ),
          ],
        );
      },
    );
  }
}
