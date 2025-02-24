
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

class _AppsPageState extends State<AppsPage> with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.example.testing_cleaner_app');
  List<Map<String, String>> apps = [];
  List<Map<String, String>> filteredApps = [];
  String searchQuery = '';
  String sortOrder = 'desc'; // 'asc' for ascending, 'desc' for descending
  List<bool> selectedApps = []; // Track selected apps with a list of booleans
  late TabController _tabController; // TabController for managing tabs

  Future<void> getInstalledApps() async {
  try {
    final bool isPermissionGranted = await platform.invokeMethod('isUsagePermissionGranted');

    if (isPermissionGranted) {
      final List<dynamic> appsList = await platform.invokeMethod('getInstalledApps');
      final Map<String, int> appUsageStats = await _getAppUsageStats();

      setState(() {
        apps = appsList.map<Map<String, String>>((app) {
          final String packageName = app["packageName"]?.toString() ?? "";
          final String screenTime = appUsageStats[packageName]?.toString() ?? "0";

          return {
            "appName": app["appName"]?.toString() ?? "Unknown App",
            "packageName": packageName,
            "versionName": app["versionName"]?.toString() ?? "Unknown Version",
            "versionCode": app["versionCode"]?.toString() ?? "Unknown Code",
            "appSize": app["appSize"]?.toString() ?? "0",
            "dataSize": app["dataSize"]?.toString() ?? "0",
            "cacheSize": app["cacheSize"]?.toString() ?? "0",
            "installDate": app["installDate"]?.toString() ?? "Unknown Date",
            "lastUpdateDate": app["lastUpdateDate"]?.toString() ?? "Unknown Date",
            "appIcon": app["appIcon"]?.toString() ?? "",
            "uninstallIntent": app["uninstallIntent"]?.toString() ?? "",
            "screenTime": screenTime,
            "isSystemApp": app["isSystemApp"]?.toString() ?? "false", // Add system app info
            "isDi  sabled": app["isDisabled"]?.toString() ?? "false", // Add disabled app info
            "isHidden": app["isHidden"]?.toString() ?? "false", // Add hidden app info
          };
        }).toList();
        filteredApps = apps; // Initially display all apps
        selectedApps = List.generate(apps.length, (_) => false); // Initialize selection states
      });
    } else {
      _showPermissionDialog();
    }
  } on PlatformException catch (e) {
    print("Failed to get apps: ${e.message}");
  }
}


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

  // Filter based on selected tab
  void filterApps(int index) {
    setState(() {
      if (index == 0) {
        filteredApps = apps.where((app) => app["isSystemApp"] == "false").toList(); // Show only installed apps
      } else if (index == 1) {
        filteredApps = apps; // Show all apps (including system and hidden)
      } else if (index == 2) {
        filteredApps = apps.where((app) => app["isSystemApp"] == "true").toList(); // System apps
      } else if (index == 3) {
        filteredApps = apps.where((app) => app["isDisabled"] == "true").toList(); // Disabled apps
      } else if (index == 4) {
        filteredApps = apps.where((app) => app["isHidden"] == "true").toList(); // Hidden apps
      }
    });
  }

  // Sort apps by install date
  void sortApps() {
    setState(() {
      filteredApps.sort((a, b) {
        final dateA = DateTime.tryParse(a["installDate"] ?? "") ?? DateTime(2000);
        final dateB = DateTime.tryParse(b["installDate"] ?? "") ?? DateTime(2000);
        return sortOrder == 'asc' ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  double calculateTotalSizeInGB() {
    double totalSizeInBytes = 0;

    // Sum the app sizes in bytes
    for (var app in filteredApps) {
      double appSize = double.tryParse(app["appSize"] ?? "0") ?? 0.0;
      totalSizeInBytes += appSize;
    }

    // Convert total size to GB (1 GB = 1024 * 1024 * 1024 bytes)
    return totalSizeInBytes / (1024 * 1024 * 1024);
  }

  // Calculate the total size of selected apps
  double calculateSelectedAppsSizeInGB() {
    double totalSizeInBytes = 0;

    // Sum the app sizes in bytes for selected apps
    for (int i = 0; i < filteredApps.length; i++) {
      if (selectedApps[i]) {
        double appSize = double.tryParse(filteredApps[i]["appSize"] ?? "0") ?? 0.0;
        totalSizeInBytes += appSize;
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
            filterApps(index);  // Update apps list when switching tabs
          },
          tabs: const [
            Tab(text: 'Installed Apps'),
            Tab(text: 'All Apps'), // Added tab for All Apps
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
                selectedApps = List.generate(filteredApps.length, (_) => selectAll);
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
        ],
      ),
      body: filteredApps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              : const Icon(Icons.apps_rounded);

                      // Get the app size in bytes
                      String appSizeInBytes = app["appSize"] ?? "0";
                      double appSizeInGB =
                          double.tryParse(appSizeInBytes) ?? 0.0;

                      double sizeInGB = appSizeInGB / (1024 * 1024 * 1024);

                      String sizeToDisplay;
                      if (sizeInGB >= 1) {
                        sizeToDisplay =
                            "${sizeInGB.toStringAsFixed(2)} GB"; 
                      } else {
                        double sizeInMB = sizeInGB * 1024; 
                        sizeToDisplay = "${sizeInMB.toStringAsFixed(2)} MB";
                      }

                      return ListTile(
                        leading: appIcon,
                        title: Text(app["appName"] ?? "Unknown App"),
                        subtitle: Text(sizeToDisplay),
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
        width: 20,
        height: 20,
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
}

// Search Delegate for searching apps
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


// ---- working properly ----
// class AppsPage extends StatefulWidget {
//   @override
//   _AppsPageState createState() => _AppsPageState();
// }

// class _AppsPageState extends State<AppsPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   List<Map<String, String>> apps = [];
//   List<Map<String, String>> filteredApps = [];
//   String searchQuery = '';
//   String sortOrder = 'desc'; // 'asc' for ascending, 'desc' for descending
//   List<bool> selectedApps = []; // Track selected apps with a list of booleans

//   Future<void> getInstalledApps() async {
//     try {
//       final bool isPermissionGranted =
//           await platform.invokeMethod('isUsagePermissionGranted');

//       if (isPermissionGranted) {
//         final List<dynamic> appsList =
//             await platform.invokeMethod('getInstalledApps');
//         final Map<String, int> appUsageStats = await _getAppUsageStats();

//         setState(() {
//           apps = appsList.map<Map<String, String>>((app) {
//             final String packageName = app["packageName"]?.toString() ?? "";
//             final String screenTime =
//                 appUsageStats[packageName]?.toString() ?? "0";
//             return {
//               "appName": app["appName"]?.toString() ?? "Unknown App",
//               "packageName": packageName,
//               "versionName":
//                   app["versionName"]?.toString() ?? "Unknown Version",
//               "versionCode": app["versionCode"]?.toString() ?? "Unknown Code",
//               "appSize": app["appSize"]?.toString() ?? "0",
//               "dataSize": app["dataSize"]?.toString() ?? "0",
//               "cacheSize": app["cacheSize"]?.toString() ?? "0",
//               "installDate": app["installDate"]?.toString() ?? "Unknown Date",
//               "lastUpdateDate":
//                   app["lastUpdateDate"]?.toString() ?? "Unknown Date",
//               "appIcon": app["appIcon"]?.toString() ?? "",
//               "uninstallIntent": app["uninstallIntent"]?.toString() ?? "",
//               "screenTime": screenTime,
//               "isSystemApp": app["isSystemApp"]?.toString() ?? "false", // add system app info
//               "isDisabled": app["isDisabled"]?.toString() ?? "false", // add disabled app info
//             };
//           }).toList();
//           filteredApps = apps; // Initially display all apps
//           selectedApps = List.generate(
//               apps.length, (_) => false); // Initialize selection states
//         });
//       } else {
//         _showPermissionDialog();
//       }
//     } on PlatformException catch (e) {
//       print("Failed to get apps: ${e.message}");
//     }
//   }

//   Future<Map<String, int>> _getAppUsageStats() async {
//     final Map<String, int> usageStatsMap = {};

//     try {
//       final List<dynamic> usageStats =
//           await platform.invokeMethod('getAppUsageStats');
//       for (var stat in usageStats) {
//         final String packageName = stat["packageName"];
//         final int screenTime = stat["screenTime"] ?? 0;
//         usageStatsMap[packageName] = screenTime;
//       }
//     } catch (e) {
//       print("Failed to fetch usage stats: ${e.toString()}");
//     }

//     return usageStatsMap;
//   }

//   void filterApps() {
//     setState(() {
//       filteredApps = apps
//           .where((app) =>
//               app["appName"]!.toLowerCase().contains(searchQuery.toLowerCase()))
//           .toList();

//       // Sort the filtered apps based on installDate
//       filteredApps.sort((a, b) {
//         DateTime dateA = DateTime.tryParse(a["installDate"]!) ?? DateTime(1970);
//         DateTime dateB = DateTime.tryParse(b["installDate"]!) ?? DateTime(1970);
//         return sortOrder == 'asc'
//             ? dateA.compareTo(dateB)
//             : dateB.compareTo(dateA);
//       });

//       selectedApps = List.generate(filteredApps.length,
//           (_) => false); // Reset selection states after filtering
//     });
//   }

//   void filterSystemApps(bool showSystemApps) {
//     setState(() {
//       filteredApps = apps.where((app) {
//         if (showSystemApps) {
//           return app["isSystemApp"] == "true";
//         }
//         return app["isSystemApp"] != "true";
//       }).toList();
//     });
//   }

//   void filterDisabledApps(bool showDisabledApps) {
//     setState(() {
//       filteredApps = apps.where((app) {
//         if (showDisabledApps) {
//           return app["isDisabled"] == "true";
//         }
//         return app["isDisabled"] != "true";
//       }).toList();
//     });
//   }

//   double calculateTotalSizeInGB() {
//     double totalSizeInBytes = 0;
//     for (var app in filteredApps) {
//       double appSize = double.tryParse(app["appSize"] ?? "0") ?? 0;
//       totalSizeInBytes += appSize;
//     }
//     return totalSizeInBytes / (1024 * 1024 * 1024); // Convert bytes to GB
//   }

//   @override
//   void initState() {
//     super.initState();
//     getInstalledApps();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double totalSizeGB = calculateTotalSizeInGB();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Installed Apps'),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               setState(() {
//                 sortOrder = value;
//                 filterApps();
//               });
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                   value: 'asc',
//                   child: Text('Sort by Install Date (Ascending)')),
//               const PopupMenuItem(
//                   value: 'desc',
//                   child: Text('Sort by Install Date (Descending)')),
//             ],
//           ),
//           // Add filter for system apps and disabled apps
//           IconButton(
//             icon: Icon(Icons.settings),
//             onPressed: () async {
//               await showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text('Filters'),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SwitchListTile(
//                           title: Text('Show System Apps'),
//                           value: filteredApps.every((app) =>
//                               app["isSystemApp"] == "true"),
//                           onChanged: (bool value) {
//                             filterSystemApps(value);
//                             Navigator.pop(context);
//                           },
//                         ),
//                         SwitchListTile(
//                           title: Text('Show Disabled Apps'),
//                           value: filteredApps.every((app) =>
//                               app["isDisabled"] == "true"),
//                           onChanged: (bool value) {
//                             filterDisabledApps(value);
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: filteredApps.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Total Apps: ${filteredApps.length}',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       Text(
//                         'Total Size: ${totalSizeGB.toStringAsFixed(2)} GB',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: filteredApps.length,
//                     itemBuilder: (context, index) {
//                       final app = filteredApps[index];
//                       String? appIconString = app['appIcon'];

//                       // Check if the appIcon is not null, not empty, and valid base64
//                       Widget appIcon =
//                           appIconString != null && appIconString.isNotEmpty
//                               ? tryDecodeBase64(appIconString)
//                               : const Icon(Icons.apps_rounded);

//                       // Get the app size in bytes
//                       String appSizeInBytes = app["appSize"] ?? "0";
//                       double appSizeInGB =
//                           double.tryParse(appSizeInBytes) ?? 0.0;

//                       // Convert size to GB
//                       double sizeInGB = appSizeInGB / (1024 * 1024 * 1024);

//                       // Show size in GB if larger than 1 GB, otherwise in MB
//                       String sizeToDisplay;
//                       if (sizeInGB >= 1) {
//                         sizeToDisplay =
//                             "${sizeInGB.toStringAsFixed(2)} GB"; // If the app size is 1 GB or more
//                       } else {
//                         // Convert size to MB if smaller than 1 GB
//                         double sizeInMB = sizeInGB * 1024; // 1 GB = 1024 MB
//                         sizeToDisplay = "${sizeInMB.toStringAsFixed(2)} MB";
//                       }
//                       return ListTile(
//                         leading: appIcon,
//                         title: Text(app["appName"] ?? "Unknown App"),
//                         subtitle: Text(
//                             "$sizeToDisplay"), // Show size in GB or MB
//                         trailing: Checkbox(
//                           value: selectedApps[index],
//                           onChanged: (bool? value) {
//                             setState(() {
//                               selectedApps[index] = value ?? false;
//                             });
//                           },
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AppDetailsPage(
//                                 apps: filteredApps,
//                                 selectedIndex: index,
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget tryDecodeBase64(String base64String) {
//     try {
//       base64String = base64String.replaceAll(RegExp(r'\s+'), '');
//       int paddingLength = 4 - (base64String.length % 4);
//       if (paddingLength != 4) {
//         base64String = base64String + "=" * paddingLength;
//       }

//       final decodedBytes = base64Decode(base64String);
//       return Image.memory(
//         decodedBytes,
//         width: 20,
//         height: 20,
//       );
//     } catch (e) {
//       return const Icon(Icons.error);
//     }
//   }

//   // Show permission dialog if necessary
//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Permission Required'),
//           content: const Text(
//               'Please enable Usage Access Permission to view installed apps.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 platform.invokeMethod('openUsageAccessSettings');
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Go to Settings'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


// class AppSearchDelegate extends SearchDelegate {
//   final Function(String) onSearch;

//   AppSearchDelegate({required this.onSearch});

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//           onSearch(query);
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // Schedule the onSearch function to be called after the current frame.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       onSearch(query); // Call onSearch after the frame completes
//     });

//     return Center(child: Text('Search results for "$query"'));
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // Schedule the onSearch function to be called after the current frame.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       onSearch(query); // Call onSearch after the frame completes
//     });

//     return Center(child: Text('Search suggestions for "$query"'));
//   }
// }
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class AppsPage extends StatefulWidget {
//   @override
//   _AppsPageState createState() => _AppsPageState();
// }

// class _AppsPageState extends State<AppsPage> {
//   static const platform = MethodChannel('com.example.testing_cleaner_app');
//   List<Map<String, String>> apps = [];
//   List<Map<String, String>> filteredApps = [];
//   String searchQuery = '';
//   String sortOrder = 'desc'; // 'asc' for ascending, 'desc' for descending

//   Future<List<Map<String, String>>> getInstalledApps() async {
//     try {
//       // Fetching the installed apps from the platform
//       final List<dynamic> apps = await platform.invokeMethod('getInstalledApps');

//       return apps.map<Map<String, String>>((app) {
//         return {
//           "appName": app["appName"]?.toString() ?? "Unknown App",
//           "packageName": app["packageName"]?.toString() ?? "",
//           "versionName": app["versionName"]?.toString() ?? "Unknown Version",
//           "versionCode": app["versionCode"]?.toString() ?? "Unknown Code",
//           "appSize": app["appSize"]?.toString() ?? "0",
//           "dataSize": app["dataSize"]?.toString() ?? "0",
//           "cacheSize": app["cacheSize"]?.toString() ?? "0",
//           "installDate": app["installDate"]?.toString() ?? "Unknown Date",
//           "lastUpdateDate": app["lastUpdateDate"]?.toString() ?? "Unknown Date",
//           "appIcon": app["appIcon"]?.toString() ?? "",
//           "uninstallIntent": app["uninstallIntent"]?.toString() ?? "",
//         };
//       }).toList();
//     } on PlatformException catch (e) {
//       print("Failed to get apps: ${e.message}");
//       return [];
//     }
//   }

//   // Filter the apps based on the search query
//   void filterApps() {
//     setState(() {
//       filteredApps = apps
//           .where((app) => app["appName"]!.toLowerCase().contains(searchQuery.toLowerCase()))
//           .toList();

//       // Sort the filtered apps based on installDate
//       filteredApps.sort((a, b) {
//         DateTime dateA = DateTime.tryParse(a["installDate"]!) ?? DateTime(1970);
//         DateTime dateB = DateTime.tryParse(b["installDate"]!) ?? DateTime(1970);
//         return sortOrder == 'asc' ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
//       });
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     getInstalledApps().then((appList) {
//       setState(() {
//         apps = appList;
//         filteredApps = appList;  // Initially display all apps
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Installed Apps'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {
//               showSearch(context: context, delegate: AppSearchDelegate(onSearch: (query) {
//                 setState(() {
//                   searchQuery = query;
//                   filterApps();
//                 });
//               }));
//             },
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               setState(() {
//                 sortOrder = value;
//                 filterApps();
//               });
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(value: 'asc', child: Text('Sort by Install Date (Ascending)')),
//               PopupMenuItem(value: 'desc', child: Text('Sort by Install Date (Descending)')),
//             ],
//           ),
//         ],
//       ),
//       body: filteredApps.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: filteredApps.length,
//               itemBuilder: (context, index) {
//                 final app = filteredApps[index];
//                 String? appIconString = app['appIcon'];

//                 // Check if the appIcon is not null, not empty, and valid base64
//                 Widget appIcon = appIconString != null && appIconString.isNotEmpty
//                     ? tryDecodeBase64(appIconString)
//                     : const Icon(Icons.app_blocking);

//                 return ListTile(
//                   leading: appIcon,
//                   title: Text(app["appName"] ?? "Unknown App"),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Package: ${app["packageName"]}"),
//                       Text("Version: ${app["versionName"]} (${app["versionCode"]})"),
//                       Text("App Size: ${app["appSize"]}"),
//                       Text("Data Size: ${app["dataSize"]}"),
//                       Text("Cache Size: ${app["cacheSize"]}"),
//                       Text("Install Date: ${app["installDate"]}"),
//                       Text("Last Update: ${app["lastUpdateDate"]}"),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () {
//                       // You can implement uninstall logic here using `app["uninstallIntent"]`
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//  Widget tryDecodeBase64(String base64String) {
//   try {
//     base64String = base64String.replaceAll(RegExp(r'\s+'), ''); // Clean whitespace

//     // Ensure padding
//     int paddingLength = 4 - (base64String.length % 4);
//     if (paddingLength != 4) {
//       base64String = base64String + "=" * paddingLength;
//     }

//     final decodedBytes = base64Decode(base64String);
//     return Image.memory(
//       decodedBytes,
//       width: 40,
//       height: 40,
//     );
//   } catch (e) {
//     print("Error decoding base64: $e");
//     print("Base64 string: $base64String"); // For debugging purposes
//     return const Icon(Icons.error);
//   }
// }

// }

// class AppSearchDelegate extends SearchDelegate {
//   final Function(String) onSearch;

//   AppSearchDelegate({required this.onSearch});

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//           onSearch(query);
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // Schedule the onSearch function to be called after the current frame.
//     WidgetsBinding.instance!.addPostFrameCallback((_) {
//       onSearch(query);  // Call onSearch after the frame completes
//     });

//     return Center(child: Text('Search results for "$query"'));
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // Schedule the onSearch function to be called after the current frame.
//     WidgetsBinding.instance!.addPostFrameCallback((_) {
//       onSearch(query);  // Call onSearch after the frame completes
//     });

//     return Center(child: Text('Search suggestions for "$query"'));
//   }
// }

